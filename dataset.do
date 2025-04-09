global st = "$S_TIME"
clear all
		set more off
		set rmsg on	
		
		capture log close						
							
		log using read_data_2.txt, text replace
		
		cd "C:\Universidade\UNIVERSIDADE DO NINHO\dissertação" 
clear
import excel using "Data.xlsx", firstrow

tab País ano
sum subsetor
inspect ROA
sum ROA ROE ESG_Score Alavancagem Tamanho E_score S_score G_score, detail
sum, detail
export excel using "Stats_10.xlsx", replace
putexcel A1 = r(mean)A2 = r(Std. Dev.) A3 = r(p25) A4 = r(p50) A5 = r(p75), sheet(Sheet1)

outxlsx using "stats.xlsx", replace sheet("Sheet1")
sum sum ROA ROE ESG_Score Alavancagem Tamanho E_score S_score G_score RDIntensity
outxlsx clear
logout , save(Stats_5) word excel tex : sum ROA ROE ESG_Score Alavancagem Tamanho E_score S_score G_score, detail

sort País ano

by País ano: sum ROA ROE ESG_Score Alavancagem Tamanho E_score S_score G_score

tab subsetor, gen(subsetordummy)
 tab subsetordummy1
 tab subsetordummy2
 tab subsetordummy3
drop O-X
tab subsetor, duplicates drop
 *Decodificando a id para que seja reconhecida como dados em painel
encode Empresa , gen(empresa_id)
*Transformando em dados em painel
xtset empresa_id ano 

reg ROA ESG Alavancagem Tamanho subsetordummy1 subsetordummy2 subsetordummy3
estimates store modelo1
reg ROA  Alavancagem  Tamanho E_score S_score G_score  subsetordummy1 subsetordummy2 subsetordummy3
estimates store modelo2
esttab modelo1 modelo2 using "Reg_roa_ols.rtf"

reg ROE ESG Alavancagem  Tamanho  subsetordummy1 subsetordummy2 subsetordummy3
estimates store modelo3
reg ROE   Alavancagem RDIntensity Tamanho E_score S_score G_score  subsetordummy1 subsetordummy2 subsetordummy3
estimates store modelo4
esttab modelo3 modelo4 using "Reg_roe_ols.rtf", replace



*Regressão efeitos fixos

xtreg ROA ESG Alavancagem Tamanho subsetordummy1 subsetordummy2 subsetordummy3  , fe
estimates store modelo5
xtreg ROA  Alavancagem Tamanho RDIntensity E_score S_score G_score subsetordummy1 subsetordummy2 subsetordummy3  , fe
estimates store modelo6
esttab modelo5 modelo6
esttab modelo5 modelo6 using "REG_ROA_FE.rtf", replace
xtreg ROE ESG Alavancagem Tamanho RDIntensity  subsetordummy1 subsetordummy2 subsetordummy3, fe
estimates store modelo7
xtreg ROE  Alavancagem Tamanho RDIntensity E_score S_score G_score subsetordummy1 subsetordummy2 subsetordummy3, fe
estimates store modelo8
esttab modelo7 modelo8 using "Reg_ROE_FE.rtf", replace

xtreg ROA ESG Alavancagem Tamanho RDIntensity subsetordummy1 subsetordummy2 subsetordummy3 i.ano, fe
xtreg ROE ESG Alavancagem Tamanho RDIntensity  subsetordummy1 subsetordummy2 subsetordummy3 i. ano, fe


xtreg ROA ESG Alavancagem Tamanho RDIntensity E_score S_score G_score subsetordummy1 subsetordummy2 subsetordummy3 i.ano, fe
xtreg ROE ESG Alavancagem Tamanho RDIntensity E_score S_score G_score subsetordummy1 subsetordummy2 subsetordummy3 i.ano, fe


*Regressão efeitos aleatórios
xtreg ROA ESG Alavancagem Tamanho  subsetordummy1 subsetordummy2 subsetordummy3, re
estimates store modelo9
xtreg ROA  Alavancagem Tamanho RDIntensity E_score S_score G_score subsetordummy1 subsetordummy2 subsetordummy3, re
estimates store modelo10
esttab modelo9 modelo10 using "Reg_ROA_RE.rtf", replace
xtreg ROE ESG Alavancagem Tamanho RDIntensity  subsetordummy1 subsetordummy2 subsetordummy3, re
estimates store modelo11
xtreg ROE  Alavancagem Tamanho RDIntensity E_score S_score G_score subsetordummy1 subsetordummy2 subsetordummy3, re
estimates store modelo12
esttab modelo11 modelo12 using "Reg_ROE_RE.rtf", replace
xtreg ROA ESG Alavancagem Tamanho RDIntensity subsetordummy1 subsetordummy2 subsetordummy3 i.ano, re
xtreg ROE ESG Alavancagem Tamanho RDIntensity  subsetordummy1 subsetordummy2 subsetordummy3 i.ano, re



 
xtreg ROA ESG Alavancagem Tamanho RDIntensity E_score S_score G_score subsetordummy1 subsetordummy2 subsetordummy3 i.ano, re
xtreg ROE ESG Alavancagem Tamanho RDIntensity E_score S_score G_score subsetordummy1 subsetordummy2 subsetordummy3 i.ano, re
 
 
 
 
 log using "C:\Universidade\UNIVERSIDADE DO NINHO\dissertação", replace
log close


// Armazenar os coeficientes estimados
matrix b = e(b)

// Exibir a equação da regressão
di "ROA = " ///
    _b[ROA] + ///
    " + (" ///
    _b[ESG_Score]*ESG_Score + ///
    ") + (" ///
    _b[Alavancagem]*Alavancagem + ///
    ") + (" ///
    _b[Tamanho]*Tamanho + ///
    ") + (" ///
    _b[RD_Intensity]*RD_Intensity + ///
    ") + (" ///
    _b[Renewable_Dummy]*Renewable_Dummy + ///
    ") + (" ///
    _b[Non_Renewable_Dummy]*Non_Renewable_Dummy + ///
    ") + (" ///
    _b[Electricity_Dummy]*Electricity_Dummy + ///
    ")"
