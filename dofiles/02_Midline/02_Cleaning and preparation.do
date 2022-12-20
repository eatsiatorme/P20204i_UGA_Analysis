
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
label var id2 "Age (based on midline questionnaire)"
rename id2 age_qx

encode age, gen(age_num)
drop age
rename age_num age_birth
label var age_birth "Age (based on birth date)"  // some errors probably due to entry errors in year of birth



*Gender
label var id3 "Gender"
rename id3 gender



*Nationality
rename a3 nationality
label var nationality "Nationality"

gen nationality2=.
replace nationality2=1 if nationality==1
replace nationality2=2 if nationality!=1 & !missing(nationality)
label define nation_lbl 1"Ugandan" 2"Non Ugandan"
label values nationality2 nation_lbl

*Residence
rename a4 residence

*Religion
rename a5 religion
replace religion=1 if religion==-96
label var religion "Religion"

*Education
rename a1a educ
replace educ=1 if educ==-96
label var educ "Level of education at baseline"

rename a1b educ_post
replace educ_post=1 if educ==-96
label var educ_post "Level of education at midline" //will not use this varialbe for causal analysis
order educ_post, after(educ)


*Marital status
label var a2 "Marital status"
rename a2 marital_status

gen marital_status2=0
replace marital_status2=1 if marital_status==1 | marital_status==2
replace marital_status2=. if !missing(marital_status2)
label define marital2_lbl 0"Not married" 1"Married"
label values marital_status2 marital2_lbl
label var marital_status2 "Marital status"
order marital_status2, after(marital_status)


*Members of household
rename a14 nb_hh
label var nb_hh "# of persons in household (including respondent)"

rename a9 nb_hh_inc
label var nb_hh_inc "# of persons in household that depend on respondent's income"
replace nb_hh_inc="0" if nb_hh_inc=="NONE"
replace nb_hh_inc="0" if nb_hh_inc=="O"
destring nb_hh_inc, replace

rename a25 nb_hh_15
label var nb_hh "# of persons in household above 15 years old"

*Household head
rename a15 hh_head
**# Bookmark #3
label var hh_head "Head of household" // Many missing obs!

*relation to head of household
**# Bookmark #4
rename a16 hh_head_relation 
label var hh_head_relation "Relation to head of household" // No obs!


*Professional experience
rename a10 pro_exp
label var pro_exp "Has professional experience (worked in exhcange of cash or in-kind)"




********************************************************************************
*                         		 EMPLOYABILITY								   *			
********************************************************************************

*JOB SEARCH

gen search_emp1=.
replace search_emp1=0 if d1==0
replace search_emp1=1 if d1==1 | d1==2 | d1==3
label var search_emp1 "Searched for employment in last 4 weeks"

gen search_emp2=.
replace search_emp2=0 if d1==0 | d1==2
replace search_emp2=1 if d1==1 | d1==3
label var search_emp2 "Searched for employment (non-self-employed) in last 4 weeks"

gen search_emp3=.
replace search_emp3=0 if d1==0 | d1==1
replace search_emp3=1 if d1==2 | d1==3
label var search_emp3 "Seeked to start a business in last 4 weeks"

label define bin_lbl 0 "No" 1"Yes"
label values search_emp? bin_lbl


