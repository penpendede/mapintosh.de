const sqlite = require('sqlite3')
const db = new sqlite.Database('./stolpersteine/db.sqlite3', function withTable (error) {
  if (!error) {
    db.all('select geometry from stein', [], function processSteins (error, rows) {
      if (!error) {
        console.log(rows)
      }
    })
  }
})
