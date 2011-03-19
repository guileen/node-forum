Topic = require '../providers/topics'

module.exports = 

  getHome: (req, res) ->
    Topic.findItems (err, topics) ->
      res.render 'topic/list', 
        topics: topics
        title: 'Home'

