
/*******************************************************************************
* Author: Thomas Eekhout
* Date: December 2022
* Project: P20204i Uganda
* Topic: Cleaning and preparation of midline data

**Add _ml to each variable referring to the midline survey

*******************************************************************************/

*Select dataset
use "$MIDLINE_merged", clear



********************************************************************************
*						TREATMENT CHARACTERISTICS  							*
********************************************************************************





/********************************************************************************
						Background characteristics
********************************************************************************/
*Cleaning and labelling
*Age at midline
label var id2_ml "Age (based on midline questionnaire)"
rename id2_ml age_qx_ml

encode age_ml, gen(age_num_ml)
drop age_ml
rename age_num_ml age_birth_ml
label var age_birth_ml "Age (based on birth date)"  // some errors probably due to entry errors in year of birth



*Gender
label var id3_ml "Gender"
rename id3_ml gender_ml



*Nationality
rename a3_ml nationality_ml
label var nationality_ml "Nationality"

gen nationality2_ml=.
replace nationality2_ml=1 if nationality_ml==1
replace nationality2_ml=2 if nationality_ml!=1 & !missing(nationality_ml)
label define nation_lbl_ml 1"Ugandan" 2"Non Ugandan"
label values nationality2_ml nation_lbl_ml

*Residence
rename a4_ml residence_ml

*Religion
rename a5_ml religion_ml
replace religion_ml=1 if religion_ml==-96
label var religion_ml "Religion"

*Education
rename a1a_ml educ_ml
replace educ_ml=1 if educ_ml==-96
label var educ_ml "Level of education at baseline"

rename a1b_ml educ_post_ml
replace educ_post_ml=1 if educ_ml==-96
label var educ_post_ml "Level of education at midline" //will not use this varialbe for causal analysis
order educ_post_ml, after(educ_ml)


*Marital status
label var a2_ml "Marital status"
rename a2_ml marital_status_ml

gen marital_status2_ml=0
replace marital_status2_ml=1 if marital_status_ml==1 | marital_status_ml==2
replace marital_status2_ml=. if !missing(marital_status2_ml)
label define marital2_lbl_ml 0"Not married" 1"Married"
label values marital_status2_ml marital2_lbl_ml
label var marital_status2_ml "Marital status"
order marital_status2_ml, after(marital_status_ml)


*Members of household
rename a14_ml nb_hh_ml
label var nb_hh_ml "# of persons in household (including respondent)"

rename a9_ml nb_hh_inc_ml
label var nb_hh_inc_ml "# of persons in household that depend on respondent's income"
replace nb_hh_inc_ml="0" if nb_hh_inc_ml=="NONE"
replace nb_hh_inc_ml="0" if nb_hh_inc_ml=="O"
destring nb_hh_inc_ml, replace

rename a25_ml nb_hh_15_ml
label var nb_hh_ml "# of persons in household above 15 years old"

*Household head
rename a15_ml hh_head_ml
**# Bookmark #3
label var hh_head_ml "Head of household" // Many missing obs!

*relation to head of household
**# Bookmark #4
rename a16_ml hh_head_relation_ml 
label var hh_head_relation_ml "Relation to head of household" // No obs!


*Professional experience
rename a10_ml pro_exp_ml
label var pro_exp_ml "Has professional experience (worked in exhcange of cash or in-kind)"




********************************************************************************
*                         		 EMPLOYABILITY								   *			
********************************************************************************

*JOB SEARCH

gen search_emp1_ml=.
replace search_emp1_ml=0 if d1_ml==0
replace search_emp1_ml=1 if d1_ml==1 | d1_ml==2 | d1_ml==3
label var search_emp1_ml "Searched for employment in last 4 weeks"
label define bin_lbl 0 "No" 1"Yes"
label values search_emp1_ml bin_lbl

gen search_emp2_ml=.
replace search_emp2_ml=0 if d1_ml==0 | d1_ml==2
replace search_emp2_ml=1 if d1_ml==1 | d1_ml==3
label var search_emp2_ml "Searched for employment (non-self-employed) in last 4 weeks"

label values search_emp2_ml bin_lbl


gen search_emp3_ml=.
replace search_emp3_ml=0 if d1_ml==0 | d1_ml==1
replace search_emp3_ml=1 if d1_ml==2 | d1_ml==3
label var search_emp3_ml "Seeked to start a business in last 4 weeks"

label define bin_lbl_ml 0 "No" 1"Yes"
label values search_emp3_ml bin_lbl


