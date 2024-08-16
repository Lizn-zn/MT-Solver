# Installation
Run the following command
```shell
pip install git+https://github.com/Lizn-zn/pysmt.git@Bottema
pip install git@github.com:Lizn-zn/MT_Solver.git
```

# Test
Run `python test/test.py` to test all solvers

# Usage

```shell
mtsolve --fpath ./test/case3.smt --z3 "--timeout 5"
```

# Some issues

- for `test/more_cases/7.smt`, syopt incorrectly give sat and a counter example