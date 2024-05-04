function [res] = get_rational_SOS(n, str_f, path, example_name)
tol = 1e-16;
tol1 = 1e-2;
tol2 = 1e-4;
tol3 = 1e-14;
iters = 10;
options=sdpsettings('sos.newton',1,'sos.congruence',0,'sos.numblkdg',1e-8, 'verbose', 0);

x = sdpvar(1, n);
f = eval(str_f);

if ~isnan(str2double(sdisplay(f)))
    res = 1;
    ts_ = sdisplay(f);
    fprintf("constant expression appears %s\n", ts_{1});

    path = path + '\' + string(example_name) + '_ret';
    fid = fopen(path ,'w');
    fprintf(fid, string(example_name) + ': ' + str_f + '\n');
    return
end
%%
tol = 1e-16;

sdpvar rm;
rm = 0;
[sol, m, Q, residuals] = solvesos([sos(f - rm)],-rm,options);

minval = double(rm);
Q = Q{1};
monos = m{1};

str = sdisplay(monos);
str = strcat(',', str(2:length(str)));
fs = sdisplay(f);

%%
V = monos;

%%
char_f = sdisplay(f);
char_V = sdisplay(V);
char_f = sym_format(char_f);
char_V = sym_format(char_V);
% 
if n == 1
    for i = 1:length(char_V)
        char_V{i} = strrep(char_V{i}, 'x', 'x1');
    end
end 
x = sym('x', [1, n]);
monos = str2sym(char_V); 
X = sym("X", [1, n]);

new_str_f = sym_format(str_f);

f = str2sym(new_str_f);

f = subs(f, x, X);

monos = subs(monos, x, X);


monos = monos.';
Q1 = Q;
Q1 = cutoff_matrix(Q, 2, 'float'); % dont forget fix here
r_min = -1;
% [r_min, vec_d, q_list, d] = rational_SOS(f, 1, 0, monos, Q1, X);

if r_min == -1
    [Q_refine, iter_cnt, nr_time] = Newton_refine_update(f, monos, Q1, tol1, iters, tol2, X);
    [r_min, vec_d, q_list, d] = rational_SOS(f, 1, 0, monos, Q_refine * Q_refine', X);
end

% if r_min == -1
%     Q_refine = Newton_refine_update(f, monos, Q1, tol2, iters, tol2, X);
%     Q_refine = Newton_list(f, monos, Q_refine, iters, tol1, tol3, X);
%     [r_min, vec_d, q_list, d] = rational_SOS(f, 1, 0, monos, Q_refine * Q_refine', X);
% end

fprintf("f - sum(vec_d .* q_list.^2) = ");
disp(expand(f - sum(vec_d .* q_list.^2)));


path = path + '\' + string(example_name) + '_ret';
fid = fopen(path ,'w');
fprintf(fid, string(example_name) + ': ' + str_f + '\n\n');
fprintf(fid, "newton refine update time: %s s\n", string(nr_time));
fprintf(fid, "newton refine update iteration count: %s\n", string(iter_cnt));
fprintf(fid, '\n----------------------------------------------\n\n');

if r_min == -1
    res = 0;
    fprintf(fid, "solve failed\n");
else
    res = 1;
    fprintf(fid, "vec_d :=\n[%s\n];\n", strjoin(string(vec_d), ', \n'));
    fprintf(fid, "q_list := \n[%s\n]", strjoin(string(q_list), ', \n'));
end

fclose(fid);