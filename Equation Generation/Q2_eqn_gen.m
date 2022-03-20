% Input     C_L_Q1.txt
%           Q2_rhs
% Output    equations.txt (Systems of equations for Q2)

clear all;
close all;
clc;
warning('off','all');

tic

% Parameters
v = 197;        % Number of vinegar variables
m = 57;         % Number of oil variables OR number of equations
n = v + m;      % Total number of variables
col = 5;        % Equations needed for column col of Q2

% Input:
C_L_Q1 = logical(importdata('C_L_Q1.txt'));
len_C_L_Q1 = length(C_L_Q1);
C_L_Q1 = reshape(C_L_Q1, m, len_C_L_Q1/m);

%C = C_L_Q1(:, 1)
%L = C_L_Q1(:, 2:n+1)

Q1 = C_L_Q1(:, n+2:end);
writematrix(Q1,'Q1.txt');

T = logical(importdata('T.txt'));
len_T = length(T);
T = reshape(T, m, len_T/m)';
writematrix(T,'T_M.txt')

syms x [v 1]
T=x;
for concat=1:m-1
    T = [T x];
end

% Inserting known values from rowhammer
% Fixed first 9 variables to ground truth
known_indexes = readmatrix('known_indexes_149.txt');
T_groundtruth = readmatrix('T_M.txt');
T_groundtruth = T_groundtruth(known_indexes, col);
T(known_indexes,col) = T_groundtruth;

% Replacing first 9 ground truth variables with random values
% Comment the following if you want to fix them to the correct values
% T(1,col) = 1;
% T(10,col) = 0;
% T(12,col) = 0;
% T(13,col) = 1;
% T(14,col) = 1;
% T(23,col) = 0;
% T(28,col) = 1;
% T(32,col) = 0;
% T(37,col) = 1;

% Making rest of the T zero as not required in attack
for h=1:m
    if h~=col
        T(:,h)=0;
    end
end

%Q2 public value to put as right hand side of the system
Q2_rhs = logical(importdata('Q2.txt'));
len_Q2_rhs = length(Q2_rhs);
Q2_rhs = reshape(Q2_rhs, m, m*(m+1)/2);
Q2_rhs = reshape(Q2_rhs', 1, len_Q2_rhs);

fileID = fopen('equations.txt','w');

Total_equations = m * m * (m+1)/2

Equation = 1;

Pk1 = zeros(v,v,'logical');
Pk2 = zeros(v,m,'logical');

for k=1:m   % For every row of Q2
    Pk1 = findPk1(Pk1,Q1(k,:),v,m);
    Pk2 = findPk2(Pk2,Q1(k,:),v,m);
    
    Pk3 = mod(transpose(T) * Pk1 * T + transpose(T) * Pk2, 2);
    
    for i=1:m
        % Generates equations for diagonal elements of Pk3.
        if i==col     % To select particular column of T, comment for whole T
            Q2 = Pk3(i,i)+Q2_rhs(Equation);
            Q2 = mod(subs(Q2, x.^2, x), 2);
            
            % Renaming variables in sequence for bosphorus sat solver
            difference = setdiff([1:v],known_indexes);
            Q2 = subs(Q2, x(difference), x(1:v-length(known_indexes)));
            
            fprintf(fileID, '%s\n', Q2);
            Equation
        end
        
        Equation = Equation + 1;
        
         for j=i+1:m
            % Comment following 4 lines if equations for non-diagonal elements of Pk3 not needed
            %Q2 = Pk3(i,j)+Pk3(j,i)+Q2_rhs(Equation);
            %Q2 = mod(subs(Q2, x.^2, x), 2);
            %fprintf(fileID, '%s\n', Q2);
            %Equation
            Equation = Equation + 1;
         end
    end
end

fclose(fileID);

toc