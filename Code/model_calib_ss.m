function deviations = model_calib_ss(calib,targets,mp,s)

% Current value of calibrated parameters:
mp.Am   = calib(1);
mp.eta  = calib(2);
mp.etaT = calib(3);  
mp.b    = calib(4);

if s.calib_psi_u == 1
    mp.psi_u    = calib(5);
end

% Given parameters solve for steady state
options     = optimset('MaxFunEvals',50000,'MaxIter',50000,'Display','off');
ss          = model_ss(mp,options);

% Given parameters and steady state, calculate targeted steady-state moments:
ss_mfct_GDP             = ss.ym/(ss.ym + mp.pc_SS*ss.yc + ss.pn*ss.yn);
ss_commodities_GDP      = mp.pc_SS*ss.yc/(ss.ym + mp.pc_SS*ss.yc + ss.pn*ss.yn);
ss_NXmfct_GDP           = (-ss.Mm)/(ss.ym + mp.pc_SS*ss.yc + ss.pn*ss.yn);
ss_NX_GDP               = (-ss.Mm-ss.Mc*mp.pc_SS)/(ss.ym + mp.pc_SS*ss.yc + ss.pn*ss.yn);
%ss_NXcommodities_GDP    = (-ss.Mc*mp.pc_SS)/(ss.ym + mp.pc_SS*ss.yc+ ss.pn*ss.yn);

% Check deviations from targets in the data:
deviations(1)   = ss_mfct_GDP        - targets.mfct_GDP; 
deviations(2)   = ss_commodities_GDP - targets.commodities_GDP;
deviations(3)   = ss_NXmfct_GDP      - targets.NXmfct_GDP;
deviations(4)   = ss_NX_GDP          - targets.NX_GDP;

if s.calib_psi_u == 1
    deviations(5)   = ss.n_s - 1/3;     % SS share of time worked
end
    
end