import os
import sys
from mtsolver.prove import prove

statements = {}
for filename in os.listdir('./test/sos_cases'):
    if filename.endswith(".smt"):
        filepath = os.path.join('./test/sos_cases', filename)
        with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read() 
        statements[int(filename[:-4])] = content
idxs = sorted(statements)

solvers = {"schd": {"timeout":10}, "tsds": {"timeout":10}}
result_types = [True, False]
stats = {solver: {result: 0 for result in result_types} for solver in solvers}

for idx in idxs:
    output = ""
    for s in solvers:
        res, msg = prove(statements[idx], {s: solvers[s]})
        output += "\n | {:<8}: {:<12} {:<24}".format(s, res, msg)
        stats[s][res] += 1
    print("Start test case {:<3} ...".format(idx) + output)
    print('-' * 50) 

stats_res = "Statistics of results for each solver:\n"
stats_res += "{:<8} {:<6} {:<6}".format("Solver", "UNSAT", "SAT")
for solver, counts in stats.items():
    stats_res += "\n{:<8}".format(solver)
    for result, count in counts.items():
        stats_res += "  {:<6}".format(count)
print(stats_res)

     