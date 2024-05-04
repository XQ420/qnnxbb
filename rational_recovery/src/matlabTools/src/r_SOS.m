
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
            error("未知错误");
        end
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
            error("未知错误");
        end
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
