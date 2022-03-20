close all;
clear all;
clc;

x = [1000000 10000000 20000000 30000000 40000000 50000000 60000000 70000000 80000000 90000000 100000000];
y10 = [185 303 635 1334 1308 2293 2416 2828 2706 3801 3121];
y10 = round(y10/30)
y01 = [235 365 704 1195 1355 2117 2846 2799 2797 3047 4190];
y01 = round(y01/30)

plot(x, y10, '-b.', 'LineWidth', 5, 'MarkerSize', 48)
hold on;
plot(x, y01, '-rd', 'LineWidth', 5, 'MarkerSize', 24)
plot(x, y10+y01, '-ks', 'LineWidth', 5, 'MarkerSize', 24)

xlabel('Number of Hammers')
ylabel('Number of Bit Flips')
set(gca,'FontSize',36)
legend('1\rightarrow0 flips','0\rightarrow1 flips','Total flips')