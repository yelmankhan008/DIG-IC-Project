clear all;
clc;
values = dlmread('W.dat');
input_weights = values(11:30,1:10);
hidden_weights = [values(31,1) values(31,11:end-1)];


inW_file = fopen('inputWeights.txt','w');
for i = 1:size(input_weights,1)
    for j = 1:size(input_weights,2)
        q = dec2q(input_weights(i,j),4,4,'bin');
        fprintf(inW_file,q);
        fprintf(inW_file,'\n');
    end
end
fclose(inW_file);

inHid_file = fopen('hiddenWeights.txt','w');
for i = 1:size(hidden_weights,1)
    for j = 1:size(hidden_weights,2)
        q = dec2q(hidden_weights(i,j),4,4,'bin');
        fprintf(inHid_file,q);
        fprintf(inHid_file,'\n');
    end
end
fclose(inHid_file);