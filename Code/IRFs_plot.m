%% This file plots the IRFs in figures 2, 3 and 4
% Run this file after solving the model for both the Emerging and the 
% Developed economy. 
% Assumption: the saved IRFs_X.mat files are saved in 'Results/' folder. 
%
% Note: For the Developed economy, IRFs in the paper are produced using a
% version with the productivity process from the Emerging economy. The 
% two economies are then compared when they are hit with the same shocks.

clear all; close all; clc;
names_fig2  = {'Productivity shock', 'Real GDP'};
names_fig3  = {'Commodity price shock', 'Real GDP'};
names_fig4 	= {'p_c', 'GDP', 'N', 'C', 'I', 'NX'};


% Emerging economy: 
load 'Results/IRFs_E.mat';
IRFs_fig2_E 	= IRFs_fig2;
IRFs_fig3_E     = IRFs_fig3;
IRFs_fig4_E     = IRFs_fig4; 

% Developed economy: 
load 'Results/IRFs_D.mat';
IRFs_fig2_D 	= IRFs_fig2;
IRFs_fig3_D     = IRFs_fig3;
IRFs_fig4_D     = IRFs_fig4; 

% Plot parameters:
xx  = (1:length(IRFs_fig2_E(:,1)))-1;
FS  = 9;       % Fontsize
LW  = 1.5;      % Linewidth

% Figure 2: Productivity Shock
fig = figure('Name', 'Productivity Shock'); 
for i=1:2 
    s(i) = subplot(1,2,i);
    plot(xx,IRFs_fig2_E(:,i),'b','LineWidth',LW); 
    hold on;
    plot(xx,IRFs_fig2_D(:,i),'r--','LineWidth',LW); 

    title(names_fig2{i}, 'FontSize', FS);
    set(s(i),'FontSize',FS);

end
set(s(1),'FontSize',FS,'XLim',[0 40],'XTick',0:20:40,'YLim',[0 0.015],'YTick',0:0.01:0.01);
set(s(2),'FontSize',FS,'XLim',[0 40],'XTick',0:20:40,'YLim',[0 0.023],'YTick',0:0.01:0.02);
s(1).Position(1) = 0.08;
s(1).Position(3) = 0.4;
s(1).Position(4) = 0.6;
s(2).Position(3) = 0.4;
s(2).Position(4) = 0.6;

legend('Emerging','Developed','Location','SouthWest','FontSize',FS);

saveas(fig,'Results/Figure2', 'epsc');


% Figure 3: Commodity Price Shock
fig = figure('Name', 'Commodity Price Shock'); 
for i=1:2 
    s(i) = subplot(1,2,i);
    plot(xx,IRFs_fig3_E(:,i),'b','LineWidth',LW); hold on;
    plot(xx,IRFs_fig3_D(:,i),'r--','LineWidth',LW); 
    title(names_fig3{i}, 'FontSize', FS);
    set(s(i),'FontSize',FS);
  
    if i==1
        legend('Emerging','Developed','Location','SouthWest','FontSize',FS);
    end
end
 set(s(1),'FontSize',FS,'XLim',[0 40],'XTick',0:20:40,'YLim',[0 0.061],'YTick',0:0.02:0.06);
 set(s(2),'FontSize',FS,'XLim',[0 40],'XTick',0:20:40,'YLim',[0 0.023],'YTick',0:0.01:0.02);
 s(1).Position(1) = 0.08;
 s(1).Position(3) = 0.4;
 s(1).Position(4) = 0.6;
 s(2).Position(3) = 0.4;
 s(2).Position(4) = 0.6;


saveas(fig,'Results/Figure3', 'epsc');

% Figure 4: Commodity Price Shock 
fig = figure('Name', 'Commodity Price Shock'); 
for i=1:6 
    s(i) = subplot(2,3,i);
    plot(xx,IRFs_fig4_E(:,i),'b','LineWidth',LW); hold on;
    plot(xx,IRFs_fig4_D(:,i),'r--','LineWidth',LW); 
    title(names_fig4{i}, 'FontSize', FS);
    set(s(i),'FontSize',FS);
    if i==5
        legend('Emerging','Developed','Location','NorthEast', 'FontSize', FS);
    end
end
set(s(1),'FontSize',FS,'XLim',[0 40],'XTick',0:20:40,'YLim',[0 0.061],'YTick',0:0.02:0.06);
set(s(2),'FontSize',FS,'XLim',[0 40],'XTick',0:20:40,'YLim',[0 0.023],'YTick',0:0.01:0.02);
set(s(3),'FontSize',FS,'XLim',[0 40],'XTick',0:20:40,'YLim',[0 0.02],'YTick',0:0.01:0.02);
set(s(4),'FontSize',FS,'XLim',[0 40],'XTick',0:20:40,'YLim',[-0.005 0.02],'YTick',0:0.01:0.02,'ytickLabel',0:0.01:0.02);
set(s(5),'FontSize',FS,'XLim',[0 40],'XTick',0:20:40,'YLim',[0 0.1],'YTick',0:0.05:0.1);
set(s(6),'FontSize',FS,'XLim',[0 40],'XTick',0:20:40,'YLim',[-0.015 0.01],'YTick',-0.01:0.01:0.01);

saveas(fig,'Results/Figure4', 'epsc');

   
    