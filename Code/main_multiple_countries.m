%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code to reproduce results in the paper 
% "Trade in Commodities and Business Cycle Volatility"  
% by David Kohn, Fernando Leibovici and H�kon Tretvoll. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clc;
clear;
close all;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Control Panel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Dynare must be available on the Matlab path
addpath C:\dynare\6.4\matlab

% Setup for this run of the code: 
s.saveResults 	= 1;   % = 1 => results for this run saved in 
	% Results/generated_results_multiple_countries.xls 
% Create folder Results if it does not exist
mkdir Results  

s.calib_ss       = 0;   % 1 = calibrate [b,eta,eta_T,Am] to steady state moments
% Run once to generate file 'calibrated_parameters.xls', then set to 0

s.hplambda      = 100;    

% Model Parameters
setmodelparameters_multiple_countries;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Steady-state calibration of [Am,eta,etaT,b,psi_u]:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if s.calib_ss == 1

    [moments_data,labels_data] = xlsread('Table4_XSectionalMoments_CountryByCountry.csv');
    country_names=labels_data(3:end,1);
    ss_calib_countries =zeros(size(moments_data,1),4);
    
    for row=1:size(moments_data,1)

        ss_targets.mfct_GDP         = moments_data(row,1); 
        ss_targets.commodities_GDP  = moments_data(row,2);
        ss_targets.NXmfct_GDP       = moments_data(row,3);
        ss_targets.NX_GDP           = moments_data(row,4);
        ss_targets.country_cat      = moments_data(row,5);
         
        % Initial guess
        mp.Am       = 1.05;    
        mp.b        = 0.1;     
        mp.eta      = 0.5;     
        mp.etaT     = 0.5;     
        
        calib_guess     = [mp.Am, mp.eta, mp.etaT, mp.b];
        
        if ss_targets.country_cat == 2 % Developed
            
            vec=[ 0.00741958     0.908501      2.60181       75.633   -0.0597892 ]; %Dev
            
            mp.Z_sd    = vec(1) ;
            mp.Z_rho 	=vec(2);  
            mp.phiK     =vec(3);
            mp.phiKx    =vec(4);              
            mp.phiNx    =mp.phiKx; 
            mp.eta_GDP = vec(5);
            mp.psi_u    = 0.558090333046562;

        elseif ss_targets.country_cat==1 %Emerging

            vec=[ 0.0120711     0.929806      7.66943      99.2186   -0.0838697 ]; %EM

            mp.Z_sd    = vec(1) ;
            mp.Z_rho 	=vec(2); 
            mp.phiK     =vec(3);
            mp.phiKx    =vec(4);              
            mp.phiNx    =mp.phiKx; 
            mp.eta_GDP = vec(5);
            mp.psi_u    =  0.400862634795429;
        
        end

        options     = optimset('MaxFunEvals',50000,'MaxIter',50000,'Display','iter');
        [ss_calib,obj]  = fsolve(@(calib)model_calib_ss(calib,ss_targets,mp,s),calib_guess,options);

        fprintf(1,'Steady_state calibration for economy %d is done. Results:\n', row);
        fprintf(1,'mp.Am = %.10f;\nmp.b = %.10f;\nmp.etaT = %.10f;\nmp.eta = %.10f;\n', ss_calib );
            
        ss_calib_countries(row,:)=ss_calib;
        
    end
    
    xlswrite('Results/calibrated_parameters.xls', [{'Country'}, {' '},{'Target Moments'},{' '}, {' '}, {' '},{'Calibrated Parameters'},{' '},{' '}],'Calibrated Parameters','A1');
    xlswrite('Results/calibrated_parameters.xls', [{' '},{'ss_targets.mfct_GDP'},{'ss_targets.commodities_GDP'},{'ss_targets.NXmfct_GDP'}, {'ss_targets.NX_GDP'},{'Am'},{'eta'},{'etaT'},{'b'}],'Calibrated Parameters','A2');
    xlswrite('Results/calibrated_parameters.xls',{'Country Category'},'Calibrated Parameters','J1');
    xlswrite('Results/calibrated_parameters.xls',country_names,'Calibrated Parameters','A3');
    xlswrite('Results/calibrated_parameters.xls',moments_data(:,1:4),'Calibrated Parameters','B3');
    xlswrite('Results/calibrated_parameters.xls',ss_calib_countries,'Calibrated Parameters','F3');
    xlswrite('Results/calibrated_parameters.xls',moments_data(:,5),'Calibrated Parameters','J3');
    
    return;
    
