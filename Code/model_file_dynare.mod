// This file sets up a small-country open economy model with three sectors: manufacturing and commodity goods (both tradable) and non-tradable goods. The country takes international interest rates and prices in each sector as given.

var C,Ns,wm,wc,wn,rm,rc,rn,rKm,rKc,rKn,p,m,q,K,B,pi_m,pi_c,pi_n,Inv,
    G,H,Xm,Xc,Xn,XT,pc,pn,pT,Z,
    Km,Nm,Ym, Kc,Nc,Yc, Kn,Nn,Yn, Mm,Mc,
    GDP,rGDP,p_GDPdef,p_CPI, TFP,NX,SHm,SHc,
	r, rw, S;
	
varexo eps_pc,eps_Z,eps_rw;

load use_in_dynare_mp.mat;
load use_in_dynare_ss.mat;
parameters bet,gam,psi_u,nu, delta,phiK,phiKx,phiNx, rstar,b_ss,psi_r, sig,sigT,eta,etaT,theta_m,Am,theta_c,Ac,theta_n,An,mu, pnSS,pTSS, Z_rho,Z_sd, 
pcSS,pc_rho,pc_sd, S_ss,eta_GDP,rw_rho,rw_sd, rGDP_ss,LSss,KSss;

// if mp.sigma==1, set this flag = 1
@#define Finalgoods_CD = 0
// if mp.sigmaT==1, set this flag = 1
@#define Tradables_CD = 1 

bet 	= p_beta; 
gam 	= p_gamma;
psi_u 	= p_psi_u;
nu      = p_nu;
delta 	= p_delta;
phiK 	= p_phiK;
phiKx 	= p_phiKx;
phiNx   = p_phiNx;
rstar 	= p_rstar;
b_ss 	= p_b;
psi_r 	= p_psi_r;   
sig 	= p_sigma;
sigT 	= p_sigmaT;
eta 	= p_eta;
etaT 	= p_etaT;
theta_m = p_theta_m;
Am 		= p_Am;
theta_c = p_theta_c;
Ac 		= p_Ac;
theta_n = p_theta_n;
An 		= p_An;
mu  	= p_mu;
pnSS    = ss_pn;
pTSS	= ss_pT;
Z_rho 	= p_Z_rho;
Z_sd 	= p_Z_sd;
pcSS 	= p_pc_SS;
pc_rho	= p_pc_rho;
pc_sd 	= p_pc_sd;
S_ss    = p_S_ss;
eta_GDP = p_eta_GDP;
rw_rho 	= 0;			// not using these in the baseline
rw_sd 	= 0; 			// not using these in the baseline

rGDP_ss = ss_ym + pcSS*ss_yc + pnSS*ss_yn;
LSss 	= ((1-theta_m)*mu*ss_ym+(1-theta_c)*mu*pcSS*ss_yc+(1-theta_n)*mu*pnSS*ss_yn) / rGDP_ss;
KSss 	= ((theta_m)*mu*ss_ym+theta_c*mu*pcSS*ss_yc+theta_n*mu*pnSS*ss_yn) / rGDP_ss;

model; 

// Bond price:
	exp( m(+1)) * ( ( exp(pT(+1)) / exp(p(+1)) ) / (exp(pT)/ exp(p)) )  = exp(q);
	1/ exp(q) = 1 + exp(r) + psi_r*(exp(-(B-b_ss))-1);

// Interest rate spread 
	1 + exp(r) = exp(rw)*exp(S);
	S = S_ss + eta_GDP*(GDP-log(rGDP_ss));
	rw = (1-rw_rho)*log(1+rstar) + rw_rho*rw(-1) + rw_sd*eps_rw;
		
// Household's budget constraint: 
	exp(p)* exp(C) + exp(p)* exp(Inv) + exp(pT)* exp(q)*B + exp(p)*phiNx/2*( exp(Nc)/ exp(Ns)-exp(Nc(-1))/ exp(Ns(-1)) )^2 + exp(p)*phiNx/2*( exp(Nm)/ exp(Ns)-exp(Nm(-1))/ exp(Ns(-1)) )^2 = exp(wm)* exp(Nm) + exp(wc)* exp(Nc) + exp(wn)* exp(Nn) + exp(rm)* exp(Km(-1)) + exp(rc)* exp(Kc(-1))  + exp(rn)* exp(Kn(-1)) + exp(pi_m) + exp(pi_c) + exp(pi_n) + exp(pT)*B(-1);
	
//SDF
	exp(m) = bet*( (exp(C)- psi_u*exp(Ns)^nu ) / (exp(C(-1))- psi_u*exp(Ns(-1))^nu ) )^(-gam) ;
	
