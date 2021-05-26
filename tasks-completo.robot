# -*- coding: utf-8 -*-
*** Settings ***
Documentation   Recogida de datos de ipyme
Library         RPA.Excel.Files
Library         RPA.Browser.Selenium
Library         String
Library         RPA.HTTP
Resource        keywords.robot


*** Keywords ***
Abrir navegador 
    &{preferences}=
    ...    Create Dictionary
    ...    download.default_directory=c:\\robocorpp\\descargas
    ...    plugins.always_open_pdf_externally=${True}
    ...    restore_on_startup=${False}
    Open available browser  https://buscadorayudas.ipyme.org/BusquedaUltimasAyudasExterno  preferences=${preferences}


*** Keywords ***
Descargar PDF
    Log     Descargando PDF

*** Keywords ***
Recorrer ayudas

    # Try to obtain the list of LI in the right side of the page
    @{ayudas}    Get Web Elements    //*[@id="up"]/main/section/div[3]/ul/li
    
    ${lineNumber}     Set Variable  ${1}
    
    FOR  ${ayuda}   IN  @{ayudas}
        Log     ${ayuda}
        
        # Try to obtain the TITLE of the record
        ${tituloayuda}      Get WebElement    //*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/a/span[2]
        ${tituloayuda}      Get Text          //*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/a/span[2]
        Log  ${tituloayuda} 
        
        # Descarga PDF
        # Click Link   //*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/div/div[3]/a
        # Sleep       5
        
        Click Link   //*[@id="up"]/main/section/div[3]/ul/li[${lineNumber}]/a
        
        # Extraer Datos infoGeneral
        Extraer Datos InfoGeneral   ${lineNumber}
        
        Click Element   //*[@id="btnVolverAlListado"]
        Sleep   1
        #Go Back

        ${lineNumber}    Set Variable    ${lineNumber + 1}
    END
    
    Sleep   1
    Click Element  //*[@id="btSiguiente"]
    Sleep   1


*** Keywords ***
Extraer Datos infoGeneral
    [Arguments]     ${linea}
    
    ${jsonFila}     Set Variable  \{

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

    ${jsonFila}     Set Variable    \[${jsonFila}\}\]
   
    Log     ${jsonFila}
    
    ${jsonobject}   To Json     ${jsonFila}
    Append Rows To Worksheet    ${jsonobject}


*** Keywords ***
Crear Excel
    Create Workbook        datos.xlsx
    Set Worksheet Value    1    1    Referencia
    Set Worksheet Value    1    2    Organismo
    Set Worksheet Value    1    3    Sector
    Set Worksheet Value    1    4    Administración
    Set Worksheet Value    1    5    Ámbito geográfico
    Set Worksheet Value    1    6    Tipo de ayuda
    Set Worksheet Value    1    7    Destinatarios
    Set Worksheet Value    1    8    Plazo de solicitud

*** Keywords ***
Cerrar navegador
    Close Browser
    Save Workbook          ${OUTPUT_DIR}${/}datos.xlsx

*** Tasks ***
Minimal task
    Abrir navegador
    Crear Excel
    ${numeroAyudas}     Get Text    //*[@id="resultadosPagina_Top"]
    Log     ${numeroAyudas}
    FOR     ${pagina}   IN RANGE  1   6
        Recorrer ayudas
    END
    [Teardown]   Cerrar navegador
