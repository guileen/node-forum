Topic = require '../providers/topics'
mongodb = require 'mongodb'
ObjectID = mongodb.BSONNative.ObjectID

checkTags = (tags, fn) ->
  tags = tags.replace /\s+,/g, ' '
  tags = tags.replace /\s+$/g, ''
  if tags.length > 0
    tags = tags.split(' ')
    fn null, tags
  else
    fn null, []

module.exports = 

  paramTopicId: (req, res, next, id) ->
    if id
      Topic.findOne _id : ObjectID.createFromHexString(id), (err, topic) ->
        if err
          return next err
        if not topic
          return next new Error 'fail to find topic'
        req.topic = topic
        next()
    else
      next()

  getTopics : (req, res) ->
    Topic.findItems {}, {comments:0}, {sort: [['lastUpdate', -1]]}, (err, topics) ->
      res.render 'topic/list', 
        topics: topics
        title: 'Latest topics'

  getTaggedTopics : (req, res) ->
    tags = req.params.tags.split('+')
    Topic.findItems { tags : { $all : tags } }, {sort: [['lastUpdate', -1]]}, (err, topics) ->
      res.render 'topic/list', 
        topics: topics
        title: 'Latest topics'

  getNewTopic : (req, res) ->
    res.render 'topic/new',
      title: 'New Topic'

  getModifyTopic : (req, res) ->
    res.render 'topic/edit',
      title: 'Modify Topic'
      topic: req.topic

  getTopic : (req, res) ->
    res.render 'topic/show', 
      topic: req.topic
      title: req.topic.title

  postTopic : (req, res) ->
    checkTags req.body.tags, (err, tags) ->
      topic = req.topic or {
        author: req.session.user,
        numComments: 0,
        voteUp: 0,
        voteDown: 0,
        vote: 0,
        createDate: new Date()
      }

      topic.title= req.body.title
      topic.content = req.body.content
      topic.lastUpdate = new Date()
      topic.tags = tags or []

      Topic.save topic, (err, topic)->
        res.redirect "/topic/#{topic._id}"

  postComment : (req, res) ->
    topic = req.topic
    index = 0
    if req.param.commentIndex
      if req.query.delete
        topic.comments.splice(req.param.commentIndex, 1)
        topic.numComments--
      else
        index = req.param.commentIndex + 1
        topic.comments[req.param.commentIndex].comment = req.body.comment
    else
      topic.comments or= []
      index = topic.comments.length + 1
      topic.comments.push({
        index: index,
        comment: req.body.comment,
        user: req.session.user,
        createDate: new Date(),
        lastUpdate: new Date()
      })
      topic.numComments++

    Topic.save topic, (err, topic) ->
      res.redirect "/topic/#{topic._id}##{index}"

  postVote: (req, res) ->
    user = req.session.user.username
    operation = req.params.updown
    topic = req.topic
    topic.voteUpUsers or= []
    topic.voteDownUsers or= []
    topic.voteUp or= 0
    topic.voteDown or= 0
    topic.vote or=0
    indexOfVoteUp = topic.voteUpUsers.indexOf(user)
    indexOfVoteDown = topic.voteDownUsers.indexOf(user)
    if ((operation is 'up' and indexOfVoteUp >= 0 ) or (operation is 'down' and indexOfVoteDown >= 0))
      if req.is 'json'
        return res.send {success: false, message: 'You have voted'}
      else 
        return res.redirect "/topic/#{topic._id}"

    if operation is 'up'
      topic.voteUpUsers.push(user)
      topic.voteUp++
      if indexOfVoteDown >=0
        topic.voteDownUsers.splice(indexOfVoteDown, 1)
        topic.voteDown--
    else if operation is 'down'
      topic.voteDownUsers.push(user)
      topic.voteDown++
      if indexOfVoteUp >=0 
        topic.voteUpUsers.splice(indexOfVoteUp, 1)
        topic.voteUp--
    topic.vote = topic.voteUp - topic.voteDown

    Topic.save topic, (err, topic) ->
      if req.is 'json'
        return res.send {success: true, message: 'You have successfully voted'}
      res.redirect "/topic/#{topic._id}"
