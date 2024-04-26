import os
import sys
sys.path.insert(0, '/data0/lizn/pysmt')
from src.solve import solve
from src.result import Result

statements = {}
for filename in os.listdir('./test/cases'):
    if filename.endswith(".smt"):
        filepath = os.path.join('./test/cases', filename)
        with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read() 
        statements[int(filename[:-4])] = content
idxs = sorted(statements)

solvers = {"z3": {"timeout":10}, "cvc5": {"timeout":10}, "msat": {"timeout":10}, "mplrc": {"timeout":10}}
result_types = [Result.SAT, Result.UNSAT, Result.UNKNOWN, Result.TIMEOUT, Result.EXCEPT]
stats = {solver: {result: 0 for result in result_types} for solver in solvers}

for idx in idxs:
    if idx > 20:
         break
    output = ""
    for s in solvers:
        res, msg = solve(statements[idx], {s: solvers[s]})
        output += "\n | {:<8}: {:<12} {:<15}".format(s, res, msg)
        stats[s][res] += 1
    print("Start test case {:<3} ...".format(idx) + output)
    print('-' * 50) 

stats_res = "Statistics of results for each solver:\n"
stats_res += "{:<8} {:<6} {:<6} {:<6} {:<6} {:<6}".format("Solver", "SAT", "UNSAT", "UNKNOWN", "TIMEOUT", "EXCEPT")
for solver, counts in stats.items():
    stats_res += "\n{:<8}".format(solver)
    for result, count in counts.items():
        stats_res += "  {:<6}".format(count)
print(stats_res)

     