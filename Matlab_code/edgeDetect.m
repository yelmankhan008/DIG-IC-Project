clc;
A = bin2dec(textread('finalOutput_camera_notEdge.txt','%s'));
%A = bin2dec(textread('output.txt','%s'));
A = dec2bin(A,9);
B = zeros(64516,1);
for i = 1:64516
   B(i) = q2dec(A(i,:),4,4,'bin');
end


B(B > 0) = 1;
%B(B <= 0.5) = 0;
%B = flip(B);
%B(B == 1 ) = -1;

B = reshape(B,[254 254]);
B = B';
imshow(B);
%imrotate(B,90)
