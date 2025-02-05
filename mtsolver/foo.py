import sys
import argparse
from mtsolver.solve import solve
from mtsolver.prove import prove
from mtsolver.utils import *
        
def solve_main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fpath", type=str, required=False,
                        help="Input SMT-LIB file. If `None`, it reads formula from stdin until `(check-sat)`")
    parser.add_argument("--z3", type=str, help="Z3's command line arguments")
    parser.add_argument("--cvc5", type=str, help="CVC5's command line arguments")
    parser.add_argument("--vampire", type=str, help="Vampire's command line arguments")
    parser.add_argument("--msat", type=str, help="MathSAT's command line arguments")
    parser.add_argument("--sysol", type=str, help="SymPy solve's command line arguments")
    parser.add_argument("--syopt", type=str, help="SymPy optim's command line arguments")
    parser.add_argument("--mplrc", type=str, help="Maple-reduce's command line arguments")
    parser.add_argument("--mplbt", type=str, help="Maple-bottema's command line arguments")
    parser.add_argument("--mmard", type=str, help="Mathematica-reduce's command line arguments")
    parser.add_argument("--mmafi", type=str, help="Mathematica-findinstance's command line arguments")
    args = parser.parse_args()
    
    if args.fpath:
        with open(args.fpath, "r") as f:
            statement = f.read()
    else:
        statement = sys.stdin.read()
    if "check-sat" not in statement:
        raise ValueError("Invalid statement in the input")
    args = vars(args)
    solvers = {}
    for s in args:
        if s in ["z3", "cvc5", "msat", "sysol", "syopt", "mplrc", "mplbt", "mmard", "mmafi"] and args[s]:
            solvers[s] = parse_args(args[s])
    ok, msg = solve(statement, solvers=solvers)
    print(ok, file=sys.stdout)
    print(msg, file=sys.stderr)
    
    
def prove_main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--fpath", type=str, required=False,
                        help="Input SMT-LIB file. If `None`, it reads formula from stdin until `(check-sat)`")
    parser.add_argument("--tsds", type=str, help="TSDS's command line arguments")
    parser.add_argument("--schd", type=str, help="SCHD's command line arguments")
    args = parser.parse_args()
    
    if args.fpath:
        with open(args.fpath, "r") as f:
            statement = f.read()
    else:
        statement = sys.stdin.read()
    if "check-sat" not in statement:
        raise ValueError("Invalid statement in the input")
    args = vars(args)
    solvers = {}
    for s in args:
        if s in ["tsds", "schd"] and args[s]:
            solvers[s] = parse_args(args[s])
    ok, msg = prove(statement, solvers=solvers)
    print(ok, file=sys.stdout)
    print(msg, file=sys.stderr)
    
    
    
