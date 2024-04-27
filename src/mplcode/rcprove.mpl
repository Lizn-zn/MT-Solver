(*
###########################################
# Main class
# Prove inequalities by RegularChains package
# Use example:
#   prove([[(0 < p)],[(p < 15)],[(p <= x)],[(x <= 15)],
          [ &not((15 <= (((x - p)^2) + ((x - 15)^2) + ((x - (p + 15))^2)^(1/2))))]], [p,x]);
###########################################
*)

with(RegularChains):
with(SemiAlgebraicSetTools):
read("./src/mplcode/utils.mpl"):

preprocess := proc(ineqs, vars):
    # preprocess the input ineqs
    local neq, f; 
    local fNew, t1, t2; # two temp vars
    local newIneqs;
    local auxIneqs, auxVars; 
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
            # handle the fraction
            t2 := fracElim(t2);
            # handle the radical
            t2, auxIneqs, auxVars := radElim(t2);
            if hastype(t1, `<`) then
                fNew := subs(t1=(t2<0), fNew);
            elif hastype(t1, `<=`) then
                fNew := subs(t1=(t2<=0), fNew);
            elif hastype(t1, `=`) then
                fNew := subs(t1=(t2=0), fNew);
            else:
                print(`Invalid formula`);
                print(f);
                done;
            fi;
            fNew := foldl(`&and`, fNew, op(auxIneqs));
        if auxVars = [] then
            if nops(neq) = 1 then
                neq[1] := fNew;
            elif nops(neq) = 2 then
                neq[2] := fNew;
            elif nops(neq) = 3 then
                neq[3] := fNew;    
            else
                print(`Invalid formula`);
                done;
            fi;    
        else
            if nops(neq) = 1 then
                neq := [parse(cat(`&E(`, auxVars, `)`)), fNew];
            elif nops(neq) = 2 then
                if has(neq[1], `&E`) then
                    auxVars := [op(auxVars), op(op(neq[1]))];
                    neq := [parse(cat(`&E(`, auxVars, `)`)), fNew];
                else
                    neq := [parse(cat(`&E(`, auxVars, `)`)), neq[1], fNew];
                fi;
            elif nops(neq) = 3 then
                if has(neq[1], `&E`) then
                    auxVars := [op(auxVars), op(op(neq[1]))];
                    neq := [parse(cat(`&E(`, auxVars, `)`)), neq[2], fNew];
                elif has(neq[2], `&E`) then
                    auxVars := [op(auxVars), op(op(neq[2]))];
                    neq := [neq[1], parse(cat(`&E(`, auxVars, `)`)), fNew];
                fi;
            else
                print(`Invalid formula`);
                done;
            fi;
        fi;
        od;
        newIneqs := [op(newIneqs), neq];
    od;
    return newIneqs, vars;
end proc:

prove := proc(ineqs, vars)
    local newEqs, newVars, preRes;
    newEqs, newVars := preprocess(ineqs, vars);
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

