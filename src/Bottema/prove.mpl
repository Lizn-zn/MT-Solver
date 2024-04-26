with(RegularChains):
with(SemiAlgebraicSetTools):
read("./src/Bottema/utils.mpl"):

####################################
# Main class
####################################

qe := proc(ineqs):
    local neq, sys, num, qeRes;
    sys := [];
    for neq in ineqs do
        num := nops(neq);
        if num = 1 then
            sys := [op(sys), neq[1]];
        else
            print(op(neq));
            # do quantifier eliminate
            if num = 2 or num = 3 then
                qeRes := QuantifierElimination(op(neq));
                if qeRes = false then
                    return [];
                else
                    sys := [op(sys), qeRes];
                fi;
            else
                print(`Invalid formula`);
                print(neq);
                return;
            fi;
        fi;
    od;
    return sys;
end proc:

# EOC of qe

prove := proc(ineqs, vars)
    local R, sys, res;
    local i, clause;

    # merge all ineqs by `&and``
    sys := qe(ineqs);
    if sys = [] then
        print(`The inequality holds.`);
        return false, [];
    fi;
    sys := foldl(`&and`, sys[1], op(sys[2..nops(sys)]));
    res := QuantifierElimination(sys, output='rootof');
    # if unsat, return
    if res = false then
        print(`The inequality holds.`);
        return false, [];
    else
        # if sat, give counter example
        R := PolynomialRing(vars);
        for clause in orSplit(res) do
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

