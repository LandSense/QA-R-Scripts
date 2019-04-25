QA-R-Scripts
Modular R Scripts for running QA analysis within QA platform or independently

'format data' for specific QA test
1. LS_ALL_format.R # identifies formats of LandSense pilot data and reformats to QA sepecific data frames

'QA tests' - pilot specific requires 'format data' first and makes use of 'generic functions', outputs QA data
2a. LS_HEI_QA_v1.R; LS_HEI_QA_v2.R # Heidelberg University, currently v2 is used
2b. LS_IGN_QA_v1.R; LS_IGN_QA_v2.R # Institut géographique national, currently v2 is used
2c. LS_UBA_QA_v1.R # Umwelbundesamt Wien
2d. LS_INO_QA_v1.R # InoSens
2e. LS_BLI_QA_v1.R # Bird life international

'generic functions' called from 'QA test'
3a. ScottsPi_v1.R # calculates contributor agreement see D5.2 and D5.4; (HEI, IGN, UBA)
3b. fun_accuracy_stratified.R # calculates categorical accuracy (thematic accuracy) see D5.2 and D5.4 (HEI, IGN, UBA, BLI)
3c. LS_delta_a.R # calculates offset of points guided vs captured (UBA)
3d. LS_delta_b.R # calculates offset of polygons and related points (INO)
3e. LS_avgGPS.R # calculates descriptive statistics about captured points GPS accuracy (INO, UBA)
