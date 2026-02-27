% This script sets all model parameters in the structure mp
% for multiple countries

% Preference parameters: 
mp.beta 	= 0.98; 	% Discount factor
mp.gamma    = 2;        % Risk aversion
mp.nu       = 1.455;    % Labor curvature

mp.psi_u    = 0;      % Labor weight in utility (will be overwritten)
s.calib_psi_u = 0;

% Technology parameters: 
mp.sigma    = 0.5;      % Eos between T and NT (if =1, set flag in Dynare .mod file)
mp.sigmaT   = 1;        % Eos between M and C  (if =1, set flag in Dynare .mod file)
mp.theta_n  = 0.25;     % Capital share NT
mp.theta_m  = 0.35;     % Capital share M
mp.theta_c  = 0.35;     % Capital share C
mp.mu       = 0.85;     % Decr. returns
mp.delta    = 0.05;     % Depreciation
mp.Ac       = 1;        % Normalized productivity 
mp.An       = 1;        % Normalized productivity 

% Interest rate:
mp.psi_r    = 0.001;            % Debt elasticity of interest rate
mp.rstar    = (1/mp.beta - 1);  % World interest rate
mp.S_ss     = 0;                % Log of SS (gross) spread

% Estimated process for relative price of commodities/manufactured goods
mp.pc_rho   = 0.957; 	% Persistence
mp.pc_sd    = 0.0591; 	% Standard deviation
mp.pc_SS    = 1;        % SS relative price

% Parameters calibrated to cross-sectional targets:
% (Need a guess to start calibration)
mp.Am       = 1.05;     % SS productivity M
mp.eta      = 0.5;      % Share of T in final goods
mp.etaT     = 0.5;      % Share of M in tradable goods
mp.b        = 0.1;      % SS debt

mp.Z_sd     = 0.00741958;    % Productivity standard deviation
mp.Z_rho 	= 0.908501;      % Productivity persistence
mp.phiK     = 2.60181;       % Adjustment cost: aggregate investment
mp.phiKx    = 75.633;      
mp.phiNx    = mp.phiKx; 
mp.eta_GDP  = -0.0838697; 

% Store names and values of all parameters for easy access:                         
mp.paramNames = { 'beta', 'gamma', 'nu', 'sigma', 'sigmaT', 'theta_n', 'theta_m', 'theta_c', ... 
    'mu', 'delta', 'Ac', 'An', 'psi_r', 'rstar', 'S_ss', 'pc_rho', 'pc_sd', 'pc_SS', ...
    'Am', 'eta', 'etaT', 'b', 'psi_u', ...
    'Z_sd', 'Z_rho', 'phiK', 'phiKx', 'phiNx', 'eta_GDP' };
    
mp.paramVals = [mp.beta, mp.gamma, mp.nu, mp.sigma, mp.sigmaT, mp.theta_n, mp.theta_m, mp.theta_c, ... 
    mp.mu, mp.delta, mp.Ac, mp.An, mp.psi_r, mp.rstar, mp.S_ss, mp.pc_rho, mp.pc_sd, mp.pc_SS, ...
    mp.Am, mp.eta, mp.etaT, mp.b, mp.psi_u, ...                     % SS calibrated 
    mp.Z_sd, mp.Z_rho, mp.phiK, mp.phiKx, mp.phiNx, mp.eta_GDP ...  % SMM calibrated
    ];





    
