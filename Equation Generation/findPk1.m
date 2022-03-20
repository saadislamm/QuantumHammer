% Alg. 1 Algorithm for reading Pk1 from Q1
% Pk1 contains v*v terms

function Pk1 = findPk1(Pk1,Q1,v,m)
from = 1;
to = v;
for i=1:v
    for j=1:v
        Pk1(i,i:v) = Q1(from:to);
    end
    from=to+1+m;
    to=from+v-1-i;
end
writematrix(Pk1,'Pk1.txt');
end