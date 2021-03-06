% Parameter fitting
    % This file works with PhenoModel.m and ModelSim.m
    
clear all; clc;

% Import data
cd('C:\Users\17313\Documents\NEON\PhenoRepo\data\pheno\GRSM');
targets = readtable('GRSM_gccTargets.csv');
targets = targets{343:707,3}; % data for 2018

% Discrete Model Simulatioin
cd('C:\Users\17313\Documents\NEON\PhenoRepo\MATLAB');
% boolean for displaying figures
fig_on = true;

T = 364; %days
x = [0:T]';

 a = 0.0054031551;
 b = 0.0005266447;
 c = 0.0069854384;
 G_init = 0.3490258844;
 
 [gcc,ncc] = PhenoModel(T,1,G_init,a,b,c);

% a = .005;
% b = .0005;
% c = .01;
% G_init = 0.3475;


%% Fitting Model
% built in fit function did not work? Trying something else
%ft = fittype( 'PhenoModel(x,G_init,a,b,c)' );
%f=fit(x,targets,ft,'StartPoint',[.3475,.0055,.0005,.01]);
%[gcc,ncc] = PhenoModel(T,f.G_init,f.a,f.b,f.c);

% Grid search: every possible parameter combination [0,1]

% plot data
if fig_on == true
    plot(x,targets,'k'); hold on;
    ylabel('Proportion of Pixels'); xlabel('Time (days)');
    % Plots
    plot(x,gcc,'g'); hold off;
    ylabel('Proportion of Pixels'); xlabel('Time (days)');
    %legend('Green','Non-green','Location','northeast');
end

