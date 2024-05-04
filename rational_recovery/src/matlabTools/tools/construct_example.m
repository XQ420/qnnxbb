function example = construct_example(path, config)

function line = readLine(fileID)
    str = fgets(fileID);  % 
    line = strtrim(str);  % 
end

example = Example();

fileID = fopen(path, 'r');  % 

str = readLine(fileID);  % 
example.n = str2num(str);
str = readLine(fileID);
example.strh = str;
m = str2num(readLine(fileID));
for i = 1:m
    str = readLine(fileID);
    str = strtrim(str);
    words = strsplit(str);
    cg = ConstrGroup();
    len = 0;
    j = 1;
    while j <= numel(words)
        if j == 1
            cg.m = str2num(words{j});
            j = j + 1;
        elseif j == 2
            len = str2num(words{j});
            j = j + 1;
        else
            k = 0;
            while k < len
                cg.constr_str{end + 1} = words{j};
                j = j + 1;
                k = k + 1;
            end

            k = 0;
            while k < len
                cg.equ{end + 1} = str2num(words{j});
                j = j + 1;
                k = k + 1;
            end
        end
    end

    cg.type = config.INIT_TYPE;
    cg.name = strcat(cg.type, "_", string(i));
    example.CG_init{end + 1} = cg;
end

u = str2num(readLine(fileID));

for i = 1:u
    str = readLine(fileID);
    str = strtrim(str);
    words = strsplit(str);
    cg = ConstrGroup();
    len = 0;
    j = 1;
    while j <= numel(words)
        if j == 1
            cg.m = str2num(words{j});
            j = j + 1;
        elseif j == 2
            len = str2num(words{j});
            j = j + 1;
        else
            k = 0;
            while k < len
                cg.constr_str{end + 1} = words{j};
                j = j + 1;
                k = k + 1;
            end

            k = 0;
            while k < len
                cg.equ{end + 1} = str2num(words{j});
                j = j + 1;
                k = k + 1;
            end
        end
    end

    cg.type = config.UNS_TYPE;
    cg.name = strcat(cg.type, "_", string(i));
    example.CG_uns{end + 1} = cg;
end

name = readLine(fileID);
example.name = name;
id = readLine(fileID);
example.ID = id;

% example

fclose(fileID);  

end
