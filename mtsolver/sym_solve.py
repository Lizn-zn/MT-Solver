from sympy import Symbol, symbols, parse_expr, solve, lambdify, Function, Lambda
from sympy import Piecewise, floor, binomial, isprime, factorial
from sympy import reduce_inequalities, simplify, sympify, powsimp, powdenest
from sympy import Eq, Ne, Le, Lt, Gt, Ge, asin, acos
from sympy import Not, And, Or
from sympy import nan, oo
from sympy.codegen.cfunctions import log2, log
from sympy.parsing.sympy_parser import parse_expr, standard_transformations, implicit_multiplication_application, convert_xor

from pysmt.smtlib.parser import SmtLibParser
from pysmt.shortcuts import REAL, INT, BOOL
from io import StringIO

from mtsolver.result import Result
import numpy as np
from scipy.optimize import minimize, differential_evolution

from mtsolver.exceptions import FormulaParseError, OptimParseError, FunctionTypeError, IllegalGetValueCommand
from mtsolver.exceptions import NoCompliationError, InvalidProblemType, SolutionTypeError, InfeasibleSolError
from mtsolver.exceptions import ScipyOptimError
from sympy.core import SympifyError

from warnings import warn

class sym_compiler:
    """Compiles SMT-LIB2 format statements into sympy format."""
    
    def __init__(self):
        self.transformations = (
            standard_transformations + 
            (implicit_multiplication_application,) + 
            (convert_xor,)
        )
        
        self.word_dict = {
            "log": log,
            "prime": isprime,
            "log2": log2,
            "binomial": binomial,
            'asin': asin,
            'acos': acos,
            'round': floor,
            'factorial': factorial,
            'Not': Not,
            'Nan': nan,
            'oo': oo
        }
        # Renamed for clarity
        self.reserved_function_names = ["sqrt", "tan", "sec"]
        
    def _reset(self):
        self.vars, self.target_vars, self.exprs, self.terms = [], [], [], []
        self.sympy_vars, self.func_vars = {}, {}
        self.obj = None
    
    def declare_var(self, name, type):
        """ Declare a variable for solving """
        self.vars.append({'name': name, 'type': type})
        if type.is_real_type():
            self.sympy_vars[name] = symbols(name, real=True)
        elif type.is_int_type():
            self.sympy_vars[name] = symbols(name, integer=True)
        elif type.is_complex_type():
            self.sympy_vars[name] = symbols(name, complex=True)
        else:
            raise FunctionTypeError(f"Datatype {type} of {name} are not supported yet")
    
    def declare_fun(self, name, input_types, output_type):
        """ Declare a function for solving """
        if name in self.reserved_function_names:
            warn(f"function {name} is already defined, skip it but may cause some error")
            return
        self.func_vars[name] = Function(name)

    def define_fun(self, name, vars, rtype, expr):
        """ Define a function for solving """
        if name in self.reserved_function_names:
            warn(f"function {name} is already defined, skip it but may cause some error")
            return
        tmp_func_vars = []
        for var in vars:
            tmp_var = symbols(var.symbol_name(), real=True)
            tmp_func_vars.append(tmp_var)
            self.func_vars[var.symbol_name()] = tmp_var
        if not expr.get_type().is_int_type() or not expr.get_type().is_real_type():
            raise FunctionTypeError(f"Datatype {expr.get_type()} in {expr} are not supported yet")
        func_expr = parse_expr(str(expr.serialize()), local_dict={**self.sympy_vars, **self.func_vars, **self.word_dict}, \
                    transformations=self.transformations, evaluate=False)
        self.func_vars[name] = Lambda(tuple(tmp_func_vars), func_expr)
    
    def define_fun_rec(self, name, vars, type, expr, recur_iter=10):
        """ Define a recursive function for solving 
            In contrast to declare_fun, declare_fun_rec is defined by equation f(x) = g(f(x)) instead
        """
        tmp_func_vars = []
        for var in vars:
            tmp_var = symbols(var.symbol_name(), real=True)
            tmp_func_vars.append(tmp_var)
            self.func_vars[var.symbol_name()] = tmp_var
        #### define stop_criteria for recur_iter
        if not expr.is_numer_ite():
            raise FunctionTypeError(f"Define_fun_rec {expr} should be expressed by numer_ite")
        cond, left, right = expr.args()
        cond, left, right = cond.serialize(), left.serialize(), right.serialize()
        if (name in str(left) and name in str(right)) or \
            (name not in str(left) and name not in str(right)):
            raise FunctionTypeError(f"Two part of ITE in Define_fun_rec {expr} both contain (or not contain) the recursive function")
        elif name in str(left):
            stop_criteria = f"Piecewise((oo, {cond}), ({right}, Not({cond})))"
        elif name in str(right):
            stop_criteria = f"Piecewise(({left}, {cond}), (oo, Not({cond})))"
        stop_criteria = parse_expr(stop_criteria, local_dict={**self.sympy_vars, **self.func_vars, **self.word_dict}, \
                                transformations=self.transformations, evaluate=False)
        #### parse function
        func = Function(name)
        self.func_vars[name] = func
        func_expr = parse_expr(str(expr.serialize()), local_dict={**self.sympy_vars, **self.func_vars, **self.word_dict}, \
                    transformations=self.transformations, evaluate=False)
        iter_expr = func_expr
        for i in range(1, recur_iter+1):
            if i == recur_iter:
                """ In last iteration, we should replace the function by the stop condition
                """
                iter_expr = iter_expr.subs(func, Lambda(tuple(tmp_func_vars), stop_criteria), simplify=False)
            else:
                iter_expr = iter_expr.subs(func, Lambda(tuple(tmp_func_vars), func_expr), simplify=False)
        self.func_vars[name] = Lambda(tuple(tmp_func_vars), iter_expr)
        return True
    
    def parse(self, formula):
        try: 
            expr = parse_expr(str(formula), local_dict={**self.sympy_vars, **self.func_vars, **self.word_dict}, \
                                    transformations=self.transformations, evaluate=False)
        except (TypeError, SyntaxError, SympifyError) as e:
            raise FormulaParseError("sym formula complier failed in expression %s, due to %s" %(formula, e))
        return expr
    
        
    def parse_formula(self, formula, encoding=False):
        """ Parse the formula into sympy format 
            encoding reprs whether encode the formula into expr and term list
            sometime have error: https://github.com/sympy/sympy/issues/23874
        """
        if formula.is_equals():
            lhs, rhs = formula.args()
            lhs, rhs = self.parse(lhs.serialize()), self.parse(rhs.serialize())
            expr = Eq(lhs, rhs)
        elif formula.is_not():
            expr = formula.args()[0]
            expr = self.parse(expr.serialize())
            expr = Not(expr)
        elif formula.is_le():
            lhs, rhs = formula.args()
            lhs, rhs = self.parse(lhs.serialize()), self.parse(rhs.serialize())
            expr = Le(lhs, rhs)
        elif formula.is_lt():
            lhs, rhs = formula.args()
            lhs, rhs = self.parse(lhs.serialize()), self.parse(rhs.serialize())
            expr = Lt(lhs, rhs)
        elif formula.is_and():
            """e.g. lhs = (0 <= final_ahmed); rhs = (final_ahmed <= 100)"""
            expr = []
            for subformula in formula.args():
                e = self.parse_formula(subformula, encoding=False)
                expr.append(e)
            expr = And(*expr)
        elif formula.is_or():
            """e.g. lhs = (0 <= final_ahmed); rhs = (final_ahmed <= 100)"""
            expr = []
            for subformula in formula.args():
                e = self.parse_formula(subformula, encoding=False)
                expr.append(e)
            expr = Or(*expr)
        else:
            raise FormulaParseError("sym formula complier is still not support this type of expression %s" %(formula))
        # save the expr and relu
        if encoding == True:
            self.exprs.append(expr)
        else:
            return expr


    def compile(self, statement):
        self._reset()
        smt_parser = SmtLibParser()
        for cmd in smt_parser.get_command_generator(StringIO(statement)):
            #### Note: cmd.args[0] is fnode
            if cmd.name == "declare-fun" or cmd.name == "declare-const":
                var = cmd.args[0]
                tmp_name, tmp_type = var.symbol_name(), var.symbol_type()
                if not tmp_type.is_function_type():
                    self.declare_var(tmp_name, tmp_type)
                else:
                    func_type = cmd.args[1]
                    param_types, return_type = func_type.param_types, func_type.return_type
                    self.declare_fun(tmp_name, param_types, return_type)
            elif cmd.name == "define-fun":
                tmp_name, tmp_vars, tmp_type, tmp_expr = cmd.args
                self.define_fun(tmp_name, tmp_vars, tmp_type, tmp_expr)
            elif cmd.name == "define-fun-rec":
                tmp_name, tmp_vars, tmp_type, tmp_expr = cmd.args
                self.define_fun_rec(tmp_name, tmp_vars, tmp_type, tmp_expr)
            elif cmd.name == "assert":
                try:
                    self.parse_formula(cmd.args[0], encoding=True)
                except SympifyError:
                    raise FormulaParseError("sym formula complier failed in expression %s" %(cmd.args[0]))
            elif cmd.name == "minimize":
                raise OptimParseError("sym formula complier is still not support this type of expression %s" %(cmd.args[0]))
            elif cmd.name == "maximize":
                raise OptimParseError("sym formula complier is still not support this type of expression %s" %(cmd.args[0]))
            elif cmd.name == "check-sat": # ignore check-sat
                continue
            elif cmd.name == "get-value":
                self.target_vars = [arg for arg in cmd.args]
            elif cmd.name == "get-model":
                self.target_vars = [var['name'] for var in self.vars]
                
