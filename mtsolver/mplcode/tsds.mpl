print("Copyright(C) 2005-2010 by Lu YANG and Yong YAO");
print([restsds,tsds,newtsds,sds,sds0,Horner,qusqr,psqrfree,newton,homog,newsds,newsds0]);
 
 with(combinat):
 with(numapprox):

 restsds:=proc(poly)
 local TT,ti,F,var,coe,curve,j,dis,coedis,xiajie,d,k,F0:
     ti:=time():
     var:=[op(indets(poly))]:
     k:=nops(var):
     if k=1 then newtsds(poly)
     else
        if degree(poly)=ldegree(poly) then 
            F:=subs(var[1]=1,poly):         
        else
            F:=poly:
            var:=[V,op(var)]:
            k:=k+1:
        fi:     
        d:=degree(F):
        F0:=F+T*(1+sum(var[i],i=2..k))^d: print(%):
        curve:=product(var[i],i=2..k)*F0:
        for j to k-1 do
            dis:=discrim(curve,var[j+1]):
            coedis:=coeff(curve,var[j+1],degree(curve,var[j+1]))*dis:
            curve:=delp(psqrfree(coedis)):            
        od:
        #print(%):
        if subs(T=0,curve)=0 then curve:=curve/T fi:
        xiajie:=xiabound(curve,T):print(`Rootbound`,%):
        F0:=subs(T=xiajie,F0):
        F0:=homog(F0,var[1]):
        newtsds(F0):
     fi:
     time()-ti:
end:



# cancel nonnegative factors of polys
delp:=proc(f)
local Ff,i,nc,var,coesig,L,nL;
    Ff:=factor(f);
    var:=[op(indets(Ff))];
    if type(Ff,`*`)=true then nc:=nops(Ff);
       L:=[];
       for i to nc do 
           coesig:=map(signum,[coeffs(op(i,Ff),var)]);
           if has(-1,coesig)=true or nops(coesig)=1 then 
              L:=[op(L),op(i,Ff)];
           fi;
       od;
       nL:=nops(L);
       product(L[j],j=1..nops(L)); 
     else 
        RETURN(Ff);    
     fi;     
end:


# cancel square factors of polys
psqrfree:=proc(f)
local L,nL;
   L:=sqrfree(f);
   nL:=nops(L[2]);
   product(L[2][i][1],i=1..nL);
end:

# compute lower bound of the smallest positive root of a polynomial
xiabound := proc(f, x)
local r, d, c, p, i, j, s, rr;
      if not type(x,name) then
        error "2nd argument must be a name"
       end if;
      p := expand(f);
      d := degree(p,x);
      p := expand(x^d*subs(x=1/x,p));
      if d = 0 or p = 0 then
        return 1
       end if;
      c := coeff(p,x,d);
      p := map(abs,taylor(p-c*x^d,x,d+1));
      c := abs(c);
     r := 1;
     i := 0;
     while signum(c*r^d-subs(x = r,p)) <= 0 do
       r := 2*r;
       i := i+1
       end do;
     s := r;
     i := min(i,3);
     for j to i do
       s := 1/2*s;
       rr := r-s;
       if signum(subs(x = rr,p)-c*rr^d) < 0 then
         r := rr
         end if
       end do;
     1/r;
end proc:

     
###########################################################################################################

 
newtsds:=proc(poly)
local polys,gosds,i,t,gon,tim,n1,test,F,var,kk;
    t:=time():
    if degree(poly)<>ldegree(poly) then 
        print(`This polynomial is not homonegeous!`):
        print(`Homonegeous transformation`):
        F:=homog(poly):
    else
        F:=poly:
    fi:
    var:=[op(indets(F))]:
    test:=newton(F,var):
    if test[1]=-1 then 
        print(`output a counter-example`):
        print(test[2]):
        print(time()-t,`second`):
        print(`The form is not positive semi-definite`):
        RETURN(false):
    else 
    polys:=qusqr(F):
    if polys=1 then 
    print(factor(poly)):
    print(time()-t,`second`):
    print(`The form is positive semi-definite`):
    RETURN(true):
    elif polys=-1 then
    print(time()-t,`second`):
    print(`The form is not positive semi-definite`):       
    RETURN(false):
    else
    print(`The times newsds runs`,1):
    gosds:=newsds([polys,var],var):
    tim:=time():
    n1:=nops(gosds):
    print([n1],[time()-t]):
    for i while gosds<>[] and has(False,gosds)<>true  do 
        print(`The times newsds runs`,i+1):
        gosds:=newsds(gosds,var)-i+i:#print(%):
        gon:=nops(gosds):
        tim:=time()-tim:
        print([gon], [tim]):
        tim:=time():
    od;
    print(time()-t,`second`):
    if gosds=[] then print(`The form is positive semi-definite`):
            RETURN(true):
        else  print(`The form is not positive semi-definite`):
            print(`output a counter-example`):
            member(False,gosds,`kk`):
            print(var):
            if kk=1 then print(gosds[kk+1]):
            else print(gosds[kk-1]):
            fi:
            RETURN(false):
    fi:
    fi:
    fi:
