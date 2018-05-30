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

## Gathering Data
* Open Firefox with Ingress Intel site: https://www.ingress.com/intel
* Enable GreasMonkey with IITC Ingress Intel total Conversion
* Zoom to view the biggest area where each portal is still visible
* Use browser zooming to zoom out until the desired region is visible, if needed resize browser screen
* Wait until finished loading (IITC bottom right corner)
* Press Portals List (IITC botom of top right box)
* Scroll down Portals list
* Press Export portals
* Sort file: bin\csvfix\csvfix input.csv > output.csv
  Original file with LF is saved with Windows CRLF
*
