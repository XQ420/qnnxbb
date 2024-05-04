classdef Example

    properties
        n; 
        strh; 
        h;
        CG_init; 
        CG_uns; 
        name; 
        ID; 
        str_H; 

    end

    methods
        function obj = Example(n, strh, Init, Uns, name, ID)
            if nargin < 1
                obj.n = 0;
                obj.strh = "-1";
                obj.CG_init = {};
                obj.CG_uns = {};
                obj.name = "NULL";
                obj.ID = "NULL";
            else
                obj.n = n;
                obj.strh = strh;
                obj.CG_init = Init;
                obj.CG_uns = Uns;
                obj.name = name;
                obj.ID = ID;
            end
        end

    end
end