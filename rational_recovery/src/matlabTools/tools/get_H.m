function str_H = get_H(n, strh, str_mul, str_R, str_constr, type, config)

x = sym('x', [1, n]);
strh = sym_format(strh);
sym_h = str2sym(strh);

str_R = sym_format(str_R{1});
sym_R = str2sym(str_R);

H = 0;

for i = 1:length(str_mul)
    new_str_mul = sym_format(str_mul{i});

    sym_mul = str2sym(new_str_mul);

    new_str_constr = rational_approximate(n, str_constr{i}, config.DENOMINATOR_UPPER);

    new_str_constr = sym_format(new_str_constr);
    sym_constr = str2sym(new_str_constr);

    H = H + sym_mul * sym_constr;
    % sym_mul
    % sym_constr
end

if type == config.INIT_TYPE
    H = -sym_h * (1 + sym_R) - H;
else
    H = sym_h * (1 + sym_R) - H;
end
H = expand(H);
str_H = string(H);
end