
//-----------------------------------------------------------------
//Start
//-----------------------------------------------------------------

//Initialize environment
	set more off
	clear all
	pause on 

//Set global directories
	global directory = "c:\Users\Jose\OneDrive - Universidad Católica de Chile\Proyecto de tesis\Kohn, D., Leibovici, F., & Tretvoll, H.  (2021)\Replication_KLT_AEJM2020\Data\CrossCountry"
	

//Change directory
	cd "${directory}"
		
//-----------------------------------------------------------------
//Setup dataset
//-----------------------------------------------------------------

do setup_data.do

//-----------------------------------------------------------------
//Load dataset
//-----------------------------------------------------------------

use dataset.dta, clear
xtset countrycode_val year

//-----------------------------------------------------------------
//Create country categories 
//-----------------------------------------------------------------
   
//GDP per capita from WB data
//PPP-adjusted series starts in 1990
	gen GDPperCapita = cGDP_PPP if year>=1970 & year<=2016 
	
//Variable selection
	bysort country: egen cGDP_PPP_avg = mean(GDPperCapita)

//Years
	bysort country: egen cGDP_PPP_avg_yearmin = min(year) if GDPperCapita~=.
	bysort country: egen cGDP_PPP_avg_yearmax = max(year) if GDPperCapita~=.
	table country, statistic(mean cGDP_PPP_avg_yearmin) statistic(mean cGDP_PPP_avg_yearmax)
	
//Country categories	
	gen country_cat = .
	replace country_cat = 1 if cGDP_PPP_avg<25000
	replace country_cat = 2 if cGDP_PPP_avg>=25000 & OECD==1 & cGDP_PPP_avg~=.

//-----------------------------------------------------------------
//Sample selection
//-----------------------------------------------------------------		

//Time period
	keep if year>=1970 & year<=2016

//Drop countries not classified as developed or emerging
	drop if country_cat==.	
	
//Drop communist countries prior to 1995
//Exclude communist periods + transition to capitalism
	gen communist = 0
	replace communist = 1 if country=="Armenia" | country=="Azerbaijan" | country=="Belarus" | country=="Bosnia and Herzegovina" | country=="Croatia" | country=="Czech Republic" | country=="Estonia" | country=="Georgia" | country=="Hungary" | country=="Kazakhstan" | country=="Kyrgyz Republic" | country=="Kyrgyzstan" | country=="Latvia" | country=="Lithuania" | country=="Moldova" |country=="Poland" | country=="Republic of Moldova" | country=="TFYR of Macedonia" | country=="Romania" | country=="Russian Federation" | country=="Slovakia" | country=="Slovak Republic" | country=="Slovenia" | country=="Tajikistan" | country=="Turkmenistan" | country=="Ukraine" | country=="Uzbekistan" 
	
	//Filter
		drop if communist==1 & year<=1994

//Drop US and China
	drop if country=="United States" || country=="China" 
	
//Drop countries without enough observations for business cycle moments
//Drop countries with less than 25 consecutive annual observations for: GDP, C, I, NX/GDP
	tsspell, c(ln_cGDP~=. & ln_cC~=. & ln_cI~=. & TB_Y~=.) 
	bysort country _spell: egen spell_obs = max(_seq)
	
	//Filter
		keep if spell_obs>=25

	//Display
		table country, statistic(max spell_obs)
		
	//Drop temporary variables
		drop spell_obs _spell _seq _end	
		
//Drop countries without enough observations for cross-sectional moments
//Drop countries with less than 15 observations for: agg NX/GDP, sectoral NX/GDP, VA shares
	sort countrycode
	by countrycode: egen nxgoods_gdp_cnt = count(nxgoods_gdp)
	by countrycode: egen nxGDP_mfct_GDP_cnt	= count(nxGDP_mfct_GDP)
	by countrycode: egen nxGDP_commodities_GDP_cnt	= count(nxGDP_commodities_GDP)
	
	by countrycode: egen vashare_commodities_cnt = count(vashare_commodities)
	by countrycode: egen vashare_srvc_cnt = count(vashare_srvc)
	by countrycode: egen vashare_mfct_cnt = count(vashare_mfct)
	
	//Keep countries with sufficiently many observations
		keep if (nxgoods_gdp_cnt>=15 & nxGDP_mfct_GDP_cnt>=15 & vashare_commodities_cnt>=15 & nxGDP_commodities_GDP_cnt>=15 & vashare_mfct_cnt>=15 & vashare_srvc_cnt>=15)	
	
