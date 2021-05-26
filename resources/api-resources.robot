*** Settings ***
Documentation   Keywords comunes a las extracciones de iPYME
Resource        api-resources.robot
Library         RPA.JSON
Library         RPA.HTTP
Library         String

*** Keywords ***
Crear Sesion
    &{headers}=    Create Dictionary    Authorization=Bearer keyvdjd4TcqMJEnpl
    Create Session    airtable    ${API_BASE_URL}    verify=True  headers=&{headers}
    #${response}=    Get Request    airtable    ${SPACEX_API_LATEST_LAUNCHES}    headers=&{headers}
    #${resp}=    Get Request    alias=airtable    uri=${SPACEX_API_LATEST_LAUNCHES}      headers=${headers}

*** Keywords ***
Insert Row
    # [Arguments]     ${row}
    &{headers}=    Create Dictionary
    ...                 Authorization=Bearer=key8gp8qHqfYK6Lgk
    ...                 Content-Type=application/json
    
    ${datos}=    Convert String to JSON     {"records":[{"fields":{"Titulo": "Prueba insercion","Fecha Limite": "2021-12-23"}}]}
    
    #{"orders": [{"id": 1},{"id": 2}]}
    #${datos}    Set Variable    
    #...    "records": [
    #...    {
    #...      "fields":
    #...         {
    #...            "Titulo": "Prueba insercion",
    #...             "Fecha Limite": "2021-12-23"
    #...         }
    #...       }

    # &{data}=    Create Dictionary    latitude=30.496346    longitude=-87.640356
    ${resp}=    Post Request    airtable    ${INSERT_ROW_IPYME}    json=${datos}
    Should Be Equal As Strings    ${resp.status_code}    200
    ${jsondata}=    To Json    ${resp.content}

