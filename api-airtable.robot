*** Settings ***
Documentation     HTTP API robot. Retrieves data from SpaceX API. Demonstrates
...               how to use RPA.HTTP (create session, get response, validate
...               response status, pretty-print, get response as text, get
...               response as JSON, access JSON properties, etc.).
Library           RPA.HTTP
Library           RPA.core.notebook
Library           RPA.JSON
Library           String
Suite Setup       Setup
Suite Teardown    Teardown

*** Variables ***
${SPACEX_API_BASE_URL}=    https://api.airtable.com/v0
${SPACEX_API_LATEST_LAUNCHES}=    /xxxxx/Ayudas%20BDNS
${INSERT_ROW_IPYME}=              /xxxxx/iPyme

*** Keywords ***
Setup
    &{headers}=    Create Dictionary    Authorization=Bearer xxxxx
    Create Session    airtable    ${SPACEX_API_BASE_URL}    verify=True  headers=&{headers}
    ${response}=    Get Request    airtable    ${SPACEX_API_LATEST_LAUNCHES}    headers=&{headers}
    #${resp}=    Get Request    alias=airtable    uri=${SPACEX_API_LATEST_LAUNCHES}      headers=${headers}


*** Keywords ***
Insert Row
    # [Arguments]     ${row}
    &{headers}=    Create Dictionary
    ...                 Authorization=Bearer=keyvdjd4TcqMJEnpl
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

Existe Row

*** Keywords ***
Teardown
    Delete All Sessions

*** Keywords ***
Log latest launch
    ${launch}=    Get latest launch
    Log info    ${launch}

*** Keywords ***
Get latest launch
    ${response}=    Get Request    airtable    ${SPACEX_API_LATEST_LAUNCHES}
    Request Should Be Successful    ${response}
    Status Should Be    200    ${response}
    [Return]    ${response}

*** Keywords ***
Log info
    [Arguments]    ${response}
    ${pretty_json}=    To Json    ${response.text}    pretty_print=True
    ${launch}=    Set Variable    ${response.json()}
    Notebook Print    ${pretty_json}
    Log    ${pretty_json}
    Notebook Print    ${launch["mission_name"]}
    Log    ${launch["mission_name"]}
    Notebook Print    ${launch["rocket"]["rocket_name"]}
    Log    ${launch["rocket"]["rocket_name"]}

*** Tasks ***
Log latest launch info
    # Log latest launch
    Insert Row
