@ECHO OFF
cls
set keeptmp=1

@rem Help:    https://stedolan.github.io/jq/manual
@rem Testing: https://jqplay.org/

IF NOT EXIST "%1" GOTO NotFound
@rem Input CSV filename parameter 1
SET input=%1
@rem Prefix/Filename only
SET filename=%~n1
@rem Prefix/Filename for S2 grids
SET s2filename=%~n1_S2_Level
@rem Prefix/Filename for csv files split by type
SET typefilename=%~n1_Type
@rem Temporary filename after csv sed corection
SET tmp=%~n1.geocsv
@rem osmcoverer has a fixed output file (only folder can be configured)
SET osm=output\output.geojson

@rem Grid and Marker Colors: #40B0F0=PokeStop Blue, #FF2020=PokeBall Red, #7080C0=ExRaid Egg Purple, #808080=Gray, #000000=Black, #800000=Dark Red
set ColorStop=#40B0F0
set ColorGym=#FF2020
set ColorExGym=#7080C0
set ColorUnknown=#808080
set ColorNone=#000000
set ColorRemoved=#800000

@rem Marker Styles: circle-stroked: Stop, minefield: Gym, star-stroked: Ex Raid, marker-stroked: Unknown, <null>: None, cross: Removed
set StyleStop=circle-stroked
set StyleGym=minefield
set StyleExGym=star-stroked
set StyleUnknown=marker-stroked
set StyleNone=
set StyleRemoved=cross

@rem Marker Size: small, medium, large
set Size=small

ECHO Converting input %input% Google Sheets or Excel csv file %tmp%

@rem Remove header
sed -r "/^Location Name/d" %input% > %tmp%

@rem Removes commas between double quotes and removes double quotes after
@rem   ASCII: 34d = 022h = "
sed -r ":r; s/(\x22[^\x22,]+),([^\x22,]*)/\1;\2/g; tr; s/\x22//g" %tmp% > %tmp%1

@rem Translate Location type column = "Unknown/Stop/Gym/Ex Gym/None/Removed" to location prefix
sed -r "s/(^.*,Stop,.*$)/Pokestop: \1/; s/(^.*,Gym,.*$)/Pokegym: \1/; s/(^.*,ExGym,.*$)/Ex Raid Pokegym: \1/; s/(^.*,Unknown,.*$)/Unknown: \1/; s/(^.*,None,.*$)/Not Availble: \1/; s/(^.*,Removed,.*$)/Removed: \1/" %tmp%1 > %tmp%2

@rem Move column 2 contents to column 1 postfix between []
sed -r "s/^([^,]*),([^,]*),(.*)$/\1 \[\2\],,\3/; s/ \[\]//" %tmp%2 > %tmp%3

@rem Seperates column 1,2,3,4 and the rest preserving quoted columns and outputs column 1,3,4
@rem   input: Name One,,lat.itude,lon.titude,..,..,..,,,
@rem   input: "Name, Two",,lat.itude,lon.titude,..,..,..,,,
@rem   ASCII: 34d = 022h = "
@rem sed -r "s/(\x22[^\x22]+\x22|[^,]*),(\x22[^\x22]+\x22|[^,]*),(\x22[^\x22]+\x22|[^,]*),(\x22[^\x22]+\x22|[^,]*),(.*),/\1,\3,\4/" %input% > %tmp%


ECHO Splitting location by type
@rem 'csvfix file_split' would append in destination files even though documentation said it won't
del %typefilename%_*.csv
@rem Split csv based on contents of Stop/Gym/ExRaid column 8, column value added to filename
@rem   -ifn: skip header row 1
@rem   -f 8: split input based on column 8
@rem   -ufn: use split column values in filename
@rem   -fp ...: output filename prefix (not exactly same as input filename or it will recurse infinitely)
csvfix file_split -f 8 -ufn -fp %typefilename%_ %tmp%3


@rem Reduce to 3 required columns Name,Latitude,Longtitude from column 1,3,4
sed -r "s/^([^,]*),([^,]*),([^,]*),([^,]*),.*$/\1,\3,\4/" %tmp%3 > %tmp%4

@rem Remove lines without GPS coordinates
sed -r "/[^,]*,,$/d" %tmp%4 > %tmp%

@rem cleanup intermediate temp files
IF [%keeptmp%] NEQ [1] (
	del %tmp%1
	del %tmp%2
	del %tmp%3
	del %tmp%4
)


FOR %%L IN (13 14 17) DO (
	ECHO Generating S2 grid level %%L in %s2filename%%%L.geojson

	@rem Convert csv to geojson with S2 grid level X, output filename is fixed
	@rem   Error: 'panic: strconv.ParseFloat: parsing "": invalid syntax' -> On lines with a name without GPS coordinates
	osmcoverer -markers=%tmp% -grid=%%L 1> nul

	@rem Select only features array first element that is the S2 grid, this looses parent structure { x, features: [..]}
	rem jq-win64.exe ".features[ 0 ]" %osm% > %s2filename%%%L.geojson1
	@rem Select only features array first element that is the S2 grid and keep parent structure
	jq-win64.exe "del( .features[] | select(.geometry.type == \"Point\") )" %osm% > %s2filename%%%L.geojson1
)

@rem Changes one value in json
@rem jq-win64.exe ".features[0].properties.\"stroke-width\"=2" output/output.geojson |more


