@ECHO OFF
cls

ECHO Please save Ingres Intell Portal lists: export.csv, export_oss.csv, export_heesch.csv, export_nistelrode.csv, export_geffen.csv, export_schaijk.csv, export_herpen.csv, export_rosmalen.csv
PAUSE
ECHO Sort and Trim column 1 of export files (without headers)
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export.csv            | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_sort.csv
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_oss.csv        | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_oss_sort.csv
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_heesch.csv     | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_heesch_sort.csv
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_nistelrode.csv | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_nistelrode_sort.csv
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_geffen.csv     | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_geffen_sort.csv
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_schaijk.csv    | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_schaijk_sort.csv
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_herpen.csv     | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_herpen_sort.csv
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_rosmalen.csv   | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_rosmalen_sort.csv
rem zoomed browser to 30% and full screen
rem bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_maas_zuid.csv             | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_maas_zuid_sort.csv
rem bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_rosmalen_nistelrode.csv   | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_rosmalen_nistelrode_sort.csv

ECHO Reformat Ingress portal exports and add City name
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_sort.csv            | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v ""           | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" | bin\csvfix\csvfix.exe put -p 11 -v "" > tmp\export2.csv
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_oss_sort.csv        | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "Oss"        | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" | bin\csvfix\csvfix.exe put -p 11 -v "" > tmp\export_oss2.csv
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_heesch_sort.csv     | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "Heesch"     | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" | bin\csvfix\csvfix.exe put -p 11 -v "" > tmp\export_heesch2.csv
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_nistelrode_sort.csv | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "Nistelrode" | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" | bin\csvfix\csvfix.exe put -p 11 -v "" > tmp\export_nistelrode2.csv
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_geffen_sort.csv     | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "Geffen"     | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" | bin\csvfix\csvfix.exe put -p 11 -v "" > tmp\export_geffen2.csv
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_schaijk_sort.csv    | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "Schaijk"    | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" | bin\csvfix\csvfix.exe put -p 11 -v "" > tmp\export_schaijk2.csv
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_herpen_sort.csv     | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "Herpen"     | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" | bin\csvfix\csvfix.exe put -p 11 -v "" > tmp\export_herpen2.csv
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_rosmalen_sort.csv   | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "Rosmalen"   | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" | bin\csvfix\csvfix.exe put -p 11 -v "" > tmp\export_rosmalen2.csv
rem zoomed browser to 30% and full screen
rem bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_maas_zuid_sort.csv           | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "OssBuiten"      | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" | bin\csvfix\csvfix.exe put -p 11 -v "" > tmp\export_maas_zuid2.csv
rem bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_rosmalen_nistelrode_sort.csv | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "RosmalenBuiten" | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" | bin\csvfix\csvfix.exe put -p 11 -v "" > tmp\export_rosmalen_nistelrode2.csv

ECHO Please save Google sheets page 1 as: GoogleSheets.csv
PAUSE
ECHO Sort and trim and dont sort header from Google Sheets file and remove header
bin\csvfix\csvfix.exe sort -rh -f 1:AI,5:N,6:N GoogleSheets.csv         | bin\csvfix\csvfix.exe trim -f 1 | bin\sed\sed -r "/Location Name/d" > tmp\GoogleSheets_sort.csv
bin\csvfix\csvfix.exe sort -rh -f 1:AI,5:N,6:N GoogleSheets_Pending.csv | bin\csvfix\csvfix.exe trim -f 1 | bin\sed\sed -r "/Location Name/d" > tmp\GoogleSheets_Pending_sort.csv

ECHO Merge Ingress portal exports with new database
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new.csv  tmp\export2.csv            | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new2.csv
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new2.csv tmp\export_oss2.csv        | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new3.csv
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new3.csv tmp\export_heesch2.csv     | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new4.csv
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new4.csv tmp\export_nistelrode2.csv | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new5.csv
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new5.csv tmp\export_geffen2.csv     | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new6.csv
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new6.csv tmp\export_schaijk2.csv    | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new7.csv
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new7.csv tmp\export_herpen2.csv     | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new8.csv
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new8.csv tmp\export_rosmalen2.csv   | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new9.csv
bin\csvfix\csvfix.exe unique -f 1,5,6 tmp\GoogleSheets_sort.csv tmp\export2.csv tmp\export_oss2.csv tmp\export_heesch2.csv tmp\export_nistelrode2.csv tmp\export_geffen2.csv tmp\export_schaijk2.csv tmp\export_herpen2.csv tmp\export_rosmalen2.csv tmp\GoogleSheets_Pending_sort.csv | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new.csv
rem zoomed browser to 30% and full screen
rem bin\csvfix\csvfix.exe unique -f 1,5,6 tmp\PokemonGoLocations_new.csv tmp\export_maas_zuid2.csv tmp\export_rosmalen_nistelrode2.csv | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new2.csv

