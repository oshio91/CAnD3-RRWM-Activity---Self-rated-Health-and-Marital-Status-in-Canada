* RRWM-1-10.02.2025
* Using Stata 15.
* RQ: What are the sociodemographic determinants of quality health among working-age Canadians? Does being married matter more than being single/never married?

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

* Labour market activity (Worked at a job or business last week - whether respondent worked or not - suitable for employment status)
tab lmam_01, mis
drop if lmam_01 == 7 | lmam_01 == 8
tab lmam_01

* Educational attainment (Education - Highest certificate, diploma or degree)
tab ehg3_01b, mis
drop if ehg3_01b == 97 | ehg3_01b == 98 | ehg3_01b == 99
tab ehg3_01b


* Income before tax (Total personal income before tax)
tab ttlincg2, mis

	
**** Univariate Analysis: Summary/Descriptive Statistics ****
*****************************
* final variables for the analysis are: srh2_110, marstat2, agegrp, sex, lmam_01, ehg3_01b, ttlincg2
tab1 srh2_110 marstat2 agegrp sex lmam_01 ehg3_01b ttlincg2
sum srh2_110 marstat2 agegrp sex lmam_01 ehg3_01b ttlincg2


**** Multivariate analysis: Table of Ordinal logistic regression model; categorical variables indicated****
****************************
ologit srh2_110 i.marstat2 i.agegrp i.sex i.lmam_01 i.ehg3_01b i.ttlincg2, or
esttab, se

*Close the log
log close
