//-----------------------------------------------------------------
//Table 2: Predetermined parameters
//-----------------------------------------------------------------

clear

// Input all parameters in one block
input str30 Parameter str15 Symbol double Value str50 Source
"Discount factor" "beta" 0.98 "Aguiar and Gopinath (2007)"
"Risk aversion" "gamma" 2.0 "Aguiar and Gopinath (2007)"
"Labor supply elasticity" "nu" 1.455 "Schmitt-Grohé and Uribe (2018)"
"Elasticity of subst. (T vs NT)" "sigma" 0.5 "See Section IV.A"
"Elasticity of subst. (C vs M)" "sigma_tau" 1.0 "See Section IV.A"
"Capital share (Non-tradables)" "theta_n" 0.25 "Schmitt-Grohé and Uribe (2018)"
"Capital share (Tradables)" "theta_m" 0.35 "Schmitt-Grohé and Uribe (2018)"
"Decreasing returns to scale" "mu" 0.85 "See Section IV.A"
"Debt elasticity of interest rate" "psi_r" 0.001 "See Section IV.A"
"World interest rate" "r_star" 0.02 "1/beta - 1"
"Depreciation rate" "delta" 0.05 "Aguiar and Gopinath (2007)"
"" "" . "" ""  // Empty row for section separator
"Persistence of relative price" "rho_c" 0.957 "See Section IV.A"
"Volatility of relative price" "sigma_c" 0.059 "See Section IV.A"
end

// Create panel indicator
gen Panel = ""
replace Panel = "Structural parameters" in 1/11
replace Panel = "Price process" in 13/14

// Order variables
order Panel Parameter Symbol Value Source

// Format display
format Value %9.3f

// Display table
list Parameter Symbol Value Source if !missing(Parameter), sepby(Panel) noobs

// Export to CSV - use correct path to CrossCountry OutputForPaper folder
cd "..\CrossCountry"
outsheet using "OutputForPaper\Table2_PredeterminedParameters.csv" if !missing(Parameter), replace comma names

display "Table 2 generated successfully!"
display "File created: Table2_PredeterminedParameters.csv"
