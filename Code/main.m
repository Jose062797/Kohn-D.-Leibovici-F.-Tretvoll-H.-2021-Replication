%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code to reproduce results in the paper 
% "Trade in Commodities and Business Cycle Volatility" 
% by David Kohn, Fernando Leibovici and H�kon Tretvoll. 
%
% January 2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Select model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

s.flag = 16; 

% 1 Emerging economy, baseline
% 2 Developed economy, baseline
% 3 Emerging economy, cross-sectional moments from developed economy
% 4 Developed economy, cross-sectional moments from emerging economy
% 5 Emerging economy, Mfct NX / GDP from developed economy
% 6 Emerging economy, Mfct NX / GDP and NT share from developed economy
% 7 Developed economy, Mfct NX / GDP from emerging economy
% 8 Developed economy, Mfct NX / GDP and NT share from emerging economy
% 9 Emerging economy, No Z shock
% 10 Developed economy, No Z shock
% 11 Emerging economy, first order IRFs
% 12 Developed economy, first order IRFs
% 13 Emerging economy, no sectoral adj. costs
% 14 Developed economy, no sectoral adj. costs
% 15 Emerging economy, cross-sectional moments + prod. process + adj. costs
% from developed economy
% 16 Developed economy,  cross-sectional moments + prod. process + adj. costs
% from emerging economy


%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Control Panel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dynare must be available on the Matlab path
addpath C:\dynare\6.4\matlab

% Setup for this run of the code: 
s.saveResults 	= 1;   % = 1 => results for this run saved in 
	% Results/generated_results.xls 
	% and IRFs saved in Results/IRFs.mat

% Create folder Results if it does not exist
mkdir Results    
    
% Set up model selection given flag
control_flags;

% Model Parameters
setmodelparameters;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Steady-state calibration of [Am,eta,etaT,b,psi_u]:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

calib_guess     = [mp.Am, mp.eta, mp.etaT, mp.b];
if s.calib_psi_u == 1
    calib_guess 	= [calib_guess, mp.psi_u];
end

options     = optimset('MaxFunEvals',2500000,'MaxIter',2500000,'Display','iter');
[ss_calib,obj]  = fsolve(@(calib)model_calib_ss(calib,ss_targets,mp,s),calib_guess,options); 

fprintf(1,'Steady_state calibration for economy %c is done. Results:\n', s.params_cross_section_targets);
if s.calib_psi_u == 1
    fprintf(1,'mp.Am = %.5f;\nmp.eta = %.5f;\nmp.etaT = %.5f;\nmp.b = %.5f;\nmp.psi_u = %.5f;\n', ss_calib );
else
    fprintf(1,'mp.Am = %.5f;\nmp.eta = %.5f;\nmp.etaT = %.5f;\nmp.b = %.5f;\n', ss_calib );   
end

% Store calibrated parameters:
mp.Am = ss_calib(1);  mp.eta = ss_calib(2);  mp.etaT = ss_calib(3);  mp.b = ss_calib(4);

% Also update mp.paramVals
mp.paramVals(strcmp(mp.paramNames, 'Am'))   = mp.Am;  
mp.paramVals(strcmp(mp.paramNames, 'eta'))  = mp.eta;
mp.paramVals(strcmp(mp.paramNames, 'etaT')) = mp.etaT; 
mp.paramVals(strcmp(mp.paramNames, 'b'))    = mp.b;  
if s.calib_psi_u == 1
   mp.psi_u 	= ss_calib(5); 
   mp.paramVals(strcmp(mp.paramNames, 'psi_u'))    = mp.psi_u;
   savedPsiU    = mp.psi_u;
   
   % Save calibrated psi_u to load in counterfactual exercise:
   save Results/savedPsiU.mat savedPsiU;     % Save in Results to prevent deleting during cleanup
end


%% Produce model results for the given set of parameters

% Solve for the steady-state
options     = optimset('MaxFunEvals',2500000,'MaxIter',2500000,'Display','iter');
ss          = model_ss(mp,options);
save_to_dynare(mp, ss);     % Dynare needs access to parameters and steady state
save model_setup.mat s mp; 	% model_results needs access to s, save_results needs access to mp

% Solve for policy functions:
if s.flag == 11 || s.flag == 12
    eval('dynare model_file_dynare_first_order.mod');
else
    eval('dynare model_file_dynare.mod');
end

% Calculate model results for this set of parameters:
model_results;

% Save results? 
if s.saveResults == 1
    save_results;
end

% Cleanup of temp files: 
pause(3);

delete model_file_dyn*.eps;
delete model_file_dyn*.m;
delete model_file_dyn*.log;
delete *.asv;
delete *.mat;

if s.flag == 11 || s.flag == 12
    if exist('model_file_dynare_first_order', 'dir')
        rmdir('model_file_dynare_first_order', 's')
    end
else
    if exist('model_file_dynare', 'dir')
        rmdir('model_file_dynare', 's')
    end
end
