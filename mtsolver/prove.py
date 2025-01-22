from mtsolver.maple_solve import maple_prove
from mtsolver.utils import *
from mtsolver.exceptions import timeout_errors
from multiprocessing import Pool, Manager

def prove(statement, solvers):
    """ integrated prove function
    Input 
        statement is the smt-lib format problem
        solver is a dict like {"schd":"schd's args", ...}
    return 
        bool     whether a certificate is available
    """
    solver_res = {}
    res_lst, msg_lst = [], []
    try:
        pool = Pool(len(solvers))
        pid_mgr = Manager().list()
        future_res = {}
        for s in solvers:
            if s in ["tsds", "schd"]:
                tmp_prover = pool.apply_async(maple_prove, (statement, s, solvers[s], pid_mgr))
                future_res[s] = tmp_prover
        for s in solvers:
            try:
                timeout = int(solvers[s].get("timeout", 30))
                res, msg = future_res[s].get(timeout)
            except timeout_errors:
                res, msg = False, "solve timeout"
            solver_res[s] = res
            if res == True: 
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
    if all([res == False for res in res_lst]):
        return False, " | ".join(msg_lst)
    else:
        return True, " | ".join(msg_lst)


