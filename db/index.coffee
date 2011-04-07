mongo = require 'mongoskin'
path  = require 'path'
module.exports = db = mongo.db settings.database

['topics','taginfo', 'users'].forEach (name)->
  if path.existsSync './'+name
    db.bind name, require './'+name
    if db[name].initialize
      db[name].initialize()
  else
    db.bind name