MOVE /Y PokemonGoLocations.csv PokemonGoLocations_old.csv
MOVE /Y PokemonGoLocations_new.csv PokemonGoLocations.csv


ECHO Split by city
del PokemonGoLocations_.csv
del PokemonGoLocations_Berghem.csv
del PokemonGoLocations_DenBosch.csv
del PokemonGoLocations_Geffen.csv
del PokemonGoLocations_GeffenBuiten.csv
del PokemonGoLocations_Heesch.csv
del PokemonGoLocations_HeeschBuiten.csv
del PokemonGoLocations_Herpen.csv
del PokemonGoLocations_Macharen.csv
del PokemonGoLocations_Nistelrode.csv
del PokemonGoLocations_NistelrodeBuiten.csv
del PokemonGoLocations_Oss.csv
del PokemonGoLocations_OssBuiten.csv
del PokemonGoLocations_Overlangel.csv
del PokemonGoLocations_Ravenstein.csv
del PokemonGoLocations_Rosmalen.csv
del PokemonGoLocations_RosmalenBuiten.csv
del PokemonGoLocations_Schaijk.csv
del PokemonGoLocations_Uden.csv
del PokemonGoLocations_Velp.csv
del PokemonGoLocations_Vinkel.csv
del PokemonGoLocations_Wijchen.csv
del PokemonGoLocations_Zeeland.csv
bin\csvfix\csvfix file_split -f 4 -ufn -fd . -fp PokemonGoLocations_ PokemonGoLocations.csv
COPY /Y PokemonGoLocations_Oss.csv + PokemonGoLocations_Berghem.csv + PokemonGoLocations_OssBuiten.csv PokemonGoLocations_OssBerghem.csv 
COPY /Y PokemonGoLocations_Schaijk.csv + PokemonGoLocations_Herpen.csv PokemonGoLocations_SchaijkHerpen.csv 


Convert.bat PokemonGoLocations.csv               OverpassTurboParks_min.geojson
Convert.bat PokemonGoLocations_Oss.csv           OverpassTurboParks_min.geojson
Convert.bat PokemonGoLocations_OssBerghem.csv    OverpassTurboParks_min.geojson
Convert.bat PokemonGoLocations_Berghem.csv       OverpassTurboParks_min.geojson
Convert.bat PokemonGoLocations_Heesch.csv        OverpassTurboParks_Heesch_min.geojson
Convert.bat PokemonGoLocations_Nistelrode.csv    OverpassTurboParks_Nistelrode_min.geojson
Convert.bat PokemonGoLocations_Geffen.csv        OverpassTurboParks_Geffen_min.geojson
Convert.bat PokemonGoLocations_Schaijk.csv       OverpassTurboParks_Schaijk_min.geojson
Convert.bat PokemonGoLocations_SchaijkHerpen.csv OverpassTurboParks_Schaijk_min.geojson
Convert.bat PokemonGoLocations_Herpen.csv        OverpassTurboParks_Schaijk_min.geojson
Convert.bat PokemonGoLocations_Rosmalen.csv      OverpassTurboParks_Rosmalen_min.geojson
rem test stops in wrong area's7
rem Convert.bat PokemonGoLocations_DenBosch.csv
rem Convert.bat PokemonGoLocations_Macharen.csv
rem Convert.bat PokemonGoLocations_DenBosch.csv
rem Convert.bat PokemonGoLocations_Overlangel.csv
rem Convert.bat PokemonGoLocations_Ravenstein.csv
rem Convert.bat PokemonGoLocations_Uden.csv
rem Convert.bat PokemonGoLocations_Velp.csv
rem Convert.bat PokemonGoLocations_Vinkel.csv
rem Convert.bat PokemonGoLocations_Wijchen.csv
rem Convert.bat PokemonGoLocations_Zeeland.csv
rem Convert.bat PokemonGoLocations_GeffenBuiten.csv
rem Convert.bat PokemonGoLocations_HeeschBuiten.csv
rem Convert.bat PokemonGoLocations_NistelrodeBuiten.csv
rem Convert.bat PokemonGoLocations_OssBuiten.csv
rem Convert.bat PokemonGoLocations_RosmalenBuiten.csv
