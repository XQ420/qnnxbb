clc;
clear;
tic;

config = Config();
config.DENOMINATOR_UPPER = 1000;
config.OK = 1;
config.REPSS = '0';
rational_model = 1;

example = Example(n, ... 
    "Interpolant",...
    { ...
    ConstrGroup(d, dr, {" Constraint condition{ polynomial f}"}, config.INIT_TYPE), ...
    }, ...
    { ...
    ConstrGroup(d, dr, {" Constraint condition{ polynomial g} "}, config.UNS_TYPE), ...
    }, ...
    "Name", ...
    1);


folderName = example.name;  
fullFolderPath = '..\matlabTools\results\' + string(folderName)

if ~isfolder(fullFolderPath)  
    mkdir(fullFolderPath);  
    disp('mkdir sucess!');
else
    disp('mkdir failed!');
end
fid = fopen(fullFolderPath + '\float-h', 'w');
fprintf(fid, example.strh);
fclose(fid);
%%

x = sdpvar(1, example.n); 
for i = 1:length(example.CG_init) 
    cg = example.CG_init{i};

    constr_exp_str_cell = cg.constr_str; 
    sdpexp_cell = {}; 
    for j = 1:length(constr_exp_str_cell) 
        con_exp_str = constr_exp_str_cell{j};
        sdpexp_cell{end + 1} = eval(con_exp_str);
    end
    cg.constr = sdpexp_cell;
    example.CG_init{i} = cg; 
end

for i = 1:length(example.CG_uns)
    cg = example.CG_uns{i};

    constr_exp_str_cell = cg.constr_str;
    sdpexp_cell = {}; 
    for j = 1:length(constr_exp_str_cell) 
        con_exp_str = constr_exp_str_cell{j};
        sdpexp_cell{end + 1} = eval(con_exp_str);
    end
    cg.constr = sdpexp_cell;
    example.CG_uns{i} = cg; 
end


str_rh = rational_approximate(example.n, example.strh, config.DENOMINATOR_UPPER, rational_model);
str_rh = sdp_format(str_rh);

fprintf("The approximate result of h is %s\n", str_rh);

h = eval(str_rh);
example.h = h; 

%% 


for i = 1:length(example.CG_init)
    cg = example.CG_init{i};
    for j = 1:length(cg.constr)
        [cg.mul{end + 1}, cg.mul_para{end + 1}, cg.mul_var{end + 1}] = polynomial(x, cg.m);  
    end
    [cg.R{1}, cg.R_para{1}, cg.R_var{1}] = polynomial(x, cg.rm);  
    example.CG_init{i} = cg;    
end



for i = 1:length(example.CG_uns)
    cg = example.CG_uns{i};
    for j = 1:length(cg.constr)
        [cg.mul{end + 1}, cg.mul_para{end + 1}, cg.mul_var{end + 1}] = polynomial(x, cg.m);
    end
    [cg.R{1}, cg.R_para{1}, cg.R_var{1}] = polynomial(x, cg.rm); 
    example.CG_uns{i} = cg;
end

%% 
options = sdpsettings('solver', 'mosek', 'verbose', 0);  

% 
for i = 1:length(example.CG_init)
    cg = example.CG_init{i};
    H = 0;
    con = [];
    para = [];
    
    for j = 1:length(cg.constr)
        if cg.equ{j} == config.ISNEQU 
            con = [con, sos(cg.mul{j})];
        end
        para = [para; cg.mul_para{j}];
        H = H + cg.mul{j}*cg.constr{j};
    end
    
    H = -example.h * (1 + cg.R{1}) - H;
    
    con = [con, sos(H), sos(cg.R{1})];  
    para = [para; cg.R_para{1}];

    cg.H{1} = H;
    sol = solvesos(con, [], options, para);
    
    if sol.problem == 0
        for j = 1:length(cg.mul)
            cg.mul{j} = double(cg.mul_para{j})' * cg.mul_var{j};
            ts_ = sdisplay(cg.mul{j});
            fprintf("The multiplier in %s is %s\n", cg.name, ts_{1});
        end
        cg.R{1} = double(cg.R_para{1})' * cg.R_var{1};
    else
        fprintf("Failed to obtain multiplier on init (H SOS decomposition failed)\n\n");
        fprintf("this constrain group is:\n");
        cg;
        ts = sdisplay(cg.H{1});
        fprintf("it's H is %s\n", ts{1});
        config.OK = 0;
    end

    if config.OK == 0
        break;
    end

    example.CG_init{i} = cg;
