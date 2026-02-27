% Run after model_results.m if you want results for this run saved in the
% file Results/generated_results.xls.
% Note: variables mp and s a loaded at the start of model_results.m

resfile     = 'Results/generated_results.xls';
% Name of IRFs file determined by the params_time_series_targets flag: 
if s.params_time_series_targets == 'E' 
    IRFfile     = 'Results/IRFs_E.mat';
else % s.params_time_series_targets == 'D' 
    IRFfile     = 'Results/IRFs_D.mat';
end
sheetName   = 'Results and params';

% Settings for this run of the code: 
xlswrite(resfile, {'Settings:', 'Cross section targets', 'Time series targets', ... 
	'Calib psi_u', 'hp_lambda'}, sheetName, 'A1');
xlswrite(resfile, [s.params_cross_section_targets, s.params_time_series_targets], sheetName, 'B2'); 
xlswrite(resfile, [s.calib_psi_u, s.hplambda], sheetName, 'D2');    % write char and int separately

% Rows for table 5:
xlswrite(resfile, {'Tab5 row1:', 'sd(Y)', 'sd(NX/Y)', 'rsd(C)', 'rsd(Inv)', ... 
    'rsd(N)', 'rsd(TFP)', 'rsd(pc)'}, sheetName, 'A4');
xlswrite(resfile, round(100*tab5_row1)/100, sheetName, 'B5');
xlswrite(resfile, {'Tab5 row2:', 'c(YY)', 'c(YNX/Y)', 'c(YC)', 'c(YInv)', 'c(YN)', 'c(YTFP)', 'c(Ypc)'}, sheetName, 'A6');
xlswrite(resfile, round(100*tab5_row2)/100, sheetName, 'B7');
xlswrite(resfile, {'Tab5_row3:', 'a(Y)', 'a(NX/Y)', 'a(C)', 'a(Inv)', 'a(N)', 'a(TFP)', 'a(pc)'}, sheetName, 'A8');
xlswrite(resfile, round(100*tab5_row3)/100, sheetName, 'B9');

% Row for table 9: 
xlswrite(resfile, {'Tab9 row:', 'rGDP', 'K^KS', 'N^LS', 'Z', 'End. TFP'}, sheetName, 'A11');
xlswrite(resfile, round(100*tab9_row)/100, sheetName, 'B12');

% Time-series targets:
xlswrite(resfile, {'Time-series targets:'}, sheetName, 'A14');
xlswrite(resfile, {'sd(Y)', 'aut(Y)', 'rsd(Inv)', 'sd(manf_sh)', 'c(Y,NX/Y)', ...
    'rsd(C)', 'sd(NX/Y)'}, sheetName, 'B15');
xlswrite(resfile, round(100*ts_targets)/100, sheetName, 'B16');
xlswrite(resfile, {'Dynamic parameters:'}, sheetName, 'A17');
xlswrite(resfile, {'Z_sd', 'Z_rho', 'phiK', 'phiKx', 'eta_GDP'}, sheetName, 'B18');
xlswrite(resfile, round(10000*[mp.Z_sd, mp.Z_rho, mp.phiK, mp.phiKx, mp.eta_GDP])/10000, ...
    sheetName, 'B19');

% Cross-sectional targets: 
xlswrite(resfile, {'Cross-sectional targets:'}, sheetName, 'A21');
xlswrite(resfile, {'manf_sh', 'comm_sh', 'manf_NX', 'NX/GDP', 'N_SS'}, sheetName, 'B22');
xlswrite(resfile, round(100*cs_targets)/100, sheetName, 'B23');
xlswrite(resfile, {'Steady-state parameters:'}, sheetName, 'A24');
xlswrite(resfile, {'Am', 'eta', 'etaT', 'b', 'psi_u'}, sheetName, 'B25');
xlswrite(resfile, round(1000*[mp.Am, mp.eta, mp.etaT, mp.b, mp.psi_u])/1000, sheetName, 'B26');

% Other parameters for this run: 
xlswrite(resfile, {'Other parameters:'}, sheetName, 'A28');
pPerRow     = 9;    % write 2 lines of 9 parameters for easier to read Excel files
for rows = 0:1 
    pnameRow    = {};
    pvalRow     = {};
    for pp = 1:pPerRow 
        pnameRow{pp}    = mp.paramNames{pp+rows*pPerRow};
        pvalRow{pp}     = mp.paramVals(pp+rows*pPerRow);
        xlswrite(resfile, pnameRow, sheetName, strcat('B',num2str(29+rows*2)));
        xlswrite(resfile, pvalRow,  sheetName, strcat('B',num2str(30+rows*2)));
    end
