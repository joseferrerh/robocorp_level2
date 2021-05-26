# -*- coding: utf-8 -*-
*** Settings ***
Documentation   Recogida de impuestos de información de subvenciones
Library         RPA.Browser.Selenium
Library         RPA.Excel.Files
Library         RPA.PDF
Library         RPA.FileSystem
Resource        common.robot
Resource        api-resources.robot


*** Variables ***
${TXT_OUTPUT_DIRECTORY_PATH}=    ${CURDIR}${/}output${/}
${OUTPUT_DIRECTORY_PATH}=        c:\\robocorpp\\descargas\\

*** Keywords ***
Abrir navegador
    &{preferences}=
    ...    Create Dictionary
    ...    download.default_directory=c:\\robocorpp\\descargas
    ...    plugins.always_open_pdf_externally=${True}
    ...    restore_on_startup=${False}
    Open available browser  https://www.infosubvenciones.es/bdnstrans/GE/es/convocatorias  preferences=${preferences}


*** Keywords ***
Crear Excel
    Create Workbook  datos.xlsx
    #Save Workbook    c:\\Robots\\infosubvenciones\\datos.xlsx
    sleep  5s
    Set Worksheet Value    1    1    BDNS
    Set Worksheet Value    1    2    Administración
    Set Worksheet Value    1    3    Departamento
    Set Worksheet Value    1    4    Órgano
    Set Worksheet Value    1    5    Fecha Registro
    Set Worksheet Value    1    6    Título Convocatoria
    Set Worksheet Value    1    7    Título Oficial
    Set Worksheet Value    1    8    InstrumentoAyuda
    Set Worksheet Value    1    9    TipoConvocatoria
    Set Worksheet Value    1    10   Presupuesto
    Set Worksheet Value    1    11   TiposBeneficiarios
    Set Worksheet Value    1    12   SectoresEconomicos
    Set Worksheet Value    1    13   Regiones
    Set Worksheet Value    1    14   Finalidad
    Set Worksheet Value    1    15   Ficheros



*** Keywords ***
Variable  
    [Arguments]  ${fila}
    ${fila}  Set Variable  ${fila-50}
    Click Element  xpath: /html[1]/body[1]/article[1]/section[1]/div[3]/div[1]/div[5]/div[1]/table[1]/tbody[1]/tr[1]/td[2]/table[1]/tbody[1]/tr[1]/td[6]/span[1]
    Sleep  5s

