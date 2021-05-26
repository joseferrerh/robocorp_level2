# robocorp_level2
Robocorp Level 2

This set of robots obtain information from two governamental page sources in Spain:
    - infosubvenciones      https://www.infosubvenciones.es/
    - ayudas para Pymes     http://www.ipyme.org/es-ES/BBDD/AyudasIncentivos/Paginas/UltimasAyudas.aspx

The robots obtain the information and upload it to the airtable environment using it's API

There are several robots:

    - to Upload an excel with the initial data
    - to enrich the rows in airtable with the entire record information
    - to obtain all the subvenciones with all its data
    - ...
    
These robots use:

    - JSON.rpa library
    - RPA.Excel.Files
    - RPA.HTTP
    - RPA.JSON
   
It also includes a couple of very simple python libraries to obtain the number of pages to parse in the website and to rename the last file in a folder.

Thanks ROBOCORP for all the good work around your technology and platform

