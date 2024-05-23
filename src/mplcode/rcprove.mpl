(*
###########################################
# Main class
# Prove inequalities by RegularChains package
# Use example:
#   prove([[(0 < p)],[(p < 15)],[(p <= x)],[(x <= 15)],
          [ &not((15 <= (((x - p)^2) + ((x - 15)^2) + ((x - (p + 15))^2)^(1/2))))]], [p,x]);
###########################################
*)

PerformProjectionStep := proc(ineqs,vars)
    local  proj_depth, R, qeRes, vars_fac, projs_fac;
    local newEqs, sys;
    newEqs := preprocess(ineqs);
    sys := qe(newEqs);
    if sys = [] then
        print(`The inequality holds.`);
        return false, [];
    fi;
    sys := foldl(`&and`, sys[1], op(sys[2..nops(sys)]));
    # var_rem := select(x -> x <> var, vars);
    R := PolynomialRing(vars);
    proj_depth := nops(vars)-1;
    qeRes:=Projection(sys,proj_depth,R);
    # vars_fac:=indets(qeRes);
    # avoid fracs
    Info(qeRes,R);
    Display(qeRes,R);
    # projs_fac:=map(x->expand(denom(x) * x), qeRes); 
    # writestat(poly_dir,[projs_fac,vars_fac]);
    # return var_rem, projs_fac, proj_depth
    # Info(projs_fac,R);
    # return projs_fac;
    return
end proc:


prove := proc(ineqs, vars)
    local newEqs, preRes;
    newEqs := preprocess(ineqs);
    local R, sys, qeRes,polys;
    # merge all ineqs by `&and``
    sys := qe(newEqs); # line by line 
    if sys = [] then
        print(`The inequality holds.`);
        return false, [];
    fi;
    sys := foldl(`&and`, sys[1], op(sys[2..nops(sys)]));
    # qeRes := QuantifierElimination(sys);
    print(sys);
    polys := extractPolynomials(sys);
    local proj_depth, vars_fac, vars_fac_list, tmp_R;
    vars_fac:=indets(polys);
    proj_depth := nops(vars_fac)-1;
    print(polys);
    print(`proj_flag`, proj_depth);
    vars_fac_list := convert(vars_fac, list);
    tmp_R:= PolynomialRing(vars_fac_list);
    qeRes:=Projection(polys,proj_depth,tmp_R);
    print(Info(qeRes, tmp_R));
    if proj_depth <> 1 then
        print(`Projection steps are not finished.`);
        print(Info(qeRes, tmp_R));
        return false, [];
    fi;
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
