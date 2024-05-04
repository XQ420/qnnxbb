for i = 1:length(example.CG_init)
    cg = example.CG_init{i};
    for j = 1:length(cg.constr)
        [cg.mul{end + 1}, cg.mul_para{end + 1}, cg.mul_var{end + 1}] = polynomial(x, cg.m);
    end
    example.CG_init{i} = cg;
end

for i = 1:length(example.CG_uns)
    cg = example.CG_uns{i};
    for j = 1:length(cg.constr)
        [cg.mul{end + 1}, cg.mul_para{end + 1}, cg.mul_var{end + 1}] = polynomial(x, cg.m);
    end
    example.CG_uns{i} = cg;
end