end  

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute results using generated excel 'calibrated_parameters.xls' 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for row=1:76 
    
    setmodelparameters_multiple_countries
    
    calibrated_parameters = xlsread('Results/calibrated_parameters.xls','Calibrated Parameters');
    s.calibrated_parameters = calibrated_parameters(:,5:9); %Am, eta, etaT, b
   
    mp.Am    = s.calibrated_parameters(row,1);
    mp.eta   = s.calibrated_parameters(row,2);
    mp.etaT   = s.calibrated_parameters(row,3);
    mp.b = s.calibrated_parameters(row,4);
    
    if s.calibrated_parameters(row,5)==1 % Emerging
        
        ts_vec  = [ 0.0120711     0.929806      7.66943      99.2186   -0.0838697 ];     
        mp.psi_u = 0.400862634795429;
    
    elseif s.calibrated_parameters(row,5) == 2 % Developed 
       
        ts_vec  = [ 0.00741958     0.908501      2.60181       75.633   -0.0597892 ];    
        mp.psi_u = 0.558090333046562;
            
    end

    mp.Z_sd    = ts_vec(1) ;
    mp.Z_rho	  = ts_vec(2);  
    mp.phiK    = ts_vec(3);
    mp.phiKx   = ts_vec(4);              
    mp.phiNx   = mp.phiKx; 
    mp.eta_GDP = ts_vec(5);
        
    s.row=row;

    % Solve for the steady-state
    options     = optimset('MaxFunEvals',50000,'MaxIter',50000,'Display','iter');
    ss          = model_ss(mp,options);
    save_to_dynare(mp, ss);     % Dynare needs access to parameters and steady state
    save model_setup.mat s mp; 	% model_results needs access to s

    % Cleanup Dynare folder from previous iteration (OneDrive can lock it)
    % Retry up to 10 times with 3s pause to wait for OneDrive to release lock
    if exist('model_file_dynare', 'dir')
        for cleanup_attempt = 1:10
            try
                rmdir('model_file_dynare', 's');
                break;
            catch
                pause(3);
            end
        end
    end

    % Run Dynare
    eval('dynare model_file_dynare.mod');

    % Calculate and save implied model results for this set of parameters
    model_results; %_multiple_countries;

    s.table_paper_panelA(s.row,:)=tab5_row1;
    s.table_paper_panelB(s.row,:)=tab5_row2;
    s.table_paper_panelC(s.row,:)=tab5_row3;

end        

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save tables with results in Excel file
% 'Results/generated_results_multiple_countries.xls'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

resfile     = 'Results/generated_results_multiple_countries.xls';
 
[moments_data,labels_data] = xlsread('Table4_XSectionalMoments_CountryByCountry.csv');
country_names=labels_data(3:end,1);
 
% Table of business cycle moments in the paper:
xlswrite(resfile, {'Country'}, 'Table_BC', 'A3');
xlswrite(resfile, country_names, 'Table_BC', 'A4');

xlswrite(resfile, {'A. Volatilities'}, 'Table_BC', 'A1');
xlswrite(resfile, {'Std.dev', ' ', 'Std.dev. relative to GDP'}, 'Table_BC', 'B2');
xlswrite(resfile, {'GDP', 'NX/GDP', 'C', 'I', 'N', 'TFP','p_c'}, 'Table_BC', 'B3');
xlswrite(resfile, s.table_paper_panelA, 'Table_BC','B4');

xlswrite(resfile, {'B. Correlation with GDP'}, 'Table_BC', 'K1');
xlswrite(resfile, {'Country'}, 'Table_BC', 'K3');
xlswrite(resfile, country_names, 'Table_BC', 'K4');

xlswrite(resfile, {'GDP', 'NX/GDP', 'C', 'I', 'N', 'TFP','p_c'}, 'Table_BC', 'L3');
xlswrite(resfile, s.table_paper_panelB, 'Table_BC', 'L4');

xlswrite(resfile, {'C. Autocorrelation'}, 'Table_BC', 'U1');
xlswrite(resfile, {'Country'}, 'Table_BC', 'U3');
xlswrite(resfile, country_names, 'Table_BC', 'U4');
xlswrite(resfile, {'GDP', 'NX/GDP', 'C', 'I', 'N', 'TFP','p_c'}, 'Table_BC', 'V3');
xlswrite(resfile, s.table_paper_panelC, 'Table_BC', 'V4');


pause(3);
% Plot Figures 5 and 6 in the paper
plot_multiple_countries;

% Cleanup of temp files: 
pause(3);

delete model_file_dyn*.eps;
delete model_file_dyn*.m;
delete model_file_dyn*.log;
delete *.asv;
delete *.mat;
if exist('model_file_dynare_simul', 'file')
    delete model_file_dynare_simul
end
if exist('model_file_dynare', 'dir')
    rmdir('model_file_dynare', 's')
end


