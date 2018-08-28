@ECHO OFF
cls
set keeptmp=1

@rem Help:    https://stedolan.github.io/jq/manual
@rem Testing: https://jqplay.org/

@rem Input CSV filename parameter 1
SET input=%1

IF NOT EXIST "%1" GOTO NotFound
mkdir tmp

@rem Prefix/Filename only
SET filename=tmp\%~n1
@rem Prefix/Filename for S2 grids
SET s2filename=tmp\%~n1_S2_Level
@rem Prefix/Filename for csv files split by type
SET typefilesplit=%~n1_Type
SET typefilename=tmp\%typefilesplit%
@rem Temporary filename after csv sed corection
SET tmp=tmp\%~n1.geocsv
@rem osmcoverer has a fixed output file (only folder can be configured)
SET osm=tmp\output.geojson
@rem osmcoverer pretty formatted and indented output or not? (true/false)
SET pretty=false
@rem Overpass turbo map of confirmed land use areas for ex-raid gyms
SET opt=%2
@rem Overpass turbo map of confirmed land use areas for ex-raid gyms temp file
SET opttmp=tmp\%2


@rem Grid and Marker Colors: #40B0F0=PokeStop Blue, #FF2020=PokeBall Red, #ff9900=Orange, #7080C0=ExRaid Egg Purple, #808080=Gray, #000000=Black, #800000=Dark Red, #000080=Dark Blue, #804000=Brown, #008000=Dark Green
set ColorStop=#40B0F0
set ColorGym=#ff9900
set ColorExGym=#FF2020
set ColorUnknown=#808080
set ColorNone=#000000
set ColorRemoved=#800000
set ColorPending=#000080
set ColorReject=#804000
set ColorPark=#008000

@rem Marker Styles: circle-stroked: Stop, minefield: Gym, star-stroked: Ex Raid, marker-stroked: Unknown, <null>: None, cross: Removed, parking: Pending, roadblock=rejected
@rem Available symbols are from https://www.mapbox.com/maki-icons/ and test them on geojson.io
set StyleStop=circle-stroked
set StyleGym=fire-station
set StyleExGym=minefield
set StyleUnknown=marker-stroked
set StyleNone=
set StyleRemoved=cross
set StylePending=parking
set StyleReject=roadblock

@rem Marker Size: small, medium, large
set Size=small
set SizeExGym=small

ECHO Converting input %input% Google Sheets or Excel csv file %tmp%

@rem Remove header
bin\sed\sed -r "/^Location Name/d" %input% > %tmp%

@rem Removes commas between double quotes and removes double quotes after
@rem   ASCII: 34d = 022h = "
bin\sed\sed -r ":r; s/(\x22[^\x22,]+),([^\x22,]*)/\1;\2/g; tr; s/\x22//g" %tmp% > %tmp%1

@rem Translate Location type column = "Unknown/Stop/Gym/Ex Gym/None/Removed" to location prefix
rem bin\sed\sed -r "s/(^.*,Stop,.*$)/Pokestop: \1/; s/(^.*,Gym,.*$)/Pokegym: \1/; s/(^.*,ExGym,.*$)/Ex Raid Pokegym: \1/; s/(^.*,Unknown,.*$)/Unknown: \1/; s/(^.*,None,.*$)/Not Availble: \1/; s/(^.*,Removed,.*$)/Removed: \1/" %tmp%1 > %tmp%2
@rem Space saving version
bin\sed\sed -r "s/(^.*,Stop,.*$)/Stop: \1/; s/(^.*,Gym,.*$)/Gym: \1/; s/(^.*,ExGym,.*$)/Ex-raid Gym: \1/; s/(^.*,Unknown,.*$)/Unknown: \1/; s/(^.*,None,.*$)/Not Availble: \1/; s/(^.*,Removed,.*$)/Removed: \1/; s/(^.*,Pending,.*$)/Pending request: \1/; s/(^.*,Rejected,.*$)/Rejected request: \1/ " %tmp%1 > %tmp%2

