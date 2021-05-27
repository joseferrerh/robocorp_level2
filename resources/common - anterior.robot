# -*- coding: utf-8 -*-
*** Settings ***
Documentation   Keywords comunes a las extracciones de iPYME
Resource        api-resources.robot
Library         RPA.JSON
Library         String

*** Variables ***
${SPACEX_API_BASE_URL}=    https://api.airtable.com/v0
${SPACEX_API_LATEST_LAUNCHES}=    /xxxxx/Ayudas%20BDNS
${INSERT_ROW_IPYME}=              /xxxxx/iPyme

*** Keywords ***
Recorrer ayudas

    # Try to obtain the list of LI in the right side of the page
    @{ayudas}    Get Web Elements    //*[@id="up"]/main/section/div[3]/ul/li
    
    ${lineNumber}     Set Variable  ${1}
    
    FOR  ${ayuda}   IN  @{ayudas}
        Log     ${ayuda}
        
        # Try to obtain the TITLE of the record
        #${tituloayuda}      Get WebElement    //*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/a/span[2]
        Sleep       1
        ${tituloayuda}      Get Text          xpath://*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/a/span[2]
        ${tituloayuda}        Replace String  ${tituloayuda}    "   {EMPTY}
        Log  ${tituloayuda} 
        ${finplazo}      Get Text          xpath://*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/div/div[2]/span
        Log  ${finplazo} 
        
        # Descarga PDF
        # Click Link   //*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/div/div[3]/a
        ${url_fichero}        Get Element Attribute        xpath://*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/div/div[3]/a     href
        Log     ${url_fichero}

        # Sleep      5
        
        # Accede a la página de detalles
        Sleep   2
        Click Link   xpath://*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/a
        
        # Extraer Datos infoGeneral
        Extraer Datos InfoGeneral   ${lineNumber}   ${tituloayuda}   ${finplazo}    ${url_fichero}
        
        Click Element   xpath://*[@id="btnVolverAlListado"]
        Sleep   1
        #Go Back

        ${lineNumber}    Set Variable    ${lineNumber + 1}
    END
    
    Sleep   1
    Click Element  //*[@id="btSiguiente"]
    Sleep   1

*** Keywords ***
Crear Excel
    Create Workbook        datos.xlsx
    Set Worksheet Value    1    1    Titulo
    Set Worksheet Value    1    2    Fecha Limite
    Set Worksheet Value    1    3    Fichero PDF
    Set Worksheet Value    1    4    Referencia
    Set Worksheet Value    1    5    Organismo
    Set Worksheet Value    1    6    Sector
    Set Worksheet Value    1    7    Administración
    Set Worksheet Value    1    8    Ámbito geográfico
    Set Worksheet Value    1    9    Tipo de ayuda
    Set Worksheet Value    1   10    Destinatarios
    Set Worksheet Value    1   11    Plazo de solicitud


*** Keywords ***
Cerrar navegador
    Close Browser
    Save Workbook          ${OUTPUT_DIR}${/}datos.xlsx

# +
*** Keywords ***
Extraer Datos infoGeneral
    [Arguments]     ${linea}    ${tituloayuda}   ${finplazo}    ${url_fichero}
    
    # La fecha se captura en formato dd/mm/yyyy los días y meses tienen formato 00
    IF  '${finplazo}' != 'Variable'
        ${year}=    Get Substring   ${finplazo}    6    10
        ${month}=   Get Substring   ${finplazo}    3    5
        ${day}=     Get Substring   ${finplazo}    0    2
        Log     ${year}-${month}-${day}
    ELSE
        ${year}=    Set Variable    2000
        ${month}=   Set Variable    01
        ${day}=     Set Variable    01
    END

    ${jsonFila}     Set Variable  \{"Titulo": "${tituloayuda}", "Fecha Limite": "${year}-${month}-${day}", "Fichero PDF": "${url_fichero}",

    @{infoGeneral}    Get Web Elements    //*[@id="up"]/main/section/div[2]/ul[1]/li
    ${linea}    Set Variable    ${1}
    FOR  ${info}   IN  @{infoGeneral}
        ${campo}        Get Text          //*[@id="up"]/main/section/div[2]/ul[1]/li[${linea}]
        IF  ${linea} == 1
            ${contenido}    Get Text          //*[@id="up"]/main/section/div[2]/ul[1]/li[${linea}]/a
        ELSE
            ${contenido}    Get Text          //*[@id="up"]/main/section/div[2]/ul[1]/li[${linea}]/span
        END
        IF  ${linea} != 1
            ${jsonFila}     Set Variable    ${jsonFila},
        END
        ${campo}        Replace String  ${campo}    :   ": "
        ${jsonFila}     Set Variable    ${jsonFila} "${campo}"
        ${linea}        Set Variable    ${linea + 1}
    END
        
    @{infoGeografica}    Get Web Elements    //*[@id="up"]/main/section/div[2]/ul[2]/li
    ${linea}    Set Variable    ${1}
    FOR  ${info}   IN  @{infoGeografica}
        ${contenido}    Get Text          //*[@id="up"]/main/section/div[2]/ul[2]/li[${linea}]/span
        ${jsonFila}     Set Variable    ${jsonFila},"Ambito Geografico":"${contenido}"
        ${linea}        Set Variable    ${linea + 1}
    END

    @{infoAdicional}    Get Web Elements    //*[@id="up"]/main/section/div[2]/ul[3]/li
    ${linea}    Set Variable    ${1}
    FOR  ${info}   IN  @{infoAdicional}
        ${campo}        Get Text          //*[@id="up"]/main/section/div[2]/ul[3]/li[${linea}]
        ${contenido}    Get Text          //*[@id="up"]/main/section/div[2]/ul[3]/li[${linea}]/span
        ${campo}        Replace String  ${campo}    :   ": "    count=1
        ${jsonFila}     Set Variable    ${jsonFila}, "${campo}"
        ${linea}        Set Variable    ${linea + 1}
    END

    ${jsonFilaExcel}     Set Variable    \[${jsonFila}\}\]
    
    Log     ${jsonFilaExcel}
    
    ${jsonobject}   To Json     ${jsonFilaExcel}
    Append Rows To Worksheet    ${jsonobject}
    
    ${jsonFilaAir}     Set Variable    {"records":[{"fields":${jsonFila}\}\}\], "typecast": true\}
    Log     ${jsonFilaAir}
   
         
    #${datos}=    Convert String to JSON     {"records":[{"fields":{"Titulo": "${tituloayuda}","Fecha Limite": "${year}-${month}-${day}"}}]}
    ${datos}=    Convert String to JSON     ${jsonFilaAir}

    ${resp}=    Post Request    airtable    ${INSERT_ROW_IPYME}    json=${datos}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${jsondata}=    To Json    ${resp.content}
   
    
    
    
