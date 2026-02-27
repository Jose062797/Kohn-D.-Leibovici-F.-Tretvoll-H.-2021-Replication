% This script sets all model parameters in the structure mp
 
% Baseline calibration

% Preference parameters: 
mp.beta 	= 0.98; 	% Discount factor
mp.gamma    = 2;        % Risk aversion
mp.nu       = 1.455;    % Labor curvature

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

if s.calib_psi_u == 1
    mp.psi_u    = 0.5;      % Labor weight in utility
else %s.calib_psi_u == 0
    
    if s.flag==3 || s.flag==5 || s.flag==6  || s.flag==15
        mp.psi_u = 0.40086;
    elseif s.flag==4 || s.flag==7 || s.flag==8  || s.flag==16
        mp.psi_u = 0.55809;
    else
        
        % check if there is a stored value for psi_u to use
        try
            load Results/savedPsiU.mat savedPsiU
            mp.psi_u 	= savedPsiU;
        catch
            error('Failed to load a stored value for psi_u.');
        end
   
    end
end

% Parameters to match time-series targets either for the Emerging or the
% Developed economy: 
if s.params_time_series_targets    == 'E'
    ts_vec  = [ 0.0120711     0.929806      7.66943      99.2186   -0.0838697 ];
else %s.params_time_series_targets == 'D'
    ts_vec  = [ 0.00741958     0.908501      2.60181       75.633   -0.0597892 ];
end

mp.Z_sd     = ts_vec(1);    % Productivity standard deviation
mp.Z_rho 	= ts_vec(2);    % Productivity persistence
mp.phiK     = ts_vec(3);    % Adjustment cost: aggregate investment
mp.phiKx    = ts_vec(4);    % Adjustment cost: sectoral allocation of capital
mp.phiNx    = mp.phiKx;     % Adjustment cost: sectoral allocation of labor
mp.eta_GDP  = ts_vec(5); 	% Sensitivity of interest rate to GDP

if s.flag == 9 || s.flag == 10 % No Z shock
    mp.Z_sd     = 0;
elseif s.flag == 13 || s.flag == 14 % No Z shock
   mp.phiKx    = 0;    % Adjustment cost: sectoral allocation of capital
   mp.phiNx    = mp.phiKx;
elseif s.flag == 15
    mp.Z_sd     = 0.00741958;    % Productivity standard deviation
    mp.Z_rho 	= 0.908501;      % Productivity persistence
    mp.phiK     = 2.60181;       % Adjustment cost: aggregate investment
    mp.phiKx    = 75.633;        % Adjustment cost: sectoral allocation of capital
    mp.phiNx    = mp.phiKx;      % Adjustment cost: sectoral allocation of labor
    
elseif s.flag == 16
    mp.Z_sd     = 0.0120711;    % Productivity standard deviation
    mp.Z_rho 	= 0.929806;     % Productivity persistence
    mp.phiK     = 7.66943;      % Adjustment cost: aggregate investment
    mp.phiKx    = 99.2186;      % Adjustment cost: sectoral allocation of capital
    mp.phiNx    = mp.phiKx;     % Adjustment cost: sectoral allocation of labor
    
end

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
