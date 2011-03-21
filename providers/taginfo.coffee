{MongoProvider} = require 'mongodb-provider'
config = require '../config'

module.exports = taginfo = new MongoProvider(config.db, 'taginfo')
