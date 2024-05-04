options = sdpsettings('solver', 'mosek', 'verbose', 0);

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
    H = -example.h - H;    
    con = [con, sos(H)];
    cg.H{1} = H;
    sol = solvesos(con, [], options, para);
    if sol.problem == 0
        for j = 1:length(cg.mul)
            cg.mul{j} = double(cg.mul_para{j})' * cg.mul_var{j};
            ts_ = sdisplay(cg.mul{j});
            fprintf("The multiplier in %s is %s\n", cg.name, ts_{1});
        end
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
        if cg.equ{j} == config.ISNEQU % 
            con = [con, sos(cg.mul{j})];
        end
        para = [para; cg.mul_para{j}];
        H = H + cg.mul{j}*cg.constr{j}; 
    end

    H = example.h - H - str2num(config.REPSS); 

    con = [con, sos(H)];
    cg.H{1} = H;
    sol = solvesos(con, [], options, para);
    if sol.problem == 0
        for j = 1:length(cg.mul)
            cg.mul{j} = double(cg.mul_para{j})' * cg.mul_var{j};
            ts_ = sdisplay(cg.mul{j});
            fprintf("The multiplier in %s is %s\n", cg.name, ts_{1});
        end
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
