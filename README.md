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
* OSMCoverer by MzHub: https://github.com/MzHub/osmcoverer

## Other resources
* Show S2 cells on a map: https://s2.sidewalklabs.com/regioncoverer
* Show Ex-Raid Park areas on a map: http://overpass-turbo.eu/s/z7D
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

| Name | Sub Name | Latitude | Longitude | OSM Link | Google Maps Link | In Ingress | PoGo Type |
|---|---|---|---|---|---|---|---|

1. Original name
1. Additional name to make the name unique, with a streetname for example
1. Original latitude
1. Original lontitude
1. Open Street Map link: `=HYPERLINK( SUBSTITUTE( SUBSTITUTE( Settings!$B$2, "%lat", $C4), "%lon", $D4), "OSM")` http://www.openstreetmap.org/?mlat=%lat&mlon=%lon&zoom=16 
1. Google Maps link: `=HYPERLINK( SUBSTITUTE( SUBSTITUTE( Settings!$B$3, "%lat", $C2), "%lon", $D2), "Google")` http://maps.google.com/maps?q=%lat,%lon
1. Available in Ingress: Yes/No. Will only be no for removed pokestops and possible future Pokemon Go submitted location
1. Pokemon GO Location type: Unknown/Stop/Gym/ExGym/None/Removed

* Edit original file in a spreadsheet to match the required format or use a script: `bin\csvfix\csvfix.exe put -p 2 -v "" input.csv | bin\csvfix\csvfix.exe put -p 5 -v "OSM" | bin\csvfix\csvfix.exe put -p 6 -v "Google" | bin\csvfix\csvfix.exe put -p 7 -v "Yes" | bin\csvfix\csvfix.exe put -p 8 -v "Unknown" > output.csv`
* Sort a file in the new format if needed: `bin\csvfix\csvfix.exe sort -rh -f 1:AI,3:N,4:N input.csv > output.csv`
  And adding quotes and CRLF.
* Merge old and new file and sort again: `bin\csvfix\csvfix.exe unique -f 1,3,4 old.csv new.csv | bin\csvfix\csvfix.exe sort -f 1:AI,3:N,4:N > output.csv`
