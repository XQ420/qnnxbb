function res = rational_approximate(n, s, upper, model)
    % model = 0 
    % model = 1 
if nargin < 4 % 
    model = 1;
end

x = sym('x', [1, n]);

s = sym_format(s);
sym_f = str2sym(s);
sym_f = expand(sym_f);
if ~isa(sym_f, 'sym')
    sym_f = sym(sym_f);
    model = 0;  % 
sym_f = expand(sym_f);

if model == 0

    [C, T] = coeffs(sym_f);
    
    res = 0;
    
    for i = 1:length(C)
        rounded_coefficients = round(double(C(i)), log10(upper));
        C_sym = sym(string(rounded_coefficients * upper) + "/" + string(upper));
        % 
        res = res + T(i) * C_sym;
    
    end
    %res = simplify(res);
    res = expand(res);
    res = string(res);
elseif model == 1
    [C, T] = coeffs(sym_f);
    C = double(C);
    m = length(C);

    min_v = 1e20;
    ret = [];
    Q = intvar(1);
    p = intvar(1, m);
    h = sum((C * Q - p).^2);
    opt = sdpsettings('solver', 'gurobi', 'verbose', 0);
    constr = [p <= Q * C, Q * C <= p + 1, upper >= Q, Q >= 1];
    optimize(constr, h, opt);

    min_v = value(h);
    retP = value(p);
    retQ = value(Q);
    P = sym(string(retP(1:m)) + "/" + string(retQ));
    g = expand(sum(P .* T));

    res = string(g);

end
