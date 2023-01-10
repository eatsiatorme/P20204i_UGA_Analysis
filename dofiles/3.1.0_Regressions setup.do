*******************************************************************************
**do-file for estimating impacts of the RISE programme in Uganda (P20204i - EUTF)**
*Author: Thomas Eekhout
*Date: January 2023

/* 
 
Outline:
1. Do-file set up
2. Selection of variables
3. Robustness test:  
4. Robustness test:
*/
********************************************************************************
*1. DO-FILE SET UP
********************************************************************************
{
//Install packages

//Clear memory
clear all

// Close any open log file
cap log close 

//Set up C4ED color scheme for graphs: 
set scheme c4ednew // Stored there: \C4ED\C4ED Global - Documents\07_Impact Evaluation Group\09_Stata. This should be be in your personal ado folder (run "sysdir list" to find it). 


//Import the data you want to use (for illustration, we use the Stata web database cattaneo2)
use "$MIDLINE_PREPARED", clear
}
********************************************************************************
* 2. SELECTION OF VARIABLES
********************************************************************************
{
********************************************************************************
/*
OVERVIEW OF THE APPROACH: 
Step 1: Define your treatment variable. You may check questions on the project 
implementation/secondary data to know whether your treated group has effectively received the project interventions, 
and whether the control group has been contaminated. If not all the individuals in the treatment group 
were actually treated, you should decide whether you want to estimate Intention-to-Treat effects or 
Average Treatment Effects on the Treated or both.
Step 2:
a. Identify potential baseline covariates:
b. Check the correlation between these variables, and eventually remove some of the variables that are too 
highly correlated with others, while not crucial to model the selection process into treatment. 
*/   
********************************************************************************

*Step 1: Define your treatment variable.
global treatment "treatment"

*Step 2: a. Identify baseline covariates
global base_cov "age_qx gender educ_ml" 
*Step 2: b. Check that the variables are behaving/defined as expected
bysort $treatment: sum $base_cov
*Step 2: c. Check the correlation between these variables
pwcorr $base_cov

save "$reg_data", replace
use "$reg_data", clear

}


