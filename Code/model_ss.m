function ss_vars = model_ss(mp,options)
% Calculates the steady state values of all variables for the parameters
% given in mp

guess       = zeros(29,1);
x_ss        = fsolve(@(x)model_ss_conditions(x,mp),guess,options);
x_ss(1:27)  = exp(x_ss(1:27));

ss_vars.c    = x_ss(1);
ss_vars.n_s  = x_ss(2);
ss_vars.wm   = x_ss(3);
ss_vars.wc   = x_ss(4);
ss_vars.wn   = x_ss(5);
ss_vars.p    = x_ss(6);
ss_vars.pT   = x_ss(7);
ss_vars.k    = x_ss(8);
ss_vars.pi_m = x_ss(9);
ss_vars.pi_c = x_ss(10);
ss_vars.pi_n = x_ss(11);
ss_vars.G    = x_ss(12);
ss_vars.H    = x_ss(13);
ss_vars.Xm   = x_ss(14);
ss_vars.Xc   = x_ss(15);
ss_vars.Xn   = x_ss(16);
ss_vars.XT   = x_ss(17);
ss_vars.km   = x_ss(18);
ss_vars.nm   = x_ss(19);
ss_vars.ym   = x_ss(20);
ss_vars.kc   = x_ss(21);
ss_vars.nc   = x_ss(22);
ss_vars.yc   = x_ss(23);
ss_vars.kn   = x_ss(24);
ss_vars.nn   = x_ss(25);
ss_vars.yn   = x_ss(26);
ss_vars.pn   = x_ss(27);
ss_vars.Mm   = x_ss(28);
ss_vars.Mc   = x_ss(29);
ss_vars.B    = mp.b;
ss_vars.m    = mp.beta;
ss_vars.rm   = (1/ss_vars.m - (1-mp.delta))*ss_vars.p;
ss_vars.rc   = (1/ss_vars.m - (1-mp.delta))*ss_vars.p;
ss_vars.rn   = (1/ss_vars.m - (1-mp.delta))*ss_vars.p;
ss_vars.rKm  = ss_vars.rm/ss_vars.p + 1-mp.delta;
ss_vars.rKc  = ss_vars.rc/ss_vars.p + 1-mp.delta;
ss_vars.rKn  = ss_vars.rn/ss_vars.p + 1-mp.delta;
ss_vars.q    = 1/(1+mp.rstar);



