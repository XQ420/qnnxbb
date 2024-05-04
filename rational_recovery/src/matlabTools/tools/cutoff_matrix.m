function res_M = cutoff_matrix(M, tol, op)
    if op == "sym"
        [m, n] = size(M);
        res_M = sym(zeros(m, n));
        
        temp_M = M;
        
        for i = 1:m
            for j = 1:n
                temp_number = temp_M(i, j);
                if abs(double(temp_number)) > 10^(-tol)
                    %res_M(i, j) = sym(rat(temp_number, tol));
                    %res_M(i, j) = str2sym(rats(temp_number));
                    temp_number = round(temp_number, 2);
                    t = sym(temp_number, 'r');
                    
                    res_M(i, j) = t;
                    %res_M(i, j) = convert(double(temp_number), 'rational', 'Digits', tol);
                end
            end
        end
    elseif op == "float"
        [m, n] = size(M);
        res_M = zeros(m, n);
        
        temp_M = M;
        
        for i = 1:m
            for j = 1:n
                temp_number = temp_M(i, j);
                if abs(double(temp_number)) > 10^(-tol)
                    % 
                    %res_M(i, j) = sym(rat(temp_number, tol));
                    %res_M(i, j) = str2sym(rats(temp_number));
                    t = round(temp_number, 2);
                    res_M(i, j) = t;
                    %res_M(i, j) = convert(double(temp_number), 'rational', 'Digits', tol);
                end
            end
        end
    end
   
end