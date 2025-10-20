# TWLComposition-during-ImpactRegimes
Data release to the paper "Total Water Level Driving Processes Influence the Potential for Coastal Change along United States Coastlines"

The script provided in this repository is used to reproduce the analysis describred in Section 2.1 of the manuscript and illustrated in the figure below at an example station (i.e., Duck, NC). In this script, the user can determine the relative contribution of individual water level components to the total water level (TWL) during Sallenger's (2000) Storm Impact Scale Regimes swash, collision, overtopping, and inundation. The script provides the TWL relative composition during each impact regime averaged across years at each individual beach profile and averaged across beach profiles during impact regimes. This data repository contains the following: 

1) [Main Script](TWLcomposition_byProfile_wrapper.mlx) - main script used to quantify the TWL relative composition during the swash, collision, overtopping, and inundation regimes at the example station Duck, NC. The script is structured in three main components: i. quantification of TWL relative composition during impact regimes, ii. creation of figures to display results, and iii. assignment of percentile ranks to TWL elevations matching each regime threshold based on the empirical cumulative distribution function of hourly TWL data.
2) [Datasets](datasets) - contains input data used in the 'TWLcomposition_byProfile_wrapper.mlx' script, where:
       - 'duck2025_hourly_shoaledwaves.mat': contains structure variable 'hourlyData', with the following fields:
           tide = astronomical tides (m)
           wl = original NOAA water level record (m)
           seasonal = seasonality (m)
           msl = relative sea level + sea level anomalies (m)
           time = datenum time
           swh = linearly backshoaled significant wave height (m), based on GOW2.0 data
           tp = peak wave period (s)
           ss = storm surge (m)
           r2 = wave runup (m), computed using a 0.05 mean beach slope value (recalculated based on individual beach profiles' mean beach slopes)
           setup = wave setup (m), computed using a 0.05 mean beach slope value (recalculated based on individual beach profiles' mean beach slopes)
           twl = total water level (m)
           swl = still water level (m)
           residual = residual signal (m), based on the difference between the measured and reconstructed SWL

   A more detailed description of the above fields can be found in the Methods & Datasets section of this manuscript and in Quadrado & Serafin (2024).       
        
       - 'morphology_NorthCarolinaDuck.csv': standard deviation of swash impact hours per year
