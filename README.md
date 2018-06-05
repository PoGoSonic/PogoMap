# PogoMap

Windows command line script and partly manual procedure to create a Pokemon Go Map based on Ingress portal locations.

## Requirements
* Ingress account
* Firefox with Greasemonkey or Chrome with ...
* IITC/Ingress Intel total Conversion Plugin for GreaseMonkey: https://iitc.me/desktop/, version 0.26.0.20170430.123533
  Disabled line 34 to 46 as player detection was not working. Disable IITC to login Ingress Intel
* IITC plugin: show list of portals // modified with export button, version 0.2.1.20170108.21732
* JQ json manipulator by Stedolan: https://stedolan.github.io/jq/, manual: https://stedolan.github.io/jq/manual
* Serial Line Editor sed: http://gnuwin32.sourceforge.net/packages/sed.htm, manual: linux man pages (online)
* CSVfix by Neil Butterworth: https://bitbucket.org/neilb/csvfix/downloads/
* OSMCoverer by MzHub: https://github.com/MzHub/osmcoverer, download: https://github.com/MzHub/osmcoverer/releases

## Other resources
* Show S2 cells on a map: https://s2.sidewalklabs.com/regioncoverer
* Show Ex-Raid Park areas on a map: http://overpass-turbo.eu/s/z7D
* Original instructions used to create this: https://www.reddit.com/r/TheSilphRoad/comments/7pq1cx/how_i_created_a_map_of_potential_exraids_and_how/
* Howto export Ingress portals: https://www.reddit.com/r/TheSilphRoad/comments/7p9ozm/i_made_a_plugin_to_show_level_17_s2_cells_on/dsflwr9/?sh=1def38f1&st=JC83GSC2

## Gathering data
* Open Firefox with Ingress Intel site: https://www.ingress.com/intel
* Enable GreasMonkey with IITC Ingress Intel total Conversion
* Zoom to view the biggest area where each portal is still visible
* Use browser zooming to zoom out until the desired region is visible, if needed resize browser screen
* Wait until finished loading (IITC bottom right corner)
* Press Portals List (IITC botom of top right box)
* Scroll down Portals list
* Press Export portals
* Sort and trim file: `bin\csvfix\csvfix sort -f 1:AI,2:N,3:N input.csv | bin\csvfix\csvfix.exe trim -f 1 > output.csv`
  Original file with LF and only the first column double quoted is saved with Windows CRLF and all three columns double quoted

## Merging location data
IITC Exports locations in three columns: 

| Name | Latitude | Longitude |
|---|---|---|

My data is enriched with Pokemon GO data and subsequent scripting needs this information:

| Name | Sub Name | Latitude | Longitude | OSM Link | Google Maps Link | In Ingress | PoGo Type | Empty |
|---|---|---|---|---|---|---|---|---|

1. Original name
1. Additional name to make the name unique, with a streetname for example
1. Original latitude
1. Original lontitude
1. Open Street Map link: `=HYPERLINK( SUBSTITUTE( SUBSTITUTE( Settings!$B$2, "%lat", $C4), "%lon", $D4), "OSM")` http://www.openstreetmap.org/?mlat=%lat&mlon=%lon&zoom=16 
1. Google Maps link: `=HYPERLINK( SUBSTITUTE( SUBSTITUTE( Settings!$B$3, "%lat", $C2), "%lon", $D2), "Google")` http://maps.google.com/maps?q=%lat,%lon
1. Available in Ingress: Yes/No. Will only be no for removed pokestops and possible future Pokemon Go submitted location
1. Pokemon GO Location type: Unknown/Stop/Gym/ExGym/None/Removed
1. Empty column, the extra comma is used by the convert script

* Edit original file in a spreadsheet to match the required format or use a script: `bin\csvfix\csvfix.exe put -p 2 -v "" input.csv | bin\csvfix\csvfix.exe put -p 5 -v "OSM" | bin\csvfix\csvfix.exe put -p 6 -v "Google" | bin\csvfix\csvfix.exe put -p 7 -v "Yes" | bin\csvfix\csvfix.exe put -p 8 -v "Unknown" | bin\csvfix\csvfix.exe put -p 9 -v "" > output.csv`
* Sort a file in the new format if needed: `bin\csvfix\csvfix.exe sort -rh -f 1:AI,3:N,4:N input.csv > output.csv`
  And adding quotes and CRLF.
* Merge old and new file and sort again: `bin\csvfix\csvfix.exe unique -f 1,3,4 old.csv new.csv | bin\csvfix\csvfix.exe sort -f 1:AI,3:N,4:N > output.csv`

## Generate parks map
* Open: http://overpass-turbo.eu/s/ujd
* Take into view the map area you want to generate for
* Press run
* Press Export download geojson
* To minimize the file run: `bin\jq\jq-win64.exe -c "." input.geojson > input_min.geojson`

## Converting location data
* Run: `Convert.bat input.csv`, writes input.geojson and input_min.geojson without formatting
* Open: http://geojson.io and load input_min.geojson, this might take a while for files >1.5Mb
You will see the created map with locations and S2 grids
* Press Save KML to save the geojson as KML

## Sharing on Google Maps
* Open: https://www.google.com/maps/d/
* Create a new map give it a name and description, for example: 
  > Red: Ex Gyms and S2 Level 13 grid (1 per cell)
  > Orange: Gym location and S2 Level 14 grid (0-1:0, 2-5: 1, 6-19: 2, 20-34: 3, 35+: 4 gyms)
  > Blue: Stop location and S2 Level 17 grid (1 per cell)
  > Gray: Unknown type
  > Black: Only portal not a stop
  > Maroon: Removed stop/gym
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
