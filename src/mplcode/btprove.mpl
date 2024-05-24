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
prove := proc(ineqs, vars)
    local newEqs, preRes, goal;
    goal := ineqs[nops(ineqs)];
    # if '<' and '=' in the goal, we should must use samplepoint 
    #                              as an additional checker for bottema, then preprocess
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
    cons := [];
    for s in sys[1..nops(sys)-1] do
        cons := [op(cons), op(andSplit(s))];  
    od;  
    goal := sys[nops(sys)];
    if has(goal, `&and`) or has(goal, `&or`) then
        error(`The proof goal should not contain logical &and or logical &or`);
    elif op(0, goal) = `&not` then
        goal := op(goal);
        gLhs := lhs(goal); # reverse them
        gRhs := rhs(goal);
    else
        error(`the last assertion should be the goal and expressed in &not format`);
    fi;
    local relop, res;
    relop = op(0, goal);
    if relop = `<=` then
        goal := (gLhs-gRhs) <= 0;
        res := yprove(goal, cons);
        if res = true then
            print(`The inequality holds.`);
        else:
            print(`The inequality does not hold.`);
        fi;
    elif relop = `<` then
        goal := (gLhs-gRhs) <= 0;
        res := yprove(goal, cons);
        if res = true then           
            goal := (gLhs-gRhs) = 0;
            newEqs := [goal, op(cons)];
            res := sample(newEqs, vars);
        elif res = false then
            print(`The inequality does not hold.`);
        fi;
    elif relop = `=` then 
        # check feasibility of goal != 0
        goal := (gLhs-gRhs) <> 0;
        newEqs := [goal, op(cons)];
        sample(newEqs, vars); 
    else
        error(`Invalid formula`, goal);
    fi;
    return;
end proc:

# EOC of prove