@rem Move column 2 contents to column 1 postfix between []
bin\sed\sed -r "s/^([^,]*),([^,]*),(.*)$/\1 \[\2\],,\3/; s/ \[\]//" %tmp%2 > %tmp%3

@rem Seperates column 1,2,3,4 and the rest preserving quoted columns and outputs column 1,3,4
@rem   input: Name One,,lat.itude,lon.titude,..,..,..,,,
@rem   input: "Name, Two",,lat.itude,lon.titude,..,..,..,,,
@rem   ASCII: 34d = 022h = "
@rem sed -r "s/(\x22[^\x22]+\x22|[^,]*),(\x22[^\x22]+\x22|[^,]*),(\x22[^\x22]+\x22|[^,]*),(\x22[^\x22]+\x22|[^,]*),(.*),/\1,\3,\4/" %input% > %tmp%


ECHO Splitting location by type
@rem 'csvfix file_split' would append in destination files even though documentation said it won't
del %typefilename%_*.csv 2> nul
@rem Split csv based on contents of Stop/Gym/ExRaid column 9, column value added to filename
@rem   -ifn: skip header row 1
@rem   -f 9: split input based on column 9
@rem   -ufn: use split column values in filename
@rem   -fd ...: output file in directory (directory in fp is not used)
@rem   -fp ...: output filename prefix (not exactly same as input filename or it will recurse infinitely)
bin\csvfix\csvfix file_split -f 9 -ufn -fd tmp -fp %typefilesplit%_ %tmp%3


@rem Reduce to 3 required columns Name,Latitude,Longtitude from column 1,5,6
bin\sed\sed -r "s/^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*).*$/\1,\5,\6/" %tmp%3 > %tmp%4

@rem Remove lines without GPS coordinates
bin\sed\sed -r "/[^,]*,,$/d" %tmp%4 > %tmp%

@rem cleanup intermediate temp files
IF [%keeptmp%] NEQ [1] (
	del %tmp%1
	del %tmp%2
	del %tmp%3
	del %tmp%4
)


@rem S2 Level 13: 1 Ex raid gym
@rem S2 Level 14: >=2 stops = 1 gym, >=6 stops = 2 gyms, >=20 = 3 gyms
@rem S2 Level 17: 1 Stop
FOR %%L IN (13 14 17) DO (
	ECHO Generating S2 grid level %%L in %s2filename%%%L.geojson

	@rem Convert csv to geojson with S2 grid level X, output filename is fixed
	@rem   Error: 'panic: strconv.ParseFloat: parsing "": invalid syntax' -> On lines with a name without GPS coordinates
	bin\osmcoverer\osmcoverer -pretty=%pretty% -outdir=tmp -markers=%tmp% -grid=%%L 1> nul

	@rem Select only features array first element that is the S2 grid, this looses parent structure { x, features: [..]}
	rem jq-win64.exe ".features[ 0 ]" %osm% > %s2filename%%%L.geojson1
	@rem Select only features array first element that is the S2 grid and keep parent structure
	bin\jq\jq-win64.exe -c "del( .features[] | select(.geometry.type == \"Point\") )" %osm% > %s2filename%%%L.geojson1
)

@rem Changes one value in json
@rem jq-win64.exe ".features[0].properties.\"stroke-width\"=2" output/output.geojson |more


ECHO Changing Color and Style S2 Grids
bin\jq\jq-win64.exe -c ".features[].properties={ \"stroke\": \"%ColorStop%\" , \"stroke-opacity\": 0.35,\"fill\": \"%ColorStop%\" ,\"fill-opacity\": 0.05, \"stroke-width\": 0.5}" %s2filename%17.geojson1 > %s2filename%17.geojson
bin\jq\jq-win64.exe -c ".features[].properties={ \"stroke\": \"%ColorGym%\"  , \"stroke-opacity\": 0.35,\"fill\": \"%ColorGym%\"  ,\"fill-opacity\": 0.05, \"stroke-width\": 1  }" %s2filename%14.geojson1 > %s2filename%14.geojson
bin\jq\jq-win64.exe -c ".features[].properties={ \"stroke\": \"%ColorExGym%\", \"stroke-opacity\": 0.35,\"fill\": \"%ColorExGym%\",\"fill-opacity\": 0.05, \"stroke-width\": 1.5}" %s2filename%13.geojson1 > %s2filename%13.geojson


