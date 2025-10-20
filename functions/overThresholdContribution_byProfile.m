function [allRegimesContribution,twl,dynamicSWL] = overThresholdContribution_byProfile(hourlyData,M,sline,toe,crest,conversion,hgow,fname,outpth)
% overThresholdContribution -  This function finds the relative contribution of TWL regarding
%the hours over a given threshold. 
%   INPUTS:
% hourlyData = structured hourly time series of data values
% sline =  mhhw relative to navd88
% toe = dune toe height in meters
% crest = dune crest height in meters
% fname = name of the location; 
% outpth = output path;
% OUTPUTS:
% date = dates in which the relative TWL contribution was evaluated
% TWL = TWL magnitude during impact regimes, in meters
% SWL = SWL magnitude during impact regimes, in meters
% Created by G. Quadrado 06/04/21
% Updated by G. Quadrado 07/06/23
% Update includes all regimes calculations in the same code instead of
% always modifying the thresholds for the chosen regime. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1.0 Set variables and paths
outpth=outpth;
M=M;
hourlyData=hourlyData;
time=hourlyData.time;
Exist=exist('limit');
if Exist == 1
    limit=limit;
else
end

% Create folders to store output
if ~exist(outpth, 'dir')
    mkdir(outpth);
end
%% 2.0 Separate MSL into relative sea level (RSL) and sea level anomalies (SLA) 
msl = hourlyData.msl-conversion; % convert from MLLW to NAVD88 based on VDatum 
mslMean=nanmean(msl); % de-mean, removes datum
warning("off")

% Separate MSL from SLA
ind = find(hourlyData.time>datenum(1925,1,1,0,0,0));
newMSL = msl(ind(1):end);
newtime = hourlyData.time(ind(1):end);
ind = find(isnan(newMSL)<1);
p = polyfit(newtime(ind),newMSL(ind),2); 
RSL = polyval(p,newtime); % long-term RSL

% Define your variables again 
[~,ia,ib]= intersect(newtime,hourlyData.time);
match = msl(ib);
sla = match - RSL; % SLA
msl = RSL; 
time = newtime;
tide = hourlyData.tide(ib);
se = hourlyData.seasonal(ib);
ss = hourlyData.ss(ib);
setup = hourlyData.setup(ib); 
splitres = hourlyData.residual(ib);
hs = hourlyData.swh(ib); 
tp = hourlyData.tp(ib); 
swl = tide+se+ss+msl+sla; 
splitres = hourlyData.residual(ib);
swl = swl + splitres; 
clear hourlyData
%% 4.0 Remove years with < 80% hourly completeness
dateR = datevec(time);
year = dateR(1,1):dateR(end,1);
years = dateR(:,1);
yearsToRemove = [];

for y = 1:length(year)
           ind = find(years==year(y));
       if sum(~isnan(swl(ind))) / (24 * 365.25) < 0.80 && year(y)>=1979
        yearsToRemove = [yearsToRemove; year(y)]; 
       else
       end
end

mask1980 = years >= 1980;
maskGood = ~ismember(years, yearsToRemove);
keepMask = mask1980 & maskGood;
time     = time(keepMask);
swl      = swl(keepMask);
tide     = tide(keepMask);
se       = se(keepMask);
ss       = ss(keepMask);
msl      = msl(keepMask);
sla      = sla(keepMask);
hs       = hs(keepMask);
tp       = tp(keepMask);
splitres = splitres(keepMask);

dateR = datevec(time);
year = dateR(1,1):dateR(end,1);
%% 5.0 Evaluate Storm Impact Regimes
% Prepare data
segnum=unique(M(:,2));
numSegments = length(segnum);
swash_cell = cell(numSegments,1);
collision_cell = cell(numSegments,1);
overtop_cell = cell(numSegments,1);
inunda_cell = cell(numSegments,1);

cnt=1; 
for seg = segnum(1,1):segnum(1,end)
        profidx=find(M(:,2)==seg);
        profnum=unique(M(profidx,3));

        % arrays for current segment
    date_swash = [];
    TWL_swash = [];
    date_collision = [];
    TWL_collision = [];
    date_overtop = [];
    TWL_overtop = [];
    date_inunda = [];
    dynamicSWL_inunda = [];

