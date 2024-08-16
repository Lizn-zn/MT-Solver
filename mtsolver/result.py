from enum import Enum

class Result(Enum):
    SAT = 1
    UNSAT = 2
    UNKNOWN = 3
    TIMEOUT = 4
    EXCEPT = 5

    def __str__(self) -> str:
        if self == Result.SAT:
            return "sat"
        elif self == Result.UNSAT:
            return "unsat"
        elif self == Result.UNKNOWN:
            return "unknown"
        elif self == Result.TIMEOUT:
            return "timeout"
        elif self == Result.EXCEPT:
            return "exception"
        else:
            raise ValueError(f"Unexpected result: {self}")