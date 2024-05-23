(*
###########################################
# Main class
# Prove inequalities by RegularChains package
# Use example:
#   prove([[(0 < p)],[(p < 15)],[(p <= x)],[(x <= 15)],
          [ &not((15 <= (((x - p)^2) + ((x - 15)^2) + ((x - (p + 15))^2)^(1/2))))]], [p,x]);
###########################################
*)

# single step projection of polys
poly_proj = proc(sys, vars, next_var, poly_dir):
    local var_rem, proj_depth, R;
    var_rem := select(x -> x <> var, vars);
    R := PolynomialRing(vars);
    proj_depth = nops(vars)-1;
    qeRes:=Projection(sys,proj_depth,proj_R);
    vars_fac:=indets(qeRes)
    projs_fac:=map(x->expand(denom(x) * x), qeRes):
    writestat(poly_dir,[projs_fac,vars_fac]);
    return var_rem, projs_fac, proj_depth
end proc:


prove := proc(ineqs, vars, next_var, tmp_poly)
    local newEqs, preRes, var_rem;
    newEqs := preprocess(ineqs);
    local R, sys, qeRes, proj_depth;
    # merge all ineqs by `&and``
    sys := qe(newEqs); # line by line 
    if sys = [] then
        print(`The inequality holds.`);
        return false, [];
    fi;
    sys := foldl(`&and`, sys[1], op(sys[2..nops(sys)]));
    var_rem, qeRes,proj_depth := poly_proj(sys,vars,next_var,tmp_poly)
    # qeRes := QuantifierElimination(sys);
    # if unsat, return
    if qeRes = false then
        print(`The inequality holds.`);
        return false, [];
    elif proj_depth = 1 then
        return 'indets', qeRes
    else
        # if sat, give counter example
        local i, clause, res;
        # R := PolynomialRing(vars);
        R := PolynomialRing(var_rem);
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