********************************************************************************
*4. ESTIMATING IMPACTS USING 		
********************************************************************************
{
********************************************************************************
*Step 1: General analysis set-ups  
********************************************************************************
*Define the sample of interest (leave empty if you want the whole sample)
global sub_group "" // (e.g., "if female==1")
*Define your cluster variable
global cluster "" // To use when you want to cluster your standard errors (e.g., "vce(cluster name_cluster)")
*Define your sampling weights whenever you need to use some
global weight "" // (e.g., "[pweight=name_weights]")
*Specify the model used (here ols)
gen ols=1
*Record outputs in a log file
cd "$export"
log using ols_estimation_results, replace
*An excel-file where all tables will be exported will be created, with a different sheet by group of outcomes/research questions
*These commands allow you to erase the previous excel file and to specify where and under which name the new excel file will be created 
cap erase "$export\ols_Estimation_results.xlsx"
global excel_path "$export\ols_Estimation_results"
********************************************************************************

********************************************************************************
*Step 2: Define groups of outcomes (and when relevant, group of covariates) by 
*research question/thematic area, that will be presented in the same table

*For illustration, we defined two groups, but more can be added. 
********************************************************************************

//Define group of outcomes and related covariates
*********************************************************************************************************************************************
**Group 1**
global sheetname1 "Employment search" // Name of the excel sheet
global sub_group1 "if employed_ml==0"
global outcome1 search_emp1_ml search_emp2_ml search_emp3_ml search_newspaper_ml search_prepcv_ml search_friends_ml  search_employer_ml search_internet_ml

global cov_var_all1 $base_cov 
 
*********************************************************************************************************************************************/
**Group 2**
global sheetname2 "Perceived employability" 
global sub_group2 "if employed_ml==0"
global outcome2 spe_score_ml e1_ml e2_ml e3_ml e4_ml e5_ml e6_ml e7_ml e8_ml e9_ml e10_ml  
global cov_var_all2 $base_cov

********************************************************************************************************************************************
**Group 3**
global sheetname3 "Employment"
global sub_group3 ""

gen formal_employ_ml_se=formal_employ_ml if stable_job_ml==1
lab var formal_employ_ml_se "Has a formal stable job (for youths in stable employment)"
gen formal_sect_ml_se=formal_sect_ml if stable_job_ml==1
lab var formal_sect_ml_se "Has a stable job in the formal sector (for youths in stable employment)"

global outcome3 employed_ml job_time_ml stable_job_ml self_employed_ml employer_ml own_account_ml reg_employee_ml apprentice_ml casual_worker_ml vul_emp_ml formal_employ_ml formal_sect_ml formal_employ_ml_se formal_sect_ml_se work_hurt_any_ml hourly_income_last6_ml //job_trade_match_ml  
*Remove outcomes with very low value: fam_work_ml: 1.22%
global cov_var_all3 $base_cov 

/******************************************************************************************************************************************
**Group 4**
global sheetname4 "Income" 
global sub_group4 " "
global outcome4 tb_avg_inc_last6_ml2 avg_inc_last6_ml2_se
global cov_var_all4 $cov_var_all3

********************************************************************************************************
**Group 5**
global sheetname5 "Economic resilience" 
global sub_group5 " "
global outcome5  tb_lowest_inc2 cv_income_ml 
global cov_var_all5 $cov_var_all3
		
********************************************************************************************************
**Group 6**
global sheetname6 "Perceived resilience"  
global sub_group6 " "
global outcome6 brs_score_ml i1_brs_ml i2_brs_ml i3_brs_ml i4_brs_ml i5_brs_ml i6_brs_ml
global cov_var_all6 $cov_var_all3
********************************************************************************************************

********************************************************************************************************
**Group 7**
global sheetname7 "Financial planning"  
global sub_group7 " "
global outcome7  fin_plan_ml fin_record_ml goal_year_ml anticip_invest_ml check_target_ml
global cov_var_all7 $cov_var_all3
********************************************************************************************************

********************************************************************************************************
**Group 8**
global sheetname8 "Business practices"  
global sub_group8 " "
global outcome8  bus_prac_ml pers_pro_ml visit_comp_ml supply_comp_ml disc_client disc_suppl advert_ml goods_profit_ml records_an_ml 
global cov_var_all8 $cov_var_all3
********************************************************************************************************/

 
********************************************************************************
*Step 3: Estimations and export of tables and graphs 

/*
We assume that more outcomes will be part of tables that will be put in the Appendix,
while graphical illustrations of a sub-set of outcomes will be used in the main report. 
Tables in the appendix display coefficients, standard errors, potential outcome means,
and the number of observations (total and by treatment status).
Graphs illustrate the magnitude of the impact expressed in percentage (% change). 
*/
******************************************************************************** 
forvalues i=1/3 { // -NUMBER TO EDIT- Defined by the number of group of outcomes
global sheetname ${sheetname`i'}
global outcome ${outcome`i'}
global cov_var_all ${cov_var_all`i'}	

//We call external do-files that do not have to be modified 
do "$dofiles\3.1.1_Regressions.do" // Runs regressions
do "$dofiles\3.1.2_export_regressions.do" // Exports tables in excel
}

/*
//Graphical illustration of results
*Saving the number of observations and results of the significance test, to add to the graph export (nothing to edit)
foreach outcome of var ${outcome`i'} {
local N_`outcome'=N_`outcome'
if p_`outcome'>=0 & p_`outcome'<=0.01 {
local str_`outcome' "***"	
local bold1_`outcome' "{bf:"
local bold2_`outcome' "}"
}
if p_`outcome'>0.01 & p_`outcome'<=0.05 {
local str_`outcome' "**"
local bold1_`outcome' "{bf:"
local bold2_`outcome' "}"	
}
if p_`outcome'>0.05 & p_`outcome'<=0.10 {
local str_`outcome' "*"
local bold1_`outcome' "{bf:"
local bold2_`outcome' "}"	
}
if p_`outcome'>0.10 & p_`outcome'!=. {
local str_`outcome' "(NS)"	
local bold1_`outcome' 
local bold2_`outcome' 
}
}
**Defining sub-set of outcomes to be part of graphs and labels for each group of outcomes
**Group of outcomes 1**
global graph1 O1 O2 // The numbers correspond to the rank of the outcome in the global "outcome" (In this example, O1 corresponds to "bweight" for group1).  
global lab_graph1 ""`bold1_bweight' Birth weight `bold2_bweight' " "{it:N=`N_bweight'}  "  " " " " " " "`bold1_lbweight' Low birth weight `bold2_lbweight' " "{it:N=`N_lbweight'}  "" //The locals `bold' allow to put the label in bold if the impact is statistically significant at the 10% level or below. The locals "N" indicate the number of observations used in the regression. Empty quotes (" ") between labels of two outcomes allow to align the label with the coefficient on the graph. The number of empty quotes need to be adjusted depending on the number of outcomes displayed on the graph. 
***
**Group of outcomes 2**
global graph2 O1 O2   
global lab_graph2 ""`bold1_prenatal1' Prenatal visit in the trimester 1 `bold2_prenatal1' " "{it:N=`N_prenatal1'}  "  " " " " " " "`bold1_nprenatal' Number of prenatal visits `bold2_nprenatal' " "{it:N=`N_nprenatal'}  ""

*Below, you may edit "xlabel(-150(10)150)" to the range of values of your outcomes or default, but we recommend having a unique scale for the whole report.
cd "$export"
	coefplot ${graph`i'},  ///
    coeflabels(_nl_1=  `"${lab_graph`i'}"', labsize(medium)) ///
	rescale(_nl_1=100) ///
	 ylabel(, notick labgap(0)) xline(0) legend(off) ///
	xtitle("Impact in %", margin(t+2) size(*1.4)) ///
	 xsize(20cm) scale(1.2) xlabel(-150(20)150)  /// //
	 graphregion(color(white)) bgcolor(white)  /// 
	format(%9.2f) mlabposition(12) mlabgap(*2) mlabel(cond(@pval<=.01, string(@b, "%9.2fc") + "***", cond(@pval<=.05, string(@b, "%9.2fc") + "**", cond(@pval<.10, string(@b, "%9.2fc") + " ", string(@b, "%9.2fc"))))) mlabsize(medium)
	graph export Results_`i'.png, replace	
		
}

log close 
}
/********************************************************************************

********************************************************************************
*5. ROBUSTNESS TEST: SENSITIVITY TO EXTREME PROPENSITY SCORES

/*
One critic addressed to using Inverse Probability-Weighted is that observations 
with a propensity score close to 1 or close to 0 can induce higher variance in 
the estimates. To assess the sensitivity of our results to extreme values of 
propensity scores, one robustness test will consist of excluding observations 
with a propensity score below 0.1 and above 0.9 (Frölich and Sperlich, 2019)).

Here, we will only produce tables that can be mentioned in the report and shared
upon request. 
*/		
********************************************************************************
{
**Step 1: Update the general set-ups**
*Create a sub-sample for observations those propensity score are between 0.1 and 0.9 
gen spl_rob=1 if ps>0.1 & ps<0.9
*Modify the global sub_group to indicate the new group to look at 
global sub_group "if spl_rob==1"
*Record outputs in a new log file
cd "$export"
log using IPWRA_Estimation_results_rob, replace
*Specify a new excel file to export results  
cap erase "$export\IPWRA_Estimation_results_rob.xlsx"
global excel_path "$export\IPWRA_Estimation_results_rob"
*Drop temporary variables created in the main regressions (make sure no permanent variables in your dataset are dropped)
drop coap_* se_* z_* N_* p_* NC_* NT_* PM_* coef_* 

**Step 2: Estimation and export**
forvalues i=1/2 { // -NUMBER TO EDIT- Defined by the number of group of outcomes, here two 
global sheetname ${sheetname`i'}
global outcome ${outcome`i'}
global cov_var_all ${cov_var_all`i'}	
//We call external do-files that do not have to be modified 
do "$dofiles\101_matching_regressions.do" // Runs regressions
do "$dofiles\102_export_regressions.do" // Exports tables in excel	
}

log close 
}
********************************************************************************
*6. ROBUSTNESS TEST: ESTIMATIONS USING COARSENED EXACT MATCHING			

/* 
A key critic to matching based on propensity scores is that these scores may be mis-specified. 
A wrong specification of the propensity score model may lead to greater imbalances within the 
sample at hand (Iacus et al., 2012).  King and Nielsen (2019) show that PSM can increase 
imbalance, inefficiency, model dependence and bias, and recommend using instead Coarsened 
Exact Matching (CEM) or Mahalanobis Distance Matching (MDM). 

Then, why not using CEM or MDM as the main matching approach?

(Sadania & Karbala, PAP LORTA Rwanda) One needs to note that their critic and results are 
applied to nearest neighbor within caliper matching rather to all uses of PSM (Guo et al., 2020). 
Guo et al. (2020) extend the comparison between these approaches to alternative uses of PSM, and 
further considers another key dimension of an IE, its external validity. By directly matching on 
covariates, CEM and MDM may lead to greater sample losses due to a lack of common support between 
the treatment and comparison groups. As such, these approaches may be suboptimal when a large number 
of matching variables is required to achieve balance (Ripollone et al., 2020). Furthermore, CEM and 
MDM also require precise knowledge on the source of selection bias and precise measurement of the 
matching variables. Guo et al. (2020) show that CEM and MDM are not always better choices than 
various uses of PSM when considering both reduction in imbalance and retention in sample size. 

Information on the CEM Stata command:  
Blackwell M, Iacus S, King G, Porro G. Cem: Coarsened Exact Matching in Stata. The Stata Journal. 
2009;9(4):524-546.
Approach:  
There is a fully automated procedure to choose a type of coarsening for each covariate. However, 
using explicit prior knowledge is preferable when such a knowledge exists.
CEM can also be used to define the common support area. In this view, it could be used before 
using ipwra running the command "drop if cem_matched". 
*/
********************************************************************************
{
**Step 1. Edit the list of matching variables: we may want to pre-define categories or instead 
*allow for an automatic selection of cut-offs. 
/*
If we you do not want any category to be further cut, use (#0) after this variable. 
Be aware of the trade-off between the number of variables, of categories, and number of matches: 
you do not want to lose too many observations while making sure to control for key sources of bias. 
Again, these decisions need to be based on your knowledge of the selection bias and of relevant 
natural cut-off (e.g., whether having primary education matters the most, irrespective of the exact
number of years of education). 
*/

global matching_var_cem mmarried (#0) mage(18 25 30 35) fbaby (#0) medu(11 12) 

**Step 2.Conduct CEM matching
cem $matching_var_cem, treatment($treatment) showbreaks
tab cem_matched // Check whether a large number of observations are matched. 

**Step 3. Look at matching quality by computing standardized differences**
*For direct comparison with IPWRA (CEM command displays L1 distance and univariate measures of imbalances). We use the same variables as displayed for IPWRA. 
*Define a matrix to save standardized differences before and after CEM matching [Formula of standardized differences can be found here: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3144483/#s11title]
local num_var: list sizeof global(matching_short) // Save the number of matching variables, which will define the number of rows in the matrix, not sure why it misses 2 variables
local num_var = `num_var'+2 // Adding these missing variables 
display `num_var'
mat SDIFF = J(`num_var',2,.) // Create an empty matrix with two columns: for unmatched and for matched samples 

local j = 0 // Start count to identify the number of the row 
local rows // Local to store variable labels and change the row name by these labels  

foreach var of var $matching_short {
forvalues i=0/1 {
quietly: sum `var' if $treatment==`i' // Extract mean and variance for unmatched sample 
scalar `var'_m`i'=r(mean)
scalar `var'_v`i'=r(Var)
quietly: sum `var' [aw=cem_weight] if $treatment==`i' // Extract mean and variance for matched sample 
scalar `var'_m`i'x=r(mean)
scalar `var'_v`i'x=r(Var)
}
scalar `var'_s=sqrt((scalar(`var'_v1)+scalar(`var'_v0))/2)
scalar `var'_sdif=(scalar(`var'_m1)-scalar(`var'_m0))/scalar(`var'_s) // Computes standardized differences for unmatched sample 
scalar `var'_sx=sqrt((scalar(`var'_v1x)+scalar(`var'_v0x))/2)
scalar `var'_sdifx=(scalar(`var'_m1x)-scalar(`var'_m0x))/scalar(`var'_sx) // Computes standardized differences for matched sample
local k=`j'+1
local j=`k' 
mat SDIFF[`k',1]=`var'_sdif // Stores standardized differences for unmatched sample in the first column 
mat SDIFF[`k',2]=`var'_sdifx // Stores standardized differences for matched sample in the second column 
local this = strtoname("`: variable label `var''") // Saves the variable label in this local 
local rows `rows' `this' // Add the variable label to the list 
}
matrix rownames SDIFF= `rows' // Replace row names by variable labels 

*Generate the graph of standardized differences before and after matching 
cd "$export"
coefplot matrix(SDIFF[,1]) matrix(SDIFF[,2]), noci ///
xline(0) xline(-0.25 0.25, lpattern(dot)) xline(-0.1 0.1, lpattern(dash)) xlabel(-1(0.2)1) ///
title("Standardized differences") legend(order(1 "Raw" 2 "Weighted")) nooffset 
graph export Bias_reduction_cem.png, replace

**Step 4. Estimations and export **
*Specify the model used (here CEM)
replace ipwra=0 
*Record outputs in a log file
cd "$export"
log using CEM_Estimation_results, replace 
*Specify a new excel file to save results  
cap erase "$export\CEM_Estimation_results.xlsx"
global excel_path "$export\CEM_Estimation_results" 

*Estimations and export 
forvalues i=1/2 { // Defined by the number of group of outcomes (here, two) 
global sheetname ${sheetname`i'}
global outcome ${outcome`i'}
global cov_var_all ${cov_var_all`i'}	

do "$dofiles\101_matching_regressions.do" // runs regressions
do "$dofiles\102_export_regressions.do" // exports outputs in excel
}
log close 
}

********************************************************************************
* END DO-FILE
********************************************************************************

exit 