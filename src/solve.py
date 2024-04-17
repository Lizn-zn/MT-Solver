from src.smt_solve import pysmt_solve
from src.sym_solve import sympy_solve
from src.maple_solve import bottema_solve
from src.result import Result
from src.exceptions import timeout_errors
from multiprocessing import Pool

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
        future_res = {}
        for s in solvers:
            args = solvers[s]
            if s in ["cvc5", "z3", "msat"]:
                tmp_solver = pool.apply_async(pysmt_solve, (statement, s, args))
                future_res[s] = tmp_solver
            if s in ["sysol", "syopt"]:
                tmp_solver = pool.apply_async(sympy_solve, (statement, s, args))
                future_res[s] = tmp_solver
            if s in ["bottema"]:
                tmp_solver = pool.apply_async(bottema_solve, (statement, s, args))
                future_res[s] = tmp_solver
        for s in solvers:
            try:
                timeout = int(solvers[s].get("timeout", 30)) + 2
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
        pool.close()
        pool.join()
    if all([res == Result.TIMEOUT for res in res_lst]):
        return Result.TIMEOUT, "solve timeout"
    elif all([res == Result.EXCEPT for res in res_lst]):
        return Result.EXCEPT, " | ".join(msg_lst)
    return Result.UNKNOWN, " | ".join(msg_lst)


