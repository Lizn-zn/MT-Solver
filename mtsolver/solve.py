from mtsolver.smt_solve import pysmt_solve
from mtsolver.sym_solve import sympy_solve
from mtsolver.maple_solve import maple_solve
from mtsolver.mma_solve import mtica_solve
from mtsolver.utils import *
from mtsolver.result import Result
from mtsolver.exceptions import timeout_errors
from multiprocessing import Pool, Manager

def solve(statement, solvers):
    """ integrated solving function
    Input 
        statement is the smt-lib format problem
        solver is a dict like {"z3":"z3's args", ...}
    return 
        SAT     if any solver find counter example
        UNSAT   if any solver prove the problem
        EXCEPT  if all solvers except
        TIMEOUT if all solvers timeout
        UNKNOWN if mixed return       
    """
    solver_res = {}
    res_lst, msg_lst = [], []
    try:
        pool = Pool(len(solvers))
        pid_mgr = Manager().list()
        future_res = {}
        for s in solvers:
            if s in ["cvc5", "z3", "msat"]:
                tmp_solver = pool.apply_async(pysmt_solve, (statement, s, solvers[s], pid_mgr))
                future_res[s] = tmp_solver
            if s in ["sysol", "syopt"]:
                tmp_solver = pool.apply_async(sympy_solve, (statement, s, solvers[s], pid_mgr))
                future_res[s] = tmp_solver
            if s in ["mplrc", "mplbt"]:
                tmp_solver = pool.apply_async(maple_solve, (statement, s, solvers[s], pid_mgr))
                future_res[s] = tmp_solver
            if s in ["mmard", "mmafi"]:
                tmp_solver = pool.apply_async(mtica_solve, (statement, s, solvers[s], pid_mgr))
                future_res[s] = tmp_solver
        for s in solvers:
            try:
                timeout = int(solvers[s].get("timeout", 30))
                res, msg = future_res[s].get(timeout)
            except timeout_errors:
                res, msg = Result.TIMEOUT, "solve timeout"
            solver_res[s] = res
            if res == Result.SAT or res == Result.UNSAT: 
                return res, msg
            else:
                res_lst.append(res)
                msg_lst.append(msg)
    finally:
        for pid in pid_mgr:
            try:
                os.killpg(pid, signal.SIGKILL)
            except ProcessLookupError:
                pass
        pool.terminate()
        pool.join()
    if all([res == Result.TIMEOUT for res in res_lst]):
        return Result.TIMEOUT, "solve timeout"
    elif all([res == Result.EXCEPT for res in res_lst]):
        return Result.EXCEPT, " | ".join(msg_lst)
    return Result.UNKNOWN, " | ".join(msg_lst)


