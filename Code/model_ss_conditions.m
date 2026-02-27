function z = model_ss_conditions(vars,mp)
% For a given set of variables and parameters, what are the deviations in
% all the steady state condtions of the model?

vars(1:27)  = exp(vars(1:27));

c       = vars(1);
n_s     = vars(2);
wm      = vars(3);
wc      = vars(4);
wn      = vars(5);
p       = vars(6);
pT      = vars(7);
k       = vars(8);
pi_m    = vars(9);
pi_c    = vars(10);
pi_n    = vars(11);
G       = vars(12);
H       = vars(13);
Xm      = vars(14);
Xc      = vars(15);
Xn      = vars(16);
XT      = vars(17);
km      = vars(18);
nm      = vars(19);
ym      = vars(20);
kc      = vars(21);
nc      = vars(22);
yc      = vars(23);
kn      = vars(24);
nn      = vars(25);
yn      = vars(26);
pn      = vars(27);
Mm      = vars(28);
Mc      = vars(29);
    
z       = zeros(29,1);

%% Households

%Easy variables
    B = mp.b;
    q = 1/(1+mp.rstar);
    m = mp.beta;    % recall: mp.rstar    = (1/mp.beta - 1);
    
    rm = (1/m - (1-mp.delta))*p;
    rc = (1/m - (1-mp.delta))*p;
    rn = (1/m - (1-mp.delta))*p;
        
%Rest of variables
z(1) = mp.psi_u*mp.nu*n_s^(mp.nu-1) -wm/p;  %nm
z(2) = mp.psi_u*mp.nu*n_s^(mp.nu-1) -wc/p;  %nc
z(3) = mp.psi_u*mp.nu*n_s^(mp.nu-1) -wn/p;  %nn
    
%Budget constraint
z(4) = wm*nm + wc*nc +wn*nn  + rm*km + rc*kc+ rn*kn + pi_m + pi_c + pi_n + pT*B*(1-q) - p*mp.delta*k - p*c; 
    

%% Final goods

sig  = mp.sigma;
z(5) = p*(G^(1/sig))*mp.eta*XT^(-1/sig) - pT;    % XT
z(6) = p*(G^(1/sig))*(1-mp.eta)*Xn^(-1/sig) - pn; %Xn

if sig==1
    z(7) = G - XT^mp.eta*Xn^(1-mp.eta);  %G  
else
    z(7) = G - (mp.eta*XT^((sig-1)/sig)+(1-mp.eta)*Xn^((sig-1)/sig))^(sig/(sig-1));  %G  
end
    

%% Tradable goods

sigT  = mp.sigmaT;
z(8) = pT*(H^(1/sigT))*mp.etaT*Xm^(-1/sigT) - 1;            %Xm
z(9) = pT*(H^(1/sigT))*(1-mp.etaT)*Xc^(-1/sigT) - mp.pc_SS; %Xc

if sigT==1
    z(10) = H - Xm^mp.etaT*Xc^(1-mp.etaT);  %H  
else
    z(10) = H - (mp.etaT*Xm^((sigT-1)/sigT)+(1-mp.etaT)*Xc^((sigT-1)/sigT))^(sigT/(sigT-1));  %H  
end
    
    
%% Manufactured goods

    z(11)  = rm - mp.theta_m*mp.mu*mp.Am*(((km^mp.theta_m)*(nm^(1-mp.theta_m)))^mp.mu)/km; %rm
    z(12)  = wm - (1-mp.theta_m)*mp.mu*mp.Am*(((km^mp.theta_m)*(nm^(1-mp.theta_m)))^mp.mu)/nm; %wm
    z(13)  = pi_m - ym + wm*nm + rm*km; %pi_m
    z(14)  = ym - mp.Am*((km^mp.theta_m)*(nm^(1-mp.theta_m)))^mp.mu; %y_m

%% Commodities

    z(15)  = rc - mp.theta_c*mp.mu*mp.pc_SS*mp.Ac*(((kc^mp.theta_c)*(nc^(1-mp.theta_c)))^mp.mu)/kc; %rc
    z(16)  = wc - (1-mp.theta_c)*mp.mu*mp.pc_SS*mp.Ac*(((kc^mp.theta_c)*(nc^(1-mp.theta_c)))^mp.mu)/nc; %wc
    z(17)  = pi_c - yc + wc*nc + rc*kc; %pi_c
    z(18)  = yc - mp.Ac*((kc^mp.theta_c)*(nc^(1-mp.theta_c)))^mp.mu; %y_c


%% Nontradable goods

    z(19)  = rn - mp.theta_n*mp.mu*pn*mp.An*(((kn^mp.theta_n)*(nn^(1-mp.theta_n)))^mp.mu)/kn; %rn
    z(20)  = wn - (1-mp.theta_n)*mp.mu*pn*mp.An*(((kn^mp.theta_n)*(nn^(1-mp.theta_n)))^mp.mu)/nn; %wn
    z(21)  = pi_n - pn*yn + wn*nn + rn*kn; %pi_n
    z(22)  = yn - mp.An*((kn^mp.theta_n)*(nn^(1-mp.theta_n)))^mp.mu; %y_n
    

%% Market clearing

    z(23) = n_s - nc - nm - nn; %n_s
    z(24) = k - kc - km - kn; %k
    z(25) = G - c - mp.delta*k; %p
    z(26) = H - XT; %pT (or H)
    z(27) = Xn - yn; %pn
    z(28) = Xm - ym - Mm; %Mm
    z(29) = Xc - yc - Mc; %Mc
   
    
% %% Rescale
%     %scale = [1 1 1 1 1 1 1 1 ym yc yn 1 1 ym yc yn 1 ym ym ym yc yc yc yn yn yn yn ym yc]';
%     %scale = [1 1 1 1 1 1 ym ym ym ym yp yp yp yp 1 1 1 ym yp 1]';
%     
%     scale=ones(size(z));
%     z = z./scale;

end
