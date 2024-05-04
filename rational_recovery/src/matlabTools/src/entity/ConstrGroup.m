classdef ConstrGroup
   
    properties
        m; 
        mul = {}; 
        mul_para = {}; 
        mul_var = {}; 
        mul_str = {}; 
        H_str = {}; 
        H = {}; 
        constr_str; 
        type; 
        equ = {}; 
        name = "CONSTR_NAME"; % name
        constr;
        R_str = {}; 
        R = {};
        rm; 
        R_para = {}; 
        R_var = {}; 
    end

    methods
        
        function obj = ConstrGroup(m, rm, constr_str, type, equ)
            if nargin == 0
                obj.m = 0;
                obj.constr_str = {};
                obj.type = "NULL";
                obj.equ = {};
                obj.rm = 0;
            else
                if nargin < 5
                    equ = num2cell(zeros(1, length(constr_str)));
                end
                obj.m = m;
                obj.rm = rm;
                obj.constr_str = constr_str;
                obj.type = type;
                obj.equ = equ;
            end
        end
    end
end