//FOCs sectoral labor choices
	exp(wm)/ exp(p) = nu*psi_u*exp(Ns)^(nu-1) + phiNx * (-exp(Nc)/(exp(Ns)^2)) * ( (exp(Nc)/exp(Ns)-exp(Nc(-1))/ exp(Ns(-1))) - exp(m(+1))*(exp(Nc(+1))/ exp(Ns(+1))-exp(Nc)/ exp(Ns)) ) + phiNx * ( 1/ exp(Ns) -exp(Nm)/(exp(Ns)^2)) * ( (exp(Nm)/ exp(Ns)-exp(Nm(-1))/ exp(Ns(-1))) - exp(m(+1))*(exp(Nm(+1))/ exp(Ns(+1))-exp(Nm)/ exp(Ns)) );

	exp(wc)/ exp(p) =  nu*psi_u*exp(Ns)^(nu-1) + phiNx * ( 1/exp(Ns) -exp(Nc)/(exp(Ns)^2)) * ( (exp(Nc)/exp(Ns)-exp(Nc(-1))/exp(Ns(-1))) - exp(m(+1))*(exp(Nc(+1))/ exp(Ns(+1))-exp(Nc)/ exp(Ns)) ) + phiNx * (-exp(Nm)/(exp(Ns)^2)) * ( (exp(Nm)/ exp(Ns)-exp(Nm(-1))/ exp(Ns(-1))) - exp(m(+1))*(exp(Nm(+1))/ exp(Ns(+1))-exp(Nm)/ exp(Ns)) );

	exp(wn)/ exp(p) =  nu*psi_u*exp(Ns)^(nu-1) + phiNx * (-exp(Nc)/(exp(Ns)^2)) * ( (exp(Nc)/exp(Ns)-exp(Nc(-1))/ exp(Ns(-1))) - exp(m(+1))*(exp(Nc(+1))/ exp(Ns(+1))-exp(Nc)/ exp(Ns)) ) + phiNx * (-exp(Nm)/(exp(Ns)^2)) * ( (exp(Nm)/ exp(Ns)-exp(Nm(-1))/ exp(Ns(-1))) - exp(m(+1))*(exp(Nm(+1))/ exp(Ns(+1))-exp(Nm)/ exp(Ns)) );		
	
//Final goods
	@#if Finalgoods_CD == 1
		exp(G)  =  exp(XT)^(eta)* exp(Xn)^(1-eta); 
	@#else
		exp(G)  = ( eta* exp(XT)^((sig-1)/sig) + (1-eta)* exp(Xn)^((sig-1)/sig))^(sig/(sig-1)); 
	@#endif	
	//FOCs
	eta*(exp(G)/ exp(XT))^(1/sig) = exp(pT)/ exp(p);
	(1-eta)*(exp(G)/ exp(Xn))^(1/sig) = exp(pn)/ exp(p);		
	
//Tradable goods	
	@#if Tradables_CD == 1
		exp(H)  = exp(Xm)^(etaT)* exp(Xc)^(1-etaT); 
	@#else
		exp(H)  = ( etaT* exp(Xm)^((sigT-1)/sigT) + (1-etaT)* exp(Xc)^((sigT-1)/sigT))^(sigT/(sigT-1)); 
	@#endif
	//FOCs
	etaT*(exp(H)/ exp(Xm))^(1/sigT) = 1/ exp(pT);
	(1-etaT)*(exp(H)/ exp(Xc))^(1/sigT) = exp(pc)/ exp(pT);	
	
//Pricing capital claims:
	exp(m(+1)) * exp(rKm(+1))     = 1;
	exp(m(+1)) * exp(rKc(+1))     = 1;
	exp(m(+1)) * exp(rKn(+1))     = 1;
	
