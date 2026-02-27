//======================================//
//Setup data from the World Bank		//
//======================================//

//Import data from Excel
	import excel using "RawData\rawdata_WB.xlsx", sheet("Data") first clear 

//Cleanup data
	drop if CountryCode==""
	
//Reshape
	reshape long YR, i(CountryCode SeriesCode) j(year) string
	rename YR v_
	
//Cleanup SeriesName
	//Eliminate symbols
		replace SeriesName = subinstr(SeriesName," ","",.)
		replace SeriesName = subinstr(SeriesName,"%","pct",.)
		replace SeriesName = subinstr(SeriesName,"(","",.)
		replace SeriesName = subinstr(SeriesName,")","",.)
		replace SeriesName = subinstr(SeriesName,"US$","USD",.)
		replace SeriesName = subinstr(SeriesName,"$","USD",.)
		replace SeriesName = subinstr(SeriesName,",","",.)
	
	//Set all to lowercase
		replace SeriesName = lower(SeriesName)
	
	//Shorten SeriesName
		replace SeriesName = subinstr(SeriesName,"includingconstruction","",.)
		replace SeriesName = subinstr(SeriesName,"forestryandfishing","",.)
		replace SeriesName = subinstr(SeriesName,"valueadded","va",.)
		replace SeriesName = subinstr(SeriesName,"taxeslesssubsidiesonproducts","nettaxes",.)
		replace SeriesName = subinstr(SeriesName,"grossvalueaddedatbasicprices","",.)
		replace SeriesName = subinstr(SeriesName,"grossvaatbasicprices","",.)	
		replace SeriesName = subinstr(SeriesName,"ofgoodsandservices","",.)	
		
		replace SeriesName = abbrev(SeriesName,30) //Set to max # of characters for variable names
		replace SeriesName = subinstr(SeriesName,"~","",.)
		
//Reshape
	drop SeriesCode
	reshape wide v_, i(CountryCode year) j(SeriesName) string		

