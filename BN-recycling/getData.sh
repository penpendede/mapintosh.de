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