*How searched for a job (non-self-employed)
foreach var of varlist  d3a-d3e{
clonevar `var'_clone=`var'
replace `var'_clone=0 if d1==0 | d1==2
}

label var d3a_clone "Read ads in newspapers/journals/magazines"
label var d3b_clone "Prepare/revise your CV"
label var d3d_clone "Talk to friends/relatives about possible job leads"
label var d3e_clone "Talk to previous employers/business acquaintances"
label var d3f_clone "Use Internet/radio/Social media"

rename d3a_clone search_newspaper
rename d3b_clone search_prepcv
rename d3d_clone search_friends
rename d3e_clone search_employer
rename d3f_clone search_internet


********************************************************************************
*                         		 EMPLOYMENT									   *			
********************************************************************************



*** there is a non-missing repeat section after b1 is no, this should not happen

* remove section for inconsistent b1 is the prefer
foreach var of varlist  job_name_1-b30_other_3{
cap replace `var'=. if b1==0
cap replace `var'="" if b1==0
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
clonevar stable_job=b1
label var stable_job "Has a stable job"

*# of stable jobs
clonevar nb_stable_job=b2
replace  nb_stable_job=0 if stable_job==0
label var nb_stable_job "Number of stable jobs"

*Has more than one stable job
cap gen several_jobs= .
replace several_jobs=0 if stable_job==0
replace several_jobs=0 if stable_job==1
replace several_jobs=1 if nb_stable_job>1 & stable_job==1 
label var several_jobs ">1 stable job"


* Employment (Based on ILO definition)
gen employed=emp_ilo
label var employed "Has a job (last 7 days)"

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
cap gen self_employed= .
replace self_employed=0 if !missing(b1) 
replace self_employed=1 if b6_1==3 | b6_2==3 | b6_3==3
label values self_employed bin_lbl
label var self_employed "Self-employed in stable job"

*Employer
cap drop employer
gen employer= .
replace employer=0 if !missing(b1) 
replace employer=1 if b6_1==3 & b21_1>0 | b6_2==3 & b21_2>0 | b6_3==3 & b21_3>0
label values employer bin_lbl
label var employer "Employer in stable job"

*Own account worker
cap gen own_account= .
replace own_account=0 if !missing(b1) 
replace own_account=1 if employer==0 & b21_1==0 | employer==0 & b21_2==0 | employer==0 & b21_3==0
label values own_account bin_lbl
label var own_account "Own account in stable job"


*Regular employee
cap gen reg_employee= .
replace reg_employee=0 if !missing(b1) 
replace reg_employee=1 if b6_1==1 | b6_2==1 | b6_3==1
label values reg_employee bin_lbl
label var reg_employee "Regular employee in stable job"

*Regular family worker
gen fam_work= .
replace fam_work=0 if !missing(b1) 
replace fam_work=1 if b6_1==2 | b6_2==2 | b6_3==2
label values fam_work bin_lbl
label var fam_work "Regular family worker in stable job"

*apprentice (includes volunteers and interns)
gen apprentice= .
replace apprentice=0 if !missing(b1) 
replace apprentice=1 if (b6_1==4 | b6_2==4 | b6_3==4) | (b6_1==6 | b6_2==6 | b6_3==6)
label values apprentice bin_lbl
label var apprentice "Apprentice in stable job"

*Casual worker
gen casual_worker= .
replace casual_worker=0 if !missing(b1) 
replace casual_worker=1 if b6_1==5 | b6_2==5 | b6_3==5
label values casual_worker bin_lbl
label var casual_worker "Casual worker in stable job"

*Other type of worker
gen other_worker= .
replace other_worker=0 if !missing(b1) 
replace other_worker=1 if self_employed==0 & reg_employee==0 & fam_work==0 & apprentice==0 & casual_worker==0  & stable_job==1
label values other_worker bin_lbl
label var other_worker "Other employment in stable job"

*Other type of worker
gen other_emp_self= .
replace other_emp_self=0 if !missing(b1) 
replace other_emp_self=1 if fam_work==1 | apprentice==1 |casual_worker==1
label values other_emp_self bin_lbl
label var other_emp_self "Other employment status"

}

{
* VULNERABLE EMPLOYMENT

*ILO defines vulnerable employment as being contributing faimily worker ot being own account worker
*It remains debatable whether apprencie and casual workers can be considered as "non-vulnerable workers"...		   

*Vulnerable employment:

cap gen vul_emp= .
replace vul_emp=0 if !missing(b1)
replace vul_emp=1 if own_account==1 | fam_work==1
replace vul_emp=0 if employer==1 | reg_employee==1 | apprentice==1 | casual_worker | other_worker // we insert this line after as if at least job is considered "non vulenrable, the obs is considered "non-vulnerable".
replace vul_emp= . if b21_1==-98 & (b21_2==-98 | b21_2==.) & (b21_3==-98 | b21_3==.) //We do not know if these self-employed employ someone
label var vul_emp "Vulnerable employment in stable job"

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
cap drop informal_sect_`i'a
gen informal_sect_`i'a= .
label var informal_sect_`i'a "Job `i' is in the informal sector [no default]"

// Identify jobs in in/formal sector based on registration
cap replace informal_sect_`i'a=0 if b12_1==1 & !missing(b3_`i')  //What does b3_i mean?
cap replace informal_sect_`i'a=0 if b20_1==1 & !missing(b3_`i')

// Identify jobs in in/formal sector based on number of workers
replace informal_sect_`i'a=0 if b6_`i'==3 & b21_`i'>=4 & !missing(b21_`i') & missing(informal_sect_`i'a) & !missing(b3_`i') // before it was set to informal for <4 and default was missing. But comment said default is informal, this does not change. This way we incorporate number of workers in the definition of formality, maybe threshold should change. 4 workers because with the respondent, number of workers=5

replace informal_sect_`i'a=1 if b6_`i'==3 & b21_`i'<4 & !missing(b21_`i')  & missing(informal_sect_`i'a) & !missing(b3_`i') //  4 workers because with the respondent, number of workers=5

// weaker info

cap replace informal_sect_`i'a=1 if b20_`i'==1 & missing(informal_sect_`i'a) & !missing(b3_`i')

**# Bookmark #2: What does .c and -b mean again?			 if .c=informal_sect_1==1 if .b=.
cap replace informal_sect_`i'a=1 if b12_`i'==.c & missing(informal_sect_`i'a) & !missing(b3_`i') // if you don't know if you're registered you are likely not


*** informal default
cap drop informal_sect_`i'b
clonevar informal_sect_`i'b= informal_sect_`i'a
label var informal_sect_`i'b "Job `i' is in the informal sector [informal default]"

//By default set as formal when has a job
replace informal_sect_`i'b=1 if !missing(b3_`i') & missing(informal_sect_`i'b)

*** formal default
cap drop informal_sect_`i'c
clonevar informal_sect_`i'c= informal_sect_`i'a
label var informal_sect_`i'c "Job `i' is in the informal sector [formal default]"

//By default set as formal when has a job
replace informal_sect_`i'c=0 if !missing(b3_`i') & missing(informal_sect_`i'c)

}

