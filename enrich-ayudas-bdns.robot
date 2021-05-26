# -*- coding: utf-8 -*-
*** Settings ***
Documentation   Recogida de datos de ipyme
Library         RPA.Excel.Files
Library         RPA.Browser.Selenium
Library         String
Library         RPA.HTTP
Resource        common.robot
Library         Paginas

*** Keywords ***
Abrir navegador 
    &{preferences}=
    ...    Create Dictionary
    ...    download.default_directory=c:\\robocorpp\\descargas
    ...    plugins.always_open_pdf_externally=${True}
    ...    restore_on_startup=${False}
    Open available browser  https://www.infosubvenciones.es/bdnstrans/GE/es/convocatorias  preferences=${preferences}


*** Keywords ***
Buscar Ayudas
    Click Element       xpath://*[@id="btnEnPlazo"]/label/span
    Sleep   2
    Click Element       xpath://*[@id="btnBuscar"]
    Sleep   5

*** Keywords ***
Extraer Datos Convocatoria BDNS
    [Arguments]  ${row}
    
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
    
    
    # Close Window
    # Switch Window   locator=MAIN

*** Tasks ***
Minimal task
    Crear Sesion
    Abrir navegador
    Sleep   10
    Click Element   xpath://*[@id="buscarConvocatoriaTO"]/div[9]/ul/li[1]/button
    Sleep   5
    Click Element   xpath://*[@id="1"]/td[1]/a
    Switch Window   NEW
    
    FOR  ${x}   IN RANGE    38
        ${resp}     Get Request     airtable    ${API_URL_BDNS}?maxRecords=100&filterByFormula=%28%7BinstrumentoAyuda%7D%20%3D%20%27%27%29&fields%5B%5D=BDNS&sort%5B0%5D%5Bfield%5D=BDNS

        ${jsondata}=    To Json    ${resp.content}

        Log  ${resp}
        
        ${first_record_id}=    Get value from JSON    ${jsondata}    $.records[0].id
        Log  ${first_record_id}

        @{all_ids}=    Get values from JSON    ${jsondata}    $..id
        Log Many  ${all_ids}
        Log Many  @{all_ids}

        @{all_refs}=    Get values from JSON    ${jsondata}    $..BDNS
        Log Many  ${all_refs}
        Log Many  @{all_refs}.length

        ${contador}     Get Length   ${all_refs}
    
        FOR  ${i}    IN RANGE  ${contador}
            Log  ${all_refs[${i}]}
            Log  ${all_ids[${i}]}
            # Open available browser  https://www.infosubvenciones.es/bdnstrans/GE/es/convocatoria/${all_refs[${i}]}
            Go To   https://www.infosubvenciones.es/bdnstrans/GE/es/convocatoria/${all_refs[${i}]}
                    
            #Sleep   1
            #Go Back
            #Sleep   1
            #Go To   https://www.infosubvenciones.es/bdnstrans/GE/es/convocatoria/${all_refs[${i}]}
            
            &{row}=       Create Dictionary
                ...           Título Oficial        ${EMPTY}
                ...           InstrumentoAyuda      ${EMPTY}
                ...           TipoConvocatoria      ${EMPTY}
                ...           Presupuesto           ${EMPTY}
                ...           TiposBeneficiarios    ${EMPTY}
                ...           SectoresEconomicos    ${EMPTY}
                ...           Regiones              ${EMPTY}
                ...           Finalidad             ${EMPTY}
                ...           Ficheros              ${EMPTY}

            Extraer Datos Convocatoria BDNS    ${row}

            Log  ${row}

            ${json}            Convert JSON to String   ${row}
            Log  ${json}
            
            # Pruebas realizadas un dia horrible que no funcionaba nada
            #${jsonFilaAir}     Set Variable    {"records":[{"id": "${all_ids[${i}]}", "fields":${json}, "typecast": true\}\]\}
            #${jsonFilaAir}     Set Variable    {"records":[{"fields":{"PlazoSolicitud": "\u00daltima convocatoria, hasta el 31 de diciembre de 2020. En espera de pr\u00f3xima convocatoria"}, "typecast": true\}\]\}
            #${jsonFilaAir}     Set Variable    {"fields":{"PlazoSolicitud": "\u00daltima convocatoria, hasta el 31 de diciembre de 2020. En espera de pr\u00f3xima convocatoria"}, "typecast": true\}

            ${jsonFilaAir}     Set Variable    {"fields":${json}, "typecast": true\}
            Log     ${jsonFilaAir}

            ${datos}=    Convert String to JSON     ${jsonFilaAir}

            Log     Actualizar registro
            ${resp}=    Patch Request    airtable    ${API_URL_BDNS}/${all_ids[${i}]}    json=${datos}
            Should Be Equal As Strings    ${resp.status_code}    200
            ${jsondata}=    To Json    ${resp.content}


        END
    END

    
    [Teardown]   Log  Done
