function [ans, iter_cnt, tot_time] = Newton_refine_update(f, monos, Q, eig_tol, max_iter, tol, indets)
tic;

mv = monos;
[m, t] = size(Q);
if m ~= t || m ~= length(mv)
    error("Invalid input")
end

[L, temp] = eig(Q);
t = diag(temp);

r = 0;
k = 0;
v = zeros(1, m*m);
sL = sym(zeros(m));
q = [];

for j = 1:length(t)
    L(:,j) = L(:,j) * sqrt(t(j));
    if abs(t(j)) > eig_tol
        r = r + 1;
        for i = 1:m
            if abs(L(i,j)) > 10^(-3)
                k = k + 1;
                v(k) = real(L(i,j));
                q = [q, sym("q" + string(k))];
                sL(i,j) = q(k);
            end
        end
    end
end

fprintf("the rank deficiency of Q %.20f\n", m - r);
v = v(1:k); % ok
t = mv * sL; % ok

% F := Vector([coeffs(expand(f-add(i^2,i=t)),indets(mv))]);
add = 0;
for i = 1:length(t)
    add = add + t(i)^2;
end
new_f = expand(f - add); % 

[F, T] = coeffs(new_f, indets); % 

% W := VectorCalculus[Jacobian](F,[seq(_q[i],i=1..k)]);
W = jacobian(F, q);

b = subs(F, q, v);

t = norm(b);

fprintf("the orginal residue without Newton iteration: %.20f.\n", t);
[n_, m_] = size(W);
fprintf("the dimension of Jacobian matrix: %d, %d.\n", n_, m_);

%%
iter_cnt = 0;
v = vpa(v);
for i = 1:max_iter
    if t > tol
        A = double(subs(W, q, v));

        digits(18);
        % v = v - (pinv(vpa(A)) * double(vpa(b')))';
        v = v - lsqminnorm(double(A), double(b'))';
        
        b = double(subs(F, q, v));
        t = norm(b);
        iter_cnt = iter_cnt + 1;
    else
        break;
    end
    fprintf("|f- \\sum f_i^2| %.20f\n", t);
end

tot_time = toc;
fprintf("\n\n=============================================\n\n");
fprintf("%d iterations, %f seconds.\n", iter_cnt, tot_time);
fprintf("|f- \\sum f_i^2| %.20f.\n", t);
fprintf("\n\n=============================================\n\n");

sL = subs(sL, q, v);
sL_update = double(sL);

for i = size(sL, 2):-1:1
    if norm(sL(:, i), 2) == 0
        sL_update = sL_update(:, [1:i-1, i+1:end]);
    end
end

ans = sL_update;




end