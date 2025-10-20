function plotTWLCompositionRegimes(datapth, figpth, fname)
% plotTWLCompositionRegimes(datapth, figpth, fname)
% INPUT: 
% datapth = folder that contains the following files: 
%  - TWL/dynamic SWL relative composition at individual beach profiles by
%  year for each regime:
%   pcentS_byprofile_<fname>.mat (pcentS: fields Seasonality, sla, SS, MSL, Tide, splitres, R2)
%   pcentC_byprofile_<fname>.mat (pcentC: same fields)
%   pcentO_byprofile_<fname>.mat (pcentO: same fields)
%   pcentI_byprofile_<fname>.mat (pcentI: same fields)
%  - Average TWL/dynamic SWL relative composition across beach profiles and
%  years: 
%   RegimesAvgContribution_<fname>.mat (allRegimesContribution: 4x7)
% 
% figpth = folder to save output figures
% fname = station name
% OUTPUT: 
% None, but saves 5 PNGs to figpth.

if ~exist(figpth,'dir'), mkdir(figpth); end

% Plot colors for TWL driving processes (i.e., MSL, Tide, Seasonality, SLA, SS, Residual, R2%/<eta>)
C = [
    0.0000 0.4471 0.7412
    0.4941 0.1843 0.5569
    0.9294 0.6941 0.1255
    0.8510 0.3255 0.0980
    0.4667 0.6745 0.1882
    0.6353 0.0784 0.1843
    0.3020 0.7451 0.9333
];

%% 1A) SWASH
load(fullfile(datapth, ['pcentS_byprofile_' fname '.mat'])); % pcentS
% Exclude profiles with empty contributions (no regime detected) by
% excluding all-zero across all components/years & MSL==100 across years
nS = size(pcentS.MSL,1);
hasNonZero_S = any(pcentS.MSL~=0 & ~isnan(pcentS.MSL),2) ...
             | any(pcentS.Tide~=0 & ~isnan(pcentS.Tide),2) ...
             | any(pcentS.Seasonality~=0 & ~isnan(pcentS.Seasonality),2) ...
             | any(pcentS.sla~=0 & ~isnan(pcentS.sla),2) ...
             | any(pcentS.SS~=0 & ~isnan(pcentS.SS),2) ...
             | any(pcentS.splitres~=0 & ~isnan(pcentS.splitres),2) ...
             | any(pcentS.R2~=0 & ~isnan(pcentS.R2),2);
msl100_S = all(pcentS.MSL==100,2);
valid_S = hasNonZero_S & ~msl100_S;

pc_S = [ ...
    nanmean(pcentS.MSL,2), ...
    nanmean(pcentS.Tide,2), ...
    nanmean(pcentS.Seasonality,2), ...
    nanmean(pcentS.sla,2), ...
    nanmean(pcentS.SS,2), ...
    nanmean(pcentS.splitres,2), ...
    nanmean(pcentS.R2,2) ];
pc_S = pc_S(valid_S,:);

f = figure('Visible','on');
b = barh(pc_S,'stacked','FaceColor','flat');
for j = 1:7, b(j).CData = C(j,:); end
xlabel('% contribution'); xlim([-10 110]); ylabel('profile number');
set(gca,'fontsize',12,'fontweight','bold'); grid on
title(['swash regime, ' fname], 'Interpreter','none')
legend('\eta_{MSL}','\eta_{A}','\eta_{SE}','\eta_{SLA}','\eta_{SS}','Residual','R_{2%}', ...
       'location','southeast','orientation','vertical','fontsize',10)
exportgraphics(f, fullfile(figpth, ['swashContribution_' fname '.png']), 'Resolution', 300);
close(f);