end:
     
 
newsds := proc(polys, var)
    local ps,np,gs,i,vs:
    ps:=polys:
    np := nops(ps):
    if np = 2 and type(ps[1], polynom) = true then
        gs := newsds0(ps, var):
        if gs = [] then
            RETURN([])
        fi
    else  
        gs:=[]:          
        for i while has(False,gs)<>true and i<=np do
            gs:=[op(gs),op(newsds0(ps[i],var))]:
        od
    fi:
    RETURN(gs):
end:
 
 
newsds0 := proc(poly, var)
    local po, id, vs, nv, per, hr, np, fs, nf, hs, vv, i, nh, mp:
    local t, n1, n2, fstemp, hrtemp, test, pova, hrva, hst:
    local k, j:
    po := poly[1]:
    pova := poly[2]:
    id := var:        
    vs := [op(id)]:   
    nv := nops(vs):
    if type(po, symmfunc(op(id))) = true then 
        print(`It is symmetric`):
        hr := Horner(po,vs):
        hrva := subs(seq(vs[k]=t[k]/k+vs[k+1],k=1..nv-1),vs[nv]=t[nv]/nv,[hr,pova]):
        hr := expand(hrva[1]):
        hrva := [hr,hrva[2]]: 
        if nargs=3 then 
            hrva := subs(seq(t[j]=vs[j], j=1..nv), hrva);            
            print(hrva) 
        fi:         
        mp := map(signum,[coeffs(hr)]): 
        n1 := nops(mp):
        if has(-1,mp)=true then
            hrva := subs(seq(t[j]=vs[j],j=1..nv),hrva):
            test := newton(hrva[1],vs):
            if test[1] = -1 then 
                RETURN([subs(test[2],hrva[2]),False]):
            else 
                RETURN([hrva]) 
            fi:   
        else 
            RETURN([])
        fi
    else 
        per:=permute(nv):
        np:=nops(per):     
        fs:=[]:
        fstemp:=[]:
        for i to np do
            hr:=subs({seq(vs[k]=vs[per[i][k]],k=1..nv)},[po,pova]):
            hrtemp:=subs({seq(vs[k]=vs[per[i][k]],k=1..nv)},po):
            if has(hrtemp,fstemp)<>true then 
                fs:=[op(fs),hr];
                fstemp:=[op(fstemp),hrtemp]:
            else fs:=fs: fstemp:=fstemp:
            fi:
        od:
        nf:=nops(fs): 
        hs:=[]:
        hst:=[]: 
        for i while has(hs,False)<>true and i<=nf do
            hr:=fs[i][1]:
            hr:=Horner(hr,vs):
            hrva:=subs(seq(vs[k]=t[k]/(k)+vs[k+1],k=1..nv-1),vs[nv]=t[nv]/nv,[hr,fs[i][2]]):
            hr:=expand(hrva[1]):
            hrva:=[hr,hrva[2]]:
            if nargs=3 then 
                hrva:=subs(seq(t[j]=vs[j],j=1..nv),hrva);            
                print(hrva) 
            fi: 
            mp:=map(signum,[coeffs(hr)]):
            n1:=nops(mp):
            if has(-1,mp)=true then           
                hrva:=subs(seq(t[j]=vs[j],j=1..nv),hrva):
                test:=newton(hrva[1],vs):
                if test[1]=-1 then 
                RETURN([subs(test[2],hrva[2]),False]):
                else 
                if has(hrva[1],hst)<>true then 
                    hs:=[op(hs),hrva]:
                    hst:=[op(hst),hrva[1]]:
                    else  hs:=hs: hst:=hst:
                fi:
                fi;
            fi
        od:
        RETURN(hs); 
    fi 
    end:    
    
