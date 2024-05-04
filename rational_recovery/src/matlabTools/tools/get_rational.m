function [tf] = get_rational(f)
[C, T] = coeffs(f);
tf = 0;
for i = 1:length(C)
    tf = tf + T(i) * sym(double(C(i)), 'r');
end

end