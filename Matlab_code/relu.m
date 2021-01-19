function [output] = relu(input)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
if input >= 0
    output = input;
else
    output = 0;
end
end