% Determine morphological thresholds for each profile 
       for k = profnum(1):profnum(end);
            [ind,~] = find(M(profidx,3)==k);
           if isempty(ind)==0
            sline = sline;
            indtoe = find(M(ind,12)==2); 
            toe = M(ind(indtoe),7);
            indcrest = find(M(ind,12)==3); 
            crest = M(ind(indcrest),7);

% Estimate wave runup for each profile based on hourly TS
ind2 = find(M(ind,11)~=999); % morphology dataset has 999 values - must remove
if ind2 > 0 
beachSlope = M(ind(ind2),11); 
 if length(beachSlope) > 1 
     beachSlope=nanmean(beachSlope); % average beach slope for profiles with more than one measurement, some profiles have more than one beach slope estimate (USGS survey covers a period, not a single day)
     [r2,setup] = CalcStockdonR2(hs,tp,beachSlope);
 else
[r2,setup] = CalcStockdonR2(hs,tp,beachSlope);
 end

% Get TWL and dynamic SWL estimates
twl = r2 + swl;
dynamicSWL = (twl - r2) + setup; 

if isempty(toe)==0&isempty(crest)==0
    if length(toe)>length(crest)
    toe = nanmean(toe);
    elseif length(crest)>length(toe)
    crest = nanmean(crest);
    else
    end
    for ii=1:length(year);
        idx=find(year(ii)==dateR(:,1));       
%% 5A) SWASH REGIME
index=find(twl(idx)>=sline&twl(idx)<toe); % swash regime is between MHHW and dune toe

% Check if index is not empty
    if isempty(index)
        disp(['Swash index empty for year: ', num2str(year(ii)), ' and profile: ', num2str(k)]);
        date_swash(k,ii)=NaN;
TWL_swash(k,ii)=NaN;
swash.time(k,ii)=NaN;
swash.Seasonality(k,ii)=NaN;
swash.sla(k,ii)=NaN;
swash.SS(k,ii)=NaN;
swash.MSL(k,ii)=NaN;
swash.Tide(k,ii)=NaN;
swash.R2(k,ii)=NaN;
swash.splitres(k,ii)=NaN;
    else
date_swash(k,ii)=time(idx(ii));
TWL_swash(k,ii)=nanmean(twl(idx(index)));
swash.time(k,ii)=nanmean(time(idx(index)));
swash.Seasonality(k,ii)=nanmean(se(idx(index)));
swash.sla(k,ii)=nanmean(sla(idx(index)));
swash.SS(k,ii)=nanmean(ss(idx(index)));
swash.MSL(k,ii)=nanmean(msl(idx(index)));
swash.Tide(k,ii)=nanmean(tide(idx(index)));
swash.R2(k,ii)=nanmean(r2(idx(index)));
swash.splitres(k,ii)=nanmean(splitres(idx(index)));
    end
% Sum the average magnitudes, otherwise total contributions won't be 100%
swash.TWL = swash.MSL + swash.Seasonality + swash.Tide + swash.sla + swash.SS + swash.R2 + swash.splitres;

%% 5B) COLLISION 
index=find(twl(idx)>=toe&twl(idx)<crest); % collision regime is between dune toe and dune crest
% Check if index is not empty
    if isempty(index)
        disp(['collision index empty for year: ', num2str(year(ii)), ' and profile: ', num2str(k)]);
        date_collision(k,ii)=NaN;
TWL_collision(k,ii)=NaN;
collision.time(k,ii)=NaN;
collision.Seasonality(k,ii)=NaN;
collision.sla(k,ii)=NaN;
collision.SS(k,ii)=NaN;
collision.MSL(k,ii)=NaN;
collision.Tide(k,ii)=NaN;
collision.R2(k,ii)=NaN;
collision.splitres(k,ii)=NaN;
    else
date_collision(k,ii)=time(idx(ii));
TWL_collision(k,ii)=nanmean(twl(idx(index)));
collision.time(k,ii)=nanmean(time(idx(index)));
collision.Seasonality(k,ii)=nanmean(se(idx(index)));
collision.sla(k,ii)=nanmean(sla(idx(index)));
collision.SS(k,ii)=nanmean(ss(idx(index)));
collision.MSL(k,ii)=nanmean(msl(idx(index)));
collision.Tide(k,ii)=nanmean(tide(idx(index)));
collision.R2(k,ii)=nanmean(r2(idx(index)));
collision.splitres(k,ii)=nanmean(splitres(idx(index)));
    end

