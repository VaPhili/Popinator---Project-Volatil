
% slope to rotation function:
% calculates the rotation of a given slope. 0 => 0°, 1 => 45°...

function out = slope_to_degree(in)
    
    out = rad2deg(atan(in));
end