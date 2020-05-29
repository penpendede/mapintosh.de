mkdir -p geoJSON
curl -o geoJSON/districts.geojson 'https://stadtplan.bonn.de/geojson?Thema=14574'
for i in 0 1 2 3; do
  jq .features[$i] < geoJSON/districts.geojson > geoJSON/district.tmp
  district=$(jq .properties.bezirk_bez < geoJSON/district.tmp | sed -e 's/"//g' -e 's/ /_/g')
  echo > geoJSON/$district.geojson <<PRE
{
  "type": "FeatureCollection",
  "features": [
PRE
  sed -e 's/^/    /' geoJSON/district.tmp >> geoJSON/$district.geojson
  echo >> geoJSON/$district.geojson <<POST
  ]
}
POST
  node -p "JSON.stringify(JSON.parse(require('fs').readFileSync(0, 'utf-8')))" \
	  < geoJSON/$district.geojson > geoJSON/$district.min.geojson
done
rm -f geoJSON/district.tmp