%% 1B) COLLISION
load(fullfile(datapth, ['pcentC_byprofile_' fname '.mat'])); % pcentC
nC = size(pcentC.MSL,1);
hasNonZero_C = any(pcentC.MSL~=0 & ~isnan(pcentC.MSL),2) ...
             | any(pcentC.Tide~=0 & ~isnan(pcentC.Tide),2) ...
             | any(pcentC.Seasonality~=0 & ~isnan(pcentC.Seasonality),2) ...
             | any(pcentC.sla~=0 & ~isnan(pcentC.sla),2) ...
             | any(pcentC.SS~=0 & ~isnan(pcentC.SS),2) ...
             | any(pcentC.splitres~=0 & ~isnan(pcentC.splitres),2) ...
             | any(pcentC.R2~=0 & ~isnan(pcentC.R2),2);
msl100_C = all(pcentC.MSL==100,2);
valid_C = hasNonZero_C & ~msl100_C;

pc_C = [ ...
    nanmean(pcentC.MSL,2), ...
    nanmean(pcentC.Tide,2), ...
    nanmean(pcentC.Seasonality,2), ...
    nanmean(pcentC.sla,2), ...
    nanmean(pcentC.SS,2), ...
    nanmean(pcentC.splitres,2), ...
    nanmean(pcentC.R2,2) ];
pc_C = pc_C(valid_C,:);

f = figure('Visible','on');
b = barh(pc_C,'stacked','FaceColor','flat');
for j = 1:7, b(j).CData = C(j,:); end
xlabel('% contribution'); xlim([-10 110]); ylabel('profile number');
set(gca,'fontsize',12,'fontweight','bold'); grid on
title(['collision regime, ' fname], 'Interpreter','none')
legend('\eta_{MSL}','\eta_{A}','\eta_{SE}','\eta_{SLA}','\eta_{SS}','Residual','R_{2%}', ...
       'location','southeast','orientation','vertical','fontsize',10)
exportgraphics(f, fullfile(figpth, ['collisionContribution_' fname '.png']), 'Resolution', 300);
close(f);

%% 1C) OVERTOPPING
load(fullfile(datapth, ['pcentO_byprofile_' fname '.mat'])); % pcentO
nO = size(pcentO.MSL,1);
hasNonZero_O = any(pcentO.MSL~=0 & ~isnan(pcentO.MSL),2) ...
             | any(pcentO.Tide~=0 & ~isnan(pcentO.Tide),2) ...
             | any(pcentO.Seasonality~=0 & ~isnan(pcentO.Seasonality),2) ...
             | any(pcentO.sla~=0 & ~isnan(pcentO.sla),2) ...
             | any(pcentO.SS~=0 & ~isnan(pcentO.SS),2) ...
             | any(pcentO.splitres~=0 & ~isnan(pcentO.splitres),2) ...
             | any(pcentO.R2~=0 & ~isnan(pcentO.R2),2);
msl100_O = all(pcentO.MSL==100,2);
valid_O = hasNonZero_O & ~msl100_O;

pc_O = [ ...
    nanmean(pcentO.MSL,2), ...
    nanmean(pcentO.Tide,2), ...
    nanmean(pcentO.Seasonality,2), ...
    nanmean(pcentO.sla,2), ...
    nanmean(pcentO.SS,2), ...
    nanmean(pcentO.splitres,2), ...
    nanmean(pcentO.R2,2) ];
pc_O = pc_O(valid_O,:);

f = figure('Visible','on');
b = barh(pc_O,'stacked','FaceColor','flat');
for j = 1:7, b(j).CData = C(j,:); end
xlabel('% contribution'); xlim([-10 110]); ylabel('profile number');
set(gca,'fontsize',12,'fontweight','bold'); grid on
title(['overtopping regime, ' fname], 'Interpreter','none')
legend('\eta_{MSL}','\eta_{A}','\eta_{SE}','\eta_{SLA}','\eta_{SS}','Residual','R_{2%}', ...
       'location','southeast','orientation','vertical','fontsize',10)
exportgraphics(f, fullfile(figpth, ['overtopContribution_' fname '.png']), 'Resolution', 300);
close(f);

%% 1D) INUNDATION
load(fullfile(datapth, ['pcentI_byprofile_' fname '.mat'])); % pcentI
nI = size(pcentI.MSL,1);
hasNonZero_I = any(pcentI.MSL~=0 & ~isnan(pcentI.MSL),2) ...
             | any(pcentI.Tide~=0 & ~isnan(pcentI.Tide),2) ...
             | any(pcentI.Seasonality~=0 & ~isnan(pcentI.Seasonality),2) ...
             | any(pcentI.sla~=0 & ~isnan(pcentI.sla),2) ...
             | any(pcentI.SS~=0 & ~isnan(pcentI.SS),2) ...
             | any(pcentI.splitres~=0 & ~isnan(pcentI.splitres),2) ...
             | any(pcentI.R2~=0 & ~isnan(pcentI.R2),2);
msl100_I = all(pcentI.MSL==100,2);
valid_I = hasNonZero_I & ~msl100_I;

pc_I = [ ...
    nanmean(pcentI.MSL,2), ...
    nanmean(pcentI.Tide,2), ...
    nanmean(pcentI.Seasonality,2), ...
    nanmean(pcentI.sla,2), ...
    nanmean(pcentI.SS,2), ...
    nanmean(pcentI.splitres,2), ...
    nanmean(pcentI.R2,2) ];
pc_I = pc_I(valid_I,:);

f = figure('Visible','on');
b = barh(pc_I,'stacked','FaceColor','flat');
for j = 1:6, b(j).CData = C(j,:); end
b(7).CData = [1.0000 0.0745 0.6510]; % <eta> for inundation
xlabel('% contribution'); xlim([-10 110]); ylabel('profile number');
set(gca,'fontsize',12,'fontweight','bold'); grid on
title(['inundation regime, ' fname], 'Interpreter','none')
legend('\eta_{MSL}','\eta_{A}','\eta_{SE}','\eta_{SLA}','\eta_{SS}','Residual','<\eta>', ...
       'location','southeast','orientation','vertical','fontsize',10)
exportgraphics(f, fullfile(figpth, ['inundaContribution_' fname '.png']), 'Resolution', 300);
close(f);

%% 2) Average TWL/dynamic SWL relative composition across regimes 
load(fullfile(datapth, ['RegimesAvgContribution_' fname '.mat']), 'allRegimesContribution');
f = figure('Visible','on'); hold on
f.Position =[553,396,687,420];
for r = 1:4
    bb = barh(r, allRegimesContribution(r,1:7), 'stacked', 'FaceColor','flat');
    for j = 1:6, bb(j).CData = C(j,:); end
    if r < 4, bb(7).CData = C(7,:); else, bb(7).CData = [1.0000 0.0745 0.6510]; end
end

title(fname)
yticks([1 2 3 4])
yticklabels({'Swash','Collision','Overtopping','Inundation'})
xlim([-5 105]); xlabel('% contribution to TWL','FontSize',14)
grid on; set(gca,'fontsize',14,'fontweight','bold')

% set legend
L(1) = patch(NaN,NaN,C(1,:), 'DisplayName','\eta_{MSL}');
L(2) = patch(NaN,NaN,C(2,:), 'DisplayName','\eta_{A}');
L(3) = patch(NaN,NaN,C(3,:), 'DisplayName','\eta_{SE}');
L(4) = patch(NaN,NaN,C(4,:), 'DisplayName','\eta_{SLA}');
L(5) = patch(NaN,NaN,C(5,:), 'DisplayName','\eta_{SS}');
L(6) = patch(NaN,NaN,C(6,:), 'DisplayName','Residual');
L(7) = patch(NaN,NaN,C(7,:), 'DisplayName','R_{2%}');
L(8) = patch(NaN,NaN,[1.0000 0.0745 0.6510], 'DisplayName','<\eta>');
legend(L, 'location','southeastoutside', 'orientation','vertical', 'fontsize',10)

exportgraphics(f, fullfile(figpth, ['averageContributionacrossregimes_' fname '.png']), 'Resolution', 300);
close(f);

end