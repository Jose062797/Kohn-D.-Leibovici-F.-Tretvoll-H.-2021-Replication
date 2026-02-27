function saved = save_to_dynare(mp, varargin)
% Save the model parameters so they are accessible by Dynare:
p_beta      = mp.beta;
p_gamma     = mp.gamma;
p_nu        = mp.nu;
p_sigma     = mp.sigma;
p_sigmaT    = mp.sigmaT;
p_theta_n   = mp.theta_n;
p_theta_m   = mp.theta_m;
p_theta_c   = mp.theta_c;
p_mu        = mp.mu;
p_delta     = mp.delta;
p_Ac        = mp.Ac;
p_An        = mp.An;
p_psi_r     = mp.psi_r;
p_rstar     = mp.rstar;
p_S_ss      = mp.S_ss;
p_pc_rho    = mp.pc_rho;
p_pc_sd     = mp.pc_sd;
p_pc_SS     = mp.pc_SS;
p_Am        = mp.Am;
p_eta       = mp.eta;
p_etaT      = mp.etaT;
p_b         = mp.b;
p_psi_u     = mp.psi_u;
p_Z_sd      = mp.Z_sd;
p_Z_rho     = mp.Z_rho;
p_phiK      = mp.phiK;
p_phiKx     = mp.phiKx;
p_phiNx     = mp.phiNx;
p_eta_GDP   = mp.eta_GDP;

save use_in_dynare_mp.mat p_beta p_gamma p_nu p_sigma p_sigmaT p_theta_n p_theta_m p_theta_c p_mu ...
    p_delta p_Ac p_An p_psi_r p_rstar p_S_ss p_pc_rho p_pc_sd p_pc_SS p_Am p_eta p_etaT p_b p_psi_u ...
    p_Z_sd p_Z_rho p_phiK p_phiKx p_phiNx p_eta_GDP;

% If necessary, save steady state so that it is accessible by Dynare:
if nargin > 1   % function call send mp and ss
    ss          = varargin{1};
    ss_c        = ss.c;
    ss_n_s      = ss.n_s;
    ss_wm       = ss.wm;
    ss_wc       = ss.wc;
    ss_wn       = ss.wn;
    ss_p        = ss.p;
    ss_pT       = ss.pT;
    ss_k        = ss.k;
    ss_pi_m     = ss.pi_m;
    ss_pi_c     = ss.pi_c;
    ss_pi_n     = ss.pi_n;
    ss_G        = ss.G;
    ss_H        = ss.H;
    ss_Xm       = ss.Xm;
    ss_Xc       = ss.Xc;
    ss_Xn       = ss.Xn;
    ss_XT       = ss.XT;
    ss_km       = ss.km;
    ss_nm       = ss.nm;
    ss_ym       = ss.ym;
    ss_kc       = ss.kc;
    ss_nc       = ss.nc;
    ss_yc       = ss.yc;
    ss_kn       = ss.kn;
    ss_nn       = ss.nn;
    ss_yn       = ss.yn;
    ss_Mm       = ss.Mm;
    ss_Mc       = ss.Mc;
    ss_B        = ss.B;
    ss_q        = ss.q;
    ss_m        = ss.m;
    ss_rm       = ss.rm;
    ss_rc       = ss.rc;
    ss_rn       = ss.rn;
    ss_pn       = ss.pn;

        
    save use_in_dynare_ss.mat ss_c ss_n_s ss_wm ss_wc ss_wn ss_p ss_pT ss_k ss_pi_m ss_pi_c ss_pi_n ss_G ss_H ss_Xm ss_Xc ...
                               ss_XT ss_Xn ss_km ss_nm ss_ym ss_kc ss_nc ss_yc ss_kn ss_nn ss_yn ss_Mm ss_Mc ss_B ss_q   ...
                               ss_m ss_rm ss_rc ss_rn ss_pn;
end
                          
saved  = 1;