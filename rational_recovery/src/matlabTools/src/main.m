function main(example, config)
tic;

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
    example.CG_uns{i} = cg; % 
end
backup_example = example;
%%
for i = 1:config.ITERS % 
    fprintf("\n\n-------Iteration %d-------\n\n", i);
    config.OK = 1;
    config.DENOMINATOR_UPPER = config.DENOMINATOR_UPPER * 10; %
    if config.DENOMINATOR_UPPER > 10^18
        error("The approximate denominator is too large, and the solution is considered to fail")
    end
    
    
    str_rh = rational_approximate(example.n, example.strh, config.DENOMINATOR_UPPER);
    str_rh = sdp_format(str_rh);

    fprintf("The approximate result of h is %s\n", str_rh);

    
    if str_rh == "0"
        continue;
    end

    h = eval(str_rh);
    example.h = h;
    generate_multiplier; %
    float_SOS; % 

    if config.OK == 0 
        example = backup_example;
        fprintf("The %dth iteration can't obtain the multiplier in float, and the loop continues.\n", i);
        continue
    end

    rationalize; 
    for j = 1:length(example.CG_init)
        cg = example.CG_init{j};
        
        str_H = get_H(example.n, str_rh, cg.mul_str, cg.constr_str, cg.type, config);
        str_H = sdp_format(str_H);
        cg.H_str{1} = str_H;
        cg.H{1} = eval(str_H);
        
        example.CG_init{j} = cg;
    end

   
    for j = 1:length(example.CG_uns)
        cg = example.CG_uns{j};

        str_H = get_H(example.n, str_rh, cg.mul_str, cg.constr_str, cg.type, config);
        str_H = sdp_format(str_H);

        
        str_H = str_H + "-" + config.REPSS;

        cg.H_str{1} = str_H;
        cg.H{1} = eval(str_H);

        example.CG_uns{j} = cg;
    end
    
   
    r_SOS
    if config.OK == 0 
        example = backup_example;
        fprintf("The rational form multiplier or H verification failed in the %d iteration, and the loop continues.\n", i);
        continue
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
             t_res = get_rational_SOS(example.n, cur_str_mul{1}, fullFolderPath, cg.name + '_' + string(k));
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
             t_res = get_rational_SOS(example.n, cur_str_mul{1}, fullFolderPath, cg.name + '_' + string(k));
             res = bitand(t_res, res);
        end
    end

    j = 1;
    for cg = example.CG_init
        cg = cg{1};
        t_res = get_rational_SOS(example.n, cg.H_str{1}, fullFolderPath, 'H_init' + string(j));
        res = bitand(res, t_res);
        j = j + 1;
    end
    j = 1;
    for cg = example.CG_uns
        cg = cg{1};
        t_res = get_rational_SOS(example.n, cg.H_str{1}, fullFolderPath, 'H_uns' + string(j));
        res = bitand(res, t_res);
        j = j + 1;
    end
    
    if config.OK == 0 
        example = backup_example;
        fprintf("The %dth iteration can't obtain a rational SOS, and the loop continues.\n", i);
        continue
    end

    if config.OK == 1
        disp("success");
        break;
    end
end


elapsedTime = toc;
fullFolderPath + '\elapsedTime';
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


end
