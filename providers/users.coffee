{MongoProvider} = require 'mongodb-provider'
config = require '../config'

module.exports = users = new MongoProvider config.db, 'users'

users.ensureIndex [['username',1],['email',1]], true, (err, reply) ->
  console.log err.stack if err
