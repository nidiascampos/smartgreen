function [xe,we]=navresample(xp,wp)

nw=length(wp);
xe=zeros(size(xp));

cdf=cumsum(wp);
cdf=cdf/cdf(nw);

u=uniformrandom4(nw);


j=1;
for i=1:nw
   while cdf(j) < u(i)
      j=j+1;
   end
   xe(i,:)=xp(j,:); 
end

we=ones(size(wp))/nw;