@rem cleanup intermediate temp files
IF [%keeptmp%] NEQ [1] (
	del %tmp%
	del %s2filename%13.geojson1
	del %s2filename%14.geojson1
	del %s2filename%17.geojson1
)


FOR %%T IN (%typefilename%_*.csv) DO (
	ECHO Generating Locations from %%~nT.geocsv in %%~nT.geojson

	@rem Reduce to 3 required columns Name,Latitude,Longtitude from column 1,5,6
    bin\sed\sed -r "s/^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*),([^,]*).*$/\1,\5,\6/" %%T > tmp\%%~nT.geocsv1

	@rem Remove lines without GPS coordinates
	bin\sed\sed -r "/[^,]*,,$/d" tmp\%%~nT.geocsv1 > tmp\%%~nT.geocsv
	
	@rem Convert csv to geojson with S2 grid level 12, output filename is fixed
	bin\osmcoverer\osmcoverer -pretty=%pretty% -outdir=tmp -markers=tmp\%%~nT.geocsv -grid=12 1> nul

	@rem Output a new array with all features array elements that have a geometry type containing 'Point'
	@rem jq-win64.exe "[.features[] | select(.geometry.type | contains(\"Point\"))]" output\output.geojson

	@rem Removes feature array element 0 which is the S2 grid added by osmcoverer
	rem jq-win64.exe "del( .features[ 0 ] )" %osm% > %%~nT.geojson1
	@rem Removes feature array element 0 which is the S2 grid added by osmcoverer, also delete level12 and level20 cellid and *within arrays we don't need them
	bin\jq\jq-win64.exe -c "del( .features[ 0 ] ) | del( .features[].properties.level12cellid ) | del( .features[].properties.level20cellid ) | del( .features[].properties.within ) | del( .features[].properties.centerwithin )" %osm% > tmp\%%~nT.geojson1

    @rem Copy properties name to properties title, for mouseover tip
	REM bin\jq\jq-win64.exe -c ".features[].properties.title=.features[].properties.name" tmp\%%~nT.geojson1 > tmp\%%~nT.geojson2
	REM bin\jq\jq-win64.exe ".features[].properties.title=.features[].properties.name" tmp\%%~nT.geojson1 > tmp\%%~nT.geojson2
	REM copy tmp\%%~nT.geojson1 > tmp\%%~nT.geojson2
    @rem Copy properties name to properties title, for mouseover tip and reconstructs features object
    bin\jq\jq-win64.exe ".features[] | .properties.title = .properties.name " tmp\%%~nT.geojson1 | bin\jq\jq-win64.exe -s "reduce . as $dot ( null; .features += $dot ) | .type=\"FeatureCollection\" " > tmp\%%~nT.geojson2
	
	@rem cleanup intermediate temp files
	IF [%keeptmp%] NEQ [1] (
		del tmp\%%~nT.geocsv
		del tmp\%%~nT.geocsv1
		del tmp\%%~nT.geojson1
	)
)

@rem cleanup osmcoverer result files
IF [%keeptmp%] NEQ [1] (
	del %osm%
	del tmp\markers_within_features.csv
)


