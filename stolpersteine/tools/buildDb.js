const convert = require('xml-js')
const fs = require('fs')

const requiredAttributes = ['id', 'lat', 'lon', 'version', 'timestamp']

fs.readFile('stolperstein-world/stolperstein-russia.osm', 'utf8', (err, xml) => {
  if (!err) {
    const data = JSON.parse(
      convert.xml2json(xml, {
        compact: true
      })
    )
    if (data && data.osm && data.osm.node) {
      const nodes = data.osm.node
      nodes.forEach(node => {
        const attributes = node._attributes
        var okay = true
        if (attributes) {
          requiredAttributes.forEach(attr => {
            okay = okay && Object.prototype.hasOwnProperty.call(attributes, attr)
          })
        }
        if (okay) {
          var id = attributes.id
          console.log(id, attributes.lat, attributes.lon, attributes.version, attributes.timestamp)
          const tags = node.tag
          if (tags) {
            tags.forEach(tag => {
              if (tag && tag._attributes) {
                const key = tag._attributes.k
                const value = tag._attributes.v
                if (key) {
                  console.log(id, key, value)
                }
              }
            })
          }
        }
      })
    }
  }
})
