from pysmt.smtlib.parser import SmtLibParser
from pysmt.shortcuts import REAL, INT, BOOL, Not, HRPrinter, MathematicaPrinter
from io import StringIO
from warnings import warn
from mtsolver.exceptions import mtica_compile_errors, FormulaParseError
from mtsolver.result import Result
from mtsolver.utils import *

class mtica_compiler:
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
        self.funs.append(f"{name} := {expr.serialize(printer=MathematicaPrinter)}")

    def define_fun_rec(self, name, vars, type, expr, recur_iter=10):
        """ Define a recursive function for solving 
            In contrast to declare_fun, declare_fun_rec is defined by equation f(x) = g(f(x)) instead
        """
        raise NotImplementedError('Unsupport command define-fun')

    def parse_formula(self, cmd):
        self.exprs.append(cmd.serialize(printer=MathematicaPrinter))

    def parse_objective(self, cmd, minimize=True):
        raise NotImplementedError('Unsupport command minimize/maximize')
            
    def compile(self, statement):
        """ compile the smt-lib statement
        """
        self._reset()
        smt_parser = SmtLibParser()
        tmp_exprs = []
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
                tmp_exprs.append(cmd.args[0])
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
        # the last expr should be negated
        for expr in tmp_exprs[:-1]:
            self.parse_formula(expr)
        self.parse_formula(Not(tmp_exprs[-1]))
        

class mtica_solver(mtica_compiler):
    def __init__(self):
        """ hyper-parameters setting
        """
        mtica_compiler.__init__(self)
        # dir_path = os.path.dirname(__file__)
        
    def reset(self):
        self.solutions = []
    
    def solve(self, args, solver_name, pid_mgr):
        """ solve and parse the result 
        """        
        # for mpl setting to mute some prints
        # prover selection
        polynomials = " && ".join(self.exprs)
        variables = "{" + ",".join([f"{var['name']}" for var in self.vars]) + "}"
        if solver_name == "mmard":
            prove_cmd = ['wolframscript', '-code', f"Reduce[{polynomials}, {variables}, Reals]"]
        elif solver_name == "mmafi":
            prove_cmd = ['wolframscript', '-code', f"FindInstance[{polynomials}, {variables}, Reals]"]
        timeout = int(args.get("timeout", 30))
        output, error = wrap_exec(prove_cmd, "", timeout, pid_mgr)
        # start_marker, end_marker = exec_args, '> quit'
        if output.strip() == "False" or output.strip() == "{}":
            return Result.UNSAT, "no counter example exists"
        else:
            res = output.strip()
            if res != "": 
                return Result.SAT, res
            else:   
                # print(exec_args)
                # print(output+error)
                return Result.EXCEPT, output+error
        
def mtica_solve(statement, solver_name, args, pid_mgr):
    s = mtica_solver()
    try:
        s.compile(statement) 
    except mtica_compile_errors as e:
        return Result.EXCEPT, f"maple compilation failed: {e}"
    res = s.solve(args, solver_name, pid_mgr)
    return res

            