// Return to sectoral investments
	exp(rKm) = ( phiK*(exp(K(-1))/ exp(K(-2))-1) +  phiKx*( exp(Km(-1))/ exp(K(-1)) - exp(Km(-2))/ exp(K(-2)) )*( 1/ exp(K(-1)) -exp(Km(-1))/ exp(K(-1))^2) + phiKx*( exp(Kc(-1))/ exp(K(-1)) - exp(Kc(-2))/ exp(K(-2)) )*(-exp(Kc(-1))/ exp(K(-1))^2) + 1 )^(-1) *  ( exp(rm)/ exp(p) + (1-delta) + phiK/2*((exp(K)/ exp(K(-1)))^2-1) + phiKx*( exp(Km)/ exp(K) - exp(Km(-1))/ exp(K(-1)) )*(1/ exp(K(-1)) -exp(Km(-1))/ exp(K(-1))^2 ) + phiKx*( exp(Kc)/ exp(K) - exp(Kc(-1))/ exp(K(-1)) )*(-exp(Kc(-1))/ exp(K(-1))^2) 	);   
	
	exp(rKc) = ( phiK*(exp(K(-1))/ exp(K(-2))-1) +  phiKx*( exp(Km(-1))/ exp(K(-1)) - exp(Km(-2))/ exp(K(-2)) )*(  -exp(Km(-1))/ exp(K(-1))^2) + phiKx*( exp(Kc(-1))/exp(K(-1)) - exp(Kc(-2))/ exp(K(-2)) )*( 1/ exp(K(-1)) -exp(Kc(-1))/ exp(K(-1))^2) + 1 )^(-1) *  ( exp(rc)/ exp(p) + (1-delta) + phiK/2*((exp(K)/ exp(K(-1)))^2-1) + phiKx*( exp(Km)/ exp(K) - exp(Km(-1))/ exp(K(-1)) )*( -exp(Km(-1))/ exp(K(-1))^2 ) + phiKx*( exp(Kc)/ exp(K) - exp(Kc(-1))/exp(K(-1)) )*(1/ exp(K(-1))-exp(Kc(-1))/ exp(K(-1))^2) 	);	

	exp(rKn) = ( phiK*(exp(K(-1))/ exp(K(-2))-1) +  phiKx*( exp(Km(-1))/ exp(K(-1)) - exp(Km(-2))/ exp(K(-2)) )*(  -exp(Km(-1))/exp(K(-1))^2) + phiKx*( exp(Kc(-1))/ exp(K(-1)) - exp(Kc(-2))/ exp(K(-2)) )*( -exp(Kc(-1))/ exp(K(-1))^2) + 1 )^(-1) *  ( exp(rn)/ exp(p) + (1-delta) + 	phiK/2*((exp(K)/ exp(K(-1)))^2-1) + phiKx*( exp(Km)/ exp(K) - exp(Km(-1))/ exp(K(-1)) )*( -exp(Km(-1))/ exp(K(-1))^2 ) + phiKx*( exp(Kc)/ exp(K) - exp(Kc(-1))/ exp(K(-1)))*(-exp(Kc(-1))/ exp(K(-1))^2) 	);	

//Capital evolution
	exp(K) = (1-delta)*exp(K(-1)) + exp(Inv) - phiK/2*(exp(K)/ exp(K(-1))-1)^2* exp(K(-1)) - phiKx/2*( exp(Km)/ exp(K) - exp(Km(-1))/ exp(K(-1)) )^2  - phiKx/2*( exp(Kc)/ exp(K) - exp(Kc(-1))/ exp(K(-1)) )^2 ;

//Manufactured goods 
	exp(wm) = (1-theta_m)*mu*Am* exp(Z)*(exp(Km(-1))^theta_m*exp(Nm)^(1-theta_m))^mu/exp(Nm);
	exp(rm) = theta_m*mu*Am* exp(Z)*(exp(Km(-1))^theta_m* exp(Nm)^(1-theta_m))^mu/ exp(Km(-1));
	exp(pi_m) = exp(Ym) - exp(wm)* exp(Nm) - exp(rm)* exp(Km(-1));
	exp(Ym) = Am* exp(Z)*(exp(Km(-1))^theta_m* exp(Nm)^(1-theta_m))^mu;

//Commodities
	exp(wc) = (1-theta_c)*mu* exp(pc)*Ac* exp(Z)*(exp(Kc(-1))^theta_c* exp(Nc)^(1-theta_c))^mu/ exp(Nc);
	exp(rc) = theta_c*mu* exp(pc)*Ac* exp(Z)*(exp(Kc(-1))^theta_c* exp(Nc)^(1-theta_c))^mu/ exp(Kc(-1));
	exp(pi_c) = exp(pc)* exp(Yc) - exp(wc)* exp(Nc) - exp(rc)* exp(Kc(-1));
	exp(Yc) = Ac* exp(Z)*(exp(Kc(-1))^theta_c* exp(Nc)^(1-theta_c))^mu;

//Nontradable goods
	exp(wn) = (1-theta_n)*mu* exp(pn)*An* exp(Z)*(exp(Kn(-1))^theta_n* exp(Nn)^(1-theta_n))^mu/ exp(Nn);
	exp(rn) = theta_n*mu* exp(pn)*An* exp(Z)*(exp(Kn(-1))^theta_n* exp(Nn)^(1-theta_n))^mu/ exp(Kn(-1));
	exp(pi_n) = exp(pn)* exp(Yn) - exp(wn)* exp(Nn) - exp(rn)* exp(Kn(-1));
	exp(Yn) = An* exp(Z)*(exp(Kn(-1))^theta_n* exp(Nn)^(1-theta_n))^mu;
		