*How searched for a job (non-self-employed)
foreach var of varlist  d3a_ml-d3e_ml{
clonevar `var'_clone=`var'
replace `var'_clone=0 if d1_ml==0 | d1_ml==2
}

label var d3a_ml_clone "Read ads in newspapers/journals/magazines"
label var d3b_ml_clone "Prepare/revise your CV"
label var d3d_ml_clone "Talk to friends/relatives about possible job leads"
label var d3e_ml_clone "Talk to previous employers/business acquaintances"
label var d3f_ml_clone "Use Internet/radio/Social media"

rename d3a_ml_clone search_newspaper
rename d3b_ml_clone search_prepcv
rename d3d_ml_clone search_friends
rename d3e_ml_clone search_employer
rename d3f_ml_clone search_internet


********************************************************************************
*                         		 EMPLOYMENT									   *			
********************************************************************************



*** there is a non-missing repeat section after b1 is no, this should not happen

* remove section for inconsistent b1 is the prefer
foreach var of varlist  job_name_1_ml-b30_other_3_ml{
cap replace `var'=. if b1_ml==0
cap replace `var'="" if b1_ml==0
}



/* vars generated


self_employed
reg_employee
fam_work
apprentice
casual_worker
other_worker

self_employed_sm
reg_employee_sm
fam_work_sm
apprentice_sm
casual_worker_sm
other_worker_sm

informal_sect_1? // ?=a,b,c
informal_sect_2? // ?=a,b,c
informal_sect_3? // ?=a,b,c
formal_sect

informal_employ_1
informal_employ_2
informal_employ_3
formal_employ

isic_simple

employed

*/
********************************************************************************
* EMPLOYMENT


*stable employment (excludes small jobs)
clonevar stable_job_ml=b1_ml
label var stable_job_ml "Has a stable job"

*# of stable jobs
clonevar nb_stable_job_ml=b2_ml
replace  nb_stable_job_ml=0 if stable_job_ml==0
label var nb_stable_job_ml "Number of stable jobs"

*Has more than one stable job
cap gen several_jobs_ml= .
replace several_jobs_ml=0 if stable_job_ml==0
replace several_jobs_ml=0 if stable_job_ml==1
replace several_jobs_ml=1 if nb_stable_job_ml>1 & stable_job_ml==1 
label var several_jobs_ml ">1 stable job"


* Employment (Based on ILO definition)
gen employed_ml=emp_ilo_ml
label var employed_ml "Has a job (last 7 days)"

/*
is considered as employed if respondent is:
b1a_1	A paid employee of someone who is not a member of your household
b1a_2	A paid worker on household farm or non-farm business enterprise
b1a_3	An employer
b1a_4	A worker non-agricultural own account worker, without employees
or
b1b has a permanent job but was absent in the past 7 days

b1a_5	Unpaid workers (e.g. Homemaker, working in non-farm family business)
b1a_6	Unpaid farmers
b1a_7	None of the above
*/

********************************************************************************


* EMPLOYMENT STATUS

{ // employment status of stable and small jobs

* In stable jobs

*Self-employed
cap gen self_employed_ml= .
replace self_employed_ml=0 if !missing(b1_ml) 
replace self_employed_ml=1 if b6_1_ml==3 | b6_2_ml==3 | b6_3_ml==3
label values self_employed_ml bin_lbl
label var self_employed_ml "Self-employed in stable job"

*Employer
cap drop employer_ml
gen employer_ml= .
replace employer_ml=0 if !missing(b1_ml) 
replace employer_ml=1 if b6_1_ml==3 & b21_1_ml>0 | b6_2_ml==3 & b21_2_ml>0 | b6_3_ml==3 & b21_3_ml>0
label values employer_ml bin_lbl
label var employer_ml "Employer in stable job"

*Own account worker
cap gen own_account_ml= .
replace own_account_ml=0 if !missing(b1_ml) 
replace own_account_ml=1 if employer_ml==0 & b21_1_ml==0 | employer_ml==0 & b21_2_ml==0 | employer_ml==0 & b21_3_ml==0
label values own_account_ml bin_lbl
label var own_account_ml "Own account in stable job"


*Regular employee
cap gen reg_employee_ml= .
replace reg_employee_ml=0 if !missing(b1_ml) 
replace reg_employee_ml=1 if b6_1_ml==1 | b6_2_ml==1 | b6_3_ml==1
label values reg_employee_ml bin_lbl
label var reg_employee_ml "Regular employee in stable job"

*Regular family worker
gen fam_work_ml= .
replace fam_work_ml=0 if !missing(b1_ml) 
replace fam_work_ml=1 if b6_1_ml==2 | b6_2_ml==2 | b6_3_ml==2
label values fam_work_ml bin_lbl
label var fam_work_ml "Regular family worker in stable job"

*apprentice (includes volunteers and interns)
gen apprentice_ml= .
replace apprentice_ml=0 if !missing(b1_ml) 
replace apprentice_ml=1 if (b6_1_ml==4 | b6_2_ml==4 | b6_3_ml==4) | (b6_1_ml==6 | b6_2_ml==6 | b6_3_ml==6)
label values apprentice_ml bin_lbl
label var apprentice_ml "Apprentice in stable job"

*Casual worker
gen casual_worker_ml= .
replace casual_worker_ml=0 if !missing(b1_ml) 
replace casual_worker_ml=1 if b6_1_ml==5 | b6_2_ml==5 | b6_3_ml==5
label values casual_worker_ml bin_lbl
label var casual_worker_ml "Casual worker in stable job"

*Other type of worker
gen other_worker_ml= .
replace other_worker_ml=0 if !missing(b1_ml) 
replace other_worker_ml=1 if self_employed_ml==0 & reg_employee_ml==0 & fam_work_ml==0 & apprentice_ml==0 & casual_worker_ml==0  & stable_job_ml==1
label values other_worker_ml bin_lbl
label var other_worker_ml "Other employment in stable job"

*Other type of worker
gen other_emp_self_ml= .
replace other_emp_self_ml=0 if !missing(b1_ml) 
replace other_emp_self_ml=1 if fam_work_ml==1 | apprentice_ml==1 |casual_worker_ml==1
label values other_emp_self_ml bin_lbl
label var other_emp_self_ml "Other employment status"

}

{
* VULNERABLE EMPLOYMENT

*ILO defines vulnerable employment as being contributing faimily worker ot being own account worker
*It remains debatable whether apprencie and casual workers can be considered as "non-vulnerable workers"...		   

*Vulnerable employment:

cap gen vul_emp_ml= .
replace vul_emp_ml=0 if !missing(b1_ml)
replace vul_emp_ml=1 if own_account_ml==1 | fam_work_ml==1
replace vul_emp_ml=0 if employer_ml==1 | reg_employee_ml==1 | apprentice_ml==1 | casual_worker_ml | other_worker_ml // we insert this line after as if at least job is considered "non vulenrable, the obs is considered "non-vulnerable".
replace vul_emp_ml= . if b21_1_ml==-98 & (b21_2_ml==-98 | b21_2_ml==.) & (b21_3_ml==-98 | b21_3_ml==.) //We do not know if these self-employed employ someone
label var vul_emp_ml "Vulnerable employment in stable job"

}



********************************************************************************
* FORMALITY (only for those with "stable" job)								   

{
	 // FORMAL EMPLOYMENT
/* 2 concepts: informal sector and informal employment are distinct concepts, they are also complementary. 
// The informal economy encompasses both perspectives and is defined as all economic activities by workers and economic units that are - in law or in practice - not covered or insufficiently covered by formal arrangements. ---> https://www.ilo.org/global/topics/wages/minimum-wages/beneficiaries/WCMS_436492/lang--en/index.htm


**INFORMAL SECTOR
//ILO recommends using the following criteria to identify the informal sector:
*	size: less than 5 workers --> used for self-employed but we do not have the info for subordinated workers.
*	legal: is not registered --> used 
*	organizational: keeps standardized records --> Do not have question at the job level so cannot be used.
*	production: at least part of the production is oreinted to the market --> implicitly assumed

* In practice, there is isually a great overlap when using the different criteria. there wouldn't be significant changes

*Current definition: works in unregistered firm or is self-employed in a unregistered firm and has less than 5 workers (including respondent)
*/


*** INFORMAL SECTOR

foreach i of num 1/3{
    
*** no default
cap drop informal_sect_`i'a_ml
gen informal_sect_`i'a_ml= .
label var informal_sect_`i'a_ml "Job `i' is in the informal sector [no default]"

// Identify jobs in in/formal sector based on registration
cap replace informal_sect_`i'a_ml=0 if b12_1_`1'_ml==1 & !missing(b3_`i'_ml)  //What does b3_i mean?
cap replace informal_sect_`i'a_ml=0 if b20_1_`1'_ml==1 & !missing(b3_`i'_ml)

