function [Runup,setup,STK_setup,STK_IG,STK_INC,STK_swash] = CalcStockdonR2(HS,PSP,S)
% This function computes the R2% using the Stockdon et al., 2006 runup
% paramaterization. 
% Created by K. Serafin 10/11/2017


g = 9.81;
% Compute wave length
L = ((g*(PSP.^2))/(2*pi));    
% First compute Iribarren number (Battjes, 1974)
xi = S./sqrt(HS./L);


% Static Setup, Stockdon (2006) Eqn: 10
STK_setup = 0.35*S*sqrt(HS.*L);    
% Infragravity Swash, Stockdon (2006) Eqn: 12
STK_IG = 0.06*sqrt(HS.*L);   
% Incident Swash, Stockdon (2006) Eqn: 11
STK_INC = 0.75*S*sqrt(HS.*L);

setup = 1.1*(STK_setup);
% Stockdon (2006) Eqn: 7, 11, and 12
STK_swash = sqrt(STK_IG.^2 + STK_INC.^2)/2;

% Runup Stockdon (2006) Eqn: 9
Runup = 1.1*(STK_setup + STK_swash);
% Use different formula for dissipative conditions
ind = find(xi<0.3);
for ii =1:length(ind)
% dissipative-specific eqn 18
        Runup(ind(ii)) = 0.043*sqrt(HS(ind(ii))*L(ind(ii)));
end



end

