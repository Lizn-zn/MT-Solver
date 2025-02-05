# Installation
Run the following command
```shell
pip install git+https://github.com/Lizn-zn/pysmt.git@Bottema
pip install git@github.com:Lizn-zn/MT_Solver.git
```

# Test
Run `python test/test.py` to test all solvers

# Usage
- SMT solver checks satisfiability of a formula
```shell
mtsolve --fpath ./test/cases/3.smt --z3 "--timeout 5"
```
- SOS prover checks a formula is a sum of squares
```shell
mtprove --fpath ./test/cases/3.smt --tsds "--timeout 5"
```
