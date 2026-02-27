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
    GDP(:,sim)      = squeeze(simulation_array(strmatch('GDP',  M_.endo_names,'exact'),:,sim))';
    NX(:,sim)       = squeeze(simulation_array(strmatch('NX',   M_.endo_names,'exact'),:,sim))';            
    C(:,sim)        = squeeze(simulation_array(strmatch('C',    M_.endo_names,'exact'),:,sim))';  
    Inv(:,sim)      = squeeze(simulation_array(strmatch('Inv',  M_.endo_names,'exact'),:,sim))';
    Ns(:,sim)       = squeeze(simulation_array(strmatch('Ns',   M_.endo_names,'exact'),:,sim))';        
    Z(:,sim)        = exp(squeeze(simulation_array(strmatch('Z',M_.endo_names,'exact'),:,sim))');    
    K(:,sim)        = squeeze(simulation_array(strmatch('K',M_.endo_names,'exact'),:,sim))';
    pc(:,sim)       = squeeze(simulation_array(strmatch('pc',  M_.endo_names,'exact'),:,sim))';     
    SHm(:,sim)      = squeeze(simulation_array(strmatch('SHm',  M_.endo_names,'exact'),:,sim))';   
    p_GDPdef(:,sim) = squeeze(simulation_array(strmatch('p_GDPdef',M_.endo_names,'exact'),:,sim))';
    p_CPI(:,sim)    = squeeze(simulation_array(strmatch('p_CPI',M_.endo_names,'exact'),:,sim))';
    p_CES(:,sim)    = squeeze(simulation_array(strmatch('p',M_.endo_names,'exact'),:,sim))';
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
    [~, rGDP(:,sim)]  = hpfilter(rGDP(:,sim),  s.hplambda);
    [~, NXGDP(:,sim)] = hpfilter(NXGDP(:,sim), s.hplambda); %In levels
    [~, C(:,sim)]     = hpfilter(C(:,sim),     s.hplambda);
    [~, Inv(:,sim)]   = hpfilter(Inv(:,sim),   s.hplambda);    
    [~, Ns(:,sim)]    = hpfilter(Ns(:,sim),    s.hplambda);
    [~, TFP(:,sim)]   = hpfilter(TFP(:,sim),   s.hplambda);

    [~, rGDP_K(:,sim)]     = hpfilter(rGDP_K(:,sim),     s.hplambda);  
    [~, rGDP_N(:,sim)]     = hpfilter(rGDP_N(:,sim),     s.hplambda);  
    [~, rGDP_TFPex(:,sim)] = hpfilter(rGDP_TFPex(:,sim), s.hplambda);  
    [~, rGDP_TFPen(:,sim)] = hpfilter(rGDP_TFPen(:,sim), s.hplambda);  
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
    % Row 1 - Standard deviations (generally relative to rGDP):
    % Preallocate vectors for all moments (Matlab says this will be faster)
    sd_rGDP_vec=zeros(simulations,1);  sd_NXGDP_vec=zeros(simulations,1);  sd_C_vec=zeros(simulations,1);
    sd_Inv_vec=zeros(simulations,1);   sd_Ns_vec=zeros(simulations,1);     sd_TFP_vec=zeros(simulations,1);
    sd_r_vec=zeros(simulations,1);     sd_pn_vec=zeros(simulations,1);     sd_pc_vec=zeros(simulations,1);
    sd_SHm_vec=zeros(simulations,1);   sd_SHc_vec=zeros(simulations,1);

    sd_rGDP_K_vec=zeros(simulations,1);         sd_rGDP_N_vec=zeros(simulations,1);
    sd_rGDP_TFPex_vec=zeros(simulations,1);     sd_rGDP_TFPen_vec=zeros(simulations,1);
    sd_PPI_CPI_vec=zeros(simulations,1);    
    
    for sim = 1:simulations
        sd_rGDP_vec(sim,1)     = 100*std(rGDP(:,sim));
        sd_NXGDP_vec(sim,1)    = 100*std(NXGDP(:,sim));
        sd_C_vec(sim,1)        = 100*std(C(:,sim));
        sd_Inv_vec(sim,1)      = 100*std(Inv(:,sim));
        sd_Ns_vec(sim,1)       = 100*std(Ns(:,sim));
        sd_TFP_vec(sim,1)      = 100*std(TFP(:,sim));    
        sd_r_vec(sim,1)        = 100*std(r(:,sim));
        sd_pn_vec(sim,1)       = 100*std(pn(:,sim));
        sd_pc_vec(sim,1)       = 100*std(pc(:,sim));
        sd_SHm_vec(sim,1)      = 100*std(SHm(:,sim));
        sd_SHc_vec(sim,1)      = 100*std(SHc(:,sim));

        sd_PPI_CPI_vec(sim,1)        = 100*std(PPI_CPI(:,sim));
        sd_rGDP_K_vec(sim,1)        = 100*std(rGDP_K(:,sim));
        sd_rGDP_N_vec(sim,1)        = 100*std(rGDP_N(:,sim));
        sd_rGDP_TFPex_vec(sim,1)    = 100*std(rGDP_TFPex(:,sim));
        sd_rGDP_TFPen_vec(sim,1)    = 100*std(rGDP_TFPen(:,sim));
    end
    
    sdY         = mean(sd_rGDP_vec);
    table_row_1 = [ sdY mean(sd_NXGDP_vec) mean(sd_C_vec)/sdY mean(sd_Inv_vec)/sdY mean(sd_Ns_vec)/sdY mean(sd_TFP_vec)/sdY ...
                    mean(sd_SHm_vec) mean(sd_SHc_vec) ...  %Note: shares not relative to rGDP
                    mean(sd_r_vec) mean(sd_pn_vec)/sdY mean(sd_pc_vec) ]; 
    
    table_GDPdecomp = (1/100)*[sdY mean(sd_rGDP_K_vec) mean(sd_rGDP_N_vec) mean(sd_rGDP_TFPex_vec) mean(sd_rGDP_TFPen_vec)];            
    sd_PPI_CPI  = mean(sd_PPI_CPI_vec);     % not reported anywhere? 
    
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    % Row 2 - Correlations with real GDP:
    c_rGDP_NXGDP_vec=zeros(simulations,1);  c_rGDP_C_vec=zeros(simulations,1);   c_rGDP_Inv_vec=zeros(simulations,1);
    c_rGDP_Ns_vec=zeros(simulations,1);     c_rGDP_TFP_vec=zeros(simulations,1); c_rGDP_SHm_vec=zeros(simulations,1);  c_rGDP_SHc_vec=zeros(simulations,1);
    c_rGDP_r_vec=zeros(simulations,1);      c_rGDP_pn_vec=zeros(simulations,1);
    
    for sim = 1:simulations
        c_rGDP_NXGDP_vec(sim,1) = corr(rGDP(:,sim),NXGDP(:,sim));
        c_rGDP_C_vec(sim,1)     = corr(rGDP(:,sim),C(:,sim)); 
        c_rGDP_Inv_vec(sim,1)   = corr(rGDP(:,sim),Inv(:,sim)); 
        c_rGDP_Ns_vec(sim,1)    = corr(rGDP(:,sim),Ns(:,sim)); 
        c_rGDP_TFP_vec(sim,1)   = corr(rGDP(:,sim),TFP(:,sim));
        c_rGDP_SHm_vec(sim,1)   = corr(rGDP(:,sim),SHm(:,sim));
        c_rGDP_SHc_vec(sim,1)   = corr(rGDP(:,sim),SHc(:,sim));   
        c_rGDP_r_vec(sim,1)     = corr(rGDP(:,sim),r(:,sim));
        c_rGDP_pn_vec(sim,1)    = corr(rGDP(:,sim),pn(:,sim));
    end

    table_row_2 = [1 mean(c_rGDP_NXGDP_vec) mean(c_rGDP_C_vec) mean(c_rGDP_Inv_vec) mean(c_rGDP_Ns_vec) mean(c_rGDP_TFP_vec) ...
                   mean(c_rGDP_SHm_vec) mean(c_rGDP_SHc_vec) mean(c_rGDP_r_vec) mean(c_rGDP_pn_vec) ]; 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    % Row 3 - Correlations with commodity prices: 
    c_pc_rGDP_vec=zeros(simulations,1);     c_pc_NXGDP_vec=zeros(simulations,1);    c_pc_C_vec=zeros(simulations,1);
    c_pc_Inv_vec=zeros(simulations,1);      c_pc_Ns_vec=zeros(simulations,1);       c_pc_TFP_vec=zeros(simulations,1);
    c_pc_SHm_vec=zeros(simulations,1);      c_pc_SHc_vec=zeros(simulations,1);      c_pc_r_vec=zeros(simulations,1);
    c_pc_pn_vec=zeros(simulations,1);
    
    for sim = 1:simulations
        c_pc_rGDP_vec(sim,1)    = corr(pc(:,sim),rGDP(:,sim));
        c_pc_NXGDP_vec(sim,1)   = corr(pc(:,sim),NXGDP(:,sim));
        c_pc_C_vec(sim,1)       = corr(pc(:,sim),C(:,sim)); 
        c_pc_Inv_vec(sim,1) 	= corr(pc(:,sim),Inv(:,sim)); 
        c_pc_Ns_vec(sim,1)  	= corr(pc(:,sim),Ns(:,sim)); 
        c_pc_TFP_vec(sim,1) 	= corr(pc(:,sim),TFP(:,sim));
        c_pc_SHm_vec(sim,1)  	= corr(pc(:,sim),SHm(:,sim));
        c_pc_SHc_vec(sim,1) 	= corr(pc(:,sim),SHc(:,sim));   
        c_pc_r_vec(sim,1)       = corr(pc(:,sim),r(:,sim));
        c_pc_pn_vec(sim,1)  	= corr(pc(:,sim),pn(:,sim));
    end
    
    table_row_3 = [mean(c_pc_rGDP_vec) mean(c_pc_NXGDP_vec) mean(c_pc_C_vec) mean(c_pc_Inv_vec) mean(c_pc_Ns_vec) ...
                   mean(c_pc_TFP_vec) mean(c_pc_SHm_vec) mean(c_pc_SHc_vec) mean(c_pc_r_vec) mean(c_pc_pn_vec) ];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    % Row 4 - Autocorrelations: 
    aut_rGDP_vec=zeros(simulations,1);  aut_NXGDP_vec=zeros(simulations,1);     aut_C_vec=zeros(simulations,1);
    aut_Inv_vec=zeros(simulations,1);   aut_Ns_vec=zeros(simulations,1);        aut_TFP_vec=zeros(simulations,1);
    aut_SHm_vec=zeros(simulations,1);   aut_SHc_vec=zeros(simulations,1);       aut_r_vec=zeros(simulations,1);
    aut_pn_vec=zeros(simulations,1);
    
    for sim = 1:simulations
        aut_rGDP_vec(sim,1)    = corr(rGDP(1:end-1,sim),rGDP(2:end,sim)); 
        aut_NXGDP_vec(sim,1)   = corr(NXGDP(1:end-1,sim),NXGDP(2:end,sim));
        aut_C_vec(sim,1)       = corr(C(1:end-1,sim),C(2:end,sim)); 
        aut_Inv_vec(sim,1)     = corr(Inv(1:end-1,sim),Inv(2:end,sim)); 
        aut_Ns_vec(sim,1)      = corr(Ns(1:end-1,sim),Ns(2:end,sim)); 
        aut_TFP_vec(sim,1)     = corr(TFP(1:end-1,sim),TFP(2:end,sim)); 
        aut_SHm_vec(sim,1)     = corr(SHm(1:end-1,sim),SHm(2:end,sim)); 
        aut_SHc_vec(sim,1)     = corr(SHc(1:end-1,sim),SHc(2:end,sim)); 
        aut_r_vec(sim,1)       = corr(r(1:end-1,sim),r(2:end,sim)); 
        aut_pn_vec(sim,1)      = corr(pn(1:end-1,sim),pn(2:end,sim)); 
    end

    table_row_4 = [mean(aut_rGDP_vec) mean(aut_NXGDP_vec) mean(aut_C_vec) mean(aut_Inv_vec) mean(aut_Ns_vec) ...
                   mean(aut_TFP_vec) mean(aut_SHm_vec) mean(aut_SHc_vec) mean(aut_r_vec) mean(aut_pn_vec) ]; 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    % Row 5 - Steady-state characteristics (parameters and ss from Dynare)
    ss_GDP          = pm_mean*ss_ym + pc_mean*ss_yc + ss_pn*ss_yn;
    ss_man_GDP      = pm_mean*ss_ym/ss_GDP;             % Manf. production
    ss_com_GDP      = pc_mean*ss_yc/ss_GDP;             % Comm. production
    ss_NXman_GDP    = -pm_mean*ss_Mm/ss_GDP;            % NX manf./GDP
    ss_NXcom_GDP    = -pc_mean*ss_Mc/ss_GDP;            % NX comm./GDP
    ss_NX_GDP       = ss_pT*ss_B*(ss_q-1)/ss_GDP;       % NX total/GDP    
    
    table_row_5 = [ss_man_GDP, ss_com_GDP, ss_NXman_GDP, ss_NXcom_GDP, ss_NX_GDP, ss_n_s, LSss]; 
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    % Additional table: interest rates
    table_r = [ mean(sd_r_vec) mean(c_rGDP_r_vec) mean(aut_r_vec) ];
% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

    % Row 1 - Volatilities:
    sd_rGDP     = mean(sd_rGDP_vec);
    sd_C        = mean(sd_C_vec);
    sd_Inv      = mean(sd_Inv_vec);
    sd_Ns       = mean(sd_Ns_vec);
    sd_NXGDP    = mean(sd_NXGDP_vec);
    sd_TFP      = mean(sd_TFP_vec);
    sd_SHm      = mean(sd_SHm_vec);
    sd_SHc      = mean(sd_SHc_vec);
    table_paper_panelA = [sd_rGDP sd_NXGDP sd_C/sd_rGDP sd_Inv/sd_rGDP sd_Ns/sd_rGDP sd_TFP/sd_rGDP sd_SHm sd_SHc];

    % Row 2 - Autocorrelations: 
    aut_rGDP    = mean(aut_rGDP_vec);
    aut_C       = mean(aut_C_vec);
    aut_Inv     = mean(aut_Inv_vec);
    aut_Ns      = mean(aut_Ns_vec);
    aut_NXGDP   = mean(aut_NXGDP_vec);
    aut_TFP     = mean(aut_TFP_vec);
    aut_SHm     = mean(aut_SHm_vec);
    aut_SHc     = mean(aut_SHc_vec);
    table_paper_panelC = [aut_rGDP aut_NXGDP aut_C aut_Inv aut_Ns aut_TFP aut_SHm aut_SHc];

    % Row 3 - Correlations with GDP 
    c_rGDP_C     = mean(c_rGDP_C_vec);
    c_rGDP_Inv   = mean(c_rGDP_Inv_vec);
    c_rGDP_Ns    = mean(c_rGDP_Ns_vec);
    c_rGDP_NXGDP = mean(c_rGDP_NXGDP_vec);
    c_rGDP_TFP   = mean(c_rGDP_TFP_vec);
    c_rGDP_SHm   = mean(c_rGDP_SHm_vec);
    c_rGDP_SHc   = mean(c_rGDP_SHm_vec);
    table_paper_panelB = [1 c_rGDP_NXGDP c_rGDP_C c_rGDP_Inv c_rGDP_Ns c_rGDP_TFP c_rGDP_SHm c_rGDP_SHc];

    % Row 4 - Steady-state characteristics (parameters and ss from Dynare)
    ss_GDP          = pm_mean*ss_ym + pc_mean*ss_yc + ss_pn*ss_yn;
    ss_man_GDP      = pm_mean*ss_ym/ss_GDP;             % Manf. production
    ss_com_GDP      = pc_mean*ss_yc/ss_GDP;             % Comm. production
    ss_man_G        = pm_mean*ss_Xm/(ss_p*ss_G);        % Manf. demand
    ss_com_G        = pc_mean*ss_Xc/(ss_p*ss_G);        % Comm. demand
    ss_manIm_GDP    = pm_mean*ss_Mm/ss_GDP;             % Manf. imports/GDP
    ss_comIm_GDP    = pc_mean*ss_Mc/ss_GDP;             % Comm. imports/GDP
    ss_NX_GDP       = ss_p*ss_B*(ss_q-1)/ss_GDP;        % NX total/GDP
    ss_NXman_GDP    = -pm_mean*ss_Mm/ss_GDP;            % NX manf./GDP
    ss_NXcom_GDP    = -pc_mean*ss_Mc/ss_GDP;            % NX comm./GDP
    ss_debt_GDP     = ss_p*ss_B/ss_GDP;                 % Debt/GDP
    table_paper_panelD = [ss_com_GDP, ss_man_GDP, ss_NXman_GDP, ss_NX_GDP];






