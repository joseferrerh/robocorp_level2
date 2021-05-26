# -*- coding: utf-8 -*-
*** Settings ***
Documentation   Recogida de datos de ipyme
Library         RPA.Excel.Files
Library         RPA.Browser.Selenium
Library         String
Library         RPA.HTTP
Resource        common.robot
Resource        api-resources.robot
Library         Paginas

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

*** Tasks ***
Minimal task
    Crear Sesion
    Abrir navegador
    Crear Excel
    ${numeroAyudas}     Get Text    //*[@id="resultadosPagina_Top"]
    ${numero_de_paginas}    get numPaginas   ${numeroAyudas}
    
    FOR     ${pagina}   IN RANGE   ${numero_de_paginas}
       Recorrer ayudas
    END
    [Teardown]   Cerrar navegador
