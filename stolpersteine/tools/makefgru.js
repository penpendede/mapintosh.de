const fs = require('fs')
const sqlite = require('sqlite3')

const FS = '\x1c' // File separator
const GS = '\x1d' // Group separator
const RS = '\x1e' // Record separator
const US = '\x1f' // Unit separator

const data = []
let currentId = -1
let currentIdx = -1
let k
let v

const db = new sqlite.Database('./stolpersteine/db.sqlite3', function withTable (error) {
  if (!error) {
    db.all('SELECT * FROM stein JOIN kv ON stein.id = kv.nodeid ORDER BY stein.id', [], function processSteins (error, rows) {
      if (!error) {
        rows.forEach(function (row) {
          if (row.id !== currentId) {
            k = row.key
            v = row.value
            delete row.key
            delete row.value
            row.kvs = [[k.replace(/\s+/g, ' '), v.replace(/\s+/g, ' ')]]
            data.push(row)
            currentId = row.id
            currentIdx++
          } else {
            data[currentIdx].kvs.push([row.key.replace(/\s+/g, ' '), row.value.replace(/\s+/g, ' ')])
          }
        })
        fs.writeFileSync(
          './stolpersteine/all.fgru',
          data.map(function (row) {
            return row.lat + RS + row.lng + GS + row.kvs.map(function (row) { return row[0] + US + row[1] }).join(RS)
          }).join(FS)
        )
      }
    })
  }
})
