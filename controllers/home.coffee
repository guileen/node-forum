Topic = require '../providers/topics'

module.exports = 

  getHome: (req, res) ->
    Topic.findItems {},{comments: 0},{sort: [['lastUpdate', -1]]}, (err, topics) ->
      res.render 'topic/list', 
        topics: topics
        title: 'Home'

