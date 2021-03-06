# PogoMap

Windows command line script and partly manual procedure to create a Pokemon Go Map based on Ingress portal locations.

## Requirements
* Ingress account
* Firefox or Chrome with Greasemonkey or TamperMonkey (works unchanged with latest IITC version)
* IITC/Ingress Intel total Conversion Plugin for GreaseMonkey: https://iitc.me/desktop/, version 0.26.0.20170430.123533
  For Gressemonkey disable line 34 to 46 as player detection was not workin, disable IITC to login Ingress Intel.
* IITC plugin: show list of portals // modified with export button, version 0.2.1.20170108.21732: https://pastebin.com/fAYVyyme
  Self modified to also export portal image urls (See IITC folder in repository)
* JQ json manipulator by Stedolan: https://stedolan.github.io/jq/, manual: https://stedolan.github.io/jq/manual, faq: https://github.com/stedolan/jq/wiki/FAQ, cookbook: https://github.com/stedolan/jq/wiki/Cookbook
  Using the more limited version 1.4 as 1.5 was giving unexpected exceptions, this might have to do with a 37 character filename limit or a 63 character full path limit.
  Daily build artifacts can be found here: https://ci.appveyor.com/project/stedolan/jq
* Serial Line Editor sed: http://gnuwin32.sourceforge.net/packages/sed.htm, manual: linux man pages (online)
* CSVfix by Neil Butterworth: https://bitbucket.org/neilb/csvfix/downloads/
* OSMCoverer by MzHub: https://github.com/MzHub/osmcoverer, download: https://github.com/MzHub/osmcoverer/releases
  Check osmcoverer -h for available commands.
  -excludecellfeatures will exclude S2 cells from the geojson. This will help the most with the file size.
  -skipmarkerless will remove parks that have no gyms
  -skipfeatureless will remove gyms that are not in parks

## Setup TamperMonkey Specific
* Firefox + TamperMonkey + IITC Desktop + IITC  Portal list
  FireFox Quantum 66.0.4 need to disable xpinstall.signatures.required to allow older plugins
* On Ingress Intell site there is no map, use layers button choose: CartoDB Dark Matter

## Other resources
* Show S2 cells on a map: https://s2.sidewalklabs.com/regioncoverer
* Show Ex-Raid Park areas on a map: http://overpass-turbo.eu/s/z7D
* Original instructions used to create this: https://www.reddit.com/r/TheSilphRoad/comments/7pq1cx/how_i_created_a_map_of_potential_exraids_and_how/
* Howto export Ingress portals: https://www.reddit.com/r/TheSilphRoad/comments/7p9ozm/i_made_a_plugin_to_show_level_17_s2_cells_on/dsflwr9/?sh=1def38f1&st=JC83GSC2

## Gathering data
* Open Firefox (or Chrome) with Ingress Intel site: https://www.ingress.com/intel
  n.b. IITC does not activate on: https://intel.ingress.com/
* Enable GreaseMonkey (or TamperMonkey) with IITC Ingress Intel total Conversion
* Zoom to view the biggest area where each portal is still visible
* Use browser zooming to zoom out until the desired region is visible (67%), if needed resize browser screen
* Wait until finished loading (IITC shows progress in the bottom right corner)
* Press Portals List (IITC botom of the top right information box)
* Scroll down Portals list
* Press: Export portals
  Modified version has: Export Portals with Images
* Sort and trim file: `bin\csvfix\csvfix sort -f 1:AI,2:N,3:N export.csv | bin\csvfix\csvfix.exe trim -f 1 > export_sort.csv`
  Original file with LF and only the first column double quoted is saved with Windows CRLF and all three columns double quoted

## Merge with public list (optional)  
* Google sheets hosts a copy of the list that other people can help maintain
* File - Download as - Comma-seperated Values (csv, current sheet) as `GoogleSheets.csv`
* Sort and trim file: `bin\csvfix\csvfix.exe sort -rh -f 1:AI,5:N,6:N GoogleSheets.csv | bin\csvfix\csvfix.exe trim -f 1 > GoogleSheets_sort.csv`
? REMOVE HEADER
* Merge original and public file and sort again: `bin\csvfix\csvfix.exe unique -f 1,4,5 PokemonGoLocations.csv GoogleSheets_sort.csv | bin\csvfix\csvfix.exe sort -f 1:AI,5:N,6:N > PokemonGoLocations_new.csv`
* Rename output `copy PokemonGoLocations_new.csv PokemonGoLocations.csv`

  
## Merging location data
IITC Exports locations in three columns: 

| Name | Latitude | Longitude |
|---|---|---|

My data is enriched with Pokemon GO data and subsequent scripting needs this information:

| Name | Address | City | Latitude | Longitude | Requestor | In Ingress | PoGo Type | Map Link |
|---|---|---|---|---|---|---|---|---|