ECHO Changing Color and Style Type Locations
@rem jq 1.5 32 and 64 bit version suddenly started crashing while testing, using jq 1.4 64 bit now
bin\jq\jq-win64.exe -c ".features[].properties.\"marker-color\"=\"%ColorStop%\"    | .features[].properties.\"marker-size\"=\"%Size%\"      | .features[].properties.\"marker-symbol\"=\"%StyleStop%\"   " %typefilename%_Stop.geojson2     > %typefilename%_Stop.geojson
bin\jq\jq-win64.exe -c ".features[].properties.\"marker-color\"=\"%ColorGym%\"     | .features[].properties.\"marker-size\"=\"%Size%\"      | .features[].properties.\"marker-symbol\"=\"%StyleGym%\"    " %typefilename%_Gym.geojson2      > %typefilename%_Gym.geojson
bin\jq\jq-win64.exe -c ".features[].properties.\"marker-color\"=\"%ColorExGym%\"   | .features[].properties.\"marker-size\"=\"%SizeExGym%\" | .features[].properties.\"marker-symbol\"=\"%StyleExGym%\"  " %typefilename%_ExGym.geojson2    > %typefilename%_ExGym.geojson
bin\jq\jq-win64.exe -c ".features[].properties.\"marker-color\"=\"%ColorUnknown%\" | .features[].properties.\"marker-size\"=\"%Size%\"      | .features[].properties.\"marker-symbol\"=\"%StyleUnknown%\"" %typefilename%_Unknown.geojson2  > %typefilename%_Unknown.geojson
bin\jq\jq-win64.exe -c ".features[].properties.\"marker-color\"=\"%ColorNone%\"    | .features[].properties.\"marker-size\"=\"%Size%\"      | .features[].properties.\"marker-symbol\"=\"%StyleNone%\"   " %typefilename%_None.geojson2     > %typefilename%_None.geojson
bin\jq\jq-win64.exe -c ".features[].properties.\"marker-color\"=\"%ColorRemoved%\" | .features[].properties.\"marker-size\"=\"%Size%\"      | .features[].properties.\"marker-symbol\"=\"%StyleRemoved%\"" %typefilename%_Removed.geojson2  > %typefilename%_Removed.geojson
bin\jq\jq-win64.exe -c ".features[].properties.\"marker-color\"=\"%ColorPending%\" | .features[].properties.\"marker-size\"=\"%Size%\"      | .features[].properties.\"marker-symbol\"=\"%StylePending%\"" %typefilename%_Pending.geojson2  > %typefilename%_Pending.geojson
bin\jq\jq-win64.exe -c ".features[].properties.\"marker-color\"=\"%ColorReject%\"  | .features[].properties.\"marker-size\"=\"%Size%\"      | .features[].properties.\"marker-symbol\"=\"%StyleReject%\" " %typefilename%_Rejected.geojson2 > %typefilename%_Rejected.geojson

IF [%keeptmp%] NEQ [1] (
	del %typefilename%_Stop.geojson2
	del %typefilename%_Gym.geojson2
	del %typefilename%_ExGym.geojson2
	del %typefilename%_Unknown.geojson2
	del %typefilename%_None.geojson2
	del %typefilename%_Removed.geojson2
	del %typefilename%_Pending.geojson2
	del %typefilename%_Rejected.geojson2
)


IF EXIST %opt% (
	ECHO Changing Color and Style Parks
	@rem Remove unused keys
	bin\jq\jq-win64.exe -c " del ( .features[].properties.source )" %opt% > %opttmp%1
	@rem Add color and style
	bin\jq\jq-win64.exe -c ".features[].properties.\"stroke\"=\"%ColorPark%\" | .features[].properties.\"stroke-opacity\"=0.35 | .features[].properties.\"fill\"=\"%ColorPark%\" | .features[].properties.\"fill-opacity\"=0.05 | .features[].properties.\"stroke-width\"=1 " %opttmp%1 > %opttmp%

	IF [%keeptmp%] NEQ [1] (
		del %opttmp%1
	)
	
) ELSE SET opttmp=


