from MathGym.utils.smt_solve import pysmt_solver
from MathGym.utils.sym_solve import sym_solver
from multiprocessing import Pool

def solve(statement, verbose=False):
    solver_res = {}
    try:
        pool = Pool(4)
        future_res = {}
        for s in ["cvc5", "z3", "msat"]:
            tmp_solver = pool.apply_async(pysmt_solver, (statement, s))
            future_res[s] = tmp_solver
        for s in ["cvc5", "z3", "msat"]:
            try:
                res = future_res[s].get(10)
                msg = "solve successfully"
            except Exception as e:
                res = None
                msg = handle_solve_exception(e)
            solver_res[s] = res
            if verbose: print(f"{s} return: {res} | details: {msg}")
            if res is not None: 
                return res
    finally:
        pool.terminate()
        pool.join()
    if res is None:
        """ sym compiling """
        try:
            s = sym_solver()
            s.compile(statement)    
        except Exception as e:
            msg = handle_solve_exception(e)
            if verbose: print(f"sym compile return: {res} | details: {msg}")
            return res    
        """ sympy solving """    
        try:
            res = s.sympy_solve()
            msg = "solve successfully"
        except Exception as e:
            res = None
            msg = handle_solve_exception(e)
        solver_res['sympy'] = res
        if verbose: print(f"sympy return: {res} | details: {msg}")
        if res is not None: 
            return res
        """ scipy optimizing """
        try:
            res = s.scipy_optim()
            msg = "solve successfully"
        except Exception as e:
            res = None
            msg = handle_solve_exception(e)
        solver_res['scipy'] = res
        if verbose: print(f"scipy return: {res} | details: {msg}")
        if res is not None: 
            return res
    return None

""" __summary__
    The following is exception handling
"""
from pysmt.exceptions import UnsupportedOperatorError, ConvertExpressionError, NonLinearError, \
                             DefinitionMissingError, InvalidSetOption, OperatorMissingError, \
                             PysmtValueError, PysmtModeError, PysmtTypeError, InternalSolverError, ModelUnsatError, \
                             ModelUnavilableError, PysmtSyntaxError, InvalidCommandArgs, \
                             NoSolverAvailableError, GoalUnavaibleError, SolverReturnedUnknownResultError, \
                             PysmtInfinityError, PysmtUnboundedOptimizationError, PysmtInfinitesimalError
from pysmt.exceptions import IllegalGetValueCommand as PysmtIllegalGetValueCommand
from z3.z3types import Z3Exception
from MathGym.utils.exceptions import FormulaParseError, OptimParseError, FunctionTypeError, NoStatementError
from MathGym.utils.exceptions import IllegalGetValueCommand as SymIllegalGetValueCommand
from MathGym.utils.exceptions import NoCompliationError, InvalidProblemType, SolutionTypeError, InfeasibleSolError, ScipyOptimError

from multiprocessing import TimeoutError as MpTimeoutError
from multiprocessing.pool import MaybeEncodingError
from timeout_decorator import timeout, TimeoutError as WrapTimeoutError

from sympy.polys.polyerrors import NotAlgebraic, NotInvertible
from mpmath.libmp.libhyper import NoConvergence
from tokenize import TokenError

smt_compile_errors = (PysmtModeError, InvalidCommandArgs, SymIllegalGetValueCommand, \
                        PysmtIllegalGetValueCommand, NoStatementError, NoCompliationError, \
                        OperatorMissingError, PysmtSyntaxError, PysmtTypeError, DefinitionMissingError, \
                        InvalidSetOption) 
sym_compile_errors = (FormulaParseError, FunctionTypeError) # (ValueError, TypeError, SympifyError, TokenError)
smt_solve_errors = (ModelUnsatError, SolverReturnedUnknownResultError, Z3Exception, \
                    InternalSolverError, NoSolverAvailableError, GoalUnavaibleError, \
                    ModelUnavilableError, PysmtUnboundedOptimizationError, ConvertExpressionError)
sympy_solve_errors = (SolutionTypeError, InvalidProblemType) # (TypeError, NotImplementedError, ValueError, IndexError, NotAlgebraic, NoConvergence, NotInvertible)
scipy_solve_errors = (InfeasibleSolError, ScipyOptimError) # (TypeError, OverflowError, RuntimeError, ValueError, PysmtValueError, PysmtModeError, ZeroDivisionError, RecursionError)
timeout_errors = (WrapTimeoutError, MpTimeoutError) 

def handle_solve_exception(e):
    if isinstance(e, smt_compile_errors):
        head = "smt compile error; " 
    elif isinstance(e, sym_compile_errors):
        head = "sym convert error; " 
    elif isinstance(e, smt_solve_errors):
        head = "smt solver error; "
    elif isinstance(e, sympy_solve_errors):
        head = "sympy solver error; "
    elif isinstance(e, scipy_solve_errors):
        head = "scipy solver error; "
    elif isinstance(e, timeout_errors):
        head = "solving timeout error; "
    else:
        raise e
    return head + str(e)
