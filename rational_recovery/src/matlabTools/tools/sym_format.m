function [result] = sym_format(s)
%
result = regexprep(s, 'x\((\d+)\)', 'x$1');

end