# +
*** Keywords ***
Extraer Datos Convocatoria
    [Arguments]  ${row}
    
    Switch Window   locator=NEW
    Sleep   2
    
    ${row.InstrumentoAyuda}   Get Text      xpath:/html/body/article/section[1]/div[2]/div[3]/div/div/ul/li
    ${row.TipoConvocatoria}   Get Text      xpath:/html/body/article/section[1]/div[2]/div[4]/div/p
    ${row.Presupuesto}        Get Text      xpath:/html/body/article/section[1]/div[2]/div[5]/div/p
    
    ${row.Finalidad}          Get Text      xpath:/html/body/article/section[1]/div[5]/div[4]/div/p

    ${row.TiposBeneficiarios}   Set Variable    
    ${row.SectoresEconomicos}   Set Variable    
    ${row.Regiones}             Set Variable    



    # Obtener Tipos de beneficiario elegibles
    @{records}    Get Web Elements    xpath:/html/body/article/section[1]/div[5]/div[1]/div/div/ul/li
    ${linea}                    Set Variable    ${1}
    ${row.TiposBeneficiarios}   Set Variable    
    FOR  ${record}   IN  @{records}
        ${campo}        Get Text        xpath:/html/body/article/section[1]/div[5]/div[1]/div/div/ul/li[${linea}]
        IF  ${linea} != 1
            ${row.TiposBeneficiarios}   Set Variable   ${row.TiposBeneficiarios}, 
        END
        ${row.TiposBeneficiarios}   Set Variable   ${row.TiposBeneficiarios} ${campo}
        ${linea}                    Set Variable   ${linea + 1}
    END
    Log     ${row.TiposBeneficiarios}

    # Obtener Sector económico del beneficiario
    @{records}    Get Web Elements    xpath:/html/body/article/section[1]/div[5]/div[2]/div/div/ul/li
    ${linea}    Set Variable    ${1}
    FOR  ${record}   IN  @{records}
        ${campo}        Get Text        xpath:/html/body/article/section[1]/div[5]/div[2]/div/div/ul/li[${linea}]
        ${campo}        Replace String  ${campo}    ,   ;
        IF  ${linea} != 1
            ${row.SectoresEconomicos}   Set Variable   ${row.SectoresEconomicos},  
        END
        ${row.SectoresEconomicos}   Set Variable   ${row.SectoresEconomicos} ${campo}
        ${linea}                    Set Variable    ${linea + 1}
    END

    # Obtener Regiones
    @{records}    Get Web Elements    xpath:/html/body/article/section[1]/div[5]/div[3]/div/div/ul/li
    ${linea}    Set Variable    ${1}
    FOR  ${record}   IN  @{records}
        ${campo}        Get Text        xpath:/html/body/article/section[1]/div[5]/div[3]/div/div/ul/li[${linea}]
        IF  ${linea} != 1
            ${row.Regiones}   Set Variable   ${row.Regiones}, 
        END
        ${row.Regiones}     Set Variable   ${row.Regiones} ${campo}
        ${linea}            Set Variable   ${linea + 1}
    END
    
    # Obtener Ficheros
    IF  ${row.BDNS} != 563876 
        @{records}    Get Web Elements    xpath:/html/body/article/section[2]/div/div/div[3]/div[3]/div/table/tbody/tr
        ${linea}    Set Variable    ${1}
        FOR  ${record}   IN  @{records}
            IF  ${linea} > 1
                ${campo}        Get Text        xpath:/html/body/article/section[2]/div/div/div[3]/div[3]/div/table/tbody/tr[${linea}]/td[4]
                Log     ${campo}
                                  
                Sleep   1
                Click Element   xpath:/html/body/article/section[2]/div/div/div[3]/div[3]/div/table/tbody/tr[${linea}]/td[4]/a
                Sleep   1

                ${url_fichero}        Get Element Attribute        xpath:/html/body/article/section[2]/div/div/div[3]/div[3]/div/table/tbody/tr[${linea}]/td[4]/a     href
                Log     ${url_fichero}
            
                # Extract text from PDF file into a text file     ${campo}
                # Sleep   8
            
                ${row.Ficheros}   Set Variable   ${row.Ficheros} | 

                ${row.Ficheros}     Set Variable   ${row.Ficheros} ${url_fichero}
           
            END
            ${linea}            Set Variable   ${linea + 1}
        END
    END
    
    ${row.InicioSolicitud}  Get Text    xpath:/html/body/article/section[1]/div[9]/div[2]/div/div/p
    IF  '${row.InicioSolicitud}' != '${EMPTY}'
        ${year}=                Get Substring   ${row.InicioSolicitud}    6    10
        ${month}=               Get Substring   ${row.InicioSolicitud}    3    5
        ${day}=                 Get Substring   ${row.InicioSolicitud}    0    2
        ${row.InicioSolicitud}  Set Variable    ${year}-${month}-${day}
    ELSE
        ${row.InicioSolicitud}     Set Variable    ${EMPTY}
    END

    ${row.FinSolicitud}     Get Text    xpath:/html/body/article/section[1]/div[9]/div[3]/div/div/p
    IF  '${row.FinSolicitud}' != '${EMPTY}'
        ${year}=                Get Substring   ${row.FinSolicitud}    6    10
        ${month}=               Get Substring   ${row.FinSolicitud}    3    5
        ${day}=                 Get Substring   ${row.FinSolicitud}    0    2
        ${row.FinSolicitud}     Set Variable    ${year}-${month}-${day}
    ELSE
        ${row.FinSolicitud}     Set Variable    ${EMPTY}
    END
    
    Close Window
    Switch Window   locator=MAIN
    
    
# -

*** Keywords ***
Extract text from PDF file into a text file
    [Arguments]    ${pdf_file_name}
    ${text}=    Get Text From Pdf    ${OUTPUT_DIRECTORY_PATH}${pdf_file_name}
    Create File    ${OUTPUT_DIRECTORY_PATH}${pdf_file_name}.txt
    FOR    ${page}    IN    @{text.keys()}
        Append To File
        ...    ${OUTPUT_DIRECTORY_PATH}${pdf_file_name}.txt
        ...    ${text[${page}]}
    END

