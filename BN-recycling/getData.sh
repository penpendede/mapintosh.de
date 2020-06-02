mkdir -p data

curl -o data/bonn.geojson 'https://stadtplan.bonn.de/geojson?Thema=21248'

curl 'https://stadtplan.bonn.de/geojson?Thema=17238' | \
	iconv -f CP1252 -t UTF-8 | \
	jq '{ type: .type, features: (.features | map( select( .geometry != null ) ) ) }' | \
	geojson-to-sqlite --spatialite data/recycling.sqlite altglas -

curl 'https://stadtplan.bonn.de/geojson?Thema=17244' | \
	iconv -f CP1252 -t UTF-8 | \
	jq '{ type: .type, features: (.features | map( select( .geometry != null ) ) ) }' | \
	geojson-to-sqlite --spatialite data/recycling.sqlite altpapier -

curl 'https://stadtplan.bonn.de/geojson?Thema=20478' | \
	iconv -f CP1252 -t UTF-8 | \
	jq '{ type: .type, features: (.features | map( select( .geometry != null ) ) ) }' | \
	geojson-to-sqlite --spatialite data/recycling.sqlite alttextil -

curl 'https://stadtplan.bonn.de/geojson?Thema=17246' | \
	iconv -f CP1252 -t UTF-8 | \
	jq '{ type: .type, features: (.features | map( select( .geometry != null ) ) ) }' | \
	geojson-to-sqlite --spatialite data/recycling.sqlite elektrokleingeraete -

curl 'https://stadtplan.bonn.de/geojson?Thema=14745' | \
	iconv -f CP1252 -t UTF-8 | \
	jq '{ type: .type, features: (.features | map( select( .geometry != null ) ) ) }' | \
	geojson-to-sqlite --spatialite data/recycling.sqlite gruen -

curl 'https://stadtplan.bonn.de/geojson?Thema=17250' | \
	iconv -f CP1252 -t UTF-8 | \
	jq '{ type: .type, features: (.features | map( select( .geometry != null ) ) ) }' | \
	geojson-to-sqlite --spatialite data/recycling.sqlite wertUndSchadstoffe -

echo "var altglas=[" > data/altglas.js
spatialite data/recycling.sqlite >> data/altglas.js <<ALTGLAS
.headers off
select '[' || x(geometry) || ',' || y(geometry) || ',"Glas (' || container_id || ')","' || standort || '"],'
from altglas;
ALTGLAS
echo "]" >> data/altglas.js

echo "var altpapier=[" > data/altpapier.js
spatialite data/recycling.sqlite >> data/altpapier.js <<ALTPAPIER
.headers off
select '[' || x(geometry) || ',' || y(geometry) || ',"Papier (' || container_id || ')","' || standort || '"],'
from altpapier;
ALTPAPIER
echo "]" >> data/altpapier.js

echo "var alttextil=[" > data/alttextil.js
spatialite data/recycling.sqlite >> data/alttextil.js <<ALTTEXTIL
.headers off
select '[' || x(geometry) || ',' || y(geometry) || ',"Textil (' || container_id || ')","' || standort || '"],'
from alttextil;
ALTTEXTIL
echo "]" >> data/alttextil.js

echo "var elektrokleingeraete=[" > data/elektrokleingeraete.js
spatialite data/recycling.sqlite >> data/elektrokleingeraete.js <<ELEKTRO
.headers off
select '[' || x(geometry) || ',' || y(geometry) || ',"Elektro (' || container_id || ')","' || standort || '"],'
from elektrokleingeraete;
ELEKTRO
echo "]" >> data/elektrokleingeraete.js

echo "var gruen=[" > data/gruen.js
spatialite data/recycling.sqlite >> data/gruen.js <<GRUEN
.headers off
select '[' || x(geometry) || ',' || y(geometry) || ',"Grün (' || container_id || ')","' ||
'<table>' ||
'<tr><th>Standort</th><td>' || standort || '</td></tr>' ||
'<tr><th>Containertyp</th><td>' || containertyp_bez || ' (' || containertyp || ')</td></tr>' ||
'<tr><th>Abfuhrtermine</th><td>' || abfuhrtermine || '</td></tr>' ||
'<tr><th>Bemerkung</th><td>' || bemerkung || '</td></tr>' ||
'</table>"],'
from gruen;
GRUEN
echo "]" >> data/gruen.js

echo "var wertUndSchadstoffe=[" > data/wertUndSchadstoffe.js
spatialite data/recycling.sqlite >> data/wertUndSchadstoffe.js <<WERTUNDSCHADSTOFFE
.headers off
select '[' || x(geometry) || ',' || y(geometry) || ',"Wert- und Schadstoffe (' || container_id || ')","' ||
'<table>' ||
'<tr><th>Standort</th><td>' || standort || '</td></tr>' ||
'<tr><th>Abfuhrtermine</th><td>' || abfuhrtermine || '</td></tr>' ||
'<tr><th>Bemerkung</th><td>' || bemerkung || '</td></tr>' ||
'</table>"],'
from wertUndSchadstoffe;
WERTUNDSCHADSTOFFE
echo "]" >> data/wertUndSchadstoffe.js