% Sum the average magnitudes, otherwise total contributions won't be 100%
collision.TWL = collision.MSL + collision.Seasonality + collision.Tide + collision.sla + collision.SS + collision.R2 + collision.splitres;

%% 3.0 OVERTOPPING/INNUNDATION       
index=find(twl(idx)>=crest); % overtopping/innundation regime is everything equal to or above the dune crest
 if isempty(index)
        disp(['overtop index empty for year: ', num2str(year(ii)), ' and profile: ', num2str(k)]);
        date_overtop(k,ii)=NaN;
TWL_overtop(k,ii)=NaN;
overtop.time(k,ii)=NaN;
overtop.Seasonality(k,ii)=NaN;
overtop.sla(k,ii)=NaN;
overtop.SS(k,ii)=NaN;
overtop.MSL(k,ii)=NaN;
overtop.Tide(k,ii)=NaN;
overtop.R2(k,ii)=NaN;
overtop.splitres(k,ii)=NaN;
 else

date_overtop(k,ii)=time(idx(ii));
TWL_overtop(k,ii)=nanmean(twl(idx(index)));
overtop.time(k,ii)=nanmean(time(idx(index)));
overtop.Seasonality(k,ii)=nanmean(se(idx(index)));
overtop.sla(k,ii)=nanmean(sla(idx(index)));
overtop.SS(k,ii)=nanmean(ss(idx(index)));
overtop.MSL(k,ii)=nanmean(msl(idx(index)));
overtop.Tide(k,ii)=nanmean(tide(idx(index)));
overtop.R2(k,ii)=nanmean(r2(idx(index)));
overtop.splitres(k,ii)=nanmean(splitres(idx(index)));
    end
% Sum the average magnitudes, otherwise total contributions won't be 100%
overtop.TWL = overtop.MSL + overtop.Seasonality + overtop.Tide + overtop.sla + overtop.SS + overtop.R2 + overtop.splitres;

%% 4.0 INUNDATION       
index=find(dynamicSWL(idx)>=crest); % overtopping/innundation regime is everything equal to or above the dune crest
 if isempty(index)
        disp(['inunda index empty for year: ', num2str(year(ii)), ' and profile: ', num2str(k)]);
        date_inunda(k,ii)=NaN;
dynamicSWL_inunda(k,ii)=NaN;
inunda.time(k,ii)=NaN;
inunda.Seasonality(k,ii)=NaN;
inunda.sla(k,ii)=NaN;
inunda.SS(k,ii)=NaN;
inunda.MSL(k,ii)=NaN;
inunda.Tide(k,ii)=NaN;
inunda.R2(k,ii)=NaN;
inunda.splitres(k,ii)=NaN;
 else
date_inunda(k,ii)=time(idx(ii));
dynamicSWL_inunda(k,ii)=nanmean(dynamicSWL(idx(index)));
inunda.time(k,ii)=nanmean(time(idx(index)));
inunda.Seasonality(k,ii)=nanmean(se(idx(index)));
inunda.sla(k,ii)=nanmean(sla(idx(index)));
inunda.SS(k,ii)=nanmean(ss(idx(index)));
inunda.MSL(k,ii)=nanmean(msl(idx(index)));
inunda.Tide(k,ii)=nanmean(tide(idx(index)));
inunda.R2(k,ii)=nanmean(setup(idx(index))); % facilitates concatenation below, but still setup
inunda.splitres(k,ii)=nanmean(splitres(idx(index)));
 end

% Sum the average magnitudes, otherwise it total contributions won't be 100%
inunda.TWL = inunda.MSL + inunda.Seasonality + inunda.Tide + inunda.sla + inunda.SS + inunda.R2 + inunda.splitres;


    end
 elseif isempty(toe)==1
 end
           else
           end
           
       end
       end

    swash_cell{cnt} = swash;
    collision_cell{cnt} = collision;
    overtop_cell{cnt} = overtop;
    inunda_cell{cnt} = inunda;
    cnt=cnt+1;
    
    clear swash collision overtop inunda
