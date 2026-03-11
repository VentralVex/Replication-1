* Import extracted IPUMS dataset
use "C:\Users\aditr\Downloads\Replication Exercise 1\usa_00003.dta", clear

*Install estout package
ssc install estout, replace

**********GENERATE VARIABLES**********


* Drop observations with non-US state birthplaces and Hawaii
drop if !inrange(bpl, 1, 56)
drop if bpl == 15

* Drop observations outside of relevant birth years
drop if !inrange(birthyr, 1920, 1931)

* Generate after, during dummy variables
gen after = inrange(birthyr, 1928, 1931)
gen during = inrange(birthyr, 1924, 1927)

* Recode gender
replace sex = sex - 1

* Generate race dummy variables
local categories "white black native chinese japanese asian_pi"

forval i = 1/6 {
    local name : word `i' of `categories'
    gen `name' = (race == `i') if !missing(race)
}

* Generate employed dummy variables
gen employed = (hrswork != 0) if !missing(hrswork)

* Recode labor force participation
replace labforce = labforce - 1 if labforce > 0

* Generate dummy variable for those who worked at least 40 weeks last year, conditional on having worked at least 1 week
gen worked40 = (wkswork1 >= 40) if wkswork1 >= 1 & !missing(wkswork1)

* Mark income coded as 9999999 or 9999998 as null
replace inctot = . if inctot == 9999999 | inctot == 9999998

* Transform income via inverse hyperbolic sine function
gen sinctot = asinh(inctot)


**********GENERATE MAPPINGS**********


*Generate state-level female proportion
bysort bpl: egen female_prop = mean(sex)

*Generate state-level black proportion
gen is_black = (race == 2) if !missing(race)
bysort bpl: egen black_prop = mean(is_black)

*Drop observations from 1920 census
drop if year == 1920

/* I still can't figure out how to generate state average latitude without hard-coding
*Generate state average latitude
tempfile main_data
save `main_data'


	*Generate crosswalk between bpl and state abbreviations
clear
input int bpl str2 state_abbr
1 "AL" 4 "AZ" 5 "AR" 6 "CA" 8 "CO" 9 "CT" 10 "DE" 11 "DC" 12 "FL" 13 "GA" ///
16 "ID" 17 "IL" 18 "IN" 19 "IA" 20 "KS" 21 "KY" 22 "LA" 23 "ME" 24 "MD" ///
25 "MA" 26 "MI" 27 "MN" 28 "MS" 29 "MO" 30 "MT" 31 "NE" 32 "NV" 33 "NH" 34 "NJ" ///
35 "NM" 36 "NY" 37 "NC" 38 "ND" 39 "OH" 40 "OK" 41 "OR" 42 "PA" 44 "RI" 45 "SC" ///
46 "SD" 47 "TN" 48 "TX" 49 "UT" 50 "VT" 51 "VA" 53 "WA" 54 "WV" 55 "WI" 56 "WY"
end
tempfile crosswalk
save `crosswalk'

import delimited "C:\Users\aditr\Downloads\Replication Exercise 1\US_GeoCode.csv", clear

	*Handle possible renamings of the variable state&territory
rename stateteritory state_abbr //Note that territory was misspelled as 'teritory'
replace state_abbr = trim(itrim(state_abbr)) //Remove leading and trailing spaces in state abbreviations

	*Drop US territories and Hawaii
drop if inlist(state_abbr, "AS", "DC", "FM", "GU", "HI")
drop if inlist(state_abbr, "MH", "MP", "PW", "PR", "VI")

keep state_abbr latitude
tempfile lat_values
save `lat_values'

	*Merge crosswalk with state latitudes
use `crosswalk', clear
merge 1:1 state_abbr using `lat_values'
keep if _merge == 3 // Keep mappings where the state abbreviation was present in both the crosswalk and the csv file
drop _merge state_abbr
tempfile lat_map
save `lat_map'

	*Finalize latitude variable generation
use `main_data', clear
merge m:1 bpl using `lat_map'
drop if _merge == 2
drop _merge
label variable latitude "State Average Latitude"
*/

* Generate state-level Goiter Rate (goiter rate * .71) (Can this be done without hard-coding?)

gen goiter_rate = .

* New England
replace goiter_rate = 0.089 if bpl == 9   // Connecticut
replace goiter_rate = 0.066 if bpl == 23  // Maine
replace goiter_rate = 0.032 if bpl == 25  // Massachusetts
replace goiter_rate = 0.070 if bpl == 33  // New Hampshire
replace goiter_rate = 0.055 if bpl == 44  // Rhode Island
replace goiter_rate = 0.214 if bpl == 50  // Vermont

* Middle Atlantic
replace goiter_rate = 0.043 if bpl == 34  // New Jersey
replace goiter_rate = 0.119 if bpl == 36  // New York
replace goiter_rate = 0.410 if bpl == 42  // Pennsylvania