##########################################
## NOTE that tsds assume the variable is nonnegative
tsds := proc(poly)
    local polys,gosds,i,t,gon,tim,n1,test,F,var,kk;
    t:=time():
    if degree(poly)<>ldegree(poly) then 
        print(`This polynomial is not homonegeous!`):
        print(`Homonegeous transformation`):
        F:=homog(poly):
    else
        F:=poly:
    fi:
    var:=[op(indets(F))]:
    test:=newton(F,var):
    if test[1]=-1 then 
        print(`output a counter-example`):
        print(test[2]):
        print(time()-t,`second`):
        print(`The form is not positive semi-definite`):
        RETURN(false):
    else 
    polys:=qusqr(F):
    if polys=1 then 
        print(factor(poly)):
        print(time()-t,`second`):
        print(`The form is positive semi-definite`):
        RETURN(true):
    elif polys=-1 then
        print(time()-t,`second`):
        print(`The form is not positive semi-definite`):       
        RETURN(false):
    else
        print(`The times sds runs`,1):
        gosds:=sds([polys,var],var):
        tim:=time():
        n1:=nops(gosds):
        print([n1],[time()-t]):
    for i while gosds<>[] and has(False,gosds)<>true  do 
        print(`The times sds runs`,i+1):
        gosds:=sds(gosds,var)-i+i:#print(%):
        gon:=nops(gosds):
        tim:=time()-tim:
        print([gon], [tim]):
        tim:=time():
    od;
    print(time()-t,`second`):
    if gosds=[] then print(`The form is positive semi-definite`):
            RETURN(true):
        else  print(`The form is not positive semi-definite`):
            print(`output a counter-example`):
            member(False,gosds,`kk`):
            print(var):
            if kk=1 then print(gosds[kk+1]):
            else print(gosds[kk-1]):
            fi:
            RETURN(false):
    fi:
    fi:
    fi:
end:
     
 
sds:=proc(polys,var)
    local ps,np,gs,i,vs:
    ps:=polys:
    np:=nops(ps):
    if np=2 and type(ps[1],polynom)=true  then 
        gs:=sds0(ps,var):
        if gs=[] then 
            RETURN([]):
        fi
    else  
        gs:=[]:          
        for i while has(False,gs)<>true and i<=np do
            gs:=[op(gs),op(sds0(ps[i],var))]:
        od
    fi:
    RETURN(gs):
end:

 
sds0:=proc(poly,var)
    local po,id,vs,nv,per,hr,np,fs,nf,hs,vv,i,nh,mp,t,n1,n2,fstemp,hrtemp,test,pova,hrva,hst:
    local k, j:
    po:=poly[1]:
    pova:=poly[2]:
    id:=var:        
    vs:=[op(id)]:   
    nv:=nops(vs):
    if type(po,symmfunc(op(id)))=true then 
        print(`It is symmetric`):
        hr:=Horner(po,vs):
        hrva:=subs(seq(vs[k]=t[k]+vs[k+1],k=1..nv-1),vs[nv]=t[nv],[hr,pova]):
        hr:=expand(hrva[1]):
        hrva:=[hr,hrva[2]]: 
        if nargs=3 then 
            hrva:=subs(seq(t[j]=vs[j],j=1..nv),hrva);            
            print(hrva) 
        fi:         
        mp:=map(signum,[coeffs(hr)]): 
        n1:=nops(mp):
        if has(-1,mp)=true then
            hrva:=subs(seq(t[j]=vs[j],j=1..nv),hrva):
            test:=newton(hrva[1],vs):
            if test[1]=-1 then 
            RETURN([subs(test[2],hrva[2]),False]):
            else 
            RETURN([hrva]) 
            fi:   
        else 
            RETURN([])
        fi
    else per:=permute(nv):
        np:=nops(per):     
        fs:=[]:
        fstemp:=[]:
        for i to np do
            hr:=subs({seq(vs[k]=vs[per[i][k]],k=1..nv)},[po,pova]):
            hrtemp:=subs({seq(vs[k]=vs[per[i][k]],k=1..nv)},po):
            if has(hrtemp,fstemp)<>true then 
                fs:=[op(fs),hr];
                fstemp:=[op(fstemp),hrtemp]:
            else fs:=fs: fstemp:=fstemp:
            fi:
        od:
        nf:=nops(fs): 
        hs:=[]:
        hst:=[]: 
        for i while has(hs,False)<>true and i<=nf do
            hr:=fs[i][1]:
            hr:=Horner(hr,vs):
            hrva:=subs(seq(vs[k]=t[k]+vs[k+1],k=1..nv-1),vs[nv]=t[nv],[hr,fs[i][2]]):
            hr:=expand(hrva[1]):
            hrva:=[hr,hrva[2]]:
            if nargs=3 then 
                hrva:=subs(seq(t[j]=vs[j],j=1..nv),hrva);            
                print(hrva) 
            fi: 
            mp:=map(signum,[coeffs(hr)]):
            n1:=nops(mp):
            if has(-1,mp)=true then           
                hrva:=subs(seq(t[j]=vs[j],j=1..nv),hrva):
                test:=newton(hrva[1],vs):
                if test[1]=-1 then 
                RETURN([subs(test[2],hrva[2]),False]):
                else 
                if has(hrva[1],hst)<>true then 
                    hs:=[op(hs),hrva]:
                    hst:=[op(hst),hrva[1]]:
                    else  hs:=hs: hst:=hst:
                fi:
                fi;
            fi
        od:
        RETURN(hs); 
    fi 
