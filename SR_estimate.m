function [Beta_estimate,MSE,MAE,MAPE,Beta3,Beta3_UL,Beta3_CIWidth,R_Square]=SR_estimate(length_pre,length_post,L,Time_series)

n=length_pre+length_post;% Total length of test time series

%% activation function
% ReLU function
start_value=0;
end_value=1;
syms a1 b1 x
eqns = [0*a1+b1-start_value==0, (L)*a1+b1-end_value==0];
S=solve(eqns,[a1 b1]);
a=S.a1;
b=S.b1;
fit=[];
for i=0:(L)
    x=i; 
    f=a*x+b;
    fit(end+1)=eval(f);
end
fit_ReLU=fit;

% Sigmoid function
syms a2 b2
eqns = [a2/(1+exp(L/2))+b2-start_value==0, a2/(1+exp(-L/2))+b2-end_value==0];
S = solve(eqns,[a2 b2]);
a=S.a2;
b=S.b2;
fit=[];
for i=-(L/2):L/2
    x=i; 
    f=a/(1+exp(-x))+b;
    fit(end+1)=eval(f);
end
fit_Sig=fit;
% plot(fit_ReLU,'k')
% hold on;
% plot(fit_Sig,'m')

%% ¿¼ÂÇÌáÇ°Á¿
intervention_Identify=[zeros(length_pre,1);ones(length_post,1)]';
time=(1:n);
post_time=[zeros(length_pre,1);(1:length_post)']';

activation_function_ReLU=[ones(length_pre,1)',fit_ReLU(2:end),ones(length_post-L,1)'];%F(t)_ReLU
activation_function_Sig=[ones(length_pre,1)',fit_Sig(2:end),ones(length_post-L,1)'];%F(t)_Sig

intervention_Identify_activation_ReLU=intervention_Identify.*activation_function_ReLU;%F(t)_ReLU*intervention_Identify
intervention_Identify_activation_Sig=intervention_Identify.*activation_function_Sig;%F(t)_Sig*intervention_Identify

post_time_activation_ReLU=post_time.*activation_function_ReLU;
post_time_activation_Sig=post_time.*activation_function_Sig;


X_classic =[ones(n,1)';time;intervention_Identify;post_time];
X_ReLU =[ones(n,1)';time;intervention_Identify_activation_ReLU;post_time_activation_ReLU];
X_Sig =[ones(n,1)';time;intervention_Identify_activation_Sig;post_time_activation_Sig];

% classic
[b_classic,bint_classic,r_classic,rint_classic,stats_classic]=regress(Time_series',X_classic',0.05);
% F_ReLU
[b_ReLU,bint_ReLU,r_ReLU,rint_ReLU,stats_ReLU]=regress(Time_series',X_ReLU',0.05);
% F_Sig
[b_Sig,bint_Sig,r_Sig,rint_Sig,stats_Sig]=regress(Time_series',X_Sig',0.05);


Beta_estimate=[b_classic bint_classic b_ReLU bint_ReLU b_Sig bint_Sig];
Beta3=[b_classic(4) b_ReLU(4) b_Sig(4)];
%% Goodness of fit of different models

% MSE:mean squared error
MSE_r_classic=sum(r_classic.^2)/n;
MSE_r_ReLU=sum(r_ReLU.^2)/n;
MSE_r_Sig=sum(r_Sig.^2)/n;
MSE=[MSE_r_classic MSE_r_ReLU MSE_r_Sig];

% MAE:mean absolute error
MAE_r_classic=sum(abs(r_classic))/n; 
MAE_r_ReLU=sum(abs(r_ReLU))/n;
MAE_r_Sig=sum(abs(r_Sig))/n;
MAE=[MAE_r_classic MAE_r_ReLU MAE_r_Sig];

% MAPE:mean absolute percentage error
MAPE_classic=0;
MAPE_ReLU=0;
MAPE_Sig=0;
for i=1:n
    MAPE_classic=MAPE_classic+abs(r_classic(i))/abs(Time_series(i));
    MAPE_ReLU=MAPE_ReLU+abs(r_ReLU(i))/abs(Time_series(i));
    MAPE_Sig=MAPE_Sig+abs(r_Sig(i))/abs(Time_series(i));
end
MAPE_classic=MAPE_classic/n;
MAPE_ReLU=MAPE_ReLU/n;
MAPE_Sig=MAPE_Sig/n;
MAPE=[MAPE_classic MAPE_ReLU MAPE_Sig];

% R_Square
R_Square=[stats_classic(1) stats_ReLU(1) stats_Sig(1)];
%% Long-term impact:Beta3
Beta3_CIWidth_classic=bint_classic(4,2)-bint_classic(4,1);
Beta3_CIWidth_ReLU=bint_ReLU(4,2)-bint_ReLU(4,1);
Beta3_CIWidth_Sig=bint_Sig(4,2)-bint_Sig(4,1);
Beta3_CIWidth=[Beta3_CIWidth_classic Beta3_CIWidth_ReLU Beta3_CIWidth_Sig];

Beta3_UL_classic=[bint_classic(4,2) bint_classic(4,1)];
Beta3_UL_ReLU=[bint_ReLU(4,2) bint_ReLU(4,1)];
Beta3_UL_Sig=[bint_Sig(4,2) bint_Sig(4,1)];
Beta3_UL=[Beta3_UL_classic;Beta3_UL_ReLU;Beta3_UL_Sig];

%%
r_error=[r_classic,r_ReLU,r_Sig]';

end