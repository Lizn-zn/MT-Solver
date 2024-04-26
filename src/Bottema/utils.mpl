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