ECHO Changing Color and Style S2 Grids
jq-win64.exe ".features[].properties={ \"stroke\": \"%ColorStop%\" , \"stroke-opacity\": 0.5,\"fill\": \"%ColorStop%\" ,\"fill-opacity\": 0.1, \"stroke-width\": 0.2 }" %s2filename%17.geojson1 > %s2filename%17.geojson
jq-win64.exe ".features[].properties={ \"stroke\": \"%ColorGym%\"  , \"stroke-opacity\": 0.5,\"fill\": \"%ColorGym%\"  ,\"fill-opacity\": 0.1, \"stroke-width\": 1   }" %s2filename%14.geojson1 > %s2filename%14.geojson
jq-win64.exe ".features[].properties={ \"stroke\": \"%ColorExGym%\", \"stroke-opacity\": 0.5,\"fill\": \"%ColorExGym%\",\"fill-opacity\": 0.1, \"stroke-width\": 2   }" %s2filename%13.geojson1 > %s2filename%13.geojson


@rem cleanup intermediate temp files
IF [%keeptmp%] NEQ [1] (
	del %tmp%
	del %s2filename%13.geojson1
	del %s2filename%14.geojson1
	del %s2filename%17.geojson1
)


FOR %%T IN (%typefilename%_*.csv) DO (
	ECHO Generating Locations from %%~nT.geocsv in %%~nT.geojson

	@rem Reduce to 3 required columns Name,Latitude,Longtitude from column 1,3,4
	sed -r "s/^([^,]*),([^,]*),([^,]*),([^,]*),.*$/\1,\3,\4/" %%T > %%~nT.geocsv1

	@rem Remove lines without GPS coordinates
	sed -r "/[^,]*,,$/d" %%~nT.geocsv1 > %%~nT.geocsv
	
	@rem Convert csv to geojson with S2 grid level 12, output filename is fixed
	osmcoverer -markers=%%~nT.geocsv -grid=12 1> nul

	@rem cleanup intermediate temp files
	IF [%keeptmp%] NEQ [1] (
		del %%~nT.geocsv
		del %%~nT.geocsv1
	)
	
	@rem Output a new array with all features array elements that have a geometry type containing 'Point'
	@rem jq-win64.exe "[.features[] | select(.geometry.type | contains(\"Point\"))]" output\output.geojson

	@rem Removes feature array element 0 which is the S2 grid added by osmcoverer
	rem jq-win64.exe "del( .features[ 0 ] )" %osm% > %%~nT.geojson1
	@rem Removes feature array element 0 which is the S2 grid added by osmcoverer, also delete level12 cellid we don't need
	jq-win64.exe "del( .features[ 0 ] ) | del( .features[].properties.level12cellid )" %osm% > %%~nT.geojson1
	 
)

@rem cleanup osmcoverer result files
IF [%keeptmp%] NEQ [1] (
	del %osm%
	del output\markers_within_features.csv
)

ECHO Changing Color and Style Type Locations
@rem jq 1.5 32 and 64 bit version suddenly started crashing while testing, using jq 1.4 64 bit now
jq-win64.exe ".features[].properties.\"marker-color\"=\"%ColorStop%\"    | .features[].properties.\"marker-size\"=\"%Size%\" | .features[].properties.\"marker-symbol\"=\"%StyleStop%\"   " %typefilename%_Stop.geojson1    > %typefilename%_Stop.geojson
jq-win64.exe ".features[].properties.\"marker-color\"=\"%ColorGym%\"     | .features[].properties.\"marker-size\"=\"%Size%\" | .features[].properties.\"marker-symbol\"=\"%StyleGym%\"    " %typefilename%_Gym.geojson1     > %typefilename%_Gym.geojson
jq-win64.exe ".features[].properties.\"marker-color\"=\"%ColorExGym%\"   | .features[].properties.\"marker-size\"=\"%Size%\" | .features[].properties.\"marker-symbol\"=\"%StyleExGym%\"  " %typefilename%_ExGym.geojson1   > %typefilename%_ExGym.geojson
jq-win64.exe ".features[].properties.\"marker-color\"=\"%ColorUnknown%\" | .features[].properties.\"marker-size\"=\"%Size%\" | .features[].properties.\"marker-symbol\"=\"%StyleUnknown%\"" %typefilename%_Unknown.geojson1 > %typefilename%_Unknown.geojson
jq-win64.exe ".features[].properties.\"marker-color\"=\"%ColorNone%\"    | .features[].properties.\"marker-size\"=\"%Size%\" | .features[].properties.\"marker-symbol\"=\"%StyleNone%\"   " %typefilename%_None.geojson1    > %typefilename%_None.geojson
jq-win64.exe ".features[].properties.\"marker-color\"=\"%ColorRemoved%\" | .features[].properties.\"marker-size\"=\"%Size%\" | .features[].properties.\"marker-symbol\"=\"%StyleRemoved%\"" %typefilename%_Removed.geojson1 > %typefilename%_Removed.geojson

IF [%keeptmp%] NEQ [1] (
	del %typefilename%_Stop.geojson1
	del %typefilename%_Gym.geojson1
	del %typefilename%_ExGym.geojson1
	del %typefilename%_Unknown.geojson1
	del %typefilename%_None.geojson1
	del %typefilename%_Removed.geojson1
)

ECHO Combine all data
@rem Help: "Merge arrays in two json files" https://github.com/stedolan/jq/issues/502
@rem Reduces the array of the objects in all files to one object
@rem Then combines all "features" records in a new "features" array
@rem Adds the type: property again (at the end)
jq-win64.exe -s "reduce .[] as $dot ({}; .features += $dot.features)  | .type=\"FeatureCollection\"" %typefilename%_Stop.geojson %typefilename%_Gym.geojson %typefilename%_ExGym.geojson %typefilename%_Unknown.geojson %typefilename%_None.geojson %typefilename%_Removed.geojson %s2filename%17.geojson %s2filename%14.geojson %s2filename%13.geojson > %filename%_New.geojson


GOTO End

:NotFound
ECHO Error: Parameter 1 filename "%input%" is not found.

:End