end

for i = 1:length(example.CG_uns)
    cg = example.CG_uns{i};
    H = 0;
    con = [];
    para = [];
    for j = 1:length(cg.constr)
        if cg.equ{j} == config.ISNEQU 
            con = [con, sos(cg.mul{j})];
        end
        para = [para; cg.mul_para{j}];
        H = H + cg.mul{j}*cg.constr{j}; 
    end

    H = example.h * (1 + cg.R{1}) - H - str2num(config.REPSS); 

    con = [con, sos(H), sos(cg.R{1})];
    para = [para; cg.R_para{1}];

    cg.H{1} = H;
    sol = solvesos(con, [], options, para);
    if sol.problem == 0
        for j = 1:length(cg.mul)
            cg.mul{j} = double(cg.mul_para{j})' * cg.mul_var{j};
            ts_ = sdisplay(cg.mul{j});
            fprintf("The multiplier in %s is %s\n", cg.name, ts_{1});
        end
        cg.R{1} = double(cg.R_para{1})' * cg.R_var{1};
    else
        fprintf("Failed to obtain multiplier on unsafe (H SOS decomposition failed)\n\n");
        fprintf("this constrain group is:\n");
        cg;
        ts = sdisplay(cg.H{1});
        fprintf("it's H is %s\n", ts{1});
        config.OK = 0;
    end
    
    if config.OK == 0
        break;
    end
    
    example.CG_uns{i} = cg;
end


for i = 1:length(example.CG_init)
    cg = example.CG_init{i};
    for j = 1:length(cg.mul)
        str_mul = sdisplay(cg.mul{j});
        str_mul = str_mul{1};
        str_mul = rational_approximate(example.n, str_mul, config.DENOMINATOR_UPPER,rational_model);
        str_mul = sdp_format(str_mul);
        cg.mul_str{j} = str_mul;
        cg.mul{j} = eval(str_mul);
    end

    str_mul = sdisplay(cg.R{1});
    str_mul = str_mul{1};
    str_mul = rational_approximate(example.n, str_mul, config.DENOMINATOR_UPPER,rational_model);
    str_mul = sdp_format(str_mul);
    cg.R_str{1} = str_mul;
    cg.R{1} = eval(str_mul);
    
    example.CG_init{i} = cg;
end

for i = 1:length(example.CG_uns)
    cg = example.CG_uns{i};
    for j = 1:length(cg.mul)
        str_mul = sdisplay(cg.mul{j});
        str_mul = str_mul{1};
        str_mul = rational_approximate(example.n, str_mul, config.DENOMINATOR_UPPER,rational_model);
        str_mul = sdp_format(str_mul);
        cg.mul_str{j} = str_mul;
        cg.mul{j} = eval(str_mul);
    end

    str_mul = sdisplay(cg.R{1});
    str_mul = str_mul{1};
    str_mul = rational_approximate(example.n, str_mul, config.DENOMINATOR_UPPER,rational_model);
    str_mul = sdp_format(str_mul);
    cg.R_str{1} = str_mul;
    cg.R{1} = eval(str_mul);
    
    example.CG_uns{i} = cg;
end


for j = 1:length(example.CG_init)
    cg = example.CG_init{j};
   
    str_H = get_H(example.n, str_rh, cg.mul_str, cg.R_str, cg.constr_str, cg.type, config);
    str_H = sdp_format(str_H);
    
    cg.H_str{1} = str_H;
    cg.H{1} = eval(str_H);
    
    example.CG_init{j} = cg;
end

for j = 1:length(example.CG_uns)
    cg = example.CG_uns{j};

    str_H = get_H(example.n, str_rh, cg.mul_str, cg.R_str, cg.constr_str, cg.type, config);
    str_H = sdp_format(str_H);

    
    str_H = str_H + "-" + config.REPSS;

    cg.H_str{1} = str_H;
    cg.H{1} = eval(str_H);

    example.CG_uns{j} = cg;
end