//Cleanup
	foreach var of varlist _all {
		replace `var' = "" if `var' ==".."
		destring `var', replace
	}
	
//Rename variables
	rename CountryCode countrycode
	rename CountryName country
	rename v_* *
	
//======================================//
//Merge with PWT 9.0					//
//======================================//	
	
//Sort and merge
	sort countrycode year
	merge 1:1 countrycode year using "RawData\rawdata_pwt90.dta"
	ren _merge _merge_pwt90

//Rename
	ren pop pop_pwt90

//======================================//
//Merge with OECD VA data				//
//======================================//				
		
//Raw data downloaded from OECD's website: Sheet "OECD.Stat export" @ rawdata_OECDVA.xlsx 
//Raw data formatted for Stata: rawdata_OECDVA.dta
		
//Sort and merge
	sort countrycode year
	merge 1:1 countrycode year using "RawData\rawdata_OECDVA.dta"
	ren _merge _merge_OECD_VA
		
//OECD indicator		
	gen OECD_temp = 0
	replace OECD_temp = 1 if _merge_OECD_VA>=2
	bysort country: egen OECD = max(OECD_temp)
	drop OECD_temp

//============================================//
//Merge with data on relative commodity price //
//============================================//	
		
//Raw data downloaded from FRED's website: Sheet "FRED graph" @ rawdata_FRED.xlsx 
//Raw data formatted for Stata: rawdata_FRED.dta
		
sort countrycode year
merge m:1 year using "RawData\rawdata_FRED.dta"
ren _merge _merge_PPIs_FRED
	
//============================================//
//Merge with data on labor across sectors     //
//============================================//	
		
//Raw data downloaded from WB's website: Sheet "Data" @ rawdata_WBlabor.xlsx 
//Raw data formatted for Stata: rawdata_WBlabor.dta
		
sort countrycode year
merge m:1 countrycode year using "RawData\rawdata_WBlabor.dta"
ren _merge _merge_laborWB
	
//======================================//
//General-use variables					//
//======================================//		
	
//Country code
	encode countrycode, g(countrycode_val)
	sort countrycode_val year	
	
//Period
	gen period = year
	
//Population
	ren populationtotal pop
	
//Real GDP (PPP)
	ren gdppppconstant2011internatiou GDP_PPP
	
//Nominal GDP
	ren gdpcurrentusd GDP
	ren gdpcurrentlcu GDP_LCU	
	
//Reorder variables
	order country countrycode year	
	
//======================================//
//Agg. exports, imports, and net exports//
//======================================//	
	
//Rename
	ren merchandiseexportscurrentusd xgoods
	ren merchandiseimportscurrentusd mgoods

	ren exportscurrentusd xtotal
	ren importscurrentusd mtotal	
		
//Net exports 
	gen nxgoods_gdp = (xgoods - mgoods)/GDP
	gen nx_gdp = (xtotal-mtotal)/GDP
		
//======================================//
//Exports and imports decomposition		//
//======================================//	
	
//Rename
	ren agriculturalrawmaterialsexpop xshare_agr
	ren foodexportspctofmerchandiseer xshare_food
	ren fuelexportspctofmerchandiseer xshare_fuel
	ren manufacturesexportspctofmercd xshare_mfct
	ren oresandmetalsexportspctofmern xshare_oremetals
	
	ren agriculturalrawmaterialsimpop mshare_agr
	ren foodimportspctofmerchandiseir mshare_food
	ren fuelimportspctofmerchandiseir mshare_fuel
	ren manufacturesimportspctofmercd mshare_mfct
	ren oresandmetalsimportspctofmern mshare_oremetals	
	
//Cleanup trade shares
	//Set missing values to zero
		replace xshare_agr 			= 0 	if xshare_agr==.
		replace xshare_food 		= 0 	if xshare_food==.
		replace xshare_fuel 		= 0 	if xshare_fuel==.
		replace xshare_mfct 		= 0 	if xshare_mfct==.
		replace xshare_oremetals 	= 0 	if xshare_oremetals==.
		
		replace mshare_agr 			= 0 	if mshare_agr==.
		replace mshare_food 		= 0 	if mshare_food==.
		replace mshare_fuel 		= 0 	if mshare_fuel==.
		replace mshare_mfct 		= 0 	if mshare_mfct==.
		replace mshare_oremetals 	= 0 	if mshare_oremetals==.		
	
	//Sum up shares across sectors
		gen xshare_total = xshare_agr + xshare_food + xshare_fuel + xshare_mfct + xshare_oremetals		
		gen mshare_total = mshare_agr + mshare_food + mshare_fuel + mshare_mfct + mshare_oremetals

	//Cleanup invalid observations
		gen xshare_valid = 1
		replace xshare_valid = 2 if xshare_total==0
		replace xshare_valid = 3 if (xshare_total<90 | xshare_total>110) & xshare_total~=0 
		tab xshare_valid
		
		gen mshare_valid = 1
		replace mshare_valid = 2 if mshare_total==0
		replace mshare_valid = 3 if (mshare_total<90 | mshare_total>110) & mshare_total~=0 
		tab mshare_valid			
		
	//Set values to missing if invalid
		replace xshare_agr 			= . if xshare_valid>1
		replace xshare_food 		= . if xshare_valid>1
		replace xshare_fuel 		= . if xshare_valid>1
		replace xshare_mfct 		= . if xshare_valid>1
		replace xshare_oremetals 	= . if xshare_valid>1	
		replace xshare_total 		= . if xshare_valid>1

		replace mshare_agr 			= . if mshare_valid>1
		replace mshare_food 		= . if mshare_valid>1
		replace mshare_fuel			= . if mshare_valid>1
		replace mshare_mfct 		= . if mshare_valid>1
		replace mshare_oremetals	= . if mshare_valid>1		
		replace mshare_total 		= . if mshare_valid>1			
		
	//Rescale valid observations so that they add up to exactly 100%
		replace xshare_agr 			= xshare_agr/xshare_total
		replace xshare_food 		= xshare_food/xshare_total
		replace xshare_fuel 		= xshare_fuel/xshare_total
		replace xshare_mfct 		= xshare_mfct/xshare_total
		replace xshare_oremetals 	= xshare_oremetals/xshare_total
		
		replace mshare_agr 			= mshare_agr/mshare_total
		replace mshare_food 		= mshare_food/mshare_total
		replace mshare_fuel 		= mshare_fuel/mshare_total
		replace mshare_mfct 		= mshare_mfct/mshare_total
		replace mshare_oremetals 	= mshare_oremetals/mshare_total
		
//Commodity share of exports and imports 
	gen xshare_commodities = xshare_agr + xshare_food + xshare_fuel + xshare_oremetals
	gen mshare_commodities = mshare_agr + mshare_food + mshare_fuel + mshare_oremetals

//Sectoral net exports
	gen nxGDP_commodities_GDP = (xshare_commodities*xgoods - mshare_commodities*mgoods)/GDP
	gen nxGDP_mfct_GDP = (xshare_mfct*xgoods - mshare_mfct*mgoods)/GDP		

//Clean agg. and sectoral NX data
//Restrict attention to country-year pairs with data on the three NX variables used
//Thus, set to missing if any of the other NX variables are missing
	replace nxgoods_gdp 			= . if nxgoods_gdp==. | nxGDP_mfct_GDP==. | nxGDP_commodities_GDP==.
	replace nxGDP_mfct_GDP 			= . if nxgoods_gdp==. | nxGDP_mfct_GDP==. | nxGDP_commodities_GDP==.
	replace nxGDP_commodities_GDP 	= . if nxgoods_gdp==. | nxGDP_mfct_GDP==. | nxGDP_commodities_GDP==.
	
//======================================//
//Value added decomposition				//
//======================================//	

//World Bank data
	//Rename variables to be used
		rename agriculturevacurrentlcu 		WB_VA_agr
		rename industryvacurrentlcu			WB_VA_ind
		rename manufacturingvacurrentlcu 	WB_VA_mfct
		rename servicesvacurrentlcu 		WB_VA_svc
		rename gvacurrentlcu				WB_VA
		
	//Value added shares
		gen WB_VA_sum = WB_VA_agr + WB_VA_ind + WB_VA_svc
		
		gen WB_vashare_agr 	= WB_VA_agr/WB_VA_sum
		gen WB_vashare_ind 	= WB_VA_ind/WB_VA_sum
		gen WB_vashare_mfct = WB_VA_mfct/WB_VA_sum
		gen WB_vashare_srvc = WB_VA_svc/WB_VA_sum
		
//OECD data
	//Create variables to be used	
		gen OECD_VA_agr 	= 1000000*oecd_va_a
		gen OECD_VA_mfct 	= 1000000*oecd_va_c
		gen OECD_VA_ind 	= 1000000*(oecd_va_btoe + oecd_va_f) 
		gen OECD_VA_svc		= 1000000*oecd_va_svc
				
	//Value added shares
		gen OECD_VA_sum = OECD_VA_agr + OECD_VA_ind + OECD_VA_svc
		
		gen OECD_vashare_agr 	= OECD_VA_agr/OECD_VA_sum
		gen OECD_vashare_ind 	= OECD_VA_ind/OECD_VA_sum
		gen OECD_vashare_mfct 	= OECD_VA_mfct/OECD_VA_sum
		gen OECD_vashare_srvc 	= OECD_VA_svc/OECD_VA_sum		
		
//Combined series		
	//Use WB or OECD
		//Use WB data for non-OECD countries
			gen VA_sum = WB_VA_sum if OECD==0
			
			gen vashare_agr 	= WB_vashare_agr 	if OECD==0
			gen vashare_mfct 	= WB_vashare_mfct 	if OECD==0
			gen vashare_ind 	= WB_vashare_ind 	if OECD==0
			gen vashare_srvc 	= WB_vashare_srvc 	if OECD==0	 
		
		//Use OECD data for OECD countries
			replace VA_sum = OECD_VA_sum if OECD==1
			
			replace vashare_agr 	= OECD_vashare_agr 	if OECD==1				
			replace vashare_mfct 	= OECD_vashare_mfct if OECD==1
			replace vashare_ind 	= OECD_vashare_ind 	if OECD==1				
			replace vashare_srvc 	= OECD_vashare_srvc	if OECD==1					
			
	//OECD countries with missing observations: Fill out with WB data
		replace VA_sum = WB_VA_sum if VA_sum==.
		
		replace vashare_agr 	= WB_vashare_agr 	if OECD==1 & vashare_agr==.			
		replace vashare_mfct 	= WB_vashare_mfct 	if OECD==1 & vashare_mfct==.
		replace vashare_ind 	= WB_vashare_ind 	if OECD==1 & vashare_ind==.
		replace vashare_srvc 	= WB_vashare_srvc 	if OECD==1 & vashare_srvc==.
		
//Commodities vs non-commodities
	gen vashare_commodities = vashare_agr + (vashare_ind-vashare_mfct)	

//======================================//
//Business cycle variables				//
//======================================//		

//Rename variables
	rename exportspctofgdp X_GDP
	rename importspctofgdp M_GDP

	rename gdppercapitaconstantlcu 			cGDP_LCU
	rename gdppercapitapppconstant2011ir 	cGDP_PPP
	
	rename grossfixedcapitalformationpcg I_GDP
	rename householdsandnpishsfinalconst C_GDP
	
//Setup variables
	//From World Bank
		gen cC 		= (C_GDP*cGDP_LCU*pop)/pop
		gen cI 		= (I_GDP*cGDP_LCU*pop)/pop
		gen TB_Y 	= (((X_GDP*cGDP_LCU*pop)/pop)-((M_GDP*cGDP_LCU*pop)/pop))/cGDP_LCU	

	//From PWT 9.0
		gen N 	= emp/pop 
		gen TFP = rtfpna //TFP index computed with RGDPna, RKna, labor input data, and LABSH (2005 value = 1 for all countries)
		
	//Logs
		gen ln_cGDP 	= ln(cGDP_LCU)
		gen ln_cC 		= ln(cC)	
		gen ln_cI 		= ln(cI)
		gen ln_N 		= ln(N)
		gen ln_TFP 		= ln(TFP)
		gen ln_pc 		= ln(rel_price_commodities)
		
//======================================//
//Save									//
//======================================//		
	
save dataset.dta, replace	
	
//======================================//		

	
