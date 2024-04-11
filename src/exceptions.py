""" __summary__
    Custom exceptions for the SymPy Compiler
"""
class SymCompileError(Exception):
    """Base class for all custom exceptions in Compilation"""
    pass

class NoStatementError(SymCompileError):
    """Raised when there is no statement in the input"""
    pass

class FormulaParseError(SymCompileError):
    """Raised when the formula cannot be parsed"""
    pass

class OptimParseError(SymCompileError):
    """Raised when the formula cannot be parsed"""
    pass

class FunctionTypeError(SymCompileError):
    """Raised when the type of a function is not as expected"""
    pass

class IllegalGetValueCommand(SymCompileError):
    """The args in get-value command is not supported by the solver."""
    pass

""" __summary__
    Custom exceptions for the SymPy Solve
"""
class SymSolveError(Exception):
    """Base class for all custom exceptions in Solving"""
    pass

class NoCompliationError(SymSolveError):
    """Raised when the formula is not compiled"""
    pass 

class InvalidProblemType(SymSolveError):
    """Raised when the problem type is not supported"""
    pass

class SolutionTypeError(SymSolveError):
    """Raised when the type of a solution is not as expected"""
    pass

class InfeasibleSolError(SymSolveError):
    """Raised when the solution is infeasible"""
    pass

class ScipyOptimError(SymSolveError):
    """Raised when the scipy optimizer fails"""
    pass



# """ __summary__
#     The following is exception handling
# """
from pysmt.exceptions import UnsupportedOperatorError, ConvertExpressionError, NonLinearError, \
                             DefinitionMissingError, InvalidSetOption, OperatorMissingError, \
                             PysmtValueError, PysmtModeError, PysmtTypeError, InternalSolverError, ModelUnsatError, \
                             ModelUnavilableError, PysmtSyntaxError, InvalidCommandArgs, \
                             NoSolverAvailableError, GoalUnavaibleError, SolverReturnedUnknownResultError, \
                             PysmtInfinityError, PysmtUnboundedOptimizationError, PysmtInfinitesimalError
from pysmt.exceptions import IllegalGetValueCommand as PysmtIllegalGetValueCommand
from z3.z3types import Z3Exception
from src.exceptions import FormulaParseError, OptimParseError, FunctionTypeError, NoStatementError
from src.exceptions import IllegalGetValueCommand as SymIllegalGetValueCommand
from src.exceptions import NoCompliationError, InvalidProblemType, SolutionTypeError, InfeasibleSolError, ScipyOptimError

from multiprocessing import TimeoutError as MpTimeoutError
from multiprocessing.pool import MaybeEncodingError

from sympy.polys.polyerrors import NotAlgebraic, NotInvertible
from mpmath.libmp.libhyper import NoConvergence
from tokenize import TokenError

""" 
   __Summary__: handle smt exception
"""
smt_compile_errors = (PysmtModeError, InvalidCommandArgs, SymIllegalGetValueCommand, \
                        PysmtIllegalGetValueCommand, NoStatementError, NoCompliationError, \
                        OperatorMissingError, PysmtSyntaxError, PysmtTypeError, DefinitionMissingError, \
                        InvalidSetOption) 
smt_solver_errors = (Z3Exception, InternalSolverError, ConvertExpressionError)
smt_unsat = (ModelUnsatError, NoSolverAvailableError, ModelUnavilableError, )
smt_unknown = (ModelUnsatError, SolverReturnedUnknownResultError, \
                    GoalUnavaibleError, PysmtUnboundedOptimizationError)

""" 
   __Summary__: handle sympy exception
"""
sym_compile_errors = (FormulaParseError, FunctionTypeError) # (ValueError, TypeError, SympifyError, TokenError)
sympy_solve_errors = (SolutionTypeError, InvalidProblemType) # (TypeError, NotImplementedError, ValueError, IndexError, NotAlgebraic, NoConvergence, NotInvertible)
scipy_solve_errors = (InfeasibleSolError, ScipyOptimError) # (TypeError, OverflowError, RuntimeError, ValueError, PysmtValueError, PysmtModeError, ZeroDivisionError, RecursionError)


"""
    __Summary__: handle maple exception
"""
maple_compile_errors = (UnsupportedOperatorError) 

timeout_errors = MpTimeoutError

