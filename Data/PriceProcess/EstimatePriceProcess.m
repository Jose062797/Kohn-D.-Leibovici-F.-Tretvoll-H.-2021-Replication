clc;
clear; 
close all;


%Load data
    [data_num, data_txt]    = xlsread('PPIs_from_FRED.xls', 'DataQ');

%Dates
    x_axis      = (1974+1/4:1/4:2016.75)';
    T           = length(x_axis);

%Setup price variable
    qp          = log(data_num(2:end,1));
    qpLag       = log(data_num(1:end-1,1));

%Plot
    figure
    s = subplot(1,1,1);
    plot(x_axis,qp,'b', 'LineWidth', 1.5);
    set(s,'FontSize', 12);
    axis([1970 2016 -0.6 0.6]);
    set(gca,'YTick',[-0.6 -0.3 0 0.3 0.6]);
    set(gca,'XTick',[1970 1980 1990 2000 2010 2015]);

%Estimate AR(1) process
    [rho,rhoint,r,rint,stats] = regress(qp-mean(qp), qpLag-mean(qpLag));

    %Display
        fprintf(1,'rho   = %.4f\n',rho);
        fprintf(1,'sigma = %.4f\n',(r'*r/T)^(1/2));
        fprintf(1,'Rsq   = %.4f\n',stats(1));

