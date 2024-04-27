from pysmt.smtlib.parser import SmtLibParser
from pysmt.shortcuts import REAL, INT, BOOL, Not, HRPrinter, MaplePrinter
from io import StringIO
from warnings import warn
from src.exceptions import maple_compile_errors, FormulaParseError
from src.result import Result
from src.utils import *

class maple_compiler:
    """ 
        The class to compile the SMT-LIB2 format statement into maple format
    """
    def __init__(self):
        self.word_dict = {}
        
    def _reset(self):
        self.vars, self.funs, self.exprs, self.goals = [], [], [], []
    
    def declare_var(self, name, type):
        """ Declare a variable for solving """
        if type != REAL:
            raise FormulaParseError(f"Maple solver does not support type {type}")
        self.vars.append({'name': name, 'type': type})
    
    def declare_fun(self, name, input_types, output_type):
        """ Declare a function for solving """
        raise NotImplementedError('Unsupport command declare-fun')

    def define_fun(self, name, vars, rtype, expr):
        """ Define a function for solving 
            This is not needed for maple
        """
        self.funs.append(f"{name} := {expr.serialize(printer=MaplePrinter)}")

    def define_fun_rec(self, name, vars, type, expr, recur_iter=10):
        """ Define a recursive function for solving 
            In contrast to declare_fun, declare_fun_rec is defined by equation f(x) = g(f(x)) instead
        """
        raise NotImplementedError('Unsupport command define-fun')

    def parse_formula(self, cmd):
        self.exprs.append(cmd.serialize(printer=MaplePrinter))

    def parse_objective(self, cmd, minimize=True):
        raise NotImplementedError('Unsupport command minimize/maximize')
            
    def compile(self, statement):
        """ compile the smt-lib statement
        """
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
                self.parse_formula(cmd.args[0])
            elif cmd.name == "minimize":
                self.parse_objective(cmd.args[0], minimize=True)
            elif cmd.name == "maximize":
                self.parse_objective(cmd.args[0], minimize=False)
            elif cmd.name == "check-sat": # ignore
                continue
            elif cmd.name == "get-value":
                self.target_vars = [arg for arg in cmd.args]
            elif cmd.name == "get-model":
                self.target_vars = self.vars

class maple_solver(maple_compiler):
    def __init__(self):
        """ hyper-parameters setting
        """
        maple_compiler.__init__(self)
        
    def reset(self):
        self.solutions = []
    
    def solve(self, args, pid_mgr):
        """ solve and parse the result 
        """
        exec_cmd = 'maple'
        polynomials = "[" + ",".join([f"[{expr}]" for expr in self.exprs]) + "]"
        variables = "[" + ",".join([f"{var['name']}" for var in self.vars]) + "]"
        prove_cmd = f'prove({polynomials}, {variables})'
        print(prove_cmd)
        exec_args = f'interface(prettyprint=0): read "./src/mplcode/rcprove.mpl": {prove_cmd};'
        timeout = int(args.get("timeout", 30))
        output, error = wrap_exec(exec_cmd, exec_args, timeout, pid_mgr)
        start_marker, end_marker = exec_args, '> quit'
        output = parse_string(output, start_marker, end_marker)
        if "The inequality holds." in output:
            return Result.UNSAT, "no counter example exists"
        else:
            start_marker = "`output a counter example`"
            end_marker = "`The inequality does not hold.`"
            res = parse_string(output, start_marker, end_marker) 
            if res != "": 
                return Result.SAT, res
            else:   
                print(output + error)
                return Result.EXCEPT, output+error
        
def maple_solve(statement, solver_name, args, pid_mgr):
    s = maple_solver()
    try:
        s.compile(statement) 
    except maple_compile_errors as e:
        return Result.EXCEPT, f"maple compilation failed: {e}"
    res = s.solve(args, pid_mgr)
    return res

            