ECHO Combine all (markers only)
@rem Help: "Merge arrays in two json files" https://github.com/stedolan/jq/issues/502
@rem Reduces the array of the objects in all files to one object
@rem Then combines all "features" records in a new "features" array
@rem Adds the type: property again (at the end)
@rem -c=Compact output, --tab=1-tab instead of 2-spaces (not working in this version)
@REM bin\jq\jq-win64.exe -c -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Stop.geojson %typefilename%_Gym.geojson %typefilename%_ExGym.geojson %typefilename%_Unknown.geojson %typefilename%_None.geojson %typefilename%_Removed.geojson %typefilename%_Pending.geojson %s2filename%17.geojson %s2filename%14.geojson %s2filename%13.geojson %opttmp% > %~n1_min.geojson
@REM bin\jq\jq-win64.exe    -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Stop.geojson %typefilename%_Gym.geojson %typefilename%_ExGym.geojson %typefilename%_Unknown.geojson %typefilename%_None.geojson %typefilename%_Removed.geojson %typefilename%_Pending.geojson %s2filename%17.geojson %s2filename%14.geojson %s2filename%13.geojson %opttmp% > %~n1.geojson
ECHO Combine all Gym location data without grids
bin\jq\jq-win64.exe -c -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Gym.geojson %typefilename%_ExGym.geojson > %~n1_raid_min.geojson
bin\jq\jq-win64.exe    -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Gym.geojson %typefilename%_ExGym.geojson > %~n1_raid.geojson
ECHO Combine all Gym location data with gym grid
bin\jq\jq-win64.exe -c -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Gym.geojson %typefilename%_ExGym.geojson %s2filename%14.geojson > %~n1_gymonly_min.geojson
bin\jq\jq-win64.exe    -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Gym.geojson %typefilename%_ExGym.geojson %s2filename%14.geojson > %~n1_gymonly.geojson
ECHO Combine all location data without grids
bin\jq\jq-win64.exe -c -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Stop.geojson %typefilename%_Gym.geojson %typefilename%_ExGym.geojson %typefilename%_Unknown.geojson %typefilename%_Pending.geojson > %~n1_min.geojson
bin\jq\jq-win64.exe    -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Stop.geojson %typefilename%_Gym.geojson %typefilename%_ExGym.geojson %typefilename%_Unknown.geojson %typefilename%_Pending.geojson > %~n1.geojson
ECHO Combine all (Ex-Raid) gym placement data (no stop grid) (less than 1Mb for geojson github limit)
bin\jq\jq-win64.exe -c -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Stop.geojson %typefilename%_Gym.geojson %typefilename%_ExGym.geojson %typefilename%_Unknown.geojson %typefilename%_None.geojson %typefilename%_Removed.geojson %typefilename%_Pending.geojson %typefilename%_Rejected.geojson %s2filename%14.geojson %s2filename%13.geojson %opttmp% > %~n1_gym_min.geojson
bin\jq\jq-win64.exe    -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Stop.geojson %typefilename%_Gym.geojson %typefilename%_ExGym.geojson %typefilename%_Unknown.geojson %typefilename%_None.geojson %typefilename%_Removed.geojson %typefilename%_Pending.geojson %typefilename%_Rejected.geojson %s2filename%14.geojson %s2filename%13.geojson %opttmp% > %~n1_gym.geojson
ECHO Combine all stop placement data (no ex raid and gym grid)
bin\jq\jq-win64.exe -c -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Stop.geojson %typefilename%_Gym.geojson %typefilename%_ExGym.geojson %typefilename%_Unknown.geojson %typefilename%_None.geojson %typefilename%_Removed.geojson %typefilename%_Pending.geojson %typefilename%_Rejected.geojson %s2filename%17.geojson %s2filename%14.geojson > %~n1_stop_min.geojson
bin\jq\jq-win64.exe    -s "reduce .[] as $dot ({}; .features += $dot.features) | .type=\"FeatureCollection\"" %typefilename%_Stop.geojson %typefilename%_Gym.geojson %typefilename%_ExGym.geojson %typefilename%_Unknown.geojson %typefilename%_None.geojson %typefilename%_Removed.geojson %typefilename%_Pending.geojson %typefilename%_Rejected.geojson %s2filename%17.geojson %s2filename%14.geojson > %~n1_stop.geojson


GOTO End

:NotFound
ECHO Error: Parameter 1 filename "%input%" is not found.

:End
