# Example with more complex expression handling
# Example with more complex expression handling
# extractPolynomials := proc(expr)
#     local polys, e;
#     polys := [];
#     for e in [op(expr)] do
#         if type(e, 'relation') then
#             polys := [op(polys), lhs(e)-rhs(e)];
#         end if;
#     end do;
#     return polys;
# end proc;


# # Use the procedure on a complex expression
# complexExpr := (x^2 + y^2 = 1) &and (x^2 - y^2 <= 0);
# expr := [x^2 + y^2 = 1, x^2 - y^2 <= 0];
# qeRes := QuantifierElimination(expr);
# polynomialParts := extractPolynomials(complexExpr);
# vars_fac:=indets(polynomialParts);
# print(vars_fac);
# x:=nops(vars_fac);


# extractPolynomials := proc(expr)
#     local polys, extract;
#     polys := [];

#     # 定义递归提取多项式的内部过程
#     extract := proc(e)
#         local sub_expr;
#         if type(e, 'relation') then
#             # 对于关系表达式，将其转换为多项式形式
#             polys := [op(polys), lhs(e) - rhs(e)];
#         elif type(e, 'function') and op(0, e) in {`and`, `or`, `not`, `&and`, `&or`, `&not`} then
#             # 对于逻辑运算符，递归提取子表达式
#             for sub_expr in [op(e)] do
#                 extract(sub_expr);
#             end do;
#         elif type(e, 'list') or type(e, 'set') then
#             # 对于集合或列表，递归提取子表达式
#             for sub_expr in e do
#                 extract(sub_expr);
#             end do;
#         end if;
#     end proc;

#     # 开始提取多项式
#     extract(expr);

#     return polys;
# end proc:

# # 示例
# expr := (a^2 - 2*a*b + b^2 = 0) &and (&not (-b^6 + 2*a^2*b^3 - a^2 <= 0));
# polynomials := extractPolynomials(expr);

# print(polynomials);

# extractProjectionPolynomials := proc(projectionResult)
#     local polys, i, sublist;

#     polys := [];

#     for i to nops(projectionResult) do
#         sublist := projectionResult[i][1];  # 获取多项式列表
#         polys := [op(polys), op(sublist)];  # 将多项式添加到结果中
#     end do;

#     return polys;
# end proc:

# # 
# projectionResult := [[[b^3 - b^2 - b - 1], [1]], [[b - 1], [1]], [[b], [1]]];
# polynomials := extractProjectionPolynomials(projectionResult);

# print(polynomials);
# 定义复杂的多项式集合

cad_polys := [
    -z, 
    -y, 
    -x, 
    x + y + z - 1, 
    ((2*z - 1)*y - z)*x - y*z, 
    -189 + 729*((-2*z + 1)*y + z)*x + 729*y*z
];

# 定义多项式环
R_1 := PolynomialRing([x, y, z]);

# 执行投影并检查结果
nlsatRes := Projection(cad_polys, 2, R_1);

# 获取详细信息
detailedInfo := DetailedInfo(nlsatRes, R_1);

# 打印详细信息
print("详细投影结果：", detailedInfo);

# 提取多项式的函数
extractPolynomialsFromConstructibleSet := proc(info)
    local polys, i, part;

    polys := [];

    for i to nops(info) do
        part := info[i];
        if type(part, 'list') then
            for j to nops(part) do
                if type(part[j], 'relation') or type(part[j], 'polynom') then
                    polys := [op(polys), part[j]];
                elif type(part[j], 'list') then
                    for k to nops(part[j]) do
                        if type(part[j][k], 'relation') or type(part[j][k], 'polynom') then
                            polys := [op(polys), part[j][k]];
                        end if;
                    end do;
                end if;
            end do;
        end if;
    end do;

    return polys;
end proc:

# 提取多项式
polynomials := extractPolynomialsFromConstructibleSet(detailedInfo);

# 打印提取的多项式
print("提取的多项式：", polynomials);