*** Keywords ***
Recorrer Ayudas
    Wait Until Element Contains    //div[@id='jqgh_grid_id']    Código BDNS
    
    ${id}     Set Variable  ${1}
    ${fila}   Set Variable  ${2}
    ${vacio}  Set Variable

    FOR   ${convocatoria}  IN RANGE  1  51
      
      Log  ${id}
      Log  ${fila}

      ${BDNS}=             Get Text  xpath://*[@id="${convocatoria}"]/td[1]
      ${administracion}=   Get Text  xpath://*[@id="${convocatoria}"]/td[2]
      ${departamento}=     Get Text  xpath://*[@id="${convocatoria}"]/td[3]
      ${organo}=           Get Text  xpath://*[@id="${convocatoria}"]/td[4]
      ${fechaRegistro}=    Get Text  xpath://*[@id="${convocatoria}"]/td[5]
      ${tituloConvocat}=   Get Text  xpath://*[@id="${convocatoria}"]/td[6]
      ${tituloOficial}=    Get Text  xpath://*[@id="${convocatoria}"]/td[7]
      
      IF  '${fechaRegistro}' != '${EMPTY}'
            ${year}=            Get Substring   ${fechaRegistro}    6    10
            ${month}=           Get Substring   ${fechaRegistro}    3    5
            ${day}=             Get Substring   ${fechaRegistro}    0    2
            ${fechaRegistro}    Set Variable    ${year}-${month}-${day}
      ELSE
            ${fechaRegistro}     Set Variable    ${EMPTY}
      END

      
      ${id}  Set Variable  ${id + 1}
      ${fila}  Set Variable  ${fila + 1}
      
      &{row}=       Create Dictionary
        ...           BDNS                  ${BDNS}
        ...           Administración        ${administracion}
        ...           Departamento          ${departamento}
        ...           Órgano                ${organo}
        ...           Fecha Registro        ${fechaRegistro}
        ...           Título Convocatoria   ${tituloConvocat}
        ...           Título Oficial        ${tituloOficial}
        ...           InstrumentoAyuda      ${vacio}
        ...           TipoConvocatoria      ${vacio}
        ...           Presupuesto           ${EMPTY}
        ...           TiposBeneficiarios    ${EMPTY}
        ...           SectoresEconomicos    ${EMPTY}
        ...           Regiones              ${EMPTY}
        ...           Finalidad             ${EMPTY}
        ...           InicioSolicitud       ${EMPTY}
        ...           FinSolicitud          ${EMPTY}
        ...           Ficheros              ${EMPTY}
        
      Click Element   xpath://*[@id="${convocatoria}"]/td[1]/a
     
      Log   ${row.Administración}
      #Log   ${row.InstrumentoAyuda}
      
      ${row.InstrumentoAyuda}      Set Variable    Instrumento Ayuda
      Log   ${row.InstrumentoAyuda}    
      
      Extraer Datos Convocatoria    ${row}
      Log   ${row.InstrumentoAyuda}    
      Log   ${row}

      Append Rows to Worksheet  ${row}  header=${TRUE}
   
      ${json}            Convert JSON to String   ${row}
      
     
      ${resp}     Get Request     airtable    ${API_URL_BDNS}?maxRecords=1&filterByFormula=BDNS%3D${row.BDNS}

      Log     ${resp} 
      Log     ${resp.content} 
      ${jsondata}=    To Json    ${resp.content}
      Log     ${jsondata}
      Log     ${jsondata}[records]
        
      IF  ${jsondata}[records]
          ${jsonFilaAir}     Set Variable    {"fields":${json}, "typecast": true\}
          ${datos}=    Convert String to JSON     ${jsonFilaAir}
          Log     ${jsondata}[records][0][id]
          Log     Ya existe la referencia ${row.BDNS}. No insertamos.
          ${resp}=    Patch Request    airtable    ${API_URL_BDNS}/${jsondata}[records][0][id]    json=${datos}
          Should Be Equal As Strings    ${resp.status_code}    200
          ${jsondata}=    To Json    ${resp.content}
      ELSE
          ${jsonFilaAir}     Set Variable    {"records":[{"fields":${json}\}\], "typecast": true\}
          ${datos}=    Convert String to JSON     ${jsonFilaAir}

          Log     Insertar registro
          ${resp}=    Post Request    airtable    ${API_URL_BDNS}    json=${datos}
          Should Be Equal As Strings    ${resp.status_code}    200
          ${jsondata}=    To Json    ${resp.content}
      END
  
      # Run Keyword If  ${id-1}%50 == 0
      # ...      Variable  ${fila}
      
    END
    
    Click Element   //*[@id="next_pager"]/span
    Sleep   3

*** Keywords ***
Cerrar navegador
    Save Workbook    datos.xlsx 
    Close Browser

*** Tasks ***
Subvenciones
    Crear Sesion
    Abrir navegador
    Input Text  xpath://*[@id="fecDesde"]   15/05/2021
    Input Text  xpath://*[@id="fecHasta"]   16/05/2021
    Click Element  //*[@id="buscarConvocatoriaTO"]/div[9]/ul/li[1]/button
    Crear Excel
    Sleep   5
    
    ${numeroAyudas}     Get Text    //*[@id="pager_right"]/div
    ${numeroPaginas}    Get Text    //*[@id="sp_1_pager"]
    Log     ${numeroPaginas}

    FOR     ${pagina}   IN RANGE  ${numeroPaginas}
        Recorrer Ayudas
    END

    [Teardown]  Cerrar navegador