*Any formal sector
cap drop formal_sect
gen formal_sect= .
replace formal_sect=0 if !missing(b1)
replace formal_sect=1 if informal_sect_1a==0 | informal_sect_2a==0 | informal_sect_3a==0
label var formal_sect "Has a stable job in the formal sector"


*** INFORMAL EMPLOYMENT
//definition used in the Gambia: "Informal employment refers to those jobs that generally lack basic social or legal protections or employment benefits and may be found in informal sector, formal sector enterprises or households." 2018 Gambia LFS.  
* Curent definition: has an informal IGA or does not have a written contract in a registered firm.

*informal employment by job
foreach i of num 1/3{
cap drop informal_employ_`i'
gen informal_employ_`i'= .

* self employed
replace informal_employ_`i'=1 if b6_`i'==3 & informal_sect_`i'a==1
replace informal_employ_`i'=0 if b6_`i'==3 & informal_sect_`i'a==0 

* not self employed
replace informal_employ_`i'=1 if b6_`i'!=3 & b13_`i'==0 | b13_`i'==2 // informal if no or oral contract
replace informal_employ_`i'=0 if b6_`i'!=3 & b13_`i'==1 & informal_sect_`i'c==0 // note I use default formal for firm, as written contract already a burden

* if no contract info then base on sector
replace informal_employ_`i'=1 if b6_`i'!=3 & missing(informal_employ_`i') & informal_sect_`i'a==1  //if in informal sector and no info on contract, then assume he is in informal employment
* replace informal_employ_`i'=0 if b6_`i'!=3 & missing(informal_employ_`i') & informal_sect_`i'a==0 //if in formal sector and no info on contract, then assume he is in formal employment  --> I cancelled out this option as the assumption doesn't seem realistic to me. This said, for Tthis sample, it does not provoke any change.


* default informal 
replace informal_employ_`i'=1 if !missing(b6_`i') & missing(informal_employ_`i')
label var informal_employ_`i' "Job `i' is informal employment"
}


*Formal employment
cap drop formal_employ
gen formal_employ= .
replace formal_employ=0 if !missing(b1)
replace formal_employ=1 if informal_employ_1==0 | informal_employ_2==0 | informal_employ_3==0
label var formal_employ "Has a formal stable job"
}

//Wrap up:
*order variables created
order self_employed reg_employee fam_work apprentice casual_worker other_worker informal_sect_1? informal_sect_2? informal_sect_3? formal_sect informal_employ_1 informal_employ_2 informal_employ_3 formal_employ,  after (nb_stable_job)


********************************************************************************
* Employment Sector								   