// Identify jobs in in/formal sector based on number of workers
replace informal_sect_`i'a_ml=0 if b6_`i'_ml==3 & b21_`i'_ml>=4 & !missing(b21_`i'_ml) & missing(informal_sect_`i'a_ml) & !missing(b3_`i'_ml) // before it was set to informal for <4 and default was missing. But comment said default is informal, this does not change. This way we incorporate number of workers in the definition of formality, maybe threshold should change. 4 workers because with the respondent, number of workers=5

replace informal_sect_`i'a_ml=1 if b6_`i'_ml==3 & b21_`i'_ml<4 & !missing(b21_`i'_ml)  & missing(informal_sect_`i'a_ml) & !missing(b3_`i'_ml) //  4 workers because with the respondent, number of workers=5

// weaker info

cap replace informal_sect_`i'a_ml=1 if b20_`i'_ml==1 & missing(informal_sect_`i'a_ml) & !missing(b3_`i'_ml)

**# Bookmark #2: What does .c and -b mean again?			 if .c=informal_sect_1==1 if .b=.
cap replace informal_sect_`i'a_ml=1 if b12_`i'_ml==.c & missing(informal_sect_`i'a_ml) & !missing(b3_`i'_ml) // if you don't know if you're registered you are likely not


*** informal default
cap drop informal_sect_`i'b_ml
clonevar informal_sect_`i'b_ml= informal_sect_`i'a_ml
label var informal_sect_`i'b_ml "Job `i' is in the informal sector [informal default]"

//By default set as formal when has a job
replace informal_sect_`i'b_ml=1 if !missing(b3_`i'_ml) & missing(informal_sect_`i'b_ml)

*** formal default
cap drop informal_sect_`i'c_ml
clonevar informal_sect_`i'c_ml= informal_sect_`i'a_ml
label var informal_sect_`i'c_ml "Job `i' is in the informal sector [formal default]"

//By default set as formal when has a job
replace informal_sect_`i'c_ml=0 if !missing(b3_`i'_ml) & missing(informal_sect_`i'c_ml)

}

