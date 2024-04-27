(*
# The following funs are utils for proving
*)

(*
orSplit splits the expr into a list of terms
*)
orSplit := proc(expr)
    local terms;
    if has(expr, `&or`) then
        terms := [op(expr)];
    else
        terms := [expr];
    fi;
    return terms;
end proc:

(*
andSplit splits the expr into a list of terms
*)
andSplit := proc(expr)
    local terms;
    if has(expr, `&and`) then
        terms := [op(expr)];
    else
        terms := [expr];
    fi;
    return terms;
end proc:

(*
anySplit splits any logical connectives in the expr
*)
anySplit := proc(expr)
    local flag, term, terms, temp;
    flag := true;
    terms := [expr];
    while flag do 
        temp := [];
        flag := false;
        for term in terms do
            if has(term, `&and`) or has(term, `&or`) or has(term, `&not`) then
                temp := [op(temp), op(term)];
                flag := true;
            else
                temp := [op(temp), term];
            fi;
        od;
        terms := temp;
    od;
    return terms;
end proc:

(*
radElim to eliminate radical using a^1/k <= 0 -> aux <= 0 &and aux^k = a
*)
radElim := proc(expr)
    local rootList, r, rules; 
    local newExpr, newVars, newCons, id;
    local base, expDenom, expNumer;
    newVars := [];
    newCons := [];
    rules := [];
    id := 1;
    rootList := indets(expr, radical);
    for r in rootList do
        newVars := [op(newVars), aux||id];
        base := op(1, r);
        expDenom := denom(op(2, r));
        expNumer := numer(op(2, r));
        if type(expDenom, even) then
            newCons := [op(newCons), newVars[id] >= 0];
        fi;
        newCons := [op(newCons), newVars[id]^expDenom = base^expNumer];
        rules := [op(rules), rootList[id] = newVars[id]];
        id := id + 1;
    od;
    newExpr := subs(rules, expr); 
    return newExpr, newCons, newVars;
end proc:

(*
fracElim to eliminate fraction using a/b <= 0 -> a*b <= 0
*)
fracElim := proc(expr)
    local newExpr;
    newExpr := expr;
    if denom(expr) <> 1 then
        newExpr := numer(expr)*denom(expr);
    fi;
    return newExpr;
end proc:

(*
qe to eliminate quantifier
*)
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
                error(`Invalid formula`, neq);
                done;
            fi;
        fi;
    od;
    return sys;
end proc:

preprocess := proc(ineqs):
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
            error(`Invalid formula`, neq);
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
                error(`Invalid formula`, f);
            fi;
            fNew := foldl(`&and`, fNew, op(auxIneqs));
            if auxVars = [] then
                if nops(neq) = 1 then
                    neq[1] := fNew;
                elif nops(neq) = 2 then
                    neq[2] := fNew;
                elif nops(neq) = 3 then
                    neq[3] := fNew;   
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
                fi;
            fi;
        od;
        newIneqs := [op(newIneqs), neq];
    od;
    return newIneqs;
end proc:

sample := proc(ineqs, vars)
    local R, res;
    R := PolynomialRing(vars);
    res := SamplePoints(ineqs, R, output='list');
    # if unsat, return
    if res = [] then
        print(`The inequality holds.`);
        return;
    else
        # if sat, give counter example
        res := BoxValues(res[1]);
        print(`output a counter example`);
        print(res);
        print(`The inequality does not hold.`);
        return; 
    fi;
    error(`Some error occurs`);
end proc:
