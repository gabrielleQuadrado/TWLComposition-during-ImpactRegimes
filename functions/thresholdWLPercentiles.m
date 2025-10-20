function pctiles = thresholdWLPercentiles(hourlyData, sline, toe, crest, conversion, outpth, fname)
% saveThresholdPercentiles
% Define percentiles of morphological thresholds relative to TWL and dynamic SWL
% and save a summary percentile struct.
%
% INPUT:
%   hourlyData = struct with fields .twl, .r2, .setup & more (optional)
%   sline = shoreline elevation (m)
%   toe = morphological survey matrix with just dune toe information; column 7 = elevation (m)
%   crest = morphological survey matrix with just dune crest information; column 7 = elevation (m)
%   conversion = datum conversion applied to hourly TWL in meters (e.g.,
%   MLLW to NAVD88); if conversion requires subtraction (MLLW - NAVD88),
%   provide positive value, otherwise provide negative value
%   outpth = output folder 
%   fname = station name 
%
% OUTPUT:
%   pctiles : struct with fields:
%          .avgpctiles  [1x4] = [swash, collision, overtopping, inundation]
%          .minpctiles  [1x4]
%          .maxpctiles  [1x4]
%          .thresholds  [1x4] = [sline, mean(toe_z), mean(crest_z), mean(crest_z)]
%          .minthresholds [1x4]
%          .maxthresholds [1x4]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist(outpth,'dir'), mkdir(outpth); end

% Convert TWL from MLLW to NAVD88
twl = hourlyData.twl - conversion;

% Define dynamic SWL (swl + setup)
dynamicSWL = (twl - hourlyData.r2) + hourlyData.setup;

% Compute TWL ECDF (for swash, collision, and overtopping regimes)
twl = sort(twl);
[f_twl, x_twl] = ecdf(twl);
[x_twl, ia] = unique(x_twl);
f_twl = f_twl(ia);

% Percentile at shoreline vs TWL
swashPctile = interp1(x_twl, f_twl, sline, 'linear') * 100;

% Percentiles at toe and crest vs TWL
toe_z   = toe(:,7);
crest_z = crest(:,7);

collisionPctile   = interp1(x_twl, f_twl, toe_z,   'linear') * 100;
overtopPctile     = interp1(x_twl, f_twl, crest_z, 'linear') * 100;

avgCollisionPctile = nanmean(collisionPctile);
minCollisionPctile = nanmin(collisionPctile);
maxCollisionPctile = nanmax(collisionPctile);

avgOvertopPctile = nanmean(overtopPctile);
minOvertopPctile = nanmin(overtopPctile);
maxOvertopPctile = nanmax(overtopPctile);

% Dynamic SWL ECDF (for inundation only)
dynamicSWL = sort(dynamicSWL);
[f_dyn, x_dyn] = ecdf(dynamicSWL);
[x_dyn, ia2] = unique(x_dyn);
f_dyn = f_dyn(ia2);

inundaPctile = interp1(x_dyn, f_dyn, crest_z, 'linear') * 100;

avgInundaPctile = nanmean(inundaPctile);
minInundaPctile = nanmin(inundaPctile);
maxInundaPctile = nanmax(inundaPctile);

% Set output struct
pctiles.avgpctiles = [swashPctile, avgCollisionPctile,  avgOvertopPctile,  avgInundaPctile];
pctiles.minpctiles = [swashPctile, minCollisionPctile,  minOvertopPctile,  minInundaPctile];
pctiles.maxpctiles = [swashPctile, maxCollisionPctile,  maxOvertopPctile,  maxInundaPctile];

pctiles.thresholds     = [sline, nanmean(toe_z),  nanmean(crest_z),  nanmean(crest_z)];
pctiles.minthresholds  = [sline, nanmin(toe_z),   nanmin(crest_z),   nanmin(crest_z)];
pctiles.maxthresholds  = [sline, nanmax(toe_z),   nanmax(crest_z),   nanmax(crest_z)];

% Save
save(fullfile(outpth, ['thresholdspctile_' fname '.mat']), "pctiles");
end
