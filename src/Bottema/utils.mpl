####################################
# The following funs are utils
####################################
orSplit := proc(expr)
    local terms;
    if has(expr, `&or`) then
        terms := [op(expr)];
    else
        terms := [expr];
    fi;
    return terms;
end proc:

andSplit := proc(expr)
    local terms;
    if has(expr, `&and`) then
        terms := [op(expr)];
    else
        terms := [expr];
    fi;
    return terms;
end proc:

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