{ // simplified ISIC1

*mapping job_category to isic_1_*

/*

ISIC_1	1	Agriculture, forestry and fishing
ISIC_1	2	Mining and quarrying
ISIC_1	3	Manufacturing
ISIC_1	4	Electricity, gas, steam and air conditioning supply
ISIC_1	5	Water supply; sewerage, waste management and remediation activities
ISIC_1	6	Construction
ISIC_1	7	Wholesale and retail trade; repair of motor vehicles and motorcycles
ISIC_1	8	Transportation and storage
ISIC_1	9	Accommodation and food service activities
ISIC_1	10	Information and communication
ISIC_1	11	Financial and insurance activities
ISIC_1	12	Real estate activities
ISIC_1	13	Professional, scientific and technical activities
ISIC_1	14	Administrative and support service activities
ISIC_1	15	Public administration and defence; compulsory social security
ISIC_1	16	Education
ISIC_1	17	Human health and social work activities
ISIC_1	18	Arts, entertainment and recreation
ISIC_1	19	Other service activities
ISIC_1	20	Activities of households as employers; undifferentiated goods- and services-producing activities of households for own use
ISIC_1	21	Activities of extraterritorial organizations and bodies

job_cat	1	Building & congrete practices - tiling and land scaping 6
job_cat	2	Tailoring & garment cutting - Tailoring machine repair 3
job_cat	3	Solar installation, repair & maintenance 4
job_cat	4	Plumbing - Repair of boreholes 5
job_cat	5	Knitting & weaving 3
job_cat	6	Welding & metal fabrication 3
job_cat	7	Electrical installation 4
job_cat	8	Caterigng & hotel management 9
job_cat	9	Motorcycle repair 7
job_cat	10	ICT-Graphic design & branding 18
job_cat	11	Mechanics of small scale & indutrial machines 3
job_cat	12	Carpentary & joinery 2



*/


foreach i of num 1/3{
cap replace isic_1_`i'=6 if (job_category_`i'==1)
cap replace isic_1_`i'=7 if (job_category_`i'==9) 
cap replace isic_1_`i'=5 if (job_category_`i'==4)
*cap replace isic_1_`i'_ml=1 if (job_category_`i'_ml==8)   & (cycle==2 | cycle==3)
cap replace isic_1_`i'=3 if (job_category_`i'==5 | job_category_`i'==6 | job_category_`i'==11)
cap replace isic_1_`i'=4 if (job_category_`i'==7 | job_category_`i'==3) 
cap replace isic_1_`i'=18 if (job_category_`i'==10) 
cap replace isic_1_`i'=2 if (job_category_`i'==12) 

}



**generate dummies

cap drop isic_simple*
clonevar isic_simple=isic_1_1

label define isic1_lbl 888 "Other" 999 "No applicable/missing", modify

replace isic_simple=888 if !missing(isic_1_1) & !(isic_1_1==3 | isic_1_1==4 | isic_1_1==6 | isic_1_1==7 )

* make wholesale and retail and motor repair into retail and other

label define isic1_lbl 7 "Retail trade", modify

*replace isic_simple=888 if !missing(isic_1_1_ml) & isic_1_1_ml==7 & isic_2_1_ml!=747

replace isic_simple=999 if !missing(b1) & missing(isic_1_1)

tab isic_simple

tabulate isic_simple, generate(isic_simple) 
*labvarch isic_simple*, after(==)

rename isic_simple? isic_simple?
rename isic_simple isic_simple

*Division by 3 main economic sectors
foreach i of num 1/3 {
cap drop  sect_`i'
cap gen sect_`i'=.
replace sect_`i'=1 if isic_1_`i'<=2 & !missing(b3_`i')
replace sect_`i'=2 if isic_1_`i'>=3 & isic_1_`i'<=6 & !missing(b3_`i')
replace sect_`i'=3 if isic_1_`i'>=7 & !missing(b3_`i')

cap label define sect_lbl 1"Primary (extraction of raw materials)" 2"Secondary (Manufacturing)" 3"Services"
label values sect_`i' sect_lbl
label var sect_`i' "Sector of employment of job `i'"
}


}



