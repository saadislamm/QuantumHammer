close all;
clear all;
clc;

c = importdata("c.txt");

plot(c(1200:1400), '-b.', 'LineWidth', 2, 'MarkerSize', 24)
xlim([0 200])
xlabel('Page Number')
ylabel('Cycles')
set(gca,'FontSize',36)