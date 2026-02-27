% After running Dynare, we must reload model_setup
load model_setup.mat
% NOTE: model_results can access parameters and steady state from Dynare, 

simulations       = options_.simul_replic;
numQuarters       = options_.periods-options_.drop;
simulation_array  = get_simul_replications(M_,options_);
simulation_array  = simulation_array(:,options_.drop+1:end,:);  % Drop 'burn' period

GDP         = zeros(numQuarters,simulations);
NX          = zeros(numQuarters,simulations);
C           = zeros(numQuarters,simulations);
Inv         = zeros(numQuarters,simulations);
Ns          = zeros(numQuarters,simulations);
Z           = zeros(numQuarters,simulations);     % For TFP calculation
K           = zeros(numQuarters,simulations);     % For TFP calculation
pc          = zeros(numQuarters,simulations);
SHm         = zeros(numQuarters,simulations);     
p_GDPdef    = zeros(numQuarters,simulations);   
p_CPI       = zeros(numQuarters,simulations);
p_CES       = zeros(numQuarters,simulations);

% First, fetch all simulations for each variable ('burn' dropped above)
for sim = 1:simulations    
    GDP(:,sim)      = squeeze(simulation_array(find(strcmp(M_.endo_names, 'GDP')),:,sim))';
    NX(:,sim)       = squeeze(simulation_array(find(strcmp(M_.endo_names, 'NX')),:,sim))';            
    C(:,sim)        = squeeze(simulation_array(find(strcmp(M_.endo_names, 'C')),:,sim))';  
    Inv(:,sim)      = squeeze(simulation_array(find(strcmp(M_.endo_names, 'Inv')),:,sim))';
    Ns(:,sim)       = squeeze(simulation_array(find(strcmp(M_.endo_names, 'Ns')),:,sim))';        
    Z(:,sim)        = exp(squeeze(simulation_array(find(strcmp(M_.endo_names, 'Z')),:,sim))');    
    K(:,sim)        = squeeze(simulation_array(find(strcmp(M_.endo_names, 'K')),:,sim))';
    pc(:,sim)       = squeeze(simulation_array(find(strcmp(M_.endo_names, 'pc')),:,sim))';     
    SHm(:,sim)      = squeeze(simulation_array(find(strcmp(M_.endo_names, 'SHm')),:,sim))';   
    p_GDPdef(:,sim) = squeeze(simulation_array(find(strcmp(M_.endo_names, 'p_GDPdef')),:,sim))';
    p_CPI(:,sim)    = squeeze(simulation_array(find(strcmp(M_.endo_names, 'p_CPI')),:,sim))';
    p_CES(:,sim)    = squeeze(simulation_array(find(strcmp(M_.endo_names, 'p')),:,sim))';
end

% Second, convert simulated quarterly series to annual
numYears        = floor(numQuarters/4);

A_GDP       = zeros(numYears,simulations);
A_rGDP      = zeros(numYears,simulations); 
A_NX        = zeros(numYears,simulations);
A_C         = zeros(numYears,simulations);
A_Inv       = zeros(numYears,simulations);
A_Ns        = zeros(numYears,simulations);
A_TFP       = zeros(numYears-1,simulations);
A_pc        = zeros(numYears,simulations);
A_SHm       = zeros(numYears,simulations);
A_p_GDPdef  = zeros(numYears,simulations);
A_p_CPI     = zeros(numYears,simulations);

A_rGDP_K    = zeros(numYears-1,simulations);
A_rGDP_N    = zeros(numYears-1,simulations);
A_rGDP_TFPex = zeros(numYears-1,simulations);
A_rGDP_TFPen = zeros(numYears-1,simulations);
        
for sim=1:simulations
    t           = 1;
    for i=1:numQuarters
      if rem(i,4)==0
        A_p_GDPdef(t,sim)  = mean(exp(p_GDPdef(i-3:i,sim)));
        A_p_CPI(t,sim)     = mean(exp(p_CPI(i-3:i,sim)));

        A_GDP(t,sim) 	= log(sum(exp(GDP(i-3:i,sim))));
        A_rGDP(t,sim)   = log(exp(A_GDP(t,sim))/A_p_GDPdef(t,sim));
        A_C(t,sim)      = log(sum( exp(p_CES(i-3:i,sim)).*exp(C(i-3:i,sim)) )/A_p_CPI(t,sim) );
        A_Inv(t,sim)    = log(sum( exp(p_CES(i-3:i,sim)).*exp(Inv(i-3:i,sim)) )/A_p_CPI(t,sim) );
        % Ns is fraction of time spent working --> can't add up over quarters
        A_Ns(t,sim)     = log(mean(exp(Ns(i-3:i,sim))));
        A_NX(t,sim)     = sum(NX(i-3:i,sim)); % NX is not logged, nominal
        if t >= 2       % TFP slightly different due to the timing of K
          A_TFP(t-1,sim)    = log( exp(A_rGDP(t,sim))/(mean(exp(K(i-4:i-1,sim)))^KSss * ...
                            exp(A_Ns(t,sim))^LSss ) );
        end
        A_SHm(t,sim)    = log(mean(exp(SHm(i-3:i,sim))));
        A_pc(t,sim)     = log(mean(exp(pc(i-3:i,sim))));
            
        t=t+1;
      end
    end

    t           = 1;
    for i=5:numQuarters
      if rem(i,4)==0
        A_rGDP_K(t,sim)     = log(mean(exp(K(i-4:i-1,sim)))^KSss );     % Note the different timing of K
        A_rGDP_N(t,sim)     = log(mean(exp(Ns(i-3:i,sim)))^LSss );
        A_rGDP_TFPex(t,sim) = log(mean(exp(Z(i-3:i,sim))));
        A_rGDP_TFPen(t,sim) = log( exp(A_rGDP(t+1,sim)) / (exp(A_rGDP_K(t,sim))*exp(A_rGDP_N(t,sim))*exp(A_rGDP_TFPex(t,sim))) );
            
        t=t+1;
      end
    end
end

% Overwrite quarterly series with annual series
GDP         = A_GDP;
rGDP        = A_rGDP;
NX          = A_NX;         % Nominal
NXGDP       = NX./exp(GDP);
C           = A_C;
Inv         = A_Inv;
Ns          = A_Ns;
TFP         = A_TFP;
pc          = A_pc;
SHm         = A_SHm;

rGDP_K      = A_rGDP_K;
rGDP_N      = A_rGDP_N;
rGDP_TFPex  = A_rGDP_TFPex;
rGDP_TFPen  = A_rGDP_TFPen;

% Third, hpfilter relevant variables and calculate moments 
for sim = 1:simulations
    [~, rGDP(:,sim)]  = sample_hp_filter(rGDP(:,sim),  s.hplambda);
    [~, NXGDP(:,sim)] = sample_hp_filter(NXGDP(:,sim), s.hplambda); %In levels
    [~, C(:,sim)]     = sample_hp_filter(C(:,sim),     s.hplambda);
    [~, Inv(:,sim)]   = sample_hp_filter(Inv(:,sim),   s.hplambda);    
    [~, Ns(:,sim)]    = sample_hp_filter(Ns(:,sim),    s.hplambda);
    [~, TFP(:,sim)]   = sample_hp_filter(TFP(:,sim),   s.hplambda);

    [~, rGDP_K(:,sim)]     = sample_hp_filter(rGDP_K(:,sim),     s.hplambda);  
    [~, rGDP_N(:,sim)]     = sample_hp_filter(rGDP_N(:,sim),     s.hplambda);  
    [~, rGDP_TFPex(:,sim)] = sample_hp_filter(rGDP_TFPex(:,sim), s.hplambda);  
    [~, rGDP_TFPen(:,sim)] = sample_hp_filter(rGDP_TFPen(:,sim), s.hplambda);  
end 

for sim=1:simulations
    rGDP(:,sim)     = rGDP(:,sim)  - mean(rGDP(:,sim));
    NXGDP(:,sim)    = NXGDP(:,sim) - mean(NXGDP(:,sim));
    C(:,sim)        = C(:,sim)     - mean(C(:,sim));
    Inv(:,sim)      = Inv(:,sim)   - mean(Inv(:,sim));
    Ns(:,sim)       = Ns(:,sim)    - mean(Ns(:,sim));
    TFP(:,sim)      = TFP(:,sim)   - mean(TFP(:,sim));
    pc(:,sim)       = pc(:,sim)    - mean(pc(:,sim));

    rGDP_K(:,sim)     = rGDP_K(:,sim)     - mean(rGDP_K(:,sim));
    rGDP_N(:,sim)     = rGDP_N(:,sim)     - mean(rGDP_N(:,sim));
    rGDP_TFPex(:,sim) = rGDP_TFPex(:,sim) - mean(rGDP_TFPex(:,sim));
    rGDP_TFPen(:,sim) = rGDP_TFPen(:,sim) - mean(rGDP_TFPen(:,sim));
end




% Build all rows with results: 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Table 5, row 1 - Standard deviations (generally relative to rGDP):
sd_rGDP_vec=zeros(simulations,1);  sd_NXGDP_vec=zeros(simulations,1);  sd_C_vec=zeros(simulations,1);
sd_Inv_vec=zeros(simulations,1);   sd_Ns_vec=zeros(simulations,1);     sd_TFP_vec=zeros(simulations,1);
sd_pc_vec=zeros(simulations,1);    sd_SHm_vec=zeros(simulations,1);   

sd_rGDP_K_vec=zeros(simulations,1);         sd_rGDP_N_vec=zeros(simulations,1);
sd_rGDP_TFPex_vec=zeros(simulations,1);     sd_rGDP_TFPen_vec=zeros(simulations,1);
       
for sim = 1:simulations
    sd_rGDP_vec(sim,1)     = 100*std(rGDP(:,sim));
    sd_NXGDP_vec(sim,1)    = 100*std(NXGDP(:,sim));
    sd_C_vec(sim,1)        = 100*std(C(:,sim));
    sd_Inv_vec(sim,1)      = 100*std(Inv(:,sim));
    sd_Ns_vec(sim,1)       = 100*std(Ns(:,sim));
    sd_TFP_vec(sim,1)      = 100*std(TFP(:,sim));    
    sd_pc_vec(sim,1)       = 100*std(pc(:,sim));
    
    sd_SHm_vec(sim,1)      = 100*std(SHm(:,sim));

    sd_rGDP_K_vec(sim,1)        = 100*std(rGDP_K(:,sim));
    sd_rGDP_N_vec(sim,1)        = 100*std(rGDP_N(:,sim));
    sd_rGDP_TFPex_vec(sim,1)    = 100*std(rGDP_TFPex(:,sim));
    sd_rGDP_TFPen_vec(sim,1)    = 100*std(rGDP_TFPen(:,sim));
end

sdY         = mean(sd_rGDP_vec);
tab5_row1   = [ sdY mean(sd_NXGDP_vec) mean(sd_C_vec)/sdY mean(sd_Inv_vec)/sdY ... 
                mean(sd_Ns_vec)/sdY mean(sd_TFP_vec)/sdY mean(sd_pc_vec)/sdY ];
            
tab9_row   = [ sdY/sdY mean(sd_rGDP_K_vec)/sdY mean(sd_rGDP_N_vec)/sdY ...
                mean(sd_rGDP_TFPex_vec)/sdY mean(sd_rGDP_TFPen_vec)/sdY ];
        
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Table 5, row 2 - Correlations with real GDP:
c_rGDP_NXGDP_vec=zeros(simulations,1);  c_rGDP_C_vec=zeros(simulations,1);   c_rGDP_Inv_vec=zeros(simulations,1);
c_rGDP_Ns_vec=zeros(simulations,1);     c_rGDP_TFP_vec=zeros(simulations,1); c_rGDP_pc_vec=zeros(simulations,1);
    
for sim = 1:simulations
    c_rGDP_NXGDP_vec(sim,1) = corr(rGDP(:,sim),NXGDP(:,sim));
    c_rGDP_C_vec(sim,1)     = corr(rGDP(:,sim),C(:,sim)); 
    c_rGDP_Inv_vec(sim,1)   = corr(rGDP(:,sim),Inv(:,sim)); 
    c_rGDP_Ns_vec(sim,1)    = corr(rGDP(:,sim),Ns(:,sim)); 
    c_rGDP_TFP_vec(sim,1)   = corr(rGDP(2:end,sim),TFP(:,sim));
    c_rGDP_pc_vec(sim,1)    = corr(rGDP(:,sim),pc(:,sim));
end

tab5_row2   = [ 1 mean(c_rGDP_NXGDP_vec) mean(c_rGDP_C_vec) mean(c_rGDP_Inv_vec) ... 
                mean(c_rGDP_Ns_vec) mean(c_rGDP_TFP_vec) mean(c_rGDP_pc_vec) ];

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Table 5, row 3 - Autocorrelations:  
aut_rGDP_vec=zeros(simulations,1);  aut_NXGDP_vec=zeros(simulations,1);     aut_C_vec=zeros(simulations,1);
aut_Inv_vec=zeros(simulations,1);   aut_Ns_vec=zeros(simulations,1);        aut_TFP_vec=zeros(simulations,1);
aut_pc_vec=zeros(simulations,1);
    
for sim = 1:simulations
    aut_rGDP_vec(sim,1)    = corr(rGDP(1:end-1,sim),rGDP(2:end,sim)); 
    aut_NXGDP_vec(sim,1)   = corr(NXGDP(1:end-1,sim),NXGDP(2:end,sim));
    aut_C_vec(sim,1)       = corr(C(1:end-1,sim),C(2:end,sim)); 
    aut_Inv_vec(sim,1)     = corr(Inv(1:end-1,sim),Inv(2:end,sim)); 
    aut_Ns_vec(sim,1)      = corr(Ns(1:end-1,sim),Ns(2:end,sim)); 
    aut_TFP_vec(sim,1)     = corr(TFP(1:end-1,sim),TFP(2:end,sim)); 
    aut_pc_vec(sim,1)      = corr(pc(1:end-1,sim),pc(2:end,sim));
end

tab5_row3   = [ mean(aut_rGDP_vec) mean(aut_NXGDP_vec) mean(aut_C_vec) mean(aut_Inv_vec) ... 
                mean(aut_Ns_vec) mean(aut_TFP_vec) mean(aut_pc_vec)]; 

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% Time-series targets: 
ts_targets     = [ sdY mean(aut_rGDP_vec) mean(sd_Inv_vec)/sdY mean(sd_SHm_vec)/100 ... 
                   mean(c_rGDP_NXGDP_vec) mean(sd_C_vec)/sdY mean(sd_NXGDP_vec) ];
% Cross-sectional targets (parameters and ss from Dynare): 
ss_GDP          = ss_ym + pcSS*ss_yc + pnSS*ss_yn;
ss_man_GDP      = ss_ym/ss_GDP;                 % Share manf. in GDP
ss_com_GDP      = pcSS*ss_yc/ss_GDP;            % Share comm. in GDP
ss_NXman_GDP    = -ss_Mm/ss_GDP;                % NX manf./GDP
%ss_NXcom_GDP    = -pcSS*ss_Mc/ss_GDP;          % NX comm./GDP
ss_NX_GDP       = ss_pT*ss_B*(ss_q-1)/ss_GDP;   % NX total/GDP    

cs_targets      = [ ss_man_GDP, ss_com_GDP, ss_NXman_GDP, ss_NX_GDP, ss_n_s ]; 
    
% Here we simply print the results to the workspace. To save the results in
% an Excel file (using xlswrite) set the flag s.saveResults=1 in main.m. 
fprintf(1, 'Rows for table 5:\n');
fprintf(1,'sd(Y)\tsd(NX/Y)\trsd(C)\trsd(Inv)\trsd(N)\trsd(TFP)\trsd(pc)\n');
fprintf(1,'%.2f\t%.2f\t\t%.2f\t%.2f\t\t%.2f\t%.2f\t\t%.2f\n', tab5_row1);
fprintf(1,'c(YY)\tc(YNX/Y)\tc(YC)\tc(YInv)\t\tc(YN)\tc(YTFP)\t\tc(Ypc)\n');
fprintf(1,'%.2f\t%.2f\t\t%.2f\t%.2f\t\t%.2f\t%.2f\t\t%.2f\n', tab5_row2);
fprintf(1,'a(Y)\ta(NX/Y)\t\ta(C)\ta(Inv)\t\ta(N)\ta(TFP)\t\ta(pc)\n');
fprintf(1,'%.2f\t%.2f\t\t%.2f\t%.2f\t\t%.2f\t%.2f\t\t%.2f\n\n', tab5_row3);

fprintf(1, 'Row for table 9:\n');
fprintf(1, 'rGDP\tK^KS\tN^LS\tZ\t\tEnd.TFP\n');
fprintf(1, '%.2f\t%.2f\t%.2f\t%.2f\t%.2f\n\n', tab9_row);

fprintf(1, 'Time-series targets:\n');
fprintf(1, 'sd(Y)\taut(Y)\trsd(Inv)\tsd(manf_sh)\tc(YNX/Y)\trsd(C)\tsd(NX/Y)\n');
fprintf(1, '%.2f\t%.2f\t%.2f\t\t%.2f\t\t%.2f\t\t%.2f\t%.2f\n', ts_targets);
fprintf(1, 'Dynamic parameters:\n');
fprintf(1, 'Z_sd\tZ_rho\tphiK\tphiKx\teta_GDP\n');
fprintf(1, '%.4f\t%.4f\t%.4f\t%.4f\t%.4f\n\n', [Z_sd Z_rho phiK phiKx eta_GDP]);

fprintf(1, 'Cross-sectional targets (steady state):\n');
fprintf(1, 'manf_sh\tcomm_sh\tmanf_NX\tNX/GDP\tN_SS\n');
fprintf(1, '%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n', cs_targets);
fprintf(1, 'Steady-state parameters:\n');
fprintf(1, 'Am\t\teta\t\tetaT\tb\t\tpsi_u\n');
fprintf(1, '%.3f\t%.3f\t%.3f\t%.3f\t%.3f\n\n', [Am eta etaT b_ss psi_u]);