*Any formal sector
cap drop formal_sect_ml
gen formal_sect_ml= .
replace formal_sect_ml=0 if !missing(b1_ml)
replace formal_sect_ml=1 if informal_sect_1a_ml==0 | informal_sect_2a_ml==0 | informal_sect_3a_ml==0
label var formal_sect_ml "Has a stable job in the formal sector"


*** INFORMAL EMPLOYMENT
//definition used in the Gambia: "Informal employment refers to those jobs that generally lack basic social or legal protections or employment benefits and may be found in informal sector, formal sector enterprises or households." 2018 Gambia LFS.  
* Curent definition: has an informal IGA or does not have a written contract in a registered firm.

*informal employment by job
foreach i of num 1/3{
cap drop informal_employ_`i'_ml
gen informal_employ_`i'_ml= .

* self employed
replace informal_employ_`i'_ml=1 if b6_`i'_ml==3 & informal_sect_`i'a_ml==1
replace informal_employ_`i'_ml=0 if b6_`i'_ml==3 & informal_sect_`i'a_ml==0 

* not self employed
replace informal_employ_`i'_ml=1 if b6_`i'_ml!=3 & b13_`i'_ml==0 | b13_`i'_ml==2 // informal if no or oral contract
replace informal_employ_`i'_ml=0 if b6_`i'_ml!=3 & b13_`i'_ml==1 & informal_sect_`i'c_ml==0 // note I use default formal for firm, as written contract already a burden

* if no contract info then base on sector
replace informal_employ_`i'_ml=1 if b6_`i'_ml!=3 & missing(informal_employ_`i'_ml) & informal_sect_`i'a_ml==1  //if in informal sector and no info on contract, then assume he is in informal employment
* replace informal_employ_`i'=0 if b6_`i'!=3 & missing(informal_employ_`i') & informal_sect_`i'a==0 //if in formal sector and no info on contract, then assume he is in formal employment  --> I cancelled out this option as the assumption doesn't seem realistic to me. This said, for Tthis sample, it does not provoke any change.


* default informal 
replace informal_employ_`i'_ml=1 if !missing(b6_`i'_ml) & missing(informal_employ_`i'_ml)
label var informal_employ_`i'_ml "Job `i' is informal employment"
}


*Formal employment
cap drop formal_employ_ml
gen formal_employ_ml= .
replace formal_employ_ml=0 if !missing(b1_ml)
replace formal_employ_ml=1 if informal_employ_1_ml==0 | informal_employ_2_ml==0 | informal_employ_3_ml==0
label var formal_employ_ml "Has a formal stable job"
}

//Wrap up:
*order variables created
order self_employed_ml reg_employee_ml fam_work_ml apprentice_ml casual_worker_ml other_worker_ml informal_sect_1?_ml informal_sect_2?_ml informal_sect_3?_ml formal_sect_ml informal_employ_1_ml informal_employ_2_ml informal_employ_3_ml formal_employ_ml,  after (nb_stable_job_ml)


********************************************************************************
save "$MIDLINE_PREPARED", replace

/*
*Add  suffix to all variables
rename * *

save "$MIDLINE_PREPARED", replace