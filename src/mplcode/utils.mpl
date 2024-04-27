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
                print(`Invalid formula`);
                print(neq);
                done;
            fi;
        fi;
    od;
    return sys;
end proc:
# EOC of qe