********************************************************************************
*             	                 INCOME						   			      *			
********************************************************************************
{ // income
/*
List of indicators created/relevant

*INCOME OVER LAST 6 MONTHS
	**Average monthly income over last 6 months:
		avg_inc_all_last6_ml

	**Average monthly income from self-employment over last 6 months:
		avg_inc_se_last6_ml

	**Average monthly income from employment over last 6 months:
		avg_inc_emp_last6_ml

	**Average monthly income from employment over last 6 months excluding inkind payments:
		avg_inc_emp2_last6_ml

*INCOME FROM CURRENT JOB
	*Monthly income from current jobs
		inc_all_current_ml

	*Monthly income from current self-employment
		inc_se_current_ml 

	*Monthly income from current employment:
		inc_emp_current_ml

	*Monthly income from current employment excluding inkind payments:
		inc_emp2_current_ml

*INCOME FROM MOST RECENT JOB
	**Average monthly income of most recent job:
		inc_most_recent_ml

*PRODUCTIVITY: Hourly income
	* Average hourly income from job 1:
		hourly_income_1_ml
		hourly_income_2_ml
		hourly_income_3_ml
	*Average hourly income over last 6 months
		hourly_income_last6_ml
		
	*Hourly income from current jobs
		hourly_income_current_ml
*/


{ //  need to put into cleaning

foreach var of varlist c2 c1_normal c4 b17_? b18_? b26_?{
	replace `var'=.b if `var'==98  | `var'==-98 // forgot - in front of missing value code
	replace `var'=.a if `var'==99 | `var'==-99 // forgot - in front of missing value code

}

* make number of months of contract to numerical var (to be put into cleaning)
destring b17_unit_s_1 b18_unit_s_1 b26_unit_s_1 b26_unit_s_2, replace

foreach var in b17_unit_s_1 b18_unit_s_1 b26_unit_s_1 b26_unit_s_2{
	replace `var'=1 if `var'==0 // round up to at least 1 month
}

replace c1=0 if (c2==0 & c4==0) | (c2==6800 & c4==680) // no income variation, should be missing


}


{ // monthly income indicators

/*
create monthly income per job in last x months

create monthly income over all non self-employment jobs over last x months

create monthly income over all self employment jobs over last x months

create monthly income over all current jobs

create monthly income most recent job

create hourly productivity 


notes/limitations: 

includes only activities for which the person was employed for at least 1 month; 

time worked is with precision of calendar month, i.e., if someone worked from mid-january in a job, income is calculated as if they worked whole january.

missing values could be more properly handled. i.e. if income is missing for one job, then total income is also somewhat missing, but here it is calculated treating missings as 0.

hours often very high. 50% reportedly work more than 45 hours/week in first job; this (among) other things makes hourly income quite low

*/


{ // income in reference periods, e.g. last 6 months (6 months is maximum based on tool)

local ref_periods 6 // any integer between 1 and 6

foreach r in `ref_periods'{
    
* generate reference period date
* precision is months, rounded to full calender months

cap drop ref_start
gen ref_start=current_month_dt-365/12*(`r'-1)
format ref_start %td

foreach i of num 1/3 {

*generate start date of job relevant to reference period, i.e. if before reference period started, then replace with reference period start
cap drop start_job_`i'
clonevar start_job_`i'=b4_`i' if b5_`i'>=ref_start & !missing(b3_`i')
replace start_job_`i'=ref_start if b4_`i'<=ref_start & b5_`i'>=ref_start & !missing(b3_`i')

* generate end date, replace with current date if ongoing
cap drop end_job_`i'
clonevar end_job_`i'=b5_`i' if b5_`i'>=ref_start & !missing(b3_`i')
replace end_job_`i'=current_month_dt if b3_`i'==1

* time in months on job during reference period, i.e., number of calendar months(!) in job
cap drop job_time_in_ref_`i'
gen job_time_in_ref_`i'=.
replace job_time_in_ref_`i'=0 if !missing(b3_`i')
replace job_time_in_ref_`i'=round((end_job_`i'-start_job_`i')/365*12+1)
replace job_time_in_ref_`i'=0 if b5_`i'<ref_start  // important if job falls outside of reference period

* hours worked per month in job for "non-self-employed"
cap drop monthly_hours_job_`i'
gen monthly_hours_job_`i'=.
replace monthly_hours_job_`i'=b16_`i'*b15_`i'*4.345 if b6_`i'!=3

* hours worked per month in job for self-employed
replace monthly_hours_job_`i'=b22_`i'*b23_`i'*4.345 if b6_`i'==3 & !missing(b6_`i') // We assume that time of oppening of the business=time worked by the owner. Once endline data is available, it will be important to check how many self-employed share ownership to assess whether this assumptions holds.



cap drop total_hours_job_`i'
gen total_hours_job_`i'=monthly_hours_job_`i'*job_time_in_ref_`i'

* generate cash income from employment
cap drop monthly_cash_job_`i'
gen monthly_cash_job_`i'=.
//replace monthly_cash_job_`i'=0 //if !missing(b3_`i'_ml)
replace monthly_cash_job_`i'=b17_`i' //if !missing(b18_`i'_ml)
replace monthly_cash_job_`i'=monthly_cash_job_`i'*4.345 if b17_unit_`i'==2 
replace monthly_cash_job_`i'=monthly_cash_job_`i'*4.345*b16_`i' if b17_unit_`i'==3
replace monthly_cash_job_`i'=monthly_cash_job_`i'/b17_unit_s_`i' if b17_unit_`i'==4 
*replace monthly_cash_job_`i'=. if b17_`i'_ml==-97 | b17_`i'_ml==-96// if answer cannot be used for calculation


* generate inkind income from employment
destring b18_unit_s_2, replace
destring b18_unit_s_3, replace
cap drop monthly_inkind_job_`i'
gen monthly_inkind_job_`i'=.
//replace monthly_inkind_job_`i'=0 if !missing(b3_`i'_ml)
replace monthly_inkind_job_`i'=b18_`i' //if !missing(b18_`i'_ml)
*replace monthly_inkind_job_`i'=. if b18_`i'_ml==-97 | b18_`i'_ml==-96// if answer cannot be used for calculation
replace monthly_inkind_job_`i'=monthly_inkind_job_`i'*4.345  if b18_unit_`i'==2
replace monthly_inkind_job_`i'=monthly_inkind_job_`i'*4.345 *b16_`i'  if b18_unit_`i'==3
replace monthly_inkind_job_`i'=monthly_inkind_job_`i'/b18_unit_s_`i' if b18_unit_`i'==4 

