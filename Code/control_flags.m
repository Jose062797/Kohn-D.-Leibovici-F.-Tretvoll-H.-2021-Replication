
if s.flag==1 || s.flag==9 || s.flag==11 || s.flag==13   % Emerging economy, baseline
    s.params_cross_section_targets  = 'E';
    % 'E' = parameters to match Emerging economy's cross-sectional targets
    % 'D' = parameters to match Developed economy's cross-sectional targets
    s.params_time_series_targets    = 'E';
    % 'E' = parameters from matching Emerging economy's time-series targets
    % 'D' = parameters from matching Developed economy's time-series targets
    
    s.calib_psi_u       = 1; 	% 0 = Counterfactual exercise: load from Results/savedPsiU.mat
                                % 1 = calibrate and save the value
    s.hplambda      = 100;    
    
    ss_targets.mfct_GDP            =  0.15283;
    ss_targets.commodities_GDP     =  0.33213;    
    ss_targets.NXmfct_GDP          = -0.10736;
    ss_targets.NX_GDP              = -0.06721;
    ss_targets.NXcommodities_GDP   =  0.04015;
    ss_targets.nontradables_GDP    = 1-(ss_targets.mfct_GDP+ss_targets.commodities_GDP); 
    
    
elseif s.flag==2 || s.flag==10 || s.flag==12 || s.flag==14 % Developed economy, baseline
    
    s.params_cross_section_targets  = 'D';
    s.params_time_series_targets    = 'D';
    s.calib_psi_u       = 1;
    s.hplambda      = 100;  
    
    ss_targets.mfct_GDP            =  0.18769;
    ss_targets.commodities_GDP     =  0.14584;
    ss_targets.NXmfct_GDP          = -0.00540;              
    ss_targets.NX_GDP              = -0.00529;        
    ss_targets.NXcommodities_GDP   =  0.00011;
    ss_targets.nontradables_GDP    = 1-(ss_targets.commodities_GDP+ss_targets.mfct_GDP);
    
elseif s.flag==3 || s.flag==15 % Emerging economy, cross-sectional moments from developed economy

    s.params_cross_section_targets  = 'D';
    s.params_time_series_targets    = 'E';
    s.calib_psi_u       = 0;
    s.hplambda      = 100;  
    
    ss_targets.mfct_GDP            =  0.18769;
    ss_targets.commodities_GDP     =  0.14584;
    ss_targets.NXmfct_GDP          = -0.00540;              
    ss_targets.NX_GDP              = -0.00529;        
    ss_targets.NXcommodities_GDP   =  0.00011;
    ss_targets.nontradables_GDP    = 1-(ss_targets.commodities_GDP+ss_targets.mfct_GDP);
    
    
    
elseif s.flag==4 || s.flag==16 % Developed economy, cross-sectional moments from emerging economy
    
    s.params_cross_section_targets  = 'E';
    s.params_time_series_targets    = 'D';
    s.calib_psi_u       = 0;
    s.hplambda      = 100;  
    
    ss_targets.mfct_GDP            =  0.15283;
    ss_targets.commodities_GDP     =  0.33213;    
    ss_targets.NXmfct_GDP          = -0.10736;
    ss_targets.NX_GDP              = -0.06721;
    ss_targets.NXcommodities_GDP   =  0.04015;
    ss_targets.nontradables_GDP    = 1-(ss_targets.mfct_GDP+ss_targets.commodities_GDP); 

elseif s.flag==5 % Emerging economy, with Mfct NX / GDP from developed
    
    s.params_cross_section_targets  = 'E';
    s.params_time_series_targets    = 'E';
    s.calib_psi_u       = 0;
    s.hplambda      = 100;   
    
    ss_targets.mfct_GDP            =  0.15283;
    ss_targets.commodities_GDP     =  0.33213;    
    ss_targets.NXmfct_GDP          = -0.00540;
    ss_targets.NX_GDP              = -0.06721;
    ss_targets.NXcommodities_GDP = ss_targets.NX_GDP - ss_targets.NXmfct_GDP; 
    ss_targets.nontradables_GDP    = 1-(ss_targets.mfct_GDP+ss_targets.commodities_GDP); 

    
elseif s.flag== 6  % Emerging economy, with Mfct NX / GDP and NT share from developed
    
    s.params_cross_section_targets  = 'E';
    s.params_time_series_targets    = 'E';
    s.calib_psi_u       = 0;
    s.hplambda      = 100;       
    
    share_T_DEV= 0.14584 + 0.18769;
    share_mfct_EM=0.15283/(0.15283+0.33213);
    ss_targets.mfct_GDP = share_mfct_EM*share_T_DEV;
    ss_targets.commodities_GDP= (1-share_mfct_EM)*share_T_DEV;
    ss_targets.NXmfct_GDP          = -0.00540;
    ss_targets.NX_GDP              = -0.06721;    
    ss_targets.NXcommodities_GDP = ss_targets.NX_GDP - ss_targets.NXmfct_GDP; 
    ss_targets.nontradables_GDP    = 1-(ss_targets.mfct_GDP+ss_targets.commodities_GDP); 

  
elseif s.flag==7 % Developed economy, with Mfct NX / GDP from emerging
    
    s.params_cross_section_targets  = 'D';
    s.params_time_series_targets    = 'D';
    s.calib_psi_u       = 0;
    s.hplambda      = 100;   
    
    ss_targets.mfct_GDP            =  0.18769;
    ss_targets.commodities_GDP     =  0.14584;
    ss_targets.NXmfct_GDP          = -0.10736;              
    ss_targets.NX_GDP              = -0.00529;        
    ss_targets.NXcommodities_GDP = ss_targets.NX_GDP - ss_targets.NXmfct_GDP; 
    ss_targets.nontradables_GDP    = 1-(ss_targets.commodities_GDP+ss_targets.mfct_GDP);
    
        
    
elseif s.flag== 8 % Developed economy, with Mfct NX / GDP and NT share from emerging
        
    s.params_cross_section_targets  = 'D';
    s.params_time_series_targets    = 'D';
    s.calib_psi_u       = 0;
    s.hplambda      = 100;      
    
    share_T_EM= 0.15283+0.33213;
    share_mfct_DEV=0.18769/(0.14584 + 0.18769);
    ss_targets.mfct_GDP = share_mfct_DEV*share_T_EM;
    ss_targets.commodities_GDP= (1-share_mfct_DEV)*share_T_EM;
    ss_targets.NXmfct_GDP          = -0.10736;
    ss_targets.NX_GDP              = -0.00529;    
    ss_targets.NXcommodities_GDP = ss_targets.NX_GDP - ss_targets.NXmfct_GDP; 
    ss_targets.nontradables_GDP    = 1-(ss_targets.mfct_GDP+ss_targets.commodities_GDP); 
    
end 

