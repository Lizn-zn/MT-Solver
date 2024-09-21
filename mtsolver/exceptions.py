from pysmt.exceptions import UnsupportedOperatorError, ConvertExpressionError, \
                             DefinitionMissingError, InvalidSetOption, OperatorMissingError, \
                             PysmtValueError, PysmtModeError, PysmtTypeError, InternalSolverError, ModelUnsatError, \
                             ModelUnavilableError, PysmtSyntaxError, InvalidCommandArgs, \
                             NoSolverAvailableError, GoalUnavaibleError, SolverReturnedUnknownResultError, \
                             PysmtInfinityError, PysmtUnboundedOptimizationError, PysmtInfinitesimalError
from pysmt.exceptions import IllegalGetValueCommand as PysmtIllegalGetValueCommand
from z3.z3types import Z3Exception
from multiprocessing import TimeoutError as MpTimeoutError
from subprocess import TimeoutExpired
from multiprocessing.pool import MaybeEncodingError

from sympy.polys.polyerrors import NotAlgebraic, NotInvertible
from mpmath.libmp.libhyper import NoConvergence
from tokenize import TokenError

""" __summary__
    Custom exceptions for the Compilation
"""

class CompileError(Exception):
    """Base class for all custom exceptions in Compilation"""
    pass

class NoStatementError(CompileError):
    """Raised when there is no statement in the input"""
    pass

class FormulaParseError(CompileError):
    """Raised when the formula cannot be parsed"""
    pass

class OptimParseError(CompileError):
    """Raised when the formula cannot be parsed"""
    pass

class FunctionTypeError(CompileError):
    """Raised when the type of a function is not as expected"""
    pass

class IllegalGetValueCommand(CompileError):
    """The args in get-value command is not supported by the solver."""
    pass

smt_compile_errors = (PysmtModeError, InvalidCommandArgs, IllegalGetValueCommand, \
                        PysmtIllegalGetValueCommand, NoStatementError, OperatorMissingError, \
                        PysmtSyntaxError, PysmtTypeError, DefinitionMissingError, InvalidSetOption) 
sym_compile_errors = (FormulaParseError, FunctionTypeError) # (ValueError, TypeError, SympifyError, TokenError)
maple_compile_errors = (UnsupportedOperatorError, FormulaParseError)
mtica_compile_errors = (UnsupportedOperatorError, FormulaParseError)  

# EOC of compilation exceptions

""" __summary__
    Custom exceptions for the Solve
"""
class SolveError(Exception):
    """Base class for all custom exceptions in Solving"""
    pass

class NoCompliationError(SolveError):
    """Raised when the formula is not compiled"""
    pass 

class InvalidProblemType(SolveError):
    """Raised when the problem type is not supported"""
    pass

class SolutionTypeError(SolveError):
    """Raised when the type of a solution is not as expected"""
    pass

class InfeasibleSolError(SolveError):
    """Raised when the solution is infeasible"""
    pass

class ScipyOptimError(SolveError):
    """Raised when the scipy optimizer fails"""
    pass

smt_solver_errors = (Z3Exception, NoSolverAvailableError, InternalSolverError, ConvertExpressionError, RuntimeError)
sympy_solve_errors = (SolutionTypeError, InvalidProblemType) # (TypeError, NotImplementedError, ValueError, IndexError, NotAlgebraic, NoConvergence, NotInvertible)
scipy_solve_errors = (InfeasibleSolError, ScipyOptimError) # (TypeError, OverflowError, RuntimeError, ValueError, PysmtValueError, PysmtModeError, ZeroDivisionError, RecursionError)


""" __summary__
    Custom exceptions for the result
"""

smt_unsat = (ModelUnsatError, ModelUnavilableError, )
smt_unknown = (ModelUnsatError, SolverReturnedUnknownResultError, \
                    GoalUnavaibleError, PysmtUnboundedOptimizationError)


""" __summary__
    timeout exception 
"""

timeout_errors = (MpTimeoutError, TimeoutExpired)