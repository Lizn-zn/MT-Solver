from src.smt_solve import pysmt_solve
from src.sym_solve import sympy_solve
from src.maple_solve import bottema_solve
from src.result import Result
from src.exceptions import timeout_errors
from multiprocessing import Pool

def solve(statement, solvers):
    solver_res = {}
    try:
        pool = Pool(len(solvers))
        future_res = {}
        for s in solvers:
            if s in ["cvc5", "z3", "msat"]:
                tmp_solver = pool.apply_async(pysmt_solve, (statement, s))
                future_res[s] = tmp_solver
            if s in ["sysol", "syopt"]:
                tmp_solver = pool.apply_async(sympy_solve, (statement, s))
                future_res[s] = tmp_solver
            if s in ["bottema"]:
                tmp_solver = pool.apply_async(bottema_solve, (statement, s))
                future_res[s] = tmp_solver
        for s in solvers:
            try:
                timeout = int(solvers[s].get("timeout", 30))
                res, msg = future_res[s].get(timeout)
            except timeout_errors:
                res, msg = Result.TIMEOUT, "solver timeout"
            solver_res[s] = res
            if res == Result.SAT or res == Result.UNSAT: 
                return res, msg
    finally:
        pool.terminate()
        pool.join()
    return None


