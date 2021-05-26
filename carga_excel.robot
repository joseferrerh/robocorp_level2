# -*- coding: utf-8 -*-
*** Settings ***
Documentation   Download an Excel file and read the rows.
Library         RPA.Excel.Files
Library         RPA.HTTP
Resource        common.robot

*** Variables ***
${EXCEL_FILE_URL}=  https://github.com/robocorp/example-activities/raw/master/web-store-order-processor/devdata/Data.xlsx
${API_BASE_URL}=           https://api.airtable.com/v0
${API_URL_BDNS}=           /appTLF4I1K4ZhQNX1/BDNS


*** Tasks ***
Read Excel File rows
    Crear Sesion
    Open Workbook   G:\\Mi unidad\\IDR\\202105_convocatorias.xls
    
    ${table}=       Read Worksheet As Table     header=True
    Close Workbook

    FOR     ${row}  IN  @{table}
        Log     ${row}
        Log     ${row}[ID BDNS]
        Log     ${row}[Órgano]
        Log     ${row}[Fecha de registro]
        
        IF  '${row}[Fecha de registro]' != 'Variable'
            ${year}=        Get Substring   ${row}[Fecha de registro]    6    10
            ${month}=       Get Substring   ${row}[Fecha de registro]    3    5
            ${day}=         Get Substring   ${row}[Fecha de registro]    0    2
            ${fecha}        Set Variable    ${year}-${month}-${day}
        ELSE
            ${fecha}        Set Variable    ${EMPTY}
        END

        
        ${resp}     Get Request     airtable    ${API_URL_BDNS}?maxRecords=1&filterByFormula=BDNS%3D${row}[ID BDNS]
        ${jsondata}=    To Json    ${resp.content}
        
        IF  ${jsondata}[records]
            Log     Ya existe la ID BDNS ${row}[ID BDNS]. No hacemos nada con esta.
        ELSE
            &{airtblrow}=       Create Dictionary
            ...           BDNS                  ${row}[ID BDNS]
            ...           Administración        ${row}[Administración]
            ...           Departamento          ${row}[Departamento]
            ...           Órgano                ${row}[Órgano]
            ...           Fecha Registro        ${fecha}
            ...           Título Convocatoria   ${row}[Título de la convocatoria]
            ...           Título Oficial        ${EMPTY}
            ...           InstrumentoAyuda      ${EMPTY}
            ...           TipoConvocatoria      ${EMPTY}
            ...           Presupuesto           ${EMPTY}
            ...           TiposBeneficiarios    ${EMPTY}
            ...           SectoresEconomicos    ${EMPTY}
            ...           Regiones              ${EMPTY}
            ...           Finalidad             ${EMPTY}
            ...           Ficheros              ${EMPTY}
            ...           BB reguladoras        ${row}[BB reguladoras]
            ...           Carga Masiva          1

            ${json}            Convert JSON to String   ${airtblrow}
            ${jsonFilaAir}     Set Variable    {"records":[{"fields":${json}\}\], "typecast": true\}

            Log     ${jsonFilaAir}

            ${datos}=    Convert String to JSON     ${jsonFilaAir}

            Log     Insertar registro
            ${resp}=    Post Request    airtable    ${API_URL_BDNS}    json=${datos}
            Should Be Equal As Strings    ${resp.status_code}    200
            ${jsondata}=    To Json    ${resp.content}
        END
    END
