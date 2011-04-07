{Db, Server} = require 'mongodb'
host = 'localhost'
port = 27017
database = 'node-fourm'

module.exports = config = 
  db : new Db(database, new Server(host, port, {}), {})

console.log "connecting to  mongodb://#{host}:#{port}/#{database} "
config.db.open (err, db) ->
  if err
    console.log 'fail to open database'
    console.log err.stack
  else
    console.log 'done'


