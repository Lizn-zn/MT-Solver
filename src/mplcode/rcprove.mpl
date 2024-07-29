(*
###########################################
# Main class
# Prove inequalities by RegularChains package
# Use example:
#   prove([[(0 < p)],[(p < 15)],[(p <= x)],[(x <= 15)],
          [ &not((15 <= (((x - p)^2) + ((x - 15)^2) + ((x - (p + 15))^2)^(1/2))))]], [p,x]);
###########################################
*)

prove := proc(ineqs, vars)
    local newEqs, preRes;
    newEqs := preprocess(ineqs);
    local R, sys, qeRes;
    # merge all ineqs by `&and``
    sys := qe(newEqs);
    if sys = [] then
        print(`The inequality holds.`);
        return false, [];
    fi;
    sys := foldl(`&and`, sys[1], op(sys[2..nops(sys)]));
    qeRes := QuantifierElimination(sys);
    # if unsat, return
    if qeRes = false then
        print(`The inequality holds.`);
        return false, [];
    else
        # if sat, give counter example
        local i, clause, res;
        R := PolynomialRing(vars);
        for clause in orSplit(qeRes) do
            res := SamplePoints(andSplit(clause), R, output='list');
            if res <> [] then
                res := BoxValues(res[1]);
                print(`output a counter example`);
                print(res);
                print(`The inequality does not hold.`);
                return true, res;
            fi;
        od;
        print(`Some error occurs`);
        return false, [];
    fi;
end proc:

# EOC of prove