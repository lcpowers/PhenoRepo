% Phenology Model - NEON Challenge
% x = number of days to simulate
% start = starting date (Jan 1 = day 1)
% G_init = initial proportion of pixels that are green
% a, b, c = rates of movement between compartments

function [G,N] = PhenoModel(x,start,G_init,a,b,c)

% Parameters
beta = @(i) (0 * (i <= 100)) + ...
    (a * (i > 100 && i <= 130)) +...
     (0 * (i > 130 && i <= 290)) +...
     (0 * (i > 290 && i <= 310)) +...
     (0 * (i > 310));
delta = @(i) (0 * (i <= 100)) +...
    (0 * (i > 100 && i <= 130)) +...
    (b * (i > 130 && i <= 290)) +...
    (c * (i > 290 && i <= 310)) +...
    (0 * (i > 310));

% Create Vectors
%G = zeros(start + x + 1); N = zeros(start + x + 1);

% Initial conditions
G(start) = G_init;
N(start) = 1 - G_init;

% Model sim
for i = start+1:(start+x)
    
    G(i) = (1 - delta(i)) * G(i-1) + beta(i) * N(i-1);
    N(i) = (1 - beta(i)) * N(i-1) + delta(i) * G(i-1);

end

end