//Drop small countries: Population < 1000000 in any given year
	sort country
	by country: egen min_pop = min(pop)  
	drop if min_pop<1000000

//Restrict attention to labor and TFP observations observed for 25 consecutive periods
	//Labor (employment)
		tsspell, c(ln_N~=.) 
		bysort country _spell: egen spell_obs = max(_seq)
		replace ln_N = . if spell_obs<25
		drop spell_obs _spell _seq _end

	//TFP
		tsspell, c(ln_TFP~=.) 
		bysort country _spell: egen spell_obs = max(_seq)
		replace ln_TFP = . if spell_obs<25
		drop spell_obs _spell _seq _end				

//-----------------------------------------------------------------
//Summary statistics
//-----------------------------------------------------------------			

//# of countries
	distinct country if country_cat==1
	distinct country if country_cat==2
	
//-----------------------------------------------------------------
//Detrending business cycles variables (after choosing sample)
//-----------------------------------------------------------------

//HP-filter data
	tsfilter hp cyc_cGDP	= ln_cGDP	, smooth(100) t(trend_cGDP)
	tsfilter hp cyc_TB_Y 	= TB_Y		, smooth(100) t(trend_TB_Y)		
	tsfilter hp cyc_cC 		= ln_cC		, smooth(100) t(trend_cC)		
	tsfilter hp cyc_cI 		= ln_cI		, smooth(100) t(trend_cI)		
	
	//Price process statistics
		preserve
			egen tag_price_year = tag(year) if ln_pc~=.
			drop if tag_price_year==0
			sum ln_pc, detail
			
			tset year
			sort year
			corr ln_pc L.ln_pc
		restore
	
	//Labor and TFP
		preserve		
			tsspell, c(ln_N~=.) 
			bysort country _spell: egen spell_obs = max(_seq)
			keep if spell_obs>=25				
			
			tsfilter hp cyc_N = ln_N, smooth(100) t(trend_N)		
			keep country year cyc_N trend_N
			sort country year
			save cyc_N.dta, replace
		restore		
		
		preserve
			tsspell, c(ln_TFP~=.) 
			bysort country _spell: egen spell_obs = max(_seq)
			keep if spell_obs>=25	
			
			tsfilter hp cyc_TFP = ln_TFP, smooth(100) t(trend_TFP)		
			keep country year cyc_TFP trend_TFP
			sort country year
			save cyc_TFP.dta, replace
		restore		
		
		sort country year
		merge country year using cyc_N.dta
		ren _merge merge_N
		
		sort country year
		merge country year using cyc_TFP.dta
		ren _merge merge_TFP

		erase cyc_N.dta
		erase cyc_TFP.dta			
	
//Save
	save dataset_processed.dta, replace   

//-----------------------------------------------------------------
//Figure 1: Economic development and business cycle volatility
//-----------------------------------------------------------------
 
//Load data
    use dataset_processed.dta, clear

//Collapse database across time
	collapse (sd) cyc_cGDP (mean) cGDP_PPP, by(country)
	
//Label variables
	label variable cyc_cGDP "Std. Dev. Real GDP"
	label variable cGDP_PPP "GDP per capita, PPP, avg. 1990-2016"
	
