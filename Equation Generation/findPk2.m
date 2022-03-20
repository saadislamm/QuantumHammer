% Alg. 2: Algorithm for reading Pk2 from Q1
% Pk2 contains v*m terms

function Pk2 = findPk2(Pk2,Q1,v,m)

from = v+1;
to = v+m;

for i=1:v
    for j=1:m
        Pk2(i,:) = Q1(from:to);
    end
    from=to+1+v-i;
    to=from+m-1;
end
writematrix(Pk2,'Pk2.txt');
end