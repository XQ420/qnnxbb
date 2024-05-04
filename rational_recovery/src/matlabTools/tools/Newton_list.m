function [ans] = Newton_list(f, monos, L, max_iter,tol1, tol2, indets)
tic;

Digits = 50;
digits(Digits);
mv = monos;
k = size(L, 2);
m = size(L, 1);

sL = sym(zeros(m, k));
L_exact = sym(zeros(m, k));

k_i = 0;
M_u = sym(zeros(m, k));
q = [];
v_temp = [];
for j = 1:k
    for i = 1:m
        if abs(L(i,j)) >= tol1
            k_i = k_i + 1;
            M_u(i,j) = sym("q" + string(k));
            q = [q, M_u(i, j)];
            sL(i,j) = sym(round(L(i, j), floor(Digits/2)), "r");
            L_exact(i,j) = sym(round(L(i, j), Digits*2), "r");
            v_temp = [v_temp, L(i,j)];
        end
    end
end

v_float = arrayfun(@(x) sym(round(x, floor(Digits/2)), "r"), v_temp);
%v_exact = arrayfun(@(x) sym(round(x, Digits*2), "r"), v_temp);
v_exact = [];
B = 50;
for i = 1:length(v_temp)
    integerPart = fix(v_temp(i));
    decimalPart = num2str(round(mod(v_temp(i), 1), B), B);
    decimalPart = decimalPart(3:end);
    while strlength(decimalPart) < B
        decimalPart = decimalPart + "0";
    end
    str = decimalPart + "/1" + strcat('0', repmat('0', 1, B - 1));
    v_exact = [v_exact, sym(str) + integerPart];
end
v = v_float - v_exact;

%F:=Vector([coeffs(expand(f - add(j^2, j=Vector[row](mv).(sL+M_u))), indets(mv))]);
temp = mv * (sL + M_u);
add = 0;
for i = 1:length(temp)
    add = add + temp(i)^2;
end
[F, T] = coeffs(expand(f - add), indets);

% W := VectorCalculus[Jacobian](F,[seq(_q[i],i=1..k)]);
W = jacobian(F, q);

b = subs(F, q, v);

t = norm(b);

fprintf("the orginal residue without Newton iteration: %.20f\n", t);
[n_, m_] = size(W);
fprintf("the dimension of Jacobian matrix: %d, %d\n", n_, m_);
%%

iter_cnt = 0;

for i = 1:max_iter
    if t > tol2
        A = subs(W, q, v);
        digits(100);
        %b
        %A
        %v = v - (pinv(vpa(A, 100)) * vpa(b', 100))';
        %v = v - lsqminnorm(A, b', 1e-30)';
        v = v - lsqminnorm(double(A), double(b'))';
        % digits(30);
        b = subs(F, q, v);
        
        t = norm(double(b));
        iter_cnt = iter_cnt + 1;
        fprintf("|f- \\sum f_i^2| %.20f\n", t);
    else
        break;
    end
end
fprintf("\n\n=============================================\n\n");
fprintf("%d iterations, %f seconds.\n", iter_cnt, toc);
fprintf("|f- \\sum f_i^2| %.20f.\n", t);
fprintf("\n\n=============================================\n\n");

gL = subs(M_u, q, v);
ans = sL + gL;

end