//Plot figure
	set scheme s1color
	
	// Create professional scatter plot with trend line
	twoway (scatter cyc_cGDP cGDP_PPP, mcolor(blue%30) msymbol(O) msize(medlarge)) ///
		   (lfit cyc_cGDP cGDP_PPP, lcolor(red) lwidth(medthick) lpattern(solid)), ///
		   title("Economic Development and Business Cycle Volatility", size(medlarge)) ///
		   xtitle("GDP per capita, PPP, avg. 1990-2016", size(medium)) ///
		   ytitle("Std. Dev. Real GDP", size(medium)) ///
		   legend(off) ///
		   graphregion(color(white)) ///
		   plotregion(color(white)) ///
		   saving("${directory}\OutputForPaper\Fig1.gph", replace)

//-----------------------------------------------------------------
//Table 1: GDP volatility and the type of goods produced and traded
//-----------------------------------------------------------------
 
//Load data
    use dataset_processed.dta, clear
	
//Collapse database across time
	collapse (sd) cyc_cGDP (mean) vashare_commodities vashare_mfct vashare_srvc xshare_commodities mshare_commodities nxGDP_mfct_GDP nxGDP_commodities_GDP nxgoods_gdp country_cat, by(country)	
	
//Adjust variables to display tables
	gen CountryGroup = ""
	replace CountryGroup = "Emerging" if country_cat==1
	replace CountryGroup = "Developed" if country_cat==2	
	
	ren nxgoods_gdp 			NX_GDP
	ren nxGDP_mfct_GDP 			MfctNX_GDP
	ren nxGDP_commodities_GDP 	CommoditiesNX_GDP
	ren vashare_mfct 			MfctVA_GDP
	ren vashare_commodities		CommoditiesVA_GDP	
	ren vashare_srvc			ServicesVA_GDP	
	ren xshare_commodities	    XCommodities_X
	ren mshare_commodities	    MCommodities_M
	ren cyc_cGDP				sd_GDP
	
//Compute Excel tables	
	tabout CountryGroup using "${directory}\OutputForPaper\Table1.csv", replace sum c(mean sd_GDP mean "CommoditiesVA_GDP" mean "MfctVA_GDP" mean "ServicesVA_GDP" mean "XCommodities_X" mean "MCommodities_M" mean "MfctNX_GDP" mean "CommoditiesNX_GDP" mean "NX_GDP") f(5) style(csv) ptotal(none)

	tabout CountryGroup using "${directory}\OutputForPaper\Table1.csv", append sum c(p25 sd_GDP p25 "CommoditiesVA_GDP" p25 "MfctVA_GDP" p25 "ServicesVA_GDP" p25 "XCommodities_X" p25 "MCommodities_M" p25 "MfctNX_GDP" p25 "CommoditiesNX_GDP" p25 "NX_GDP") f(5) style(csv) ptotal(none)

	tabout CountryGroup using "${directory}\OutputForPaper\Table1.csv", append sum c(p75 sd_GDP p75 "CommoditiesVA_GDP" p75 "MfctVA_GDP" p75 "ServicesVA_GDP" p75 "XCommodities_X" p75 "MCommodities_M" p75 "MfctNX_GDP" p75 "CommoditiesNX_GDP" p75 "NX_GDP") f(5) style(csv) ptotal(none)
	
//-----------------------------------------------------------------
//Table 4: Cross-sectional moments
//-----------------------------------------------------------------
 
//Load data
    use dataset_processed.dta, clear

//Collapse database across time
	collapse (mean) nxgoods_gdp nxGDP_mfct_GDP vashare_mfct vashare_commodities country_cat, by(country)
	
//Adjust variables to display tables
	gen CountryGroup = ""
	replace CountryGroup = "Emerging" if country_cat==1
	replace CountryGroup = "Developed" if country_cat==2
	
	ren nxgoods_gdp 	NX_GDP
	ren nxGDP_mfct_GDP 	MfctNX_GDP
	ren vashare_mfct 	MfctVA_GDP
	ren vashare_commodities	CommoditiesVA_GDP
	
