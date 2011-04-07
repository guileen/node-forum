module.exports = 

  getHome: (req, res) ->
    db.topics.findItems {},{comments: 0},{sort: [['lastUpdate', -1]]}, (err, topics) ->
      res.render 'topic/list', 
        topics: topics
        title: 'Home'