for cg = example.CG_init
    if config.OK == 0
        break;
    end
    cg = cg{1};

    try
        sol = optimize(sos(cg.H{1}), [], options);
        if sol.problem ~= 0
            config.OK = 0;
            disp("rational-H decomposition failed");
            break;
        end
    catch
        num = eval(cg.H_str{1});
        if isnan(num)
            error("Unknown error");
        end
    end
    
    
    if isa(cg.R{1}, 'sdpvar')
        sol = optimize(sos(cg.R{1}), [], options);
        if sol.problem ~= 0
            config.OK = 0;
            disp('rational multiplier R failed');
        end
    elseif isa(cg.R{1}, 'double') || isa(cg.R{1}, 'int32')
        
    else
        error('Multiplier subtype error')
    end

   
    for j = 1:length(cg.mul)
        if cg.equ{j} == config.ISEQU
            continue;
        end
        mul = cg.mul{j};

        if isa(mul, 'sdpvar')
            sol = optimize(sos(mul), [], options);
            if sol.problem ~= 0
                config.OK = 0;
                disp("rational-multiplier decomposition failed");
                break;
            end
        elseif isa(mul, 'double') || isa(mul, 'int32')

        else
            error("Multiplier subtype error")
        end
        if config.OK == 0
            break
        end
    end
end

for cg = example.CG_uns
    if config.OK == 0
       break;
    end
    cg = cg{1};

    try
        sol = optimize(sos(cg.H{1}), [], options);
        if sol.problem ~= 0
            config.OK = 0;
            disp("rational H decomposition failed");
            break;
        end
    catch
        num = eval(cg.H_str{1});
        if isnan(num)
            error("Unknown error");
        end
    end

   
    if isa(cg.R{1}, 'sdpvar')
        sol = optimize(sos(cg.R{1}), [], options);
        if sol.problem ~= 0
            config.OK = 0;
            disp('rational multiplier R failed');
        end
    elseif isa(cg.R{1}, 'double') || isa(cg.R{1}, 'int32')
        
    else
        error('Multiplier subtype error')
    end

   
    for j = 1:length(cg.mul)
        if cg.equ{j} == config.ISEQU
            continue;
        end
        mul = cg.mul{j};
        if isa(mul, 'sdpvar')
            sol = optimize(sos(mul), [], options);
            if sol.problem ~= 0
                config.OK = 0;
                disp("rational-multiplier decomposition failed");
                break;
            end
        elseif isa(mul, 'double') || isa(mul, 'int32')

        else
            error("Multiplier subtype error")
        end
        if config.OK == 0
            break
        end
    end
end


res = 1;

disp("start multiplier rational SOS");
for j = 1:length(example.CG_init)
    cg = example.CG_init{j};
    for k = 1:length(cg.mul_str)
        if cg.equ{k} == config.ISEQU
            continue;
        end
        cur_str_mul = cg.mul_str{k};

        cur_str_mul = sdp_format(cur_str_mul);
         t_res = get_rational_SOS(example.n, cur_str_mul{1}, fullFolderPath, 'initial_' + string(j) + '_' + string(k));
         res = bitand(t_res, res);
    end
end

for j = 1:length(example.CG_uns)
    cg = example.CG_uns{j};
    for k = 1:length(cg.mul_str)
        if cg.equ{k} == config.ISEQU
            continue;
        end
        cur_str_mul = cg.mul_str{k};

        cur_str_mul = sdp_format(cur_str_mul);
         t_res = get_rational_SOS(example.n, cur_str_mul{1}, fullFolderPath, 'unsafe_' + string(j) + '_' + string(k));
         res = bitand(t_res, res);
    end
end



j = 1;
for cg = example.CG_init
    cg = cg{1};
    t_res = get_rational_SOS(example.n, cg.H_str{1}, fullFolderPath, 'H_init' + string(j));
    res = bitand(res, t_res);
    t_res = get_rational_SOS(example.n, cg.R_str{1}, fullFolderPath, 'R_init' + string(j));
    res = bitand(res, t_res);
    j = j + 1;
end


j = 1;
for cg = example.CG_uns
    cg = cg{1};
    t_res = get_rational_SOS(example.n, cg.H_str{1}, fullFolderPath, 'H_uns' + string(j));
    res = bitand(res, t_res);
    t_res = get_rational_SOS(example.n, cg.R_str{1}, fullFolderPath, 'R_uns' + string(j));
    j = j + 1;
end

elapsedTime = toc;
fid = fopen(fullFolderPath + '\elapsedTime', 'w');
fprintf(fid, "elapsed time: %f s\n", elapsedTime);
fclose(fid);

if config.OK == 1
    fid = fopen(fullFolderPath + '\rational-h', 'w');
    fprintf(fid, "rational h: %s\n", str_rh);
    fclose(fid);
else
    fid = fopen(fullFolderPath + '\fail-example', 'w');
    fprintf(fid, "rational h: %s\n", str_rh);
    fclose(fid);
end

toc;