//Market clearing conditions
	exp(Xm) = exp(Ym) + Mm;
	exp(Xc) = exp(Yc) + Mc;
	exp(Xn) = exp(Yn);
	exp(G)  = exp(C) + exp(Inv) + phiNx/2*( exp(Nc)/ exp(Ns)-exp(Nc(-1))/ exp(Ns(-1)) )^2 + phiNx/2*( exp(Nm)/ exp(Ns)-exp(Nm(-1))/ exp(Ns(-1)) )^2 ;
	exp(H)  = exp(XT);
	exp(K)  = exp(Km) + exp(Kc) + exp(Kn);
	exp(Ns) = exp(Nm) + exp(Nc) + exp(Nn);  

//Exogenous processes	
	//Productivity
	Z = Z_rho*Z(-1) + Z_sd*eps_Z;

	//Relativbe price of commodities
	pc = pc_rho*pc(-1) + pc_sd*eps_pc;

//Other variables
    exp(GDP) 	  = exp(Ym) + exp(pc)*exp(Yc) + exp(pn)*exp(Yn);
	exp(rGDP) 	  = exp(Ym) + pcSS*exp(Yc) + pnSS*exp(Yn);
   	exp(p_GDPdef) = exp(GDP)/exp(rGDP);
   	exp(p_CPI) 	  = (exp(p)*exp(G))/(exp(Xm) + pcSS*exp(Xc)+ pnSS*exp(Xn));
	exp(TFP) 	  = exp(rGDP)/((exp(K(-1))^KSss)*(exp(Ns)^LSss));
	NX = -Mm-exp(pc)*Mc;

// Sectoral shares
	exp(SHm)    = exp(Ym)/exp(GDP);
	exp(SHc)    = exp(pc)*exp(Yc)/exp(GDP);

end;

	load use_in_dynare_ss.mat;
	//ss_p = 1;
	//qm_mean = 1/8;
	initval;
	C 		= log(ss_c);
	Ns 		= log(ss_n_s);
	wm 		= log(ss_wm);
	wc 		= log(ss_wc);
	wn      = log(ss_wn);
	rm 		= log(ss_rm);
	rc 		= log(ss_rc);
	rn 		= log(ss_rn);
	rKn     = log(ss_rn/ss_p+(1-delta));
	rKm     = log(ss_rm/ss_p+(1-delta));
	rKc     = log(ss_rc/ss_p+(1-delta));
    p 		= log(ss_p);
	m 		= log(ss_m);
	q 		= log(ss_q);
	K 		= log(ss_k);
	B 		= ss_B;
	pi_m 	= log(ss_pi_m);
	pi_c 	= log(ss_pi_c);
	pi_n 	= log(ss_pi_n);
	Inv 	= log(delta*ss_k);
	G 		= log(ss_G);
	H 		= log(ss_H);
	Xm 		= log(ss_Xm);
	Xc 		= log(ss_Xc);
	Xn 		= log(ss_Xn);
	XT 		= log(ss_XT);
	pc 		= log(pcSS);
	pn      = log(pnSS);
	pT      = log(ss_pT);
	Z 		= 0;
	Km 		= log(ss_km);
	Nm 		= log(ss_nm);
	Ym 		= log(ss_ym);
	Kc 		= log(ss_kc);
	Nc 		= log(ss_nc);
	Yc 		= log(ss_yc);
	Kn 		= log(ss_kn);
	Nn 		= log(ss_nn);
	Yn 		= log(ss_yn);
	Mm 		= ss_Mm;
	Mc 		= ss_Mc;
	GDP 	= log(ss_ym + pcSS*ss_yc + pnSS*ss_yn);
	rGDP     = log(rGDP_ss);
	p_GDPdef = log(1);
	p_CPI 	 = log(1);
	TFP 	= log(rGDP_ss/((ss_k^KSss)*(ss_n_s^LSss)));
	NX 		= -ss_Mm-ss_Mc*pcSS;
	SHm     = log( ss_ym/rGDP_ss );
	SHc     = log( pcSS*ss_yc/(ss_ym + pcSS*ss_yc + pnSS*ss_yn) );
	
	r = log((1 + rstar)*exp(S_ss) - 1); 
	S = S_ss;
	rw = log(1+rstar); 
	end;

	shocks;
		var eps_Z = 1;
		var eps_pc = 1;
		var eps_rw = 1;
	end;
	
	steady(solve_algo=3);
	check;

set_dynare_seed(0);		// seed = 0 --> replicate results in the paper

stoch_simul(order=2,pruning,irf=41,nograph,periods=1188,drop=1000,simul_replic=100,hp_filter=1600);  // Main results

