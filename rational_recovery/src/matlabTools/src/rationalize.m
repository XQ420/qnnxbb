
for i = 1:length(example.CG_init)
    cg = example.CG_init{i};
    for j = 1:length(cg.mul)
        str_mul = sdisplay(cg.mul{j});
        str_mul = str_mul{1};
        str_mul = rational_approximate(example.n, str_mul, config.DENOMINATOR_UPPER);
        str_mul = sdp_format(str_mul);
        cg.mul_str{j} = str_mul;
        cg.mul{j} = eval(str_mul);
        
    end
    example.CG_init{i} = cg;
end

for i = 1:length(example.CG_uns)
    cg = example.CG_uns{i};
    for j = 1:length(cg.mul)
        str_mul = sdisplay(cg.mul{j});
        str_mul = str_mul{1};
        str_mul = rational_approximate(example.n, str_mul, config.DENOMINATOR_UPPER);
        str_mul = sdp_format(str_mul);
        cg.mul_str{j} = str_mul;
        cg.mul{j} = eval(str_mul);
    end
    example.CG_uns{i} = cg;
end
