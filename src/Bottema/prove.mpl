with(RegularChains):
with(SemiAlgebraicSetTools):
read("./src/Bottema/utils.mpl"):

####################################
# Main class
####################################

preprocess := proc(ineqs, vars):
    local id, newIneqs, neq, f; 
    local fNew, t1, t2; # two temp vars
    newIneqs := [];
    for neq in ineqs do
        if nops(neq) = 1 then
            f := neq[1]
        elif nops(neq) = 2 then
            f := neq[2]
        elif nops(neq) = 3 then
            f := neq[3]
        else
            print(`Invalid formula`);
            print(neq);
            return;
        fi;
        fNew := f;
        for t1 in anySplit(f) do
            t2 := lhs(t1) - rhs(t1);
            if denom(t2) <> 1 then
                t2 := numer(t2)*denom(t2);
                if hastype(t1, `<`) then
                    fNew := subs(t1=(t2<0), fNew);
                elif hastype(t1, `<=`) then
                    fNew := subs(t1=(t2<=0), fNew);
                elif hastype(t1, `=`) then
                    fNew := subs(t1=(t2=0), fNew);
                else:
                    print(`Invalid formula`);
                    print(f);
                    return;
                fi;
            fi;
        if nops(neq) = 1 then
            neq[1] := fNew;
        elif nops(neq) = 2 then
            neq[2] := fNew;
        elif nops(neq) = 3 then
            neq[3] := fNew;
        else
            print(`Invalid formula`);
            print(neq);
            return;
        fi;
        od;
        newIneqs := [op(newIneqs), neq];
    od;
    print(newIneqs);
    return [newIneqs, vars];
end proc:

qe := proc(ineqs):
    local neq, sys, num, qeRes;
    sys := [];
    for neq in ineqs do
        num := nops(neq);
        if num = 1 then
            sys := [op(sys), neq[1]];
        else
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
    local newEqs, newVars, preRes;
    preRes := preprocess(ineqs, vars);
    newEqs := preRes[1];
    newVars := preRes[2];

    local R, sys, qeRes;
    # merge all ineqs by `&and``
    sys := qe(newEqs);
    if sys = [] then
        print(`The inequality holds.`);
        return false, [];
    fi;
    sys := foldl(`&and`, sys[1], op(sys[2..nops(sys)]));
    qeRes := QuantifierElimination(sys, output='rootof');
    # if unsat, return
    if qeRes = false then
        print(`The inequality holds.`);
        return false, [];
    else
        # if sat, give counter example
        local i, clause, res;
        R := PolynomialRing(newVars);
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
