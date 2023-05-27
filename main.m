clc;clear;
Time_series=xlsread('Test.xlsx','Sheet1');
T_e=length(Time_series);% Total length of test time series
T_0=72; % Nominal intervention point 
length_pre=T_0;% Test time series length before nominal intervention time
length_post=T_e-length_pre;% Test time series length after nominal intervention time
%% For a specific lag length, three models are used to estimate the intervention effect:

L=8; % lag length of intervention effect
[Beta_estimate,MSE,MAE,MAPE,Beta3,Beta3_UL,Beta3_CIWidth,R_Square]=SR_estimate(length_pre,length_post,L,Time_series');

% CSR
Beta_estimate_CSR=Beta_estimate(:,1:3)
Goodness_of_fit_CSR=[MSE(1) MAE(1) MAPE(1) R_Square(1)]
% OSR_ReLU
Beta_estimate_OSR_ReLU=Beta_estimate(:,4:6)
Goodness_of_fit_OSR_ReLU=[MSE(2) MAE(2) MAPE(2) R_Square(2)]
% OSR_Sig
Beta_estimate_OSR_Sig=Beta_estimate(:,7:9)
Goodness_of_fit_OSR_Sig=[MSE(3) MAE(3) MAPE(3) R_Square(3)]
%% Selection of the lag length
index_matrix_set=[];
MSE_OSR_ReLU=[];
MSE_OSR_Sig=[];
for i=1:10
    [Beta_estimate,MSE,MAE,MAPE,Beta3,Beta3_UL,Beta3_CIWidth,R_Square]=SR_estimate(length_pre,length_post,i,Time_series');
    index_matrix=[i*ones(1,3)' (1:3)' MSE' MAE' MAPE' Beta3' Beta3_UL Beta3_CIWidth' R_Square'];
    index_matrix_set=[index_matrix_set;index_matrix];    
    MSE_OSR_ReLU=[MSE_OSR_ReLU;i MSE(2)];
    MSE_OSR_Sig=[MSE_OSR_Sig;i MSE(3)];
end

%% Taking MSE as an example for the goodness of model fitting

% OSR_ReLU
min_MSE_OSR_ReLU=min(MSE_OSR_ReLU(:,2));
[x,y]=find(MSE_OSR_ReLU==min_MSE_OSR_ReLU); % returns the index
Selection_L_OSR_ReLU=MSE_OSR_ReLU(x,1)
min_MSE_OSR_ReLU

% OSR_Sig
min_MSE_OSR_Sig=min(MSE_OSR_Sig(:,2));
[x,y]=find(MSE_OSR_Sig==min_MSE_OSR_Sig); % returns the index
Selection_L_OSR_Sig=MSE_OSR_Sig(x,1)
min_MSE_OSR_Sig



