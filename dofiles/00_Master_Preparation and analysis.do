/*
Project: EUTF Uganda
Dofile: Preparation of data and analysis
Author: Thomas Eekhout
Date: July 2022
*/

clear


*quietly{
clear all

// General Globals
global ONEDRIVE "C:\Users\/`c(username)'\C4ED"


/*
if "`c(username)'"=="ThomasEekhout" | "`c(username)'"=="NathanSivewright" {
global P20204i "$ONEDRIVE\P20204i_EUTF_UGA - Documents" 
}
else{
global P20204i "$ONEDRIVE\P20204i_EUTF_UGA - Dokumente"
}
*/

if "`c(username)'" == "Personal" {
	global ONEDRIVE "C:\Users\/Personal\C4ED\"
	global dofiles "C:\Users\Personal\OneDrive - C4ED\Documents\GitHub\P20204i_UGA_Analysis\dofiles"
}

if "`c(username)'"=="NathanSivewright" { 
	global timezone = 1
global dofiles "C:\Users\/`c(username)'\Documents\GitHub\PP20204i_UGA_Analysis\dofiles"
}

if "`c(username)'"=="ThomasEekhout" { 
	global timezone = 1
global dofiles "C:\Users\/`c(username)'\Downloads\GitHub\P20204i_UGA_Analysis\dofiles"
}

if "`c(username)'"=="ElikplimAtsiatorme" {
	global timezone = 1
global dofiles "C:\Users\/`c(username)'\Documents\GitHub\P20204i_UGA_Analysis\dofiles"
}

global ANALYSIS "$P20204i\02_Analysis"
global version = 1
global date = string(date("`c(current_date)'","DMY"),"%tdNNDD")
global time = string(clock("`c(current_time)'","hms"),"%tcHHMMSS")
global datetime = "$date"+"$time"
*global dofiles "$ANALYSIS\01_DoFiles\Data Preparation and Analysis"
global encrypted_drive "H"
global encrypted_path "$encrypted_drive:"
global project_folder "$ONEDRIVE\$folder\02_Analysis" 
global tables "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\03_Tables_Graphs"
global tablesRR22 "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\01_Research Report 2022"

//Datasets globals


global BASELINE_DATA "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\01_Baseline\complete_bl.dta"

**Cohort 1
global ATTENDANCE_EXCEL_C1 "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\01_Baseline\01_Attendance data_c1.xlsx"
global ATTENDANCE_DTA_C1 "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\01_Baseline\01_Attendance data_c1.dta"

**Cohort 2
global ATTENDANCE_EXCEL_C2 "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\01_Baseline\02_Attendance data_c2.xlsx"
global ATTENDANCE_DTA_C2 "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\01_Baseline\02_Attendance data_c2.dta"



global ATTENDANCE_CLEAN "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\01_Baseline\10_Attendance data_cleaned.dta"
global BASELINE_DATA_COMPLETE "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\01_Baseline\Baseline_attendance_cleaned.dta"
global DATA_PREPARED "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\01_Baseline\Baseline_prepared_for_analysis.dta"
global ATTENDANCE_RATES "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\01_Baseline\Monitoring"


*MIDLINE DATA
global MIDLINE_RAW "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\02_Midline\C1\Youth\RISE_MIDLINE_1_NoPII.dta"
global MIDLINE_merged "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\MIDLINE_merged.dta"
global MIDLINE_PREPARED "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\02_Data\02_midline_prepared.dta"


*REGRESSIONS
global reg_data "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\03_regression_data.dta"
global export "$ONEDRIVE\P20204i_EUTF_UGA - Documents\02_Analysis\03_Tables_Graphs\03_Regressions"



//Load maketable command programme 
cd "$dofiles"
do "99_maketable_PROGRAM.do"
cd "$dofiles"
*}

/********************************************************************************
							Baseline and monitoring data preparation
********************************************************************************/
*do "01_Baseline\01_Decryption.do"
*cd "$dofiles"
do "01_Baseline\02_Merging_baseline and Attendance.do"
cd "$dofiles"
do "01_Baseline\03_Cleaning and preparation.do" // Need to save prepared data without PIIs in "$Analysis\02_Data\01_Baseline_prepared.dta"
cd "$dofiles"

/********************************************************************************
							Midline data preparation 
********************************************************************************/

***
cd "$dofiles"
do "02_Midline\01_Merge of cohorts.do"
cd "$dofiles"
do "02_Midline\02_Cleaning and preparation.do"


/********************************************************************************
							Endline data preparation 
********************************************************************************/


/********************************************************************************
							Data analysis
********************************************************************************/

/*
do "1.1_Power calculations_WIP.do"
cd "$dofiles"
do "1.2_Balance_checks_WIP.do"
cd "$dofiles"

do "1.3_Attendance rates.do"
*/

do "3.1.0_Regressions setup.do"

