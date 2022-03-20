%%
close all;
clear all;
clc;
v = 197;    % Vinegars
m = 57;     % Oils

%%%%%%%%%%%%%%%%%%%%%%%%%% 1 Hour %%%%%%%%%%%%%%%%%%%%%%%%%%%
rc = importdata("flips1h.txt");
map1h = zeros(v,m);
for i=1:length(rc)
    map1h(rc(i,1), rc(i,2)) = map1h(rc(i,1), rc(i,2)) + 1;    
end
num_bits1h = nnz(map1h);

%%%%%%%%%%%%%%%%%%%%%%%%%% 2 Hours %%%%%%%%%%%%%%%%%%%%%%%%%%%
rc = importdata("flips2h.txt");
map2h = zeros(v,m);
for i=1:length(rc)
    map2h(rc(i,1), rc(i,2)) = map2h(rc(i,1), rc(i,2)) + 1;    
end
num_bits2h = nnz(map2h);

%%%%%%%%%%%%%%%%%%%%%%%%%% 4 Hours %%%%%%%%%%%%%%%%%%%%%%%%%%%
rc = importdata("flips4h.txt");
map4h = zeros(v,m);
for i=1:length(rc)
    map4h(rc(i,1), rc(i,2)) = map4h(rc(i,1), rc(i,2)) + 1;    
end
num_bits4h = nnz(map4h);

%%%%%%%%%%%%%%%%%%%%%%%%%% 8 Hours %%%%%%%%%%%%%%%%%%%%%%%%%%%
rc = importdata("flips8h.txt");
map8h = zeros(v,m);
for i=1:length(rc)
    map8h(rc(i,1), rc(i,2)) = map8h(rc(i,1), rc(i,2)) + 1;    
end
num_bits8h = nnz(map8h);

%%%%%%%%%%%%%%%%%%%%%%%%%% 16 Hours %%%%%%%%%%%%%%%%%%%%%%%%%%%
rc = importdata("flips16h.txt");
map16h = zeros(v,m);
for i=1:length(rc)
    map16h(rc(i,1), rc(i,2)) = map16h(rc(i,1), rc(i,2)) + 1;    
end
num_bits16h = nnz(map16h);

font_size = 20;
subplot(1,5,1);
imshow(map1h)
axis on
title({'1 Hour';[num2str(num_bits1h), ' bits']})
ylabel('Rows of T_{197\times57}')
set(gca,'FontSize',font_size)

subplot(1,5,2);
imshow(map2h)
axis on
set(gca,'ytick',[])
title({'2 Hours';[num2str(num_bits2h), ' bits']})
set(gca,'FontSize',font_size)

subplot(1,5,3);
imshow(map4h);
axis on
set(gca,'ytick',[])
title({'4 Hours';[num2str(num_bits4h), ' bits']})
xlabel('Columns of T_{197\times57}')
set(gca,'FontSize',font_size)

subplot(1,5,4);
imshow(map8h);
axis on
set(gca,'ytick',[])
title({'8 Hours';[num2str(num_bits8h), ' bits']})
set(gca,'FontSize',font_size)

subplot(1,5,5);
imshow(map16h);
axis on
set(gca,'ytick',[])
title({'16 Hours';[num2str(num_bits16h), ' bits']})
set(gca,'FontSize',font_size)

%%

% Number of bits per column
for i=1:m
    bits_col1h(i) = nnz(map1h(:,i));
    bits_col2h(i) = nnz(map2h(:,i));
    bits_col4h(i) = nnz(map4h(:,i));
    bits_col8h(i) = nnz(map8h(:,i));
    bits_col16h(i) = nnz(map16h(:,i));
end

figure;
font_size = 36;
bar(bits_col16h)
xlim([1 57])
ylim([1 197])
hold on;
bar(bits_col8h)
bar(bits_col4h)
bar(bits_col2h)
bar(bits_col1h)
xlabel('Column number of T_{197\times57}')
ylabel('Bits recovered per col of T_{197\times57}')
legend('16h','8h','4h','2h','1h')
set(gca,'FontSize',font_size)

%%

% Import data from text file
% Script for importing data from the following text file:
%
%    filename: flips.txt
% Setup the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 2);
% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ",";
% Specify column names and types
opts.VariableNames = ["SatApr25170955EDT2020", "VarName2"];
opts.VariableTypes = ["double", "double"];
% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
% Import the data
flips = readtable("flips.txt", opts);
% Convert to output type
flips = table2array(flips);
% Clear temporary variables
clear opts
%

rc = flips;
map = zeros(v,m);
for i=1:length(rc)
    if isnan(rc(i,1)) == false
        map(rc(i,1), rc(i,2)) = map(rc(i,1), rc(i,2)) + 1;
    end
    for j=1:m
        bits_col(j) = nnz(map(:,j));
    end
    if max(bits_col)>=140
        [M,I] = max(bits_col)
        break
    end
end

i
% in flips.txt at i row, look for time stamp and calculate the time
% duration of the online phase at this instance
% which is 3h 39m in our case.

% Total number of bits recovered at this instance 
num_bits = nnz(map)
%writematrix(bits_col, 'bits_col.txt');

% Writing known indexes of col with max bits recovered
known = find(map(:,I));
writematrix(known, 'known_indexes_140.txt');

% Finding second max
bits_col(I) = -Inf;
[M2 I2] = max(bits_col)

% Finding third max
bits_col(I2) = -Inf;
[M3 I3] = max(bits_col)

% Finding fourth max
bits_col(I3) = -Inf;
[M4 I4] = max(bits_col)

figure;
font_size = 36;
bar(bits_col)
xlim([1 57])
ylim([1 197])
hold on;
b = bar(I,M);
xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', 24)
b = bar(I2,M2);
xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', 24)
b = bar(I3,M3);
xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', 24)
b = bar(I4,M4);
xtips1 = b(1).XEndPoints;
ytips1 = b(1).YEndPoints;
labels1 = string(b(1).YData);
text(xtips1,ytips1,labels1,'HorizontalAlignment','center','VerticalAlignment','bottom', 'FontSize', 24)

xlabel('Column number of T_{197\times57}')
ylabel('Bits recovered per col of T_{197\times57}')
%title('Number of bits recovered per column of T_{197\times57}')
legend('Attack Instance - 3h 49m','Highest - Col 5', '2^{nd} Highest - Col 23', '3^{rd} Highest - Col 7', '4^{th} Highest - Col 21')    % TODO: dont hardcode values
set(gca,'FontSize',font_size)