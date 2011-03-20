{loggedIn, role, recentlyTopics } = require './middlewares'
home = require './controllers/home'
users = require './controllers/users'
topics = require './controllers/topics'

module.exports = (app) ->

  #Middlewares
  app.all '*', recentlyTopics

  #Home
  app.get '/', home.getHome

  # Users
  app.get '/user/login', users.getLogin
  app.post '/user/login', users.postLogin
  app.get '/user/signup', users.getSignUp
  app.post '/user/signup', users.postSignUp
  app.get '/user/profile', loggedIn, users.getProfile
  app.post '/user/profile', loggedIn, users.postProfile
  app.get '/user/logout', loggedIn, users.getLogout

  # Topics
  app.param 'topicId', topics.paramTopicId
  app.get '/topic/new', loggedIn, topics.getNewTopic
  app.get '/topic/:topicId/modify', loggedIn, topics.getModifyTopic
  app.get '/topic/:topicId', topics.getTopic
  app.post '/topic/:topicId?', loggedIn, topics.postTopic
  app.post '/topic/:topicId/comment/:commentIndex?', loggedIn, topics.postComment
  # tags
  app.get '/topic/tagged/:tags', topics.getTaggedTopics
  # vote
  app.get '/topic/:topicId/vote/:updown', loggedIn, topics.postVote
