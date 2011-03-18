{loggedIn, role } = require './middlewares'
users = require './controllers/users'

module.exports = (app) ->

  # Users
  app.get '/user/login', users.getLogin
  app.post '/user/login', users.postLogin
  app.get '/user/signup', users.getSignUp
  app.post '/user/signup', users.postSignUp
  app.get '/user/profile', loggedIn, users.getProfile
  app.post '/user/profile', loggedIn, users.postProfile
  app.get '/user/logout', loggedIn, users.getLogout

  #Home
  app.get '/', home.getHome