%% 6. Combine all segments into a single array
% Magnitude of components - single structure for all segs
MAGswash = vertcat(swash_cell{:});
MAGcollision = vertcat(collision_cell{:});
MAGovertop = vertcat(overtop_cell{:});
MAGinunda = vertcat(inunda_cell{:});

fields = fieldnames(MAGswash);
for i = 1:numel(fields)
    combinedMAGswash.(fields{i}) = vertcat(MAGswash.(fields{i}));
    combinedMAGcollision.(fields{i}) = vertcat(MAGcollision.(fields{i}));
    combinedMAGovertop.(fields{i}) = vertcat(MAGovertop.(fields{i}));
    combinedMAGinunda.(fields{i}) = vertcat(MAGinunda.(fields{i}));
end


% Save individual magnitude files
filename = [outpth fname '_swashMAG.mat'];
save(filename,'combinedMAGswash');
% Collision
filename = [outpth fname '_collisionMAG.mat'];
save(filename,'combinedMAGcollision');
% Overtopping
filename = [outpth fname '_overtopMAG.mat'];
save(filename,'combinedMAGovertop');
% Inundation 
filename = [outpth fname '_inundaMAG.mat'];
save(filename,'combinedMAGinunda');
%% 7. Calculate contributions to each event in each regime

%%%%%% CONTRIBUTIONS FOR INDIVIDUAL IMPACT REGIME EVENTS AT INDIVIDUAL BEACH PROFILES %%%%%%
% 7A) SWASH 
% remove datum from TWL and MSL
TWL_swash = combinedMAGswash.TWL-mslMean;
MSLswash = combinedMAGswash.MSL-mslMean;

pcentS.Seasonality=(combinedMAGswash.Seasonality.*100)./TWL_swash;
pcentS.sla=(combinedMAGswash.sla.*100)./TWL_swash;
pcentS.SS=(combinedMAGswash.SS.*100)./TWL_swash;
pcentS.MSL=(MSLswash.*100)./TWL_swash;
pcentS.Tide=(combinedMAGswash.Tide.*100)./TWL_swash;
pcentS.splitres=(combinedMAGswash.splitres.*100)./TWL_swash;
pcentS.R2=(combinedMAGswash.R2.*100)./TWL_swash;

filename = [outpth 'pcentS_byprofile_' fname '.mat'];
save(filename,'pcentS')

% 7B) COLLISION 
% remove datum from TWL and MSL
TWL_collision = combinedMAGcollision.TWL-mslMean;
MSLcollision = combinedMAGcollision.MSL-mslMean;

pcentC.Seasonality=(combinedMAGcollision.Seasonality.*100)./TWL_collision;
pcentC.sla=(combinedMAGcollision.sla.*100)./TWL_collision;
pcentC.SS=(combinedMAGcollision.SS.*100)./TWL_collision;
pcentC.MSL=(MSLcollision.*100)./TWL_collision;
pcentC.Tide=(combinedMAGcollision.Tide.*100)./TWL_collision;
pcentC.splitres=(combinedMAGcollision.splitres.*100)./TWL_collision;
pcentC.R2=(combinedMAGcollision.R2.*100)./TWL_collision;

filename = [outpth 'pcentC_byprofile_' fname '.mat'];
save(filename,'pcentC')

% 7C) OVERTOPPING
% remove datum from TWL and MSL
TWL_overtop = combinedMAGovertop.TWL-mslMean;
MSLovertop = combinedMAGovertop.MSL-mslMean;

pcentO.Seasonality=(combinedMAGovertop.Seasonality.*100)./TWL_overtop;
pcentO.sla=(combinedMAGovertop.sla.*100)./TWL_overtop;
pcentO.SS=(combinedMAGovertop.SS.*100)./TWL_overtop;
pcentO.MSL=(MSLovertop.*100)./TWL_overtop;
pcentO.Tide=(combinedMAGovertop.Tide.*100)./TWL_overtop;
pcentO.splitres=(combinedMAGovertop.splitres.*100)./TWL_overtop;
pcentO.R2=(combinedMAGovertop.R2.*100)./TWL_overtop;

filename = [outpth 'pcentO_byprofile_' fname '.mat'];
save(filename,'pcentO')

