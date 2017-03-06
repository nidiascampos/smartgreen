function u=uniformrandom4(n)
% an algorithm to compute an ordered set of uniforma numbers

u=zeros(n,1); % a column
c=1/n;
c2=c/2;
u(1)=c2;
ur=c2*(rand(size(u))-0.5);

for i=2:n
   u(i)=u(i-1)+c;
   u(i-1)=u(i-1)+ur(i-1);
end
u(n)=u(n)+ur(n);