//Compute Excel tables	
	//By country group
		tabout CountryGroup using "${directory}\OutputForPaper\Table4_XSectionalMoments.csv", replace sum c(mean "MfctVA_GDP" mean "CommoditiesVA_GDP" mean "MfctNX_GDP" mean "NX_GDP") f(5) style(csv) ptotal(none)
	
	//Country-by-country
		tabout country using "${directory}\OutputForCountryByCountryExercise\Table4_XSectionalMoments_CountryByCountry.csv", replace sum c(mean "MfctVA_GDP" mean "CommoditiesVA_GDP" mean "MfctNX_GDP" mean "NX_GDP" mean country_cat) f(5) style(csv) ptotal(none)

//-----------------------------------------------------------------
//Table 4: Business cycle moments
//-----------------------------------------------------------------

//Standard deviations
	//Load data
		use dataset_processed.dta, clear
			
	//Collapse dataset
		collapse (sd) cyc_cGDP cyc_cC cyc_cI cyc_TB_Y (mean) country_cat, by(country)

	//Adjust variables to display tables
		gen CountryGroup = ""
		replace CountryGroup = "Emerging" if country_cat==1
		replace CountryGroup = "Developed" if country_cat==2

	//Rename variables
		ren cyc_cGDP sd_Y
		ren cyc_TB_Y sd_TB_Y
		ren cyc_cC sd_C
		ren cyc_cI sd_I
		
	//Compute relative standard deviations
		gen sd_C_Y = sd_C/sd_Y
		gen sd_I_Y = sd_I/sd_Y

	//Compute Excel tables
		tabout CountryGroup using "${directory}\OutputForPaper\Table4_BCMoments.csv", replace sum c(mean sd_Y mean "sd_TB_Y" mean "sd_C_Y" mean "sd_I_Y") f(5) style(csv) ptotal(none)
		
//Correlations		
	//Load data
		use dataset_processed.dta, clear
		
	//Compute correlations
		sort country 

		egen corr_TBY_Y = corr(cyc_TB_Y cyc_cGDP)		, by(country)
		
		sort countrycode_val year
		gen lag_cyc_cGDP = L.cyc_cGDP
		sort country
		egen ac_Y = corr(cyc_cGDP lag_cyc_cGDP)	, by(country)
		
	//Collapse	
		collapse (mean) corr_TBY_Y ac_Y country_cat, by(country)
		
	//Adjust variables to display tables	
		gen CountryGroup = ""
		replace CountryGroup = "Emerging" if country_cat==1
		replace CountryGroup = "Developed" if country_cat==2
		
	//Compute Excel tables
		tabout CountryGroup using "${directory}\OutputForPaper\Table4_BCMoments.csv", append sum c(mean "corr_TBY_Y" mean ac_Y) f(5) style(csv) ptotal(none)
		
//-----------------------------------------------------------------
//Table 4: Std. dev. share of manufactures in GDP
//-----------------------------------------------------------------
	
//Load data
	use dataset_processed.dta, clear
		
//Sort data
	sort countrycode_val year
	
//Take logs
	gen ln_vashare_mfct = ln(vashare_mfct)

//Compute standard deviations
	egen sd_ln_vashare_mfct = sd(ln_vashare_mfct), by(country)		

//Collapse data
	collapse (mean) sd_ln_vashare_mfct country_cat, by(country)
	
//Adjust variables to display tables	
	gen CountryGroup = ""
	replace CountryGroup = "Emerging" if country_cat==1
	replace CountryGroup = "Developed" if country_cat==2
	
//Excel tables
	tabout CountryGroup using "${directory}\OutputForPaper\Table4_StdDevMfctShare.csv", replace sum c(mean "sd_ln_vashare_mfct") f(5) style(csv) ptotal(none)

//-----------------------------------------------------------------
//Table 5, Panel A: Standard deviations
//-----------------------------------------------------------------
	
//Load data
	use dataset_processed.dta, clear
		
//Compute standard deviation of commodity prices
	bysort country: egen ln_pc_cnt = count(ln_pc)
	egen ln_pc_cnt_max = max(ln_pc_cnt)
	encode countrycode, g(countrycode_num)
	egen countrycode_min = min(countrycode_num) if ln_pc_cnt==ln_pc_cnt_max
	
	sum ln_pc if countrycode_num==countrycode_min, detail
	gen sd_pc = r(sd)