*generate monthly profits from self-employment
cap drop monthly_profit_job_`i'
gen monthly_profit_job_`i'=.
//replace monthly_profit_job_`i'=0 if !missing(b3_`i'_ml)
replace monthly_profit_job_`i'=b26_`i' // if !missing(b26_`i'_ml)
*replace monthly_profit_job_`i'=. if b26_`i'_ml==-97 | b26_`i'_ml==-96// if answer cannot be used for calculation
replace monthly_profit_job_`i'=monthly_profit_job_`i'*4.345  if b26_unit_`i'==2
replace monthly_profit_job_`i'=monthly_profit_job_`i'*4.345 *b16_`i' if b26_unit_`i'==3
replace monthly_profit_job_`i'=monthly_profit_job_`i'/b26_unit_s_`i' if b26_unit_`i'==4 

* generate total monthly income of job (for later, not reference period)
cap drop total_monthly_`i'
egen total_monthly_`i'=rowtotal(monthly_cash_job_`i' monthly_inkind_job_`i' monthly_profit_job_`i') , missing

* calculate total income by type from job during whole reference period (assuming working full calendar months)
cap drop total_cash_job_`i'
gen total_cash_job_`i'=monthly_cash_job_`i'*job_time_in_ref_`i'

cap drop total_inkind_job_`i'
gen total_inkind_job_`i'=monthly_inkind_job_`i'*job_time_in_ref_`i'

