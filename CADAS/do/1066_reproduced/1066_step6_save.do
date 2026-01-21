********************************************************************************
* STEP 6: SAVE OUTPUT
* Keep relevant variables and save to 1066.dta and excel/1066.xlsx
********************************************************************************

display _newline(1)
display "--------------------------------------------------------------------------------"
display "STEP 6: Saving output..."
display "--------------------------------------------------------------------------------"

*-------------------------------------------------------------------------------
* KEEP RELEVANT VARIABLES
*-------------------------------------------------------------------------------

keep pid relscore cogscore nametot count animals_diss animals animtot ///
     wordtot1 wordtot2 paper papertot c_66a c_66b c_66c c_66d c_66e c_66f story ///
     storytot pencil watch chair shoes knuckle elbow should bridge hammer ///
     pray chemist repeat town street store address month day year nod point ///
     circle circle_diss pentag pentag_diss pentag_strict chief longmem season c_11 c_12 ///
     c_13 wordimm c_21 c_22 c_23 worddel miss1 miss3 misstot activ mental memory put ///
     kept frdname famname convers wordfind wordwrg past lastsee lastday ///
     orient lostout lostin chores hobby money change reason feed dress ///
     toilet recall dem1066_score dem1066 dem1066_score_quint dem1066_quint immed ///
     learn1 learn2 learn3

*-------------------------------------------------------------------------------
* ORDER VARIABLES
*-------------------------------------------------------------------------------

order pid relscore cogscore nametot count animals_diss animals animtot ///
      wordtot1 wordtot2 paper papertot c_66a c_66b c_66c c_66d c_66e c_66f story ///
      storytot pencil watch chair shoes knuckle elbow should bridge hammer ///
      pray chemist repeat town street store address month day year nod point ///
      circle circle_diss pentag pentag_diss pentag_strict chief longmem season c_11 c_12 ///
      c_13 wordimm c_21 c_22 c_23 worddel miss1 miss3 misstot activ mental memory put ///
      kept frdname famname convers wordfind wordwrg past lastsee lastday ///
      orient lostout lostin chores hobby money change reason feed dress ///
      toilet recall dem1066_score dem1066 dem1066_score_quint dem1066_quint immed ///
      learn1 learn2 learn3

*-------------------------------------------------------------------------------
* EXPORT TO EXCEL
*-------------------------------------------------------------------------------

capture mkdir excel
export excel using "excel/1066.xlsx", replace firstrow(variables)

*-------------------------------------------------------------------------------
* SAVE STATA FILE
*-------------------------------------------------------------------------------

save 1066.dta, replace

*-------------------------------------------------------------------------------
* EXPORT CASES WITH MISSING ALGORITHM VARIABLES
*-------------------------------------------------------------------------------

* Create diagnostics folder if it doesn't exist
capture mkdir "1066_diagnostics"

* Google Drive path for diagnostics
if $country == 1 {
    if `"$language"' == "E" {
        local gdrive_path "/Users/chrissoria/Google Drive/other computers/My Laptop (1)/documents/cadas/data/CADAS data upload/Rep Dom/latest_data/TRANSLATED/1066_DIAGNOSTIC_EXCELS"
    }
    else {
        local gdrive_path "/Users/chrissoria/Google Drive/other computers/My Laptop (1)/documents/cadas/data/CADAS data upload/Rep Dom/latest_data/1066_DIAGNOSTIC_EXCELS"
    }
}
else if $country == 2 {
    if `"$language"' == "E" {
        local gdrive_path "/Users/chrissoria/Google Drive/other computers/My Laptop (1)/documents/cadas/data/CADAS data upload/cuba/latest_data/TRANSLATED/1066_DIAGNOSTIC_EXCELS"
    }
    else {
        local gdrive_path "/Users/chrissoria/Google Drive/other computers/My Laptop (1)/documents/cadas/data/CADAS data upload/cuba/latest_data/1066_DIAGNOSTIC_EXCELS"
    }
}
capture mkdir "`gdrive_path'"

preserve

* Count and display cases missing dem1066 classification
quietly count if missing(dem1066)
local n_missing = r(N)
display _newline(1)
display "Cases with missing dem1066 classification: `n_missing'"

* Keep only cases with missing dem1066
keep if missing(dem1066)