//Collapse dataset
	collapse (sd) cyc_cGDP cyc_cC cyc_cI cyc_TB_Y cyc_N cyc_TFP (mean) sd_pc country_cat, by(country)

//Adjust variables to display tables
	gen CountryGroup = ""
	replace CountryGroup = "Emerging" if country_cat==1
	replace CountryGroup = "Developed" if country_cat==2

//Rename variables
	ren cyc_cGDP sd_Y
	ren cyc_TB_Y sd_TB_Y
	ren cyc_cC sd_C
	ren cyc_cI sd_I
	ren cyc_N sd_N
	ren cyc_TFP sd_TFP
	
//Compute relative standard deviations
	gen sd_C_Y = sd_C/sd_Y
	gen sd_I_Y = sd_I/sd_Y
	gen sd_N_Y = sd_N/sd_Y
	gen sd_TFP_Y = sd_TFP/sd_Y	
	
	//Commodity prices, treated differently since not country-specific
	//Thus first compute avg. std. dev. of real GDP, then compute relative std. dev. of commodity prices to real GDP
		bysort CountryGroup: egen sd_Y_avg = mean(sd_Y)
		gen sd_pc_Y = sd_pc/sd_Y_avg
	
//Summary statistics
	table country_cat, statistic(mean sd_Y) statistic(mean sd_C_Y)
	
	//# of countries
		distinct country if country_cat==1
		distinct country if country_cat==2

//Compute Excel tables
	tabout CountryGroup using "${directory}\OutputForPaper\Table5.csv", replace sum c(mean sd_Y mean "sd_TB_Y" mean "sd_C_Y" mean "sd_I_Y"  mean "sd_N_Y" mean "sd_TFP_Y" mean "sd_pc_Y") f(5) style(csv) ptotal(none)

	//Country-by-country
	//Used to run country-by-country exercise
		tabout country using "${directory}\OutputForCountryByCountryExercise\Table5_PanelA_CountryByCountry.csv", replace sum c(mean sd_Y mean "sd_TB_Y" mean "sd_C_Y" mean "sd_I_Y"  mean "sd_N_Y" mean "sd_TFP_Y" mean "sd_pc_Y" mean country_cat) f(5) style(csv) ptotal(none)

//-------------------------------------------------------------------
//Table 5, Panels B and C: Correlations with GDP and autocorrelations
//-------------------------------------------------------------------

//Load data
	use dataset_processed.dta, clear
	
//Compute correlations
	sort country 

	egen corr_Y_Y 	= corr(cyc_cGDP cyc_cGDP)	, by(country)
	egen corr_C_Y 	= corr(cyc_cC cyc_cGDP)		, by(country)
	egen corr_I_Y 	= corr(cyc_cI cyc_cGDP)		, by(country)
	egen corr_TBY_Y = corr(cyc_TB_Y cyc_cGDP)	, by(country)
	egen corr_N_Y 	= corr(cyc_N cyc_cGDP)		, by(country)
    egen corr_TFP_Y = corr(cyc_TFP cyc_cGDP)	, by(country)
	egen corr_pc_Y  = corr(ln_pc cyc_cGDP) 		, by(country)	
	
	sort countrycode_val year
	gen lag_cyc_cGDP 	= L.cyc_cGDP
	gen lag_cyc_cC 		= L.cyc_cC
	gen lag_cyc_cI 		= L.cyc_cI
	gen lag_cyc_TB_Y 	= L.cyc_TB_Y
	gen lag_cyc_N 		= L.cyc_N
	gen lag_cyc_TFP 	= L.cyc_TFP
	gen lag_pc 			= L.ln_pc

	sort country
	egen ac_Y 		= corr(cyc_cGDP lag_cyc_cGDP)	, by(country)
	egen ac_C 		= corr(cyc_cC lag_cyc_cC)		, by(country)
	egen ac_I 		= corr(cyc_cI lag_cyc_cI)		, by(country)
	egen ac_TB_Y 	= corr(cyc_TB_Y lag_cyc_TB_Y)	, by(country)
	egen ac_N 		= corr(cyc_N lag_cyc_N)			, by(country)
	egen ac_TFP 	= corr(cyc_TFP lag_cyc_TFP)		, by(country)
	egen ac_pc 		= corr(ln_pc lag_pc)			, by(country)
	
