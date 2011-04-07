module.exports = 
  initialize: ()->
    this.ensureIndex [['username',1],['email',1]], true, (err, reply) ->
      console.log err.stack if err
