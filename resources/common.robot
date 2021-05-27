# -*- coding: utf-8 -*-
*** Settings ***
Documentation   Keywords comunes a las extracciones de iPYME
Resource        api-resources.robot
Library         RPA.JSON
Library         String
Library         Paginas

*** Variables ***
${API_BASE_URL}=           https://api.airtable.com/v0
${API_URL_BDNS}=           /xxxxxx/BDNS
${API_URL_DOCS}=           /xxxxxx/Documentos
${API_URL_IPYME}=          /xxxxxx/iPyme

*** Keywords ***
Recorrer ayudas

    # Try to obtain the list of LI in the right side of the page
    @{ayudas}    Get Web Elements    //*[@id="up"]/main/section/div[3]/ul/li
    
    ${lineNumber}     Set Variable  ${1}
    
    FOR  ${ayuda}   IN  @{ayudas}

        Wait Until Page Contains Element         //*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/div/div[3]/a     3
        Sleep   0.5
        ${enlace}    Run Keyword And Ignore Error    Get Element Attribute       //*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/div/div[3]/a     href
        IF  '${enlace}[0]' == 'PASS'
            ${idAyuda}   get idAyuda     ${enlace}[1]
        ELSE
            ${enlace}    Run Keyword And Ignore Error    Get Element Attribute       //*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/div/div[3]/a     href
            ${idAyuda}   get idAyuda     ${enlace}[1]
        END
        

        ${resp}     Get Request     airtable    ${API_URL_IPYME}?maxRecords=1&filterByFormula=Referencia%3D${idAyuda}
        ${jsondata}=    To Json    ${resp.content}
        
        IF  ${jsondata}[records]
            Log     Ya existe la referencia ${idAyuda}. No hacemos nada con esta.
        ELSE
            ${finplazo}      Get Text          xpath://*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/div/div[2]/span
            # La fecha se captura en formato dd/mm/yyyy los días y meses tienen formato 00
            IF  '${finplazo}' != 'Variable'
                ${year}=        Get Substring   ${finplazo}    6    10
                ${month}=       Get Substring   ${finplazo}    3    5
                ${day}=         Get Substring   ${finplazo}    0    2
                ${finplazo}     Set Variable    ${year}-${month}-${day}
            ELSE
                ${finplazo}     Set Variable    ${EMPTY}
            END

            ${tituloAyuda}      Get Text          xpath://li[${lineNumber}]/a/span[contains(@class,"tituloAyuda")]

            ${ambitoGeogr}      Get Text          xpath://li[${lineNumber}]/div/div/span[contains(@class,"dgip-ambito")]


            # Obtener URL de descarga PDF
            # Click Link   //*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/div/div[3]/a
            ${url_fichero}        Get Element Attribute        xpath://*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/div/div[3]/a     href

            &{row}=       Create Dictionary
            ...             Referencia              ${idAyuda}
            ...             Titulo                  ${tituloAyuda}
            ...             Organismo               ${EMPTY}        
            ...             Sector                  ${EMPTY}          
            ...             Administración          ${EMPTY}                
            ...             AmbitoGeográfico        ${ambitoGeogr}
            ...             TipoAyuda               ${EMPTY}
            ...             Destinatarios           ${EMPTY}
            ...             PlazoSolicitud          ${EMPTY}
            ...             FechaLímite             ${finplazo}
            ...             FicheroPDF              ${url_fichero}

            # Sleep      5

            # Accede a la página de detalles
            #Click Link   xpath://*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/a
            #Sleep   2
            
            # Obtain the TITLE of the record
            #${tituloayuda}      Get Text          xpath://*[@id="up"]/main/section/div[2]/p[2]
            # Quitar comillas del título
            #${row.Titulo}       Replace String  ${tituloayuda}    "   {EMPTY}

            #Sleep   0.5

            # Extraer Datos infoGeneral
            #Extraer Datos InfoGeneral   ${row}

            #Click Element   xpath://*[@id="btnVolverAlListado"]
            #Sleep   1

            Log     ${idAyuda} ${tituloAyuda} ${ambitoGeogr} ${finplazo} ${url_fichero}

            Append Rows To Worksheet    ${row}
            ${json}            Convert JSON to String   ${row}
            ${jsonFilaAir}     Set Variable    {"records":[{"fields":${json}\}\], "typecast": true\}

            Log     ${jsonFilaAir}

            ${datos}=    Convert String to JSON     ${jsonFilaAir}

            Log     Insertar registro
            ${resp}=    Post Request    airtable    ${API_URL_IPYME}    json=${datos}
            Should Be Equal As Strings    ${resp.status_code}    200
            ${jsondata}=    To Json    ${resp.content}
        
        END

        ${lineNumber}    Set Variable    ${lineNumber + 1}
    END
    
    # Wait Until Page Contains Element     //*[@id="btSiguiente"]
    Sleep   2
    Click Element  //*[@id="btSiguiente"]
    Sleep   1

*** Keywords ***
Crear Excel
    Create Workbook        datos.xlsx
    Set Worksheet Value    1    1    Referencia
    Set Worksheet Value    1    2    Titulo
    Set Worksheet Value    1    3    Organismo
    Set Worksheet Value    1    4    Sector
    Set Worksheet Value    1    5    Administración
    Set Worksheet Value    1    6    AmbitoGeográfico
    Set Worksheet Value    1    7    TipoAyuda
    Set Worksheet Value    1    8    Destinatarios
    Set Worksheet Value    1    9    PlazoSolicitud
    Set Worksheet Value    1   10    FechaLímite
    Set Worksheet Value    1   11    FicheroPDF


*** Keywords ***
Cerrar navegador
    Close Browser
    Save Workbook          ${OUTPUT_DIR}${/}datos.xlsx

*** Keywords ***
Extraer Datos infoGeneral
    [Arguments]     ${row}
    
    ${row.Referencia}       Get Text          //*[@id="up"]/main/section/div[2]/ul[1]/li[1]/a
    ${row.Organismo}        Get Text          //*[@id="up"]/main/section/div[2]/ul[1]/li[2]/span
    ${row.Sector}           Get Text          //*[@id="up"]/main/section/div[2]/ul[1]/li[3]/span
    ${row.Administración}   Get Text          //*[@id="up"]/main/section/div[2]/ul[1]/li[4]/span
    
    ${row.AmbitoGeográfico}     Get Text      //*[@id="up"]/main/section/div[2]/ul[2]/li[1]/span
    
    ${row.TipoAyuda}        Get Text      //*[@id="up"]/main/section/div[2]/ul[3]/li[1]/span
    ${row.Destinatarios}    Get Text      //*[@id="up"]/main/section/div[2]/ul[3]/li[2]/span
    ${row.PlazoSolicitud}   Get Text      //*[@id="up"]/main/section/div[2]/ul[3]/li[3]/span
    
    [Return]    ${row}

