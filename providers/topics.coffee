{MongoProvider} = require 'mongodb-provider'
config = require '../config'

module.exports = topics = new MongoProvider(config.db, 'topics')
