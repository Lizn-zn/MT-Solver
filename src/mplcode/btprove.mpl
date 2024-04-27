(*
###########################################
# Main class
# Prove inequalities by RegularChains package
# The code implements the following steps:
    # 1) preprocess the fraction a/b <= 0 by a * b <= 0
    # 2) preprocess the radical sqrt(a) <= b by aux <= b &and aux^2 = a
    # 3) conduct quantifier elimination
    # 4) if unsat, return false, []; if sat, return true, counter example
# Use example:
    # prove([[(0 < p)],[(p < 15)],[(p <= x)],[(x <= 15)],
         [ &not((15 <= (((x - p)^2) + ((x - 15)^2) + ((x - (p + 15))^2)^(1/2))))]], [p,x]);
    # prove([[(((a ^ 2) + (b ^ 2)) = (2 * a * b))],[ &not(((2 * (a ^ 2) * (b ^ 3)) <= ((a ^ 2) + (b ^ 6))))]], [b,a]);
###########################################
*)

with(RegularChains):
with(SemiAlgebraicSetTools):
read("./src/mplcode/utils.mpl"):
read("./src/mplcode/bottema.mpl"):

prove := proc(ineqs, vars)
    local newEqs, preRes, goal;
    goal := ineqs[nops(ineqs)];
    # if we must use samplepoint, then preprocess
    # else, we avoid the preprocessing
    if hastype(goal, `<`) or hastype(goal, `=`) then
        newEqs := preprocess(ineqs);
    else:
        newEqs := ineqs; 
    fi;
    local R, s, sys, qeRes;
    # merge all ineqs by `&and``
    sys := qe(newEqs);
    if sys = [] then
        print(`The inequality holds.`);
        return;
    fi;
    # check the validity
    for s in sys do
        if has(s, `&or`) or has(s, `&implies`) then
            error(`Bottema prover does not support logical &or and logical &implies`);
        fi;
    od;
    local gLhs, gRhs, cons;
    goal := sys[nops(sys)];
    cons := sys[1..nops(sys)-1];
    if has(goal, `&not`) then
        goal := op(goal);
        gLhs := lhs(goal); # reverse them
        gRhs := rhs(goal);
    else
        error(`the last assertion should be the goal and expressed in &not format`);
    fi;
    local res;
    if hastype(goal, `<=`) then
        goal := (gLhs-gRhs) <= 0;
        res := yprove(goal, cons);
        if res = true then
            print(`The inequality holds.`);
        else:
            print(`The inequality does not hold.`);
        fi;
    elif hastype(goal, `<`) then
        goal := (gLhs-gRhs) <= 0;
        res := yprove(goal, cons);
        if res = true then           
            goal := (gLhs-gRhs) = 0;
            newEqs := [goal, op(cons)];
            res := sample(newEqs, vars);
        elif res = false then
            print(`The inequality does not hold.`);
        fi;
    elif type(goal, `=`) then
        goal := (gLhs-gRhs) = 0;
        newEqs := [goal, op(cons)];
        sample(newEqs, vars); 
    else
        error(`Invalid formula`, goal);
    fi;
    return;
end proc:

# EOC of prove

prove([[(0 < a)],[(0 < m)],[(0 < c)],[((a + m + c) = 12)],[&not((((a * m * c) + (a * m) + (m * c) + (a * c)) < 112))]], [a,m,c]);