function [rm, d, rQ_mul_mv, dist] = rational_SOS(f, g, minval, monos, Q, indets)
tic; % timer

mv = monos;
[m, t] = size(Q);
if m ~= t || m ~= length(mv)
    error("Invalid input")
end

rf = f;
rg = g;
rm = sym(minval, 'r');
rQ = Q;

% rf - rm * rg - mv * rQ * mv.'

t = expand(rf - rm * rg - mv * rQ * mv.');

r = sym('r');
p = sym("p", [1, m]);
t = t * r;

%%%%%%%%%%%%%%%%%
%t = 0
%%%%%%%%%%%%%%%%%%
part1 = 0;
for i = 1:m
    part1 = part1 + p(i) * mv(i);
end

q = sym("q", [1, m]);
part2 = 0;
for i = 1:m
    part2 = part2 + q(i) * mv(i);
end

t = expand(t + part1 * part2);

[C, T] = coeffs(t, indets); %% 

t = C;
% b := map(i->coeff(i,_r),t);   
b = [];
for i = 1:length(t)
    [cc, T] = coeffs(t(i),r);
    flag = 0;
    for j = 1:length(T)
        if string(T(j)) == "r"
            flag = 1;
            b = [b, cc(j)];
            break
        end
    end
    % if col > 1
    %     b = [b, cc(2)]; % it may be not a p^1, but I dont want to fix it.
    % I have fixed it
    if flag == 0
        b = [b, sym(0, "r")];
    end
end
% b

% t := [seq(t[i]-b[i]*_r,i=1..nops(t))];
temp_t = [];
for i = 1:length(t)
    temp_t = [temp_t, t(i) - b(i) * r];
end

t = temp_t;
% t := add(b[i]*t[i]/norm(t[i],2)^2,i=1..nops(t));
temp_t = 0;
for i = 1:length(t)
    c = coeffs(t(i));
    norm2 = sym(0, "r");
    for j = 1:length(c)
        norm2 = norm2 + abs(c(j))^2;
    end
    temp_t = temp_t + b(i) * t(i) / norm2;
end
t = expand(temp_t);

% t := [seq(coeff(t,_p[i]),i=1..m)];
temp_t = [];

for i = 1:length(p)
    [C, T] = coeffs(t, p(i));
    col = size(C, 2);
    flag = 0;
    for j = 1:length(T)
        if string(T(j)) == "p" + string(i)
            flag = 1;
            temp_t = [temp_t, C(j)];
            break;
        end
    end
    if flag == 0
        temp_t = [temp_t, sym(0, "r")];
    end
end
t = temp_t;

% A,b := LinearAlgebra[GenerateMatrix](t,[seq(_q[i],i=1..m)]);
% t
% q
A = sym(zeros(length(t), length(q)));
% 
for i = 1:length(t)
    [C, T] = coeffs(t(i), q);
    dic = dictionary(T, C);
    for j = 1:length(q)
        if isKey(dic, q(j))
            A(i, j) = dic(q(j));
        else
            A(i, j) = sym(0, "r");
        end
    end
end

dist = double(norm(A, 'fro'));
fprintf("the distance between Q and rQ is %.20f\n", dist);

rQ = rQ + A;

% rQ := (LinearAlgebra[Transpose](rQ)+rQ)/2;
rQ = (rQ.' + rQ) / 2;
d = sym(zeros(m, 1));
for i = 1:m
    t = rQ(i, i);
    if t > 0
        d(i) = 1/t;
        for j = i+1:m
            for k = j:m
                rQ(j, k) = rQ(j, k) - rQ(i, j)*rQ(i, k)/t;
            end
        end
    elseif norm(rQ(i, i:end)) > 0
        disp('norm is');
        disp(double(norm(rQ(i, i:end))));
        disp('rQ is not positive semidefinite.');
        d = [];
        rm = -1;
        dist = -1;
        rQ_mul_mv = [];
        return;
    end
    rQ(i+1:end, i) = 0;
end

disp(char(rm) + " is the lower bound.");
disp("finish rational SOS.");
disp(['time: ' num2str(toc) ' s']);
d;
rQ_mul_mv = rQ * mv.';

end

