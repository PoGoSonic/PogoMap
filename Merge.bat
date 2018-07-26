@ECHO OFF
cls

ECHO Please save Ingres Intell Portal lists: export.csv, export_oss.csv, export_heesch.csv, export_nistelrode.csv, export_geffen.csv
PAUSE
ECHO Sort and Trim column 1 of export files (without headers)
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export.csv | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_sort.csv
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_oss.csv | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_oss_sort.csv
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_heesch.csv | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_heesch_sort.csv
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_nistelrode.csv | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_nistelrode_sort.csv
bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export_geffen.csv | bin\csvfix\csvfix.exe trim -f 1 > tmp\export_geffen_sort.csv

ECHO Reformat Ingress portal exports and add City name
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_sort.csv | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "" | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" > tmp\export2.csv
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_oss_sort.csv | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "Oss" | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" > tmp\export_oss2.csv
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_heesch_sort.csv | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "Heesch" | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" > tmp\export_heesch2.csv
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_nistelrode_sort.csv | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "Nistelrode" | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" > tmp\export_nistelrode2.csv
bin\csvfix\csvfix.exe put -p 2 -v "" tmp\export_geffen_sort.csv | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 4 -v "Geffen" | bin\csvfix\csvfix.exe put -p 7 -v "" | bin\csvfix\csvfix.exe put -p 8 -v "Yes" | bin\csvfix\csvfix.exe put -p 9 -v "Unknown" | bin\csvfix\csvfix.exe put -p 10 -v "" > tmp\export_geffen2.csv

ECHO Please save Google sheets page 1 as: GoogleSheets.csv
PAUSE
ECHO Sort and trim and dont sort header from Google Sheets file and remove header
bin\csvfix\csvfix.exe sort -rh -f 1:AI,5:N,6:N GoogleSheets.csv | bin\csvfix\csvfix.exe trim -f 1 | bin\sed\sed -r "/Location Name/d" > tmp\GoogleSheets_sort.csv

ECHO Merge Ingress portal exports with new database
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new.csv tmp\export2.csv | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new2.csv
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new2.csv tmp\export_oss2.csv | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new3.csv
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new3.csv tmp\export_heesch2.csv | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new4.csv
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new4.csv tmp\export_nistelrode2.csv | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new5.csv
@REM bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations_new5.csv tmp\export_geffen2.csv | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new6.csv
bin\csvfix\csvfix.exe unique -f 1,5,6 tmp\GoogleSheets_sort.csv tmp\export2.csv tmp\export_oss2.csv tmp\export_heesch2.csv tmp\export_nistelrode2.csv tmp\export_geffen2.csv | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new.csv

ECHO Split by city
MOVE /Y PokemonGoLocations.csv PokemonGoLocations_old.csv
MOVE /Y PokemonGoLocations_new.csv PokemonGoLocations.csv
del PokemonGoLocations_Oss.csv
del PokemonGoLocations_Oss_Buiten.csv
del PokemonGoLocations_Berghem.csv
del PokemonGoLocations_Geffen.csv
del PokemonGoLocations_Heesch.csv
bin\csvfix\csvfix file_split -f 4 -ufn -fd . -fp PokemonGoLocations_ PokemonGoLocations.csv
COPY PokemonGoLocations_Oss.csv + PokemonGoLocations_Berghem.csv PokemonGoLocations_OssBerghem.csv 




Convert.bat PokemonGoLocations.csv OverpassTurboParks_min.geojson
Convert.bat PokemonGoLocations_Oss.csv OverpassTurboParks_min.geojson
Convert.bat PokemonGoLocations_OssBerghem.csv OverpassTurboParks_min.geojson
