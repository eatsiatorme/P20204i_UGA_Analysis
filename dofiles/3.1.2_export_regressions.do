// Code for exporting tables on excel (main and robustness regressions)

//Main tables
if ols== 1 { 
global model "OLS" 
global column B
}
if ols== 0 { 
global model "CEM" 
global column B
}

* Excel output table
// Output regressions in Excel
	
// Create the excel file
putexcel set "${excel_path}", modify sheet ($sheetname) 

//Format and fill table
local num_coef: list sizeof global(outcome)
display `num_coef'

local num_rows = (`num_coef'*2) +3 
display `num_rows'

local notes1 = `num_rows' +1
local notes2 = `num_rows' +2
local notes3 = `num_rows' +3

// Format headers	
	
//Set font 
local col G
		
putexcel (A1:`col'`num_rows'), font("Times New Roman", 10)
putexcel (A1:`col'3), font("Times New Roman", 10, white)

//Font for notes
putexcel (A`notes1':`col'`notes3'), font("Times New Roman", 8, black) txtindent(1)

//Color
putexcel (A1:`col'2), fpattern(solid,  "004 123 119") // Background color of the main heading (C4ED's colors)
putexcel (A3:`col'3), fpattern(solid,  "005 163 159") // Background color of sub-heading (slightly lighter)
putexcel (A4:`col'`num_rows'), fpattern(solid, "255 255 255") // Background color of the content of the table (white here) 

//Column headings
putexcel (A3:`col'3), merge
putexcel A3 = "$sheetname", bold left 
putexcel (B1:C2), merge
putexcel (D1:D2), merge
putexcel B1 = "ITT", bold hcenter vcenter txtwrap

putexcel D1 = "Control mean", bold hcenter vcenter txtwrap

putexcel (E1:G1), merge
putexcel E1 = "Observations", bold hcenter txtwrap
putexcel E2 = "Total", bold hcenter txtwrap
putexcel F2 = "Treated", bold hcenter txtwrap
putexcel G2 = "Control", bold hcenter txtwrap

//Borders
putexcel (A1:`col'1),  border(top, thin, white) 
putexcel (A2:`col'2),  border(bottom, thin, white) 
putexcel (A3:`col'3),  border(bottom, thin, white) 

//Notes
putexcel (A`notes1':`col'`notes1'), merge
putexcel A`notes1' = "Notes: *, **, & *** represent statistical significance at the 10%, 5%, & 1% level respectively."
putexcel (A`notes2':`col'`notes2'), merge
if ols==1  {
putexcel A`notes2' = "Results from OLS regressions. Regressions include covariates. (1) An inverse hyperbolic sine transformation was used."
putexcel (A`notes3':`col'`notes3'), merge
putexcel A`notes3'= "POM is expressed in the outcome's original unit. For binary outcomes, the POM corresponds to a share."
}
if ols==0  {
putexcel A`notes2' = "Coefficients from OLS regressions for continuous outcomes, and marginal effects from probit regressions for binary outcomes, using CEM. Regressions include covariates.  (1) An inverse hyperbolic sine transformation was used."
putexcel (A`notes3':`col'`notes3'), merge
putexcel A`notes3'= "The (weighted) control mean is expressed in the outcome's original unit. For binary outcomes, the control mean corresponds to a share."
}

//Save labels: SPECIFY SHORTER LABELS FOR IT TO WORK
foreach v of var $outcome {
local l`v' : variable label `v'
}

//Fill with estimated coefficients: IPWRA 
if ols==1  {
local j = 4

	foreach outcome in $outcome { // loop over names of outcome variables
		putexcel A`j' = "`l`outcome''"
			local k = `j'+1
				putexcel B`j'=coap_`outcome', nformat(number_d2)  right
				putexcel B`k'=se_`outcome',  nformat((0.00)) right
				if p_`outcome'<=0.01 {
				putexcel C`j'="***",  left
				}
				if p_`outcome'>0.01 & p_`outcome'<=0.05 {
				putexcel C`j'="**",  left
				}
				if p_`outcome'>0.05 & p_`outcome'<=0.10 {
				putexcel C`j'="*",  left
				}
				putexcel E`j'= N_`outcome', nobold hcenter // Nb of observations 
				putexcel F`j'= NT_`outcome', nobold hcenter  // Nb of observations for Treated
				putexcel G`j'= NC_`outcome', nobold hcenter // Nb of observations for Control 
				
				if PM_`outcome'>=1000 {
				putexcel D`j'=PM_`outcome', nformat(number)  hcenter // Comma-separated numbers for numbers above 1000 and no decimal
				}
				if PM_`outcome'<1000 {
				putexcel D`j'=PM_`outcome', nformat(number_d2)  hcenter // For numbers below 1000, we allow for up to two decimaös 
				}
		local j = `j' + 2
	}
}

//Fill with estimated coefficients: CEM 
if ols==0  {
local j = 4

	foreach outcome in $outcome { // loop over names of outcome variables
		putexcel A`j' = "`l`outcome''"
			local k = `j'+1
				putexcel B`j'=cocem_`outcome', nformat(number_d2)  right
				putexcel B`k'=secem_`outcome',  nformat((0.00)) right
				if pcem_`outcome'<=0.01 {
				putexcel C`j'="***",  left
				}
				if pcem_`outcome'>0.01 & pcem_`outcome'<=0.05 {
				putexcel C`j'="**",  left
				}
				if pcem_`outcome'>0.05 & pcem_`outcome'<=0.10 {
				putexcel C`j'="*",  left
				}
				putexcel E`j'= Ncem_`outcome', nobold hcenter // Nb of observations 
				putexcel F`j'= NTcem_`outcome', nobold hcenter  // Nb of observations for Treated
				putexcel G`j'= NCcem_`outcome', nobold hcenter // Nb of observations for Control 
				
				if PMcem_`outcome'>=1000 {
				putexcel D`j'=PMcem_`outcome', nformat(number)  hcenter // Comma-separated numbers for numbers above 1000 and no decimal
				}
				if PMcem_`outcome'<1000 {
				putexcel D`j'=PMcem_`outcome', nformat(number_d2)  hcenter // For numbers below 1000, we allow for up to two decimals 
				}
		local j = `j' + 2
	}
}