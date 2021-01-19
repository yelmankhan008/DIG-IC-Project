clc;
fileID = fopen('test4.txt','r');
formatSpec = '%d';
sizeA = [256 256];
A = fscanf(fileID,formatSpec,sizeA);
A = A';
A = interp1([0,255],[-1,1],A);

file1 = fopen('input4.txt','w');
for i = 2:255
    for j = 2:255
        
        q = dec2q(A(i-1,j-1),4,4,'bin');
        fprintf(file1,q);
        
        q = dec2q(A(i-1,j),4,4,'bin');
        fprintf(file1,q);
        
        q = dec2q(A(i-1,j+1),4,4,'bin');
        fprintf(file1,q);
        
        q = dec2q(A(i,j-1),4,4,'bin');
        fprintf(file1,q);
        
        q = dec2q(A(i,j),4,4,'bin');
        fprintf(file1,q);
        
        q = dec2q(A(i,j+1),4,4,'bin');
        fprintf(file1,q);
        
        q = dec2q(A(i+1,j-1),4,4,'bin');
        fprintf(file1,q);
        
        q = dec2q(A(i+1,j),4,4,'bin');
        fprintf(file1,q);
        
        q = dec2q(A(i+1,j+1),4,4,'bin');
        fprintf(file1,q);
        
        fprintf(file1,'\n');
    end
end
fclose(file1);
