Topic = require '../providers/topics'
mongodb = require 'mongodb'
ObjectID = mongodb.BSONNative.ObjectID

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
    Topic.findItems (err, topics) ->
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
    if req.topic
      topic = req.topic
      topic.title= req.body.title
      topic.content = req.body.content
      topic.lastUpdate = new Date()
    else
      topic = 
        title: req.body.title
        content: req.body.content
        createDate: new Date()
        lastUpdate: new Date()

    Topic.save topic, (err, topic)->
      res.render 'topic/show',
        topic: topic
        title: topic.title

  postComment : (req, res) ->
    topic = req.topic
    console.log 'post comment'
    console.dir topic
    if req.param.commentIndex
      if req.query.delete
        topic.comments.splice(req.param.commentIndex, 1)
      else
        topic.comments[req.param.commentIndex].comment = req.body.comment
    else
      topic.comments or= []
      topic.comments.push({
        comment: req.body.comment,
        user: req.session.user 
      })
    console.log 'modified topic'
    console.dir topic

    Topic.save topic, (err, topic) ->
      res.render 'topic/show'
        topic: topic
        title: topic.title