* East North Central
replace goiter_rate = 0.779 if bpl == 17  // Illinois
replace goiter_rate = 0.649 if bpl == 18  // Indiana
replace goiter_rate = 1.143 if bpl == 26  // Michigan
replace goiter_rate = 0.559 if bpl == 39  // Ohio
replace goiter_rate = 1.402 if bpl == 55  // Wisconsin

* West North Central
replace goiter_rate = 0.668 if bpl == 19  // Iowa
replace goiter_rate = 0.125 if bpl == 20  // Kansas
replace goiter_rate = 0.804 if bpl == 27  // Minnesota
replace goiter_rate = 0.399 if bpl == 29  // Missouri
replace goiter_rate = 0.214 if bpl == 31  // Nebraska
replace goiter_rate = 0.873 if bpl == 38  // North Dakota
replace goiter_rate = 0.409 if bpl == 46  // South Dakota

* South Atlantic
replace goiter_rate = 0.059 if bpl == 10  // Delaware
replace goiter_rate = 0.139 if bpl == 11  // District of Columbia
replace goiter_rate = 0.025 if bpl == 12  // Florida
replace goiter_rate = 0.052 if bpl == 13  // Georgia
replace goiter_rate = 0.094 if bpl == 24  // Maryland
replace goiter_rate = 0.181 if bpl == 37  // North Carolina
replace goiter_rate = 0.094 if bpl == 45  // South Carolina
replace goiter_rate = 0.338 if bpl == 51  // Virginia
replace goiter_rate = 0.789 if bpl == 54  // West Virginia

* East South Central
replace goiter_rate = 0.056 if bpl == 1   // Alabama
replace goiter_rate = 0.141 if bpl == 21  // Kentucky
replace goiter_rate = 0.064 if bpl == 28  // Mississippi
replace goiter_rate = 0.196 if bpl == 47  // Tennessee

* West South Central
replace goiter_rate = 0.040 if bpl == 5   // Arkansas
replace goiter_rate = 0.062 if bpl == 22  // Louisiana
replace goiter_rate = 0.072 if bpl == 40  // Oklahoma
replace goiter_rate = 0.030 if bpl == 48  // Texas

* Mountain
replace goiter_rate = 0.121 if bpl == 4   // Arizona
replace goiter_rate = 0.529 if bpl == 8   // Colorado
replace goiter_rate = 2.691 if bpl == 16  // Idaho
replace goiter_rate = 2.100 if bpl == 30  // Montana
replace goiter_rate = 0.638 if bpl == 32  // Nevada
replace goiter_rate = 0.088 if bpl == 35  // New Mexico
replace goiter_rate = 1.572 if bpl == 49  // Utah
replace goiter_rate = 1.537 if bpl == 56  // Wyoming

* Pacific
replace goiter_rate = 1.314 if bpl == 2   // Alaska
replace goiter_rate = 0.445 if bpl == 6   // California
replace goiter_rate = 2.631 if bpl == 41  // Oregon
replace goiter_rate = 2.340 if bpl == 53  // Washington

label variable goiter_rate "State-level Goiter Rate (Draft Exams)"
replace goiter_rate = goiter_rate * .71 //Scale Goiter Rate by the difference between the 25th and 75th percentile (.71)


**********RUN REGRESSION**********

* Set up control macros
local controls sex white black native chinese japanese asian_pi ///
               c.birthyr##i.year ///
               /// i.after##c.latitude i.during##c.latitude /// Latitude isn't working right now
               i.after##c.female_prop i.during##c.female_prop ///
               i.after##c.black_prop i.during##c.black_prop ///
			   i.bpl /// state fixed effects
			   
local treatment c.goiter_rate##i.after c.goiter_rate##i.during

foreach var in employed labforce worked40 sinctot {
    qui regress `var' `treatment' `controls' [pweight = perwt], vce(cluster bpl)
	qui sum `var' if e(sample) [aw = perwt]
    estadd scalar dv_mean = r(mean)
	eststo `var'
}

*Generate table
esttab employed labforce worked40 sinctot using "C:\Users\aditr\Downloads\Replication Exercise 1\Table2_Iodization.tex", ///
    replace booktabs ///
    b(5) se(5) star(* 0.10 ** 0.05 *** 0.01) ///
    title("Table 2.---Effects of Salt Iodization on Labor and Income Outcomes") ///
    mtitle("1(Employed)" "1(Participated in the Labor Force)" "1(Worked at least 40 weeks)" "sinh$^{-1}$(Income)") ///
    keep(1.after#c.goiter_rate 1.during#c.goiter_rate) ///
    coeflabels(1.after#c.goiter_rate "After $\times$ Goiter Rate" ///
               1.during#c.goiter_rate "During $\times$ Goiter Rate") ///
    scalars("Observations" "dv_mean Mean of dependent variable") ///
    sfmt(%12.0fc %12.3f) ///