cap drop total_profit_job_`i'
gen total_profit_job_`i'=monthly_profit_job_`i'*job_time_in_ref_`i'


* hourly incomevars
cap drop hourly_income_`i'
gen hourly_income_`i'=.
replace hourly_income_`i'=total_monthly_`i'/monthly_hours_job_`i'
label var hourly_income_`i' "Average hourly income from `i'. job"
replace hourly_income_`i'=. if b17_`i'==-97 | b17_`i'==-96 |b18_`i'==-97 | b18_`i'==-96 //| b26_`i'_ml==-97 | b26_`i'_ml==-96 | // if answer cannot be used for calculation

}

* calculate total income by type during reference period
cap drop total_income_last`r'mo
egen total_income_last`r'mo=rowtotal(total_cash_job_? total_inkind_job_? total_profit_job_?)
replace total_income_last`r'mo=. if missing(b1)
replace total_income_last`r'mo=0 if b1==0


cap drop total_cash_last`r'mo
egen total_cash_last`r'mo=rowtotal(total_cash_job_?)
replace total_cash_last`r'mo=. if missing(b1)
replace total_cash_last`r'mo=0 if b1==0


cap drop total_inkind_last`r'mo
egen total_inkind_last`r'mo=rowtotal(total_inkind_job_?)
replace total_inkind_last`r'mo=. if missing(b1)
replace total_inkind_last`r'mo=0 if b1==0


cap drop total_profit_last`r'mo
egen total_profit_last`r'mo=rowtotal(total_profit_job_?)
replace total_profit_last`r'mo=. if missing(b1)
replace total_profit_last`r'mo=0 if b1==0


* calculate average monthly income by type during reference period

cap drop avg_inc_all_last`r'
gen avg_inc_all_last`r'=(total_cash_last`r'mo+total_inkind_last`r'mo+total_profit_last`r'mo)/`r'

label var avg_inc_all_last`r' "Average monthly income over last `r' months"

cap drop avg_inc_se_last`r'
gen avg_inc_se_last`r'=total_profit_last`r'mo/`r'

label var avg_inc_se_last`r' "Average monthly income from self-employment over last `r' months"

cap drop avg_inc_emp_last`r'
gen avg_inc_emp_last`r'=(total_cash_last`r'mo+total_inkind_last`r'mo)/`r'

label var avg_inc_emp_last`r' "Average monthly income from employment over last `r' months"

cap drop avg_inc_emp2_last`r'
gen avg_inc_emp2_last`r'=(total_cash_last`r'mo)/`r'

label var avg_inc_emp2_last`r' "Average monthly income from employment over last `r' months excl. inkind"


* calculate hourly_income overall last r months
cap drop total_hours_last`r'mo
egen total_hours_last`r'mo=rowtotal(total_hours_job_?)
replace total_hours_last`r'mo=. if missing(b1)
foreach i in 1 2 3{
replace total_hours_last`r'mo=. if missing(monthly_hours_job_`i') & !missing(total_monthly_`i')
*replace total_income_last`r'mo=. if b26_`i'_ml==-97 | b26_`i'_ml==-96 | b17_`i'_ml==-97 | b17_`i'_ml==-96 |b18_`i'_ml==-97 | b18_`i'_ml==-96 // if income information not disclosed by respondent 
}


cap drop hourly_income_last`r'
gen hourly_income_last`r'=total_income_last`r'/total_hours_last`r'

label var hourly_income_last`r' "Average hourly income over last `r' months"
}

}


*Months in employment during the last 6 months --> variable to place in employment section
cap drop job_time
gen job_time=job_time_in_ref_1
replace job_time= job_time_in_ref_2 if job_time_in_ref_2<job_time
replace job_time= job_time_in_ref_2 if job_time_in_ref_3<job_time
label var job_time "Months in employment in the last 6 months"


{ // income in current jobs

cap drop inc_all_current
gen inc_all_current=.
replace inc_all_current=0 

cap drop inc_se_current
gen inc_se_current=.
replace inc_se_current=0 

cap drop inc_emp_current
gen inc_emp_current=.
replace inc_emp_current=0

cap drop inc_emp2_current
gen inc_emp2_current=.
replace inc_emp2_current=0 

cap drop hours_current
gen hours_current=.
replace hours_current=0

foreach i of num 1/3{
replace inc_all_current=inc_all_current+monthly_cash_job_`i' if b3_`i'==1 & !missing(monthly_cash_job_`i')
replace inc_all_current=inc_all_current+monthly_inkind_job_`i' if b3_`i'==1 & !missing(monthly_inkind_job_`i')
replace inc_all_current=inc_all_current+monthly_profit_job_`i' if b3_`i'==1 & !missing(monthly_profit_job_`i')

replace inc_se_current=inc_se_current+monthly_profit_job_`i' if b3_`i'==1
replace inc_emp_current=inc_emp_current+monthly_cash_job_`i'+monthly_inkind_job_`i' if b3_`i'==1
replace inc_emp2_current=inc_emp2_current+monthly_cash_job_`i' if b3_`i'==1

replace hours_current=hours_current+monthly_hours_job_`i'  if b3_`i'==1 
}

