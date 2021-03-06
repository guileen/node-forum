{loggedIn, role, recentlyTopics } = require './middlewares'
home = require './controllers/home'
users = require './controllers/users'
topics = require './controllers/topics'

topTags = require './middlewares/toptags'

module.exports = (app) ->

  #Middlewares
  app.get '*', recentlyTopics
  app.get '*', topTags

  #Home
  app.get '/', topics.getTopics

  # Users
  app.get '/user/login', users.getLogin
  app.post '/user/login', users.postLogin
  app.get '/user/signup', users.getSignUp
  app.post '/user/signup', users.postSignUp
  app.get '/user/profile', loggedIn, users.getProfile
  app.post '/user/profile', loggedIn, users.postProfile
  app.get '/user/logout', loggedIn, users.getLogout

  # tags
  app.get '/tag/:tags?', topics.getTaggedTopics

  # Topics
  app.get '/topic/new', loggedIn, topics.getNewTopic
  app.get '/topic/:topicId/modify', loggedIn, topics.getModifyTopic
  app.get '/topic/:topicId', topics.getTopic
  app.post '/topic/', loggedIn, topics.postNewTopic
  app.post '/topic/:topicId', loggedIn, topics.postModifyTopic
  app.post '/topic/:topicId/comment/:commentIndex?', loggedIn, topics.postComment
  # vote
  app.get '/topic/:topicId/vote/:updown', loggedIn, topics.postVote
