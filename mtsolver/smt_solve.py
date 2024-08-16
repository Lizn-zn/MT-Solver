from io import StringIO
from pysmt.smtlib.parser import SmtLibParser
from pysmt.shortcuts import Solver, Optimizer
from mtsolver.exceptions import smt_compile_errors, smt_solver_errors, \
                            smt_unsat, smt_unknown
from mtsolver.result import Result
from mtsolver.utils import *

def pysmt_solve(statement, solver_name, args, pid_mgr):
    solver_args = normalize(args, solver_name)
    smt_parser = SmtLibParser()
    smt_parser.env.enable_div_by_0 = False
    script = smt_parser.get_script(StringIO(statement))  
    Opt = Optimizer if any(cmd.name in ["maximize", "minimize"] for cmd in script) else Solver
    try:
        with Opt(name=solver_name, solver_options=solver_args) as opt:
            logs = script.evaluate(opt)
    except smt_compile_errors as e:
        return Result.EXCEPT, f"smt compilation failed: {e}"
    except smt_solver_errors as e:
        return Result.EXCEPT, f"solver {solver_name} error: {e}"
    except smt_unsat:
        return Result.UNSAT, "no counter example exists"
    except smt_unknown:
        return Result.UNKNOWN, "solver returns unknown"
    """
    logs[-1] is exit; logs[-2] is get-model; logs[-3] is check-sat
    """ 
    _, res = logs[-2]  
    res = str(res).replace("?", "").split('\n')
    res = f'[{", ".join(res)}]'
    return Result.SAT, res