cap drop hourly_income_current
gen hourly_income_current=.
replace hourly_income_current=inc_all_current/hours_current

label var inc_all_current "Monthly income from current jobs"

label var inc_se_current "Monthly income from current self-employment"

label var inc_emp_current "Monthly income from current employment"

label var inc_emp2_current "Monthly income from current employment excl. inkind"

label var hourly_income_current "Hourly income from current jobs"
}

{ // calculate average monthly income of the job with most recent starting date

cap drop inc_most_recent 

gen inc_most_recent=.
replace inc_most_recent=total_monthly_1 if !missing(b4_1) & b4_1<b4_2 & b4_1<b4_3 & b3_1==1

replace inc_most_recent=total_monthly_2 if !missing(b4_2) & b4_2<b4_1 & b4_2<b4_3 & b3_2==1

replace inc_most_recent=total_monthly_3 if !missing(b4_3) & b4_3<b4_2 & b4_3<b4_1 & b3_3==1

label var inc_most_recent "Average monthly income of most recent job"
}


* make missing those which are not asked about employment questions

local incomevars avg_inc_* inc_* hourly_income_last*

foreach var of varlist `incomevars'{
replace `var'=. if missing(b1) // just to be sure not to include those that are not asked this module, those asked, even if no information provided, might have 0 income

foreach i of num 1/3{
replace `var'=. if b26_`i'==-97 | b26_`i'==-96 | b17_`i'==-97 | b17_`i'==-96 |b18_`i'==-97 | b18_`i'==-96 // if income information not disclosed by respondent, make it missing
}
}


}
}






*RISE Participation
cap drop rise_attend
gen rise_attend = .
replace rise_attend = 1 if rise_institute== 1 | rise_course ==1
replace rise_attend = 0 if rise_attend ==.
label var rise_attend "Attended RISE TSTT trainings"
cap label define rise_attend_lbl 0 "Did not Attend in RISE TSTT" 1 "Attended RISE TSTT"
label val rise_attend rise_attend_lbl

cap drop fles_attend //Refers only to trainees who completed the tstt trainings and took part in the fles training.
gen fles_attend =. 
replace fles_attend = 1 if rise_check_fles == 1
replace fles_attend =0 if rise_check_fles == 0
label var fles_attend "Attended RISE FLES trainings"
cap label define fles_attend_lbl 0 "Did not attend FLES training" 1 "Attended RISE FLES training"
label val fles_attend fles_attend_lbl


*training quality
cap drop tf_teacher_qual
egen tf_teacher_qual=rowmean(k1 k2 k4)
replace tf_teacher_qual=. if missing(k1) | missing(k2) | missing(k4)

label var tf_teacher_qual "Quality of teaching at RISE TSTT training (1=very bad; 5=excellent)"


cap drop tf_centre_qual
gen tf_centre_qual=k5

label var tf_centre_qual "Quality of RISE VTIs Centres (1=very bad; 5=excellent)"


cap drop tf_skills_qual
egen tf_skills_qual=rowmean(k6 k8 k9 k10)
replace tf_skills_qual=. if missing(k6) | missing(k8) | missing(k9)  | missing(k10)
label var tf_skills_qual "RISE TSTT trainings develop skills (1=very bad; 5=excellent)"


cap drop fles_complement
clonevar fles_complement = k15
label var fles_complement "Complementarity of FLES with TSTT trainings" 

cap drop fles_teacher_qual
egen fles_teacher_qual = rowmean(k16 k17)
replace fles_teacher_qual =. if missing(k17) | missing(k16)
label var fles_teacher_qual "RISE FLES trainings provide business skills"



*Self-perceived employability
drop spe_score
egen spe_score=rowmean (e1_spe e2_spe e3_spe e4_spe e5_spe e6_spe e7_spe e8_spe e9_spe e10_spe)
label var spe_score "Self Perceived Employability Scale Score"

alpha e1 e2 e3 e4 e5 e6 e7 e8 e9 e10, item
local cronbach=round(`r(alpha)',0.01)

/*
 

********************************************************************************
save "$MIDLINE_PREPARED", replace


*Add  suffix to all variables (Except for applicant id and treatment variables)
ds ApplicantID treatment, not
foreach var of varlist `r(varlist)' {
	rename `var' `var'_ml
}



save "$MIDLINE_PREPARED", replace