1. Original in-game name
1. Address or additional name to make names unique (e.g. Streetname)
   Reverse geocode is possible from GPS to address: `=IMPORTXML( SUBSTITUTE( SUBSTITUTE( Settings!$B$7, "%lat", $E42), "%lon", $F42) , "reversegeocode/addressparts/road") & " " & IMPORTXML( SUBSTITUTE( SUBSTITUTE( Settings!$B$7, "%lat", $E42), "%lon", $F42) , "reversegeocode/addressparts/house_number")` https://nominatim.openstreetmap.org/reverse?format=xml&lat=%lat&lon=%lon&zoom=18&addressdetails=1&email=<yourmail>%40<yourmaildomain>
1. City or Area for filtering, map size needs to be controlled and limited to <1Mb to be able to use http://geojson.io with a geojsno file from github without login
1. Original GPS latitude
1. Original GPS lontitude
1. Signature of requestor, only for reference
1. Available in Ingress: Yes/No. Will only be no for removed pokestops and possible future Pokemon Go submitted location
1. Pokemon GO Location type: Unknown/Stop/Gym/ExGym/None/Removed
1. Open Street Map link: `=SUBSTITUTE( SUBSTITUTE( Settings!$B$2, "%lat", $E4), "%lon", $F4)` http://www.openstreetmap.org/?mlat=%lat&mlon=%lon&zoom=16 
   or: Google Maps link: `=SUBSTITUTE( SUBSTITUTE( Settings!$B$3, "%lat", $E2), "%lon", $F2)` http://maps.google.com/maps?q=%lat,%lon
   or: Ingress Portal link: `=SUBSTITUTE( SUBSTITUTE( Settings!$B$1, "%lat", $E2), "%lon", $F2)` https://www.ingress.com/intel?ll=%lat,%lon&z=17&pll=%lat,%lon
   
* Edit original file in a spreadsheet to match the required format or use a script: `bin\csvfix\csvfix.exe put -p 2 -v "" export_sort.csv | bin\csvfix\csvfix.exe put -p 3 -v "" | bin\csvfix\csvfix.exe put -p 6 -v "" | bin\csvfix\csvfix.exe put -p 7 -v "Yes" | bin\csvfix\csvfix.exe put -p 8 -v "Unknown" | bin\csvfix\csvfix.exe put -p 9 -v "" > output.csv`
* Sort a file in the new format if needed: `bin\csvfix\csvfix.exe sort -rh -f 1:AI,5:N,6:N output.csv > output_sort.csv`
  And adding quotes and CRLF (should be unchanged as sorting is already done after gathering).
* Merge old and new file and sort again: `bin\csvfix\csvfix.exe unique -f 1,5,6 PokemonGoLocations.csv output_sort.csv | bin\csvfix\csvfix.exe sort -f 1:AI,4:N,5:N > output_merge.csv`
* Rename output `copy output_merge.csv PokemonGoLocations.csv`

