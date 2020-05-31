mkdir -p data
curl -o data/tree.data 'https://stadtplan.bonn.de/geojson?Thema=21367'
iconv -f CP1252 -t UTF-8 data/tree.data -o data/tree.json
echo Importing tree data into a spatialite database. This will take quite some time.
geojson-to-sqlite --spatialite data/tree.sqlite tree data/tree.json
spatialite data/tree.sqlite <<CREATEVIEW
create view if not exists v_tree as select
trim(deutscher_name) as name,
'<i>' || trim(lateinischer_name) || '</i><br>' || 'Age: ' || \`alter\` || ' years' as description,
x(geometry) as lon,
y(geometry) as lat
from tree;
CREATEVIEW
curl -o data/bonn.geojson 'https://stadtplan.bonn.de/geojson?Thema=21248'
echo "var treeData = [" > data/tree.js
spatialite data/tree.sqlite >> data/tree.js <<GETJS
.headers off
select '[' || lat || ',' || lon || ',"' || name || '","' || description || '"],' from v_tree;
GETJS
echo "]" >> data/tree.js
