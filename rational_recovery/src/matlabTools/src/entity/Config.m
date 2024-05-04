classdef Config
    properties
        DENOMINATOR_UPPER = 1;
        MODEL = 1;
        ITERS = 20;
        OK = 1;
        INIT_TYPE = "initial";
        UNS_TYPE = "unsafe";
        % 
        ISEQU = 1;
        ISNEQU = 0;
        REPSS = "1/10000";
    end

    methods
        function obj = Config()
   
        end

    end
end