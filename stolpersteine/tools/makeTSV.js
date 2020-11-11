const fs = require('fs')
const sqlite = require('sqlite3')

const db = new sqlite.Database('./stolpersteine/db.sqlite3', function withTable (error) {
  if (!error) {
    db.all('select lat, lng from stein', [], function processSteins (error, rows) {
      if (!error) {
        fs.writeFileSync(
          './stolpersteine/all.tsv',
          rows.map(function (row) {
            return [row.lat, row.lng].join('\t')
          }).join('\n')
        )
      }
    })
  }
})
