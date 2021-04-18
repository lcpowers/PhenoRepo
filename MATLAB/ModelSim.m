% Discrete Model Simulatioin

% boolean for displaying figures
fig_on = true;

T = 365; %days
time = 0:T;

[gcc,ncc] = PhenoModel(T,1,0.1,a,b,c);

% plot data
if fig_on == true
    % Plots
    plot(time,gcc,'g',time,ncc,'b');
    ylabel('Proportion of Pixels'); xlabel('Time (days)');
    legend('Green','Non-green','Location','northeast');
end
   