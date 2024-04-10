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


