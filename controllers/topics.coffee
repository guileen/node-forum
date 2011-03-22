Topic = require '../providers/topics'
TagInfo = require '../providers/taginfo'
mongodb = require 'mongodb'
ObjectID = mongodb.BSONNative.ObjectID

tagsToArray = (tags, fn) ->
  tags = tags.replace /[\s,]+/g, ' '
  tags = tags.replace /\s+$/g, ''
  if tags.length > 0
    tags = tags.split(' ')
    fn null, tags
  else
    fn null, []

compareTags = (oldTags, newTags, fn) ->
  if oldTags and oldTags.length > 0
    removedTags = oldTags.slice()
    addedTags = newTags.slice()
    for i in [addedTags.length - 1 .. 0]
      tag = addedTags[i]
      index = removedTags.indexOf(tag)
      if index >= 0
        removedTags.splice(index, 1)
        addedTags.splice(i, 1)
    fn addedTags, removedTags
  else
    fn newTags, oldTags

getRelativeTags = (tags, fn) ->
  if tags is null or tags.length is 0
    return TagInfo.findItems {}, {limit: 10, sort: [['count', -1]]}, fn
  reduce = 'function(key, values){
    var count = 0;
    for(var i in values){
      count += values[i];
    }
    return count;
  }'

  map = 'function(){
    for(i in this.tags){
      tag = this.tags[i];
      if(tags.indexOf(tag)<0)
        emit(tag, 1);
    }
  }'

  Topic.mapReduce map, reduce, {
    query: {tags:{$all:tags}}
    scope: {tags: tags}
  }, (err, collection) ->
    if err
      if err.result
        console.dir err.result
      return fn err
    collection.find {}, {limit: 10, sort: [['value', -1]]}, (err, cursor)->
      cursor.toArray fn

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
      getRelativeTags null, (err, relativeTags) ->
        res.render 'topic/list', 
          topics: topics
          title: 'Latest topics'
          baseTagUrl: '/topic/tagged/'
          relativeTags: relativeTags

  getTaggedTopics : (req, res) ->
    tags = req.params.tags.split('+')
    Topic.findItems { tags : { $all : tags } }, {sort: [['lastUpdate', -1]]}, (err, topics) ->
      TagInfo.findItems {name: {$in : tags}}, (err, tagInfos) ->
        getRelativeTags tags, (err, relativeTags) ->
          res.render 'topic/list', 
            topics: topics
            title: 'Latest topics'
            boardTags: tagInfos
            baseTagUrl: "/topic/tagged/#{tags.join('+')}+"
            relativeTags: relativeTags

  getNewTopic : (req, res) ->
    res.render 'topic/new',
      title: 'New Topic'

  getModifyTopic : (req, res) ->
    res.render 'topic/edit',
      title: 'Modify Topic'
      topic: req.topic

  getTopic : (req, res) ->
    TagInfo.findItems {name: {$in : req.topic.tags}}, (err, tagInfos) ->
      getRelativeTags req.topic.tags, (err, relativeTags) ->
        res.render 'topic/show', 
          topic: req.topic
          title: req.topic.title
          tagInfos: tagInfos
          baseTagUrl: '/topic/tagged/'
          relativeTags: relativeTags

  postTopic : (req, res) ->
    tagsToArray req.body.tags, (err, tags) ->
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

      # retrieve addedTags and removedTags
      tags or= []
      compareTags topic.tags, tags, (addedTags, removedTags)->
        topic.tags = tags
        Topic.save topic, (err, topic)->
          res.redirect "/topic/#{topic._id}"
          addedTags.forEach (tag)->
            TagInfo.update {name: tag}, {$inc: {count: 1}}, {upsert: true}, (err, docs)->
          TagInfo.update {name: {$in: removedTags}}, {$inc: {count: -1}}, (err, docs)->


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
