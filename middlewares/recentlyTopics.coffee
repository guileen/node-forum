Topic = require '../providers/topics'

module.exports = (req, res, next) ->
  Topic.findItems {},{comments: 0},{sort: [['lastUpdate', -1]]}, (err, topics) ->
    if err
      next err
    req.recentlyTopics = topics
    next()
