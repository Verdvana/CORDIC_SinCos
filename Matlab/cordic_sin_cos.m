clc;
clear all;
close all;

K=0.607253;

N=16;

x=zeros(16,1);
y=zeros(16,1);
z=zeros(16,1);

r=[45,26.5651,14.0362,7.1250,3.5763,1.7899,0.8952,0.4476,0.2238,0.1119,0.0560,0.0280,0.0140,0.007,0.0035,0.0018];

x(1) = K;
y(1) = 0;
z(1) = 30;
  fprintf('shift %d result is \t %f ,%f ,%f\n',1,x(1),y(1),z(1));

for i=2:N
    
    if(z(i-1)>=0)
      x(i)=x(i-1)-(y(i-1)*2^(2-i));
      y(i)=y(i-1)+(x(i-1)*2^(2-i));
      z(i)=z(i-1)-r(i-1);
    else
      x(i)=x(i-1)+(y(i-1)*2^(2-i));
      y(i)=y(i-1)-(x(i-1)*2^(2-i));
      z(i)=z(i-1)+r(i-1);
    end 
    
    
    fprintf('shift %d result is \t %f ,%f ,%f\n',i,x(i),y(i),z(i));
end