## Split by City (optional)
* Run: `bin\csvfix\csvfix file_split -f 4 -ufn -fd tmp -fp PokemonGoLocations_ PokemonGoLocations.csv
* Sort with header and add " to a file if needed: `bin\csvfix\csvfix.exe sort -rh -f 1:AI,4:N,5:N output.csv > output_sort.csv`
* Further process a city csv file

## Generate parks map
* Open: http://overpass-turbo.eu/s/vs3 (2018-01-16)
* Take into view the map area you want to generate for
* Press run
* Press Export download geojson, save as: OverpassTurboParks.geojson
* To minimize the file run: `bin\jq\jq-win64.exe -c "." OverpassTurboParks.geojson > OverpassTurboParks_min.geojson`

## Converting location data
* Run: `Convert.bat PokemonGoLocations.csv`, writes input.geojson and input_min.geojson without formatting
  Or: `Convert.bat PokemonGoLocations.csv OverpassTurboParks_min.geojson`
* Open: http://geojson.io and load input_min.geojson, this might take a while for files >1.5Mb
You will see the created map with locations and S2 grids
* Press Save KML to save the geojson as KML

## Sharing on Google Maps
* Open: https://www.google.com/maps/d/
* Create a new map give it a name and description, for example: 
  > Lower levels are 1/4 except the first level are 1/6 of the globe:
  >         S2 Level  6 Geoblocking, Ingress portal review (en buurcellen)
  >         S2 Level  9 Regional pokemon?
  >         S2 Level 10 Pokemon caught/Egg found location (iOS and Android resolve to names differently)
  >         S2 Level 10/11 Weather?
  >         S2 Level 12 One Ex raid invitation per cycle
  > Red:    S2 Level 13 Ex Gyms and grid (1 per cell)
  > Orange: S2 Level 14 Gym location and (0-1:0, 2-5: 1, 6-19: 2, 20-59: 3, (unconfirmed 27+: 4 gyms?)), Biome?
  >         S2 Level 15 Geoblocking military
  >         S2 Level 16 Pokestop viewing/loading distance, World map
  > Blue:   S2 Level 17 Stop location (1 per cell, oudste ingress portal)
  >         S2 Level 19 Ingress Portal location (1 per cell)
  >         S2 Level 20 Pokemon spawn locations & center in land use for ex raids, Egg walking distance?
  > Gray: Unknown type
  > Black: Only portal not a stop
  > Maroon: Removed stop/gym
  > See: https://pokemongohub.net/post/article/comprehensive-guide-s2-cells-pokemon-go/
  > See: https://pokemongo.gamepress.gg/s2-cells-foundation-pokemon-go-design
  > See: http://blog.christianperone.com/2015/08/googles-s2-geometry-on-the-sphere-cells-and-hilbert-curve/
  > See: https://articles.pokebattler.com/2018/02/26/determining-which-gyms-will-get-you-ex-raid-passes-for-mewtwo-part-2/
* Press import and select the KML file
  Google Maps looses location colors and symbols and grid colors and there was an error importing the KML file

## Sharing on Geojson.io
* Open: http://geojson.io
* Create an account or enable (OAuth via GitHub)
* Commit and Push the geojson file in a github repository
* Open the the GitHub repository geojson file
* The page URL can be open shared as long as the geojson file does not exeed 1Mb GitHub API limitation

# Other resources (untested)
* https://www.reddit.com/r/TheSilphRoad/comments/7p9ozm/i_made_a_plugin_to_show_level_17_s2_cells_on/dsflwr9/?sh=1def38f1&st=JC83GSC2

# Notifications
## PokemonGo Maps
De kaarten zijn weer bijgewerkt (ook de oude links):
Alle Gyms in de omgeving: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_raid_min.geojson&map=12/51.7402/5.5220
Alle Stops in de omgeving: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_min.geojson&map=12/51.7402/5.5220
Deze kaarten werken het beste in Chrome of Firefox, ook op mobiel. Indien een locatie niet klopt of als je weet welk type de grijze zijn mag je dat aan mij doorgeven.
Voor het aanvragen en plannen van stops en gyms in Ingress zijn er aanvullende kaarten op aanvraag beschikbaar voor: Oss, Berghem, Geffen/Nuland, Heesch, Nistelrode/Maashorst, Schaijk/Reek, Herpen, Rosmalen.

## Ingress Maps
De kaarten zijn weer bijgewerkt:
Alle Gyms in de omgeving: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_raid_min.geojson&map=12/51.7402/5.5220
Alle Stops in de omgeving: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_min.geojson&map=12/51.7402/5.5220
Alle Gyms S2Level14: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_gymonly_min.geojson&map=12/51.7402/5.5220

Oss Stops S2Level14+17: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Oss_stop_min.geojson&map=13/51.7643/5.5330
Berghem Stops S2Level14+17: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Berghem_stop_min.geojson&map=14/51.7627/5.5717
Oss-Berghem Gyms S2Level13+14: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_OssBerghem_gym_min.geojson&map=13/51.7643/5.5330

Geffen-Nuland Stops S2Level14+17: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Geffen_stop_min.geojson&map=14/51.7314/5.4415
Geffen-Nuland Gyms S2Level13+14: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Geffen_gym_min.geojson&map=14/51.7314/5.4415

Heesch Stops S2Level14+17: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Heesch_stop_min.geojson&map=14/51.7340/5.5320
Heesch Gyms S2Level13+14: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Heesch_gym_min.geojson&map=14/51.7340/5.5320

Nistelrode-Maashorst Stops S2Level14+17: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Nistelrode_stop_min.geojson&map=13/51.7025/5.5814
Nistelrode-Maashorst Gyms S2Level13+14: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Nistelrode_gym_min.geojson&map=13/51.7025/5.5814

Schaijk Stops S2Level14+17: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Schaijk_stop_min.geojson&map=13/51.7396/5.6372
Herpen Stops S2Level14+17: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Herpen_stop_min.geojson&map=14/51.7686/5.6413
Schaijk-Herpen S2Level13+14: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_SchaijkHerpen_gym_min.geojson&map=13/51.7490/5.6430

Rosmalen Stops S2Level14+17: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Rosmalen_stop_min.geojson&map=13/51.7217/5.3601
Rosmalen Gyms S2Level13+14: http://geojson.io/#id=github:PoGoSonic/PogoMap/blob/master/PokemonGoLocations_Rosmalen_gym_min.geojson&map=13/51.7217/5.3601

Deze kaarten werken het beste in Chrome of Firefox, ook op mobiel.