end: 

 
# convert polynomial to Horner form
Horner:=proc(poly,vars)
    local po,vs,nv,i:
    po:=poly:
    vs:=vars:
    po:=convert(po, horner, vars);
    RETURN(po)
end:
 
# cancel square factors of polys 
qusqr:=proc(f)
    local sqr,g,n,L,i,temp1,temp2;
    sqr:=sqrfree(f);
    g:=sqr[2];
    n:=nops(g);
    L:=signum(sqr[1]);
    for i to n do 
        temp1:=g[i][2];
        if  temp1 mod 2=0 then  
            temp2:=1;
        else 
            temp2:=g[i][1];
        fi;
        L:=L*temp2;
    od;
    RETURN(L);
end:
 
# compute the Newton polygon of a polynomial
newton:=proc(f,var)
    local nvar,A,i,j,T,S,lcoe,f1,rb,f1var,simp,po,coes:
    nvar:=nops(var):
    A:=choose(nvar,nvar-1):
    for i to nvar do           
        T:=A[i]:
        S:=[seq(var[T[j]]=1,j=1..nvar-1)]:
        f1:=sort(subs(S,f)):
        if nops(indets(f1))<>0 then 
            lcoe:=lcoeff(f1):
            f1var:=op(indets(f1)):
            if signum(lcoe)=-1 then
                rb:=rootbound1(f1,f1var):
                RETURN([-1,[op(S),f1var=rb]]):
            fi:
        fi:
        od:
    RETURN(f):      
end:
 
 
# make polynomial homogeneous
# can specify new variable, default variable is V (capital)
homog:=proc(f)
    local var,i,n,varseq,V;
    var:=[op(indets(f))]:
    n:=nops(var):
    if nargs=1 then 
       varseq:={seq(var[i]=var[i]/V,i=1..n)};
    fi:
    if nargs=2 then 
       varseq:={seq(var[i]=var[i]/args[2],i=1..n)};
    fi;
    numer(subs(varseq,f));
end:

# compute upper bound of the largest root of a polynomial
rootbound1 := proc(f, x)
    local r, d, c, p, i, j, s, rr;
    if not type(x,name) then
        error "2nd argument must be a name"
    end if;
    p := expand(f);
    d := degree(p,x);
    if d = 0 or p = 0 then
        return 1
    end if;
    c := coeff(p,x,d);
    p := map(abs,taylor(p-c*x^d,x,d+1));
    c := abs(c);
    r := 1;
    i := 0;
    while signum(c*r^d-subs(x = r,p)) <=0  do
        r := 2*r;
        i := i+1
    end do;
    s := r;
    i := min(i,3);
    for j to i do
        s := 1/2*s;
        rr := r-s;
        if signum(subs(x = rr,p)-c*rr^d) <0 then
            r := rr
        end if
    end do;
    r
end proc:

prove := proc(polys, vars)
    # by default, the last poly is the polynomial to be proved
    local result, concl, expr, i, l, r:
    print(`start to prove`):
    # require all vars is nonnegative, chech whether it is in polys
    for i to nops(vars) do
        if not has(polys, vars[i] >= 0) and not has(polys, vars[i] > 0) then
            print(`Negative variable exists!`, vars[i]):
            print(`The poly cannot be proved by sds-based method`):
            return(false):
        fi:
    od:
    concl := polys[-1]:
    expr := op(concl):
    if not has(op(0, concl), `&not`) or not hastype(expr, `<=`) then
        print(`The poly format is illegal`):
        print(`The poly cannot be proved by sds-based method`):
        return(false):
    else
        l, r := op(expr):
        result := tsds(r - l):
        if result = false then
            print(`The poly cannot be proved by sds-based method`):
            return(false):
        else
            print(`The poly is proved to be sum-of-squares by sds-based method`):
            return(true):
        fi:
    fi:
end proc:


# prove([(a > 0), (b > 0), (c > 0), (((a ^ 2) + (b ^ 2)) = (2 * a * b)),&not(((2 * (a ^ 2) * (b ^ 3)) <= ((a ^ 2) + (b ^ 6))))], [b,a]);
# prove([(0 <= a),(0 <= b),(0 <= c),&not((((a + b + c) ^ 3) <= ((3 + (a ^ 5) + ((-1) * (a ^ 2))) * (3 + (b ^ 5) + ((-1) * (b ^ 2))) * (3 + (c ^ 5) + ((-1) * (c ^ 2))))))], [a,b,c]);
# prove([(0 <= a),(0 <= b),(0 <= c),((a * b * c) = 1),&not((((1 / sqrt((1 + (8 * a)))) + (1 / sqrt((1 + (8 * b)))) + (1 / sqrt((1 + (8 * c))))) <= 2))], [a,b,c]);
