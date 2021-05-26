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
    Open available browser  https://buscadorayudas.ipyme.org/BusquedaAvanzada  preferences=${preferences}


*** Keywords ***
Buscar Ayudas
    Click Element       xpath://*[@id="btnEnPlazo"]/label/span
    Sleep   2
    Click Element       xpath://*[@id="btnBuscar"]
    Sleep   5

*** Tasks ***
Minimal task
    Crear Sesion
    Abrir navegador
    
    FOR  ${x}   IN RANGE    15
        ${resp}     Get Request     airtable    ${API_URL_IPYME}?maxRecords=1000&filterByFormula=Organismo%3D""&sort%5B0%5D%5Bfield%5D=Referencia

        ${jsondata}=    To Json    ${resp.content}

        Log  ${resp}

        ${first_record_id}=    Get value from JSON    ${jsondata}    $.records[0].id
        Log  ${first_record_id}

        @{all_ids}=    Get values from JSON    ${jsondata}    $..id
        Log Many  ${all_ids}
        Log Many  @{all_ids}

        @{all_refs}=    Get values from JSON    ${jsondata}    $..Referencia
        Log Many  ${all_refs}
        Log Many  @{all_refs}.length

        ${contador}     Get Length   ${all_refs}
    
        FOR  ${i}    IN RANGE  ${contador}
            Log  ${all_refs[${i}]}
            Log  ${all_ids[${i}]}
            Go TO   https://buscadorayudas.ipyme.org/FichaAyuda?idAyuda=${all_refs[${i}]}
            &{row}=       Create Dictionary
                ...             Organismo               ${EMPTY}        
                ...             Sector                  ${EMPTY}          
                ...             Administración          ${EMPTY}                
                ...             TipoAyuda               ${EMPTY}
                ...             Destinatarios           ${EMPTY}
                ...             PlazoSolicitud          ${EMPTY}

            Extraer Datos InfoGeneral   ${row}

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
            ${resp}=    Patch Request    airtable    ${API_URL_IPYME}/${all_ids[${i}]}    json=${datos}
            Should Be Equal As Strings    ${resp.status_code}    200
            ${jsondata}=    To Json    ${resp.content}


        END
    END

    
    [Teardown]   Log  Done
