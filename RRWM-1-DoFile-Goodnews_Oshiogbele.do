* RRWM-1-10.02.2025
* Using Stata 15.
/* RQs: i) What sociodemographic factors determine the quality of self-rated health among working-age Canadians?
		ii) Does being in a partnership have a greater impact on health than being single or never married? 
		iii) Is marital status a more significant determinant of health than educational attainment?
*/

/*set working directory*/
cd "C:\Users\oshio\Documents\CAnD3 RRWM 1\Stata Works"

/*start the log*/
log using "RRWM-1-LogFile-Goodnews_Oshiogbele.log"

/*load the dataset; "use" command won't work since this is not a .dta file.*/
import delimited "gss-12M0025-E-2017-c-31_F1.csv"

****** DATA CLEANING AND SAMPLING *****
***************************************

*** Keep only these 7 variables of interest to make the dataset more manageable
keep srh_110 marstat agec sex lmam_01 ehg3_01b ttlincg2

*** Drop individuals outside the working age (that is, outside 15-64; since the gss surveys 15 year olds and above, focus on dropping those > 63 years )
drop if agec > 64

*****Clean the dependent variable *****
***************************************
* Using the data's codebook, define and apply labels where numbers represent subcategories (that is, do this for variables that were not recoded):
*** Examined the DV and drop observations with unusable values.
tab srh_110, mis
drop if srh_110 == 7 | srh_110 == 8 | srh_110 == 9
tab srh_110, mis

* Recode the DV and generated a new variable named "Self-rated health cleaned"
recode srh_110 (1 = 1 "Excellent") ///
          (2 = 2 "Very good") ///
          (3 = 3 "Good") ///
          (4 5 = 4 "Not Good"), gen(srh2_110)
label variable srh2_110 "Self-rated health cleaned"
tab srh2_110
tab srh2_110, nol

*****Clean the independent variables *****
******************************************
* Marital status 
tab marstat, mis
drop if marstat == 97 | marstat == 98
tab marstat

recode marstat (1 2 = 1 "Partnered") ///
          (6 = 2 "Single, never married") ///
          (3 4 5 = 3 "Other"), gen(marstat2)
label variable marstat2 "Marital status cleaned"
tab marstat2
tab marstat2, nol


* Age (transform from a discrete to an ordinal variable with five categories)
tab agec, mis

recode agec (15/24 = 1 "15-24 (Youth)") ///
			(25/34 = 2 "25-34 (Young adults)") ///
			(35/44 = 3 "35-44 (Middle-aged adults") ///
			(45/54 = 4 "45-54 (Senior adults") ///
			(55/64 = 5 "55-64 (Pre-retirement adults"), gen(agegrp)
label variable agegrp "Age group"
tab agegrp
tab agegrp, nol

* Sex
tab sex, mis
label define sexlabel 1 "Male" 2 "Female"
label values sex sexlabel
tab sex

* Labour market activity (Worked at a job or business last week - whether respondent worked or not - suitable for employment status)
tab lmam_01, mis
drop if lmam_01 == 7 | lmam_01 == 8
tab lmam_01
label define lmam_01label 1 "Yes" 2 "No"
label values lmam_01 lmam_01label
tab lmam_01


* Educational attainment (Education - Highest certificate, diploma or degree)
tab ehg3_01b, mis
drop if ehg3_01b == 97 | ehg3_01b == 98 | ehg3_01b == 99
tab ehg3_01b
label define ehg3_01blabel 1 "Less than high school diploma or its equivalent" ///
							2 "High school diploma or a high school equivalency certificate" ///
							3 "Trade certificate or diploma" ///
							4 "College, CEGEP or other non-university certificate or diploma (other than trades certificates or diplomas)" ///
							5 "University qual. < bachelor's" ///
							6 "Bachelor's degree (e.g. B.A., B.Sc., LL.B.)" ///
							7 "University qual. > bachelor's"
label values ehg3_01b ehg3_01blabel
tab ehg3_01b


* Income before tax (Total personal income before tax)
tab ttlincg2, mis
label define ttlincg2label 1 "Less than $25,000" ///
							2 "$25,000 to $49,999" ///
							3 "$50,000 to $74,999" ///
							4 "$75,000 to $99,999" ///
							5 "$100,000 to $124,999" ///
							6 "$125,000 and more"
label values ttlincg2 ttlincg2label
tab ttlincg2

	
**** Univariate Analysis: Summary/Descriptive Statistics ****
*****************************
* final variables for the analysis are: srh2_110, marstat2, agegrp, sex, lmam_01, ehg3_01b, ttlincg2
* First, tabulate each (although this output will not be reproduced in image [jpg] format, it will serve as confirmation of percentages that the next step will generate)
tab1 srh2_110 marstat2 agegrp sex lmam_01 ehg3_01b ttlincg2

* Since all variables are categorical, create descriptive summary statistics by transforming them into dummies so that their outputted mean values will be their subcategorical percentages in fractions (0.5=50%) and hidden reference categories will make up the remaining percentages inside 100%.
sum i.srh2_110 i.marstat2 i.agegrp i.sex i.lmam_01 i.ehg3_01b i.ttlincg2



**** Bivariate Analysis: Contingency tables, showing and testing (Chi2) associations between the DV and each IV.
tab marstat2 srh2_110, row chi2

tab ehg3_01b srh2_110, row chi2

tab agegrp srh2_110, row chi2

tab sex srh2_110, row chi2

tab lmam_01 srh2_110, row chi2

tab ttlincg2 srh2_110, row chi2


**** Multivariate analysis: Table of Ordinal logistic regression model; categorical variables indicated****
****************************
* Regress the dependent variable against only the marital status and educational attainment independent variables. Estimates as odds ratios.
ologit srh2_110 i.marstat2 i.ehg3_01b, or
*Create stored regression estimate
eststo: ologit srh2_110 i.marstat2 i.ehg3_01b, or

* Regress the dependent variable against all the independent variables. Estimates as odds ratios.
ologit srh2_110 i.marstat2 i.ehg3_01b i.agegrp i.sex i.lmam_01 i.ttlincg2, or
* Create stored regression estimate
eststo: ologit srh2_110 i.marstat2 i.ehg3_01b i.agegrp i.sex i.lmam_01 i.ttlincg2, or

* Create publication-quality table from stored regression estimates (that is, in a journal-like, customizable format).
* Add "eform" to show the estimates as odds ratios (exponentiated coefficients for easier interpretation) instead of coefficients.
esttab, se eform


*Close the log
log close