//Collapse	
	collapse (mean) corr_Y_Y corr_C_Y corr_I_Y corr_TBY_Y corr_N_Y corr_TFP_Y corr_pc_Y ac_Y ac_C ac_I ac_TB_Y ac_N ac_TFP ac_pc country_cat, by(country)
	
//Adjust variables to display tables	
	gen CountryGroup = ""
	replace CountryGroup = "Emerging" if country_cat==1
	replace CountryGroup = "Developed" if country_cat==2
	
//Compute Excel tables
	//Correlations with GDP
		tabout CountryGroup using "${directory}\OutputForPaper\Table5.csv", append sum c(mean corr_Y_Y mean "corr_TBY_Y" mean corr_C_Y mean corr_I_Y mean corr_N_Y mean corr_TFP_Y mean corr_pc_Y) f(5) style(csv) ptotal(none)
		
	//Autocorrelations
		tabout CountryGroup using "${directory}\OutputForPaper\Table5.csv", append sum c(mean ac_Y mean "ac_TB_Y" mean ac_C mean ac_I  mean ac_N mean ac_TFP mean ac_pc) f(5) style(csv) ptotal(none)

//-----------------------------------------------------------------
//Table 11: Cross-country evidence
//-----------------------------------------------------------------
 
//Load data
    use dataset_processed.dta, clear	
	sort country year
	
//Setup additional variables
	by country: egen sd_Y = sd(cyc_cGDP)
	
//Collapse database across time
	collapse (mean) sd_Y nxGDP_mfct_GDP vashare_commodities vashare_mfct vashare_srvc nxgoods_gdp cGDP_PPP, by(country)	
		
//Additional variables
	gen ln_cgdp = ln(cGDP_PPP)
	gen nxGDP_mfct_GDP_abs= abs(nxGDP_mfct_GDP)

//Label variables
	label variable nxGDP_mfct_GDP_abs "(Abs) Mfct NX/GDP"
	label variable vashare_commodities "VA Commodities/GDP"
	label variable vashare_mfct "VA Mfct/GDP"
	label variable vashare_srvc "VA Non-Tradables/GDP"
	label variable nxgoods_gdp "Agg NX/GDP"
	label variable ln_cgdp "GDP per capita (log)"

//Regressions
	//Column (1)
		regress sd_Y nxGDP_mfct_GDP_abs, beta robust
		estimates store C1, title(Col.1)
		estadd beta, replace
		
	//Column (2)
		regress sd_Y ln_cgdp, beta robust
		estimates store C2, title(Col.2)
		estadd beta, replace
		
	//Column (3)
		regress sd_Y nxGDP_mfct_GDP_abs ln_cgdp, beta robust
		estimates store C3, title(Col.3)
		estadd beta, replace
		
	//Column (4)
		regress sd_Y nxGDP_mfct_GDP_abs vashare_srvc ln_cgdp, beta robust
		estimates store C4, title(Col.4)
		estadd beta, replace
		
	//Column (5)
		regress sd_Y nxGDP_mfct_GDP_abs vashare_commodities vashare_mfct nxgoods_gdp ln_cgdp, beta robust
		estimates store C5, title(Col.5)
		estadd beta, replace
		
	//Table
		estout C1 C2 C3 C4 C5 using "${directory}\OutputForPaper\Table11.xls", cells(beta(fmt(2)) p(fmt(3))) legend label varlabels(_cons Constant) stats(r2 N, fmt(2 0) label(R-sqr Obs)) noabbrev replace 

//-----------------------------------------------------------------