end

% Save IRFs - Note IRFs in the paper produced from 1st order approximation in Dynare: 
% Also note that for the developed economy's response to a productivity shock, we 
% want to feed in the same sequence of shocks that hit the emerging economy to make the IRFs
% comparable. That means a shock of one emerging-country-standard
% deviation, with the emerging-country-persistence. 
if s.params_cross_section_targets  == 'D' && ...
   s.params_time_series_targets    == 'D'
    lenIRF    = options_.irf;
	EM_sd_Z   = 0.0120711;    
	EM_rho_Z  = 0.929806;
	DEV_sd_Z  = 0.00741958;
    shockZ    = [0; 1; 0]*EM_sd_Z/DEV_sd_Z;      % scale shock to EM sd
   
    % State and control variables in Dynare: 
    state_vars      = oo_.dr.state_var;
    control_vars    = oo_.dr.order_var(~ismember(oo_.dr.order_var, state_vars))';
    
    % State space representation: 
    A = oo_.dr.ghx(oo_.dr.inv_order_var(state_vars),:);
    B = oo_.dr.ghu(oo_.dr.inv_order_var(state_vars),:);   
    C = oo_.dr.ghx(oo_.dr.inv_order_var(control_vars),:);
    D = oo_.dr.ghu(oo_.dr.inv_order_var(control_vars),:);

    Zindex      = 0;
    for i=1:length(M_.endo_names)
        if strcmp(M_.endo_names{i}, 'Z')
            Zindex  = i;
            break;
        end
    end
    % Change persistence coefficient to EM value: 
    A(find(state_vars==Zindex),find(state_vars==Zindex))    = EM_rho_Z;

    % Compute adjusted IRFs: 
    SVirf       = zeros(length(state_vars), lenIRF);
    CVirf       = zeros(length(control_vars), lenIRF);
    SVirf(:,1)  = B*shockZ;
    CVirf(:,1)  = D*shockZ;

    for q = 2:lenIRF
        SVirf(:,q) = A*SVirf(:,q-1);
        CVirf(:,q) = C*SVirf(:,q-1);
    end
    
    rGDPindex   = 0;
    for i=1:length(M_.endo_names)
        if strcmp(M_.endo_names{i}, 'rGDP')
            rGDPindex  = i;
            break;
        end
    end
    
    TFP_eps_Z   = SVirf(find(state_vars==Zindex),:)';
    rGDP_eps_Z  = CVirf(find(control_vars==rGDPindex),:)';
end

% Map IRFs from oo_.irfs struct (Dynare 6.x) to local variables
% For flag=1 (Emerging, 2nd order), use oo_.irfs directly
if ~exist('TFP_eps_Z', 'var')
    if isfield(oo_.irfs, 'TFP_eps_Z')
        TFP_eps_Z  = oo_.irfs.TFP_eps_Z';
        rGDP_eps_Z = oo_.irfs.rGDP_eps_Z';
    else
        TFP_eps_Z  = zeros(options_.irf, 1);
        rGDP_eps_Z = zeros(options_.irf, 1);
    end
end
if ~exist('pc_eps_pc', 'var')
    pc_eps_pc   = oo_.irfs.pc_eps_pc';
    rGDP_eps_pc = oo_.irfs.rGDP_eps_pc';
    Ns_eps_pc   = oo_.irfs.Ns_eps_pc';
    C_eps_pc    = oo_.irfs.C_eps_pc';
    Inv_eps_pc  = oo_.irfs.Inv_eps_pc';
    NX_eps_pc   = oo_.irfs.NX_eps_pc';
end

% Figure 2:
IRFs_fig2   = [TFP_eps_Z rGDP_eps_Z];

% Figure 3: 
IRFs_fig3   = [pc_eps_pc rGDP_eps_pc];

% Figure 4: 
IRFs_fig4 	= [IRFs_fig3 Ns_eps_pc C_eps_pc Inv_eps_pc NX_eps_pc];

save(IRFfile, 'IRFs_fig2', 'IRFs_fig3', 'IRFs_fig4');