% 7D) INUNDATION 
% remove datum from TWL and MSL
TWL_inunda = combinedMAGinunda.TWL-mslMean;
MSLinunda = combinedMAGinunda.MSL-mslMean;

pcentI.Seasonality=(combinedMAGinunda.Seasonality.*100)./TWL_inunda;
pcentI.sla=(combinedMAGinunda.sla.*100)./TWL_inunda;
pcentI.SS=(combinedMAGinunda.SS.*100)./TWL_inunda;
pcentI.MSL=(MSLinunda.*100)./TWL_inunda;
pcentI.Tide=(combinedMAGinunda.Tide.*100)./TWL_inunda;
pcentI.splitres=(combinedMAGinunda.splitres.*100)./TWL_inunda;
pcentI.R2=(combinedMAGinunda.R2.*100)./TWL_inunda;

filename = [outpth 'pcentI_byprofile_' fname '.mat'];
save(filename,'pcentI')

%%%%%%% Calculate averaged relative contributions for each profile %%%%%%
%%%%%% AVERAGE CONTRIBUTIONS ACROSS IMPACT REGIME EVENTS AT INDIVIDUAL BEACH PROFILES %%%%%%
for i = 1:length(pcentS.MSL);
pcentswash(i,1:7) = [nanmean(pcentS.MSL(i,:),2); nanmean(pcentS.Tide(i,:),2); nanmean(pcentS.Seasonality(i,:),2); nanmean(pcentS.sla(i,:),2); nanmean(pcentS.SS(i,:),2); nanmean(pcentS.splitres(i,:),2); nanmean(pcentS.R2(i,:),2)];
pcentcollision(i,1:7) = [nanmean(pcentC.MSL(i,:),2); nanmean(pcentC.Tide(i,:),2); nanmean(pcentC.Seasonality(i,:),2); nanmean(pcentC.sla(i,:),2); nanmean(pcentC.SS(i,:),2); nanmean(pcentC.splitres(i,:),2); nanmean(pcentC.R2(i,:),2)];
pcentovertop(i,1:7) = [nanmean(pcentO.MSL(i,:),2); nanmean(pcentO.Tide(i,:),2); nanmean(pcentO.Seasonality(i,:),2); nanmean(pcentO.sla(i,:),2); nanmean(pcentO.SS(i,:),2); nanmean(pcentO.splitres(i,:),2); nanmean(pcentO.R2(i,:),2)];
pcentinunda(i,1:7) = [nanmean(pcentI.MSL(i,:),2); nanmean(pcentI.Tide(i,:),2); nanmean(pcentI.Seasonality(i,:),2); nanmean(pcentI.sla(i,:),2); nanmean(pcentI.SS(i,:),2); nanmean(pcentI.splitres(i,:),2); nanmean(pcentI.R2(i,:),2)];
end

for i = 1:length(pcentswash)
    if pcentswash(i,2:7)==0
        pcentswash(i,1:7)=NaN;
    else
    end
end

for i = 1:length(pcentcollision)
    if pcentcollision(i,2:7)==0
        pcentcollision(i,1:7)=NaN;
    else
    end
end

for i = 1:length(pcentovertop)
    if pcentovertop(i,2:7)==0
        pcentovertop(i,1:7)=NaN;
    else
    end
end

for i = 1:length(pcentinunda)
    if pcentinunda(i,2:7)==0
        pcentinunda(i,1:7)=NaN;
    else
    end
end

% Calculate averaged relative contributions across profiles for each regime
%%%%%% AVERAGE CONTRIBUTIONS ACROSS BEACH PROFILES AT EACH SITE %%%%%%
for i = 1:7
avgRegimeswash(1,i) = nanmean(pcentswash(:,i));
avgRegimecollision(1,i) = nanmean(pcentcollision(:,i));
avgRegimeovertop(1,i) = nanmean(pcentovertop(:,i));
avgRegimeinunda(1,i) = nanmean(pcentinunda(:,i));
end

allRegimesContribution = [avgRegimeswash;avgRegimecollision;avgRegimeovertop;avgRegimeinunda];
save([outpth 'RegimesAvgContribution_' fname '.mat'],"allRegimesContribution");

end

