const convert = require('xml-js')
const sqlite = require('sqlite3')
const hash = require('imurmurhash')
const fs = require('fs')

const requiredAttributes = ['id', 'lat', 'lon', 'version', 'timestamp']
const fileNames = [
  'stolperstein-world/stolperstein-europe.osm',
  'stolperstein-world/stolperstein-russia.osm'
]

function getHash (value) {
  return ('00000000' + hash(value).result().toString(16)).slice(-8)
}
function getHex (value) {
  return ('000000000' + parseInt(value).toString(16)).slice(-9)
}
function getId (id, k, v) {
  return getHex(id) + getHash(k) + getHash(v)
}

const db = new sqlite.Database('./stolpersteine/db.sqlite3', function withTable (error) {
  if (!error) {
    db.serialize(function withSerialized (error) {
      if (!error) {
        db.run('PRAGMA JOURNAL_MODE=OFF')
          .run('PRAGMA SYNCHRONOUS=OFF')
          .run('PRAGMA LOCKING_MODE=EXCLUSIVE')
          .run('PRAGMA TEMP_STORE=MEMORY')
          .run('DROP TABLE IF EXISTS stein')
          .run('DROP TABLE IF EXISTS kv')
          .run(
            'CREATE TABLE stein (' +
            'id INTEGER NOT NULL PRIMARY KEY,' +
            'geometry TEXT,' +
            'version INTEGER,' +
            'timestamp TEXT' +
            ')'
          )
          .run(
            'CREATE TABLE kv (' +
            'hash TEXT PRIMARY KEY,' +
            'nodeid INTEGER,' +
            'key TEXT,' +
            'value TEXT,' +
            'FOREIGN KEY(nodeid) REFERENCES stein(nodeid)' +
            ')'
          )
          .run('BEGIN TRANSACTION')
        const insertStein = db.prepare('INSERT OR REPLACE INTO stein VALUES (?, ?, ?, ?)')
        const insertKv = db.prepare('INSERT OR REPLACE INTO kv VALUES (?, ?, ?, ?)')
        let count = fileNames.length
        fileNames.forEach(function fileLoop (fileName) {
          let data
          fs.readFile(fileName, 'utf8', (err, xml) => {
            if (!err) {
              data = JSON.parse(
                convert.xml2json(xml, {
                  compact: true
                })
              )
              if (data && data.osm && data.osm.node) {
                const nodes = data.osm.node
                nodes.forEach(node => {
                  const attributes = node._attributes
                  let okay = true
                  if (attributes) {
                    requiredAttributes.forEach(attr => {
                      okay = okay && Object.prototype.hasOwnProperty.call(attributes, attr)
                    })
                  }
                  if (okay) {
                    const id = attributes.id
                    insertStein.run(
                      id,
                      '{type: "Point",coordinates:[' + attributes.lon + ',' + attributes.lat + ']}',
                      attributes.version,
                      attributes.timestamp
                    )
                    const tags = node.tag
                    if (tags) {
                      let k
                      let v
                      tags.forEach(tag => {
                        if (tag && tag._attributes) {
                          k = tag._attributes.k
                          v = tag._attributes.v
                          if (k) {
                            insertKv.run(getId(id, k, v), id, k, v)
                          }
                        }
                      })
                    }
                  }
                })
              }
              if (!--count) {
                db.run('COMMIT TRANSACTION')
              }
            }
          })
        })
      }
    })
  }
})
