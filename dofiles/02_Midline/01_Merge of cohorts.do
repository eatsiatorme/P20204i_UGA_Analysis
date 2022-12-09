
/*******************************************************************************
* Author: Thomas Eekhout
* Date: December 2022
* Project: P20204i Uganda
* Topic: Cleaning and preparation of midline data

*******************************************************************************/

*Select dataset
use "$MIDLINE_RAW", clear


gen cycle =.  //Either move this to cleaning or merge wih Cohort from baseline
replace cycle = 1
cap lab def L_cycle 1 "Cohort 1" 2 "Cohort 2" 3 "Cohort 3"
label val cycle L_cycle 
********************************************************************************


*Add  suffix to all variables
ds ApplicantID treatment, not
foreach var of varlist `r(varlist)' {
	rename `var' `var'_ml
}

save "$MIDLINE_merged", replace