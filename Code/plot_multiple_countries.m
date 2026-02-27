
% Parameters for plots
f=12;   % Fontsize for every plot
lw=1.5;   % Linewidth for every plot

% Load data
BC_moments_data= xlsread('Table5_PanelA_CountryByCountry.csv');
% sd Y,	sd TB_Y, sd C_Y, sd I_Y, sd N_Y, sd TFP_Y, sd Pc_Y country_cat
sd_Y=BC_moments_data(:,1);

[moments_data,labels_data] = xlsread('Table4_XSectionalMoments_CountryByCountry.csv');
country_names=labels_data(3:end,1);

ss_targets.mfct_GDP         = moments_data(:,1); 
ss_targets.commodities_GDP  = moments_data(:,2);
ss_targets.NXmfct_GDP       = moments_data(:,3);
ss_targets.NX_GDP           = moments_data(:,4);
ss_targets.country_cat      = moments_data(:,5);

calibrated_parameters = xlsread('Results/calibrated_parameters.xls','Calibrated Parameters');
s.calibrated_parameters = calibrated_parameters(:,5:9); %Am, eta, etaT, b

resfile     = 'Results/generated_results_multiple_countries.xls';
moments_model=xlsread(resfile, 'Table_BC');

%% Figure 5

figure;
fig=scatter(ss_targets.NXmfct_GDP,sd_Y,20,'s','filled',...
              'MarkerEdgeColor',[0 0 1],...
              'MarkerFaceColor',[.2 .2 1],...
              'LineWidth',lw);

hold on
scatter(ss_targets.NXmfct_GDP,moments_model(:,1)/100,20,'d','filled',...
              'MarkerEdgeColor',[1 0 0],...
              'MarkerFaceColor',[1 .2 .2],...
              'LineWidth',lw);

hold on

[b1,b1int,r1,r1int,stats1] = regress(sd_Y,[ones(length(ss_targets.NXmfct_GDP),1) ss_targets.NXmfct_GDP]);
[b2,b2int,r2,r2int,stats2] = regress(moments_model(:,1)/100,[ones(length(ss_targets.NXmfct_GDP),1) ss_targets.NXmfct_GDP]);

 
trend1 = refline([b1(2) b1(1)]);
set(trend1,'Color',[0 0 1],'linewidth',lw);

trend2 = refline([b2(2) b2(1)]);
set(trend2,'Color',[1 0 0],'linewidth',lw);

hold on

a=round(b2(1)*100)/100;
b=round(b2(2)*100)/100;
c=round(stats2(1)*100)/100;
text(-0.005,0.065,['y=',num2str(a),'-',num2str(abs(b)),'x'],'FontSize',f,'FontWeight','bold','color',[1 0 0]) 
text(-0.005,0.056,['R^2=',num2str(c)],'FontSize',f,'FontWeight','bold','color',[1 0 0]) 

a=round(b1(1)*100)/100;
b=round(b1(2)*100)/100;
c=round(stats1(1)*100)/100;
text(-0.005,0.09,['y=',num2str(a),'-',num2str(abs(b)),'x'],'FontSize',f,'FontWeight','bold','color',[0 0 1]) 
text(-0.005,0.081,['R^2=',num2str(c)],'FontSize',f,'FontWeight','bold','color',[0 0 1]) 



set(gca,'FontSize',f,'XTick',-0.3:0.1:0.1,'YTick',0:0.03:0.12);
axis([-0.28 0.12 0 0.12])


h=xlabel('Manufactures net exports-to-GDP ratio');
to = findobj( h, 'type', 'text' );
set( to, 'fontsize', f );

h=ylabel('Std. dev. real GDP');
to = findobj( h, 'type', 'text' );
set( to, 'fontsize', f );

hleg = legend('Data','Model','Location','NorthEast');
th = findobj( hleg, 'type', 'text' );
set( th, 'fontsize', f );

saveas(fig,'Results/Figure5', 'epsc');


%% Figure 6

[b2,b2int,r2,r2int,stats2] = regress(moments_model(:,1)/100,[ones(length(ss_targets.NXmfct_GDP),1) ss_targets.NXmfct_GDP ss_targets.commodities_GDP ss_targets.mfct_GDP ss_targets.NX_GDP]);
[b1,b1int,r1,r1int,stats1] = regress(sd_Y,[ones(length(ss_targets.NXmfct_GDP),1) ss_targets.NXmfct_GDP ss_targets.commodities_GDP ss_targets.mfct_GDP ss_targets.NX_GDP]);

data_pred=[ones(length(ss_targets.NXmfct_GDP),1) ss_targets.NXmfct_GDP ss_targets.commodities_GDP ss_targets.mfct_GDP ss_targets.NX_GDP]*b1;
model_pred=[ones(length(ss_targets.NXmfct_GDP),1) ss_targets.NXmfct_GDP ss_targets.commodities_GDP ss_targets.mfct_GDP ss_targets.NX_GDP]*b2;

figure; 
fig=scatter(model_pred,data_pred,20,'s','filled',...
              'MarkerEdgeColor',[0 0 1],...
              'MarkerFaceColor',[.2 .2 1],...
              'LineWidth',lw);
          
          
hold on

[b1,b1int,r1,r1int,stats1] = regress(data_pred,[ones(length(model_pred),1) model_pred]);

trend1 = refline([b1(2) b1(1)]);
set(trend1,'Color',[0 0 1],'linewidth',lw);

hold on

trend2 = refline([1 0]);
set(trend2,'Color',[0 0 0],'linewidth',lw,'linestyle','--');

a=round(b1(1)*100)/100;
b=round(b1(2)*100)/100;
c=round(stats1(1)*100)/100;
text(0.045,0.03,['y=',num2str(a),'+',num2str(b),'x'],'FontSize',f,'FontWeight','bold','color',[0 0 1]) 
text(0.045,0.026,['R^2=',num2str(c)],'FontSize',f,'FontWeight','bold','color',[0 0 1]) 


set(gca,'FontSize',f,'XTick',0:0.02:0.06,'YTick',0:0.02:0.06);
axis([0.013 0.0605 0.013 0.0605])

h=xlabel('$\widehat{sd(Y)}$ Model');
to = findobj( h, 'type', 'text' );
set( to, 'fontsize', f, 'Interpreter','latex');

h=ylabel('$\widehat{sd(Y)}$ Data');
to = findobj( h, 'type', 'text' );
set( to, 'fontsize', f, 'Interpreter','latex');

saveas(fig,'Results/Figure6', 'epsc');  