if _N > 0 {
    * Keep only pid for merge
    keep pid

    * Save pid list to tempfile
    tempfile missing_pids
    save `missing_pids', replace

    * Create deduplicated tempfile from cog.dta
    use "$data_path/cog.dta", clear
    bysort pid: keep if _n == 1
    tempfile cog_unique
    save `cog_unique', replace

    * Create deduplicated tempfile from cog_scoring.dta
    use "$data_path/cog_scoring.dta", clear
    bysort pid: keep if _n == 1
    tempfile cog_scoring_unique
    save `cog_scoring_unique', replace

    * Create deduplicated tempfile from infor.dta
    use "$data_path/infor.dta", clear
    bysort pid: keep if _n == 1
    tempfile infor_unique
    save `infor_unique', replace

    * Reload pid list and merge
    use `missing_pids', clear

    * Merge with deduplicated cog.dta to get original cognitive variables
    merge 1:1 pid using `cog_unique', keepusing( ///
        globalrecordid ///
        c_0 c_65 ///
        c_24 c_25 c_48 c_49 c_50 c_51 c_52 c_53 c_54 c_55 c_56 ///
        c_26 c_8 c_61 c_62 ///
        c_72_1 ///
        c_11 c_12 c_13 c_21 c_22 c_23 ///
        c_27 c_28 c_29 ///
        c_66a c_66b c_66c c_66d c_66e c_66f ///
        c_1 c_3 c_5 ///
        c_70_p c_70_d_c c_69_p c_69_c c_69_d c_2_p_c c_2_d ///
        c_32 c_40 ///
    ) keep(match) nogen
    rename globalrecordid cog_recordid

    * Merge with cog_scoring.dta to get scoring variables
    merge 1:1 pid using `cog_scoring_unique', keepusing( ///
        globalrecordid cs_72_1 cs_32_cleaned cs_40 ///
    ) keep(match) nogen
    rename globalrecordid cogscoring_recordid

    * Merge with infor.dta to get informant variables
    merge 1:1 pid using `infor_unique', keepusing( ///
        i_a2 i_a3 i_a4 ///
    ) keep(match) nogen

    * Rename variables to Spanish descriptive names (verified against source labels)
    capture rename c_0 recuerdo_nombre_entrevistador
    capture rename c_65 recuerdo_nombre_diferido
    capture rename c_24 nombrar_lapiz
    capture rename c_25 nombrar_reloj
    capture rename c_48 nombrar_silla
    capture rename c_49 nombrar_zapatos
    capture rename c_50 nombrar_nudillo
    capture rename c_51 nombrar_codo
    capture rename c_52 nombrar_hombro
    capture rename c_53 definir_puente
    capture rename c_54 uso_martillo
    capture rename c_55 que_hacen_iglesia
    capture rename c_56 donde_comprar_medicinas
    capture rename c_26 repeticion_frase
    capture rename c_8 orientacion_pueblo
    capture rename c_1 orientacion_ano
    capture rename c_3 orientacion_mes
    capture rename c_5 orientacion_dia
    capture rename c_70_p nombrar_gobernador
    capture rename c_70_d_c nombrar_presidente
    capture rename c_69_p memoria_descubridor_PR
    capture rename c_69_c memoria_apostol_cuba
    capture rename c_69_d memoria_padres_patria_RD
    capture rename c_2_p_c orientacion_estacion
    capture rename c_2_d orientacion_temporada
    capture rename i_a2 informante_verifica_calles
    capture rename i_a3 informante_verifica_tienda
    capture rename i_a4 informante_verifica_direccion
    capture rename c_61 comando_mover_cabeza_si
    capture rename c_62 comando_apuntar_ventana_puerta
    capture rename c_72_1 dibujo_circulo
    capture rename cs_72_1 dibujo_circulo_score
    capture rename c_32 dibujo_pentagono
    capture rename cs_32_cleaned dibujo_pentagono_score
    capture rename c_40 fluidez_animales_intento
    capture rename cs_40 fluidez_animales_conteo
    capture rename c_11 recuerdo_inmediato_barco
    capture rename c_12 recuerdo_inmediato_casa
    capture rename c_13 recuerdo_inmediato_pescado
    capture rename c_21 recuerdo_diferido_barco
    capture rename c_22 recuerdo_diferido_casa
    capture rename c_23 recuerdo_diferido_pescado
    capture rename c_27 papel_mano_derecha
    capture rename c_28 papel_doblar_mitad
    capture rename c_29 papel_colocar_piernas
    capture rename c_66a historia_tres_ninos
    capture rename c_66b historia_casa_incendio
    capture rename c_66c historia_hombre_valiente
    capture rename c_66d historia_saco_ninos
    capture rename c_66e historia_heridas_pequenas
    capture rename c_66f historia_todos_bien

    * Export to local diagnostics folder
    export delimited using "1066_diagnostics/1066_missing_cogscore_cases.csv", replace

    * Also copy to Google Drive
    capture export delimited using "`gdrive_path'/1066_missing_cogscore_cases.csv", replace

    display "Missing cogscore cases exported to:"
    display "  - 1066_diagnostics/1066_missing_cogscore_cases.csv"
    display "  - Google Drive: 1066_DIAGNOSTIC_EXCELS/"
}
else {
    display "No cases with missing cogscore components."
}

restore

display _newline(1)
display "STEP 6 complete: Data saved."
display "  - 1066.dta"
display "  - excel/1066.xlsx"
display "  - 1066_diagnostics/1066_missing_cogscore_cases.csv"
display "  - Google Drive: 1066_DIAGNOSTIC_EXCELS/1066_missing_cogscore_cases.csv"
display "--------------------------------------------------------------------------------"
