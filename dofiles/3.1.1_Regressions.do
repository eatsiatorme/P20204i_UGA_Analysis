********************************************************************************
*Code for running main and robustness regressions
********************************************************************************

**Set up: this should specified in your main do-file**
*Define your treatment variable
local treatment "$treatment"
*Define the sample of interest (leave empty if you want the whole sample)
local sub_group "$sub_group" // (e.g., "if female==1")
*Define your cluster variable
local cluster "$cluster" // To use when you want to cluster your standard errors (e.g., "vce(cluster name_cluster)")
*Define your sampling weights whenever you need to use some
local weight "$weight" // (e.g., "[pweight=name_weights]")
*Define your covariates
local covariates "$base_cov"

*To replace control mean by untransformed mean when inverse hyperbolic (asinh) or logarithmic (ln) transformations are used
cap drop ln_mean ah_mean
gen ln_mean=0
gen ah_mean=0

*Generate identifiers for coefplots
local number=0

*This loops over each outcome of the list of outcomes you want in one table. This global is defined in the main do file.
foreach outcome of global outcome {  
//Identify if binary outcome (to estimate probit regressions)
cap drop binary
gen binary=0
quietly tab `outcome'
replace binary=1 if r(r)==2 

//Identify whether the variable is in asinh or log form (it requires that your variables start with "ah_" or "ln_")
	gen lnd_`outcome' = substr("`outcome'", 1, 2)
	replace ln_mean=1 if  lnd_`outcome' =="ln"
	replace ln_mean=0 if lnd_`outcome' !="ln"
	replace ah_mean=1 if  lnd_`outcome' =="ah"
	replace ah_mean=0 if lnd_`outcome' !="ah"
	drop lnd_*	

*************************************************************************************************************************************************
//Regression main model: OLS 
*************************************************************************************************************************************************
    	if ols==1 {
			if binary==0 { // Regression equation for continuous outcomes 
	reg `outcome' `treatment' `covariates' `sub_group'  `weight'
     *gen elast=((sinh(_b[r1vs0.`treatment']+_b[POmean:0.`treatment']) - sinh(_b[POmean:0.`treatment'])) / sinh(_b[POmean:0.`treatment'])) * 100
     }
	 if binary==1 { // Regression equation for binary outcomes  
	reg `outcome' `treatment'  `covariates' `sub_group'  `weight'
	 }
		}
	***Exporting relevant statistics*** 

	//Coefficients without transformation 
	gen coap_`outcome'=_b[`treatment']  
	gen se_`outcome'=_se[`treatment']
	gen z_`outcome'=_b[`treatment']/_se[`treatment']
	gen N_`outcome'=e(N)
	gen obs=1
	egen NTT_`outcome'=count(obs) if `treatment'==1 & e(sample)
	egen NT_`outcome'=mean(NTT_`outcome')
	egen NNT_`outcome'=count(obs) if `treatment'==0 & e(sample)
	egen NC_`outcome'=mean(NNT_`outcome')
	gen p_`outcome'= (2*(normal(-(abs(_b[`treatment'])/se_`outcome'))))
	drop obs
	
	//Drop temporary variables
	cap drop  elast NNT_* NTT_*

	//Control mean (POmeans) 
	*gen PM_`outcome'=_b[POmean:0.`treatment']  //NOT SURE WHAT IS HAPPENING HERE
	sum `outcome' if `treatment'==0
	gen PM_`outcome'=r(mean)
	//Compute impact in terms of percentage change for exporting in tables 
	if ah_mean==0  {
	*gen coef_`outcome'=(_b[`treatment']/_b[POmean:0.`treatment'])*100 //NOT SURE WHAT IS HAPPENING HERE
	gen coef_`outcome'=(_b[`treatment']/[PM_`outcome'])*100

	}
	//Compute the semi-elasticity when an inverse hyperbolic transformation (asinh) is used
	if ah_mean==1 {
	gen coef_`outcome'=elast
	}
    //Compute impact in terms of percentage change and store for exporting in coefplot
	if ah_mean==0  {
	*nlcom _b[`treatment']/_b[POmean:0.`treatment'] , post
	nlcom _b[`treatment']/[PM_`outcome'] , post

	local number=`number'+1
	estimates store O`number'
	}
	if ah_mean==1  {
	*nlcom ((sinh(_b[r1vs0.`treatment']+_b[POmean:0.`treatment']) - sinh(_b[POmean:0.`treatment'])) / sinh(_b[POmean:0.`treatment'])) * 100 , post // Still to be tested   // NOTSURE WHAT IS HAPENNING HERE
	nlcom ((sinh(_b[`treatment']+[PM_`outcome']) - sinh([PM_`outcome'])) / sinh([PM_`outcome'])) * 100 , post // Still to be tested 

	local number=`number'+1
	estimates store O`number'
	}
	*/
    }
		
*************************************************************************************************************************************************

*************************************************************************************************************************************************
//Regression robustness: CEM
*************************************************************************************************************************************************
	if ols==0 {
	}
		