class sym_solver(sym_compiler):
    def __init__(self):
        """ 
            hyper-parameters 
            alg_tol is the tolerance for the algorithm to converge
            check_tol is the tolerance for the check-sat command
        """
        sym_compiler.__init__(self)
        
    def reset(self):
        """Reset the solver state."""
        self.solutions = []
            
    def type_check(self, solutions):
        """ check the validality of the solution """
        if not isinstance(solutions, list): 
            raise SolutionTypeError(f"solution {solutions} is not well-formed")
        elif len(solutions) == 0:
            return []
        elif len(solutions) > 1:
            warn(f"multiple solutions are found, but only one is returned")
        for solution in solutions: # check all derived solution
            final_sol = {}
            for var in self.vars:
                if self.sympy_vars[var['name']] not in solution: 
                    warn(f"the solution is not complete, obtain solution of {[k for k in solution.keys()]},"
                                        f" but required {[v['name'] for v in self.vars]}")
                    continue
                if var['type'].is_int_type():
                    tmp_res = solution[self.sympy_vars[var['name']]]
                    final_sol[var['name']] = str(tmp_res)                        
                    try:
                        if abs(tmp_res - int(tmp_res)) > self.check_tol:
                            raise SolutionTypeError("type check fail in %s = %s, but expect it is INT" %(var['name'], str(tmp_res)))
                    except TypeError:
                        raise SolutionTypeError("variable %s is invalid: %s" %(var['name'], str(tmp_res)))
                else:
                    tmp_res = solution[self.sympy_vars[var['name']]]
                    final_sol[var['name']] = str(tmp_res)
            return final_sol
    
    """ __summary__
        The following are the main functions for solving
    """
    def sympy_solve(self, statement=None):
        #### check-sat
        if len(self.vars) == 0: 
            return Result.EXCEPT, "No vars to be solved, re-compile and check the statement"
        if len(self.target_vars) == 0: 
            return Result.EXCEPT, "Statment does not contain get-value or get-model"
        if self.obj:
            return Result.EXCEPT, "Infeasible due to the problem is optimization task"
        else:
            try:
                x = Symbol("x", positive=True, real=True)
                mappings = {self.sympy_vars[key] : x for key in self.sympy_vars.keys()}
                exprs = [expr.xreplace(mappings) for expr in self.exprs[:-1] if expr.func == Eq]
                expr = self.exprs[-1].xreplace(mappings)
                if expr.func == Lt:
                    exprs.append(Eq(expr.args[0] - expr.args[1], -0.01))
                elif expr.func == Gt:
                    exprs.append(Eq(expr.args[0] - expr.args[1], 0.01))
                else:
                    exprs.append(False)
                x_sol = solve(exprs, x, dict=True)
                if x_sol == []:
                    return Result.UNKNOWN, "failed to find a feasible solution numerically"
                else:
                    solutions = [{self.sympy_vars[key] : x_sol[0][x] for key in self.sympy_vars.keys()}]
            except (ValueError, TypeError, AttributeError, NotImplementedError) as e:
                return Result.EXCEPT, f"sympy solver fail due to that `{e}"
        #### get-value
        check_res = self.type_check(solutions)
        try:
            res = ", ".join([f"{var} := {check_res[str(var)]}" for var in self.target_vars])
            return Result.SAT, f"[{res}]"
        except KeyError as e:
            return Result.EXCEPT, "sympy solver fail due to that get-value is not well-formed"

    """ __summary__
        The following are the main functions for optimizing
    """
    def sympy_prove(self, statement=None):
        #### check-sat
        if len(self.vars) == 0: 
            return Result.EXCEPT, "No vars to be solved, re-compile and check the statement"
        if len(self.target_vars) == 0: 
            return Result.EXCEPT, "Statment does not contain get-value or get-model"
        tmp_mappings = {}
        for (name, var) in self.sympy_vars.items():
            if f"0.0 < {var}" in [str(e) for e in self.exprs] or f"0.0 <= {var}" in [str(e) for e in self.exprs]:
                pos_symbol = Symbol(name, positive=True)
                tmp_mappings[var] = pos_symbol 
        goal = self.exprs[-1].xreplace(tmp_mappings)
        """
        We simply call sympy to check whether the last formula is satisfiable (without considering the constraint)
        """
        if goal.func == Ne:
            left, right = goal.args
            sympy_expr = powsimp(powdenest(left - right, force=True), force=True)
            sympy_expr = simplify(sympy_expr, force=True)
            res = sympy_expr == 0
        elif goal.func == Gt:
            left, right = goal.args
            res = simplify(left - right) <= 0
        elif goal.func == Lt:
            left, right = goal.args
            res = simplify(left - right) >= 0
        elif goal.func == Ge:
            left, right = goal.args
            res = simplify(left - right) < 0
        elif goal.func == Le:
            left, right = goal.args
            res = simplify(left - right) > 0
        elif goal.func == Eq:
            left, right = goal.args
            res = simplify(left - right) != 0
        else:
            raise FormulaParseError("sym formula complier is still not support this type of expression %s" %(goal))
        
        if res == True:
            return Result.UNSAT, "The last formula is unsatisfiable"
        else:
            return Result.UNKNOWN, "The last formula cannot be proved without using any context"
    
    def check_feasibility(self, res):
        """ check the feasibility of the solution 
            res is the results of scipy """
        if self.obj:
            cons_loss = lambdify([self.sympy_vars[key] for key in self.sympy_vars.keys()], self.cons_loss, modules='numpy')
            try:
                sol = self.retype_var(res.x)
                feasibility = cons_loss(*sol)
            except:
                raise SolutionTypeError(f"the solution {res.x} is invalid")
        else:
            feasibility = res.fun
        if feasibility < self.check_tol:
            final_sol = {}
            for id, var in enumerate(self.vars):
                tol = abs(round(res.x[id]) - res.x[id])
                if var['type'].is_int_type():
                    if tol < self.check_tol:
                        final_sol[self.sympy_vars[var['name']]] = round(res.x[id])
                    else:
                        # raise InfeasibleSolError(f"the solution {res.x} is not feasible due to {var['name']} is not integer")
                        return []
                else:
                    final_sol[self.sympy_vars[var['name']]] = (res.x[id])
            return [final_sol]
        else:
            # raise InfeasibleSolError(f"the solution {res.x} is not feasible, the feasibility loss is {feasibility}")
            return []
        
    def retype_var(self, param):
        """ retype the variable to integer if necessary """
        fresh_param = []
        for (idx, p) in enumerate(param):
            if self.integrality[idx] == True:
                fresh_param.append(int(p))
            else:
                fresh_param.append(p)        
        return fresh_param


def sympy_solve(statement, solver_name, args, pid_mgr):
    """
    Solve symbolic math problems using the specified solver.
    
    Args:
        statement: The SMT-LIB2 format statement to solve
        solver_name: Name of the solver to use ('sysol' or 'syopt')
        args: Additional solver arguments
        pid_mgr: Process ID manager
        
    Returns:
        tuple: (Result enum, solution string or error message)
    """
    solver = sym_solver()
    solver.compile(statement)
    
    if solver_name == "sysol":
        return solver.sympy_prove()
    elif solver_name == "syopt":
        return solver.sympy_solve()
    else:
        return Result.EXCEPT, f"Unknown solver: {solver_name}"