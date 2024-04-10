from io import StringIO
from pysmt.smtlib.parser import SmtLibParser
from pysmt.shortcuts import Solver, Optimizer
from MathGym.utils.exceptions import IllegalGetValueCommand, NoStatementError

def pysmt_solver(statement, solver_name='z3'):
    smt_parser = SmtLibParser()
    smt_parser.env.enable_div_by_0 = False
    script = smt_parser.get_script(StringIO(statement))  
    Opt = Optimizer if any(cmd.name in ["maximize", "minimize"] for cmd in script) else Solver
    with Opt(name=solver_name) as opt:
        logs = script.evaluate(opt)
    if len(logs) == 0:
        raise NoStatementError("No statement in the smtlib provided")
    cmd, res = logs[-1] 
    if cmd == "get-value":
        return [str(res[key]).replace("?", "") for key in res]
    elif cmd == "get-model":
        res = str(res).replace("?", "").split('\n') # remove ? in the model
        return res
    else:
        raise IllegalGetValueCommand("the last command in smtlib is not get-value or get-models")