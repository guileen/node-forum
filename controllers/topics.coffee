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

