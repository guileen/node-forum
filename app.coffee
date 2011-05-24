require.paths.unshift(__dirname + '/support')
global.settings = require('./settings')
global.db = require('./db')

express = require('express')
helpers = require('./helpers/helpers')
dynamicHelpers = require('./helpers/dynamicHelpers')

app = module.exports = express.createServer()

# Configuration

RedisStore = require('connect-redis')
app.configure () ->
  app.set('views', __dirname + '/views')
  app.set('view engine', 'jade')
  app.use(express.bodyParser())
  app.use(express.methodOverride())
  app.use(express.cookieParser())
  app.use(express.session({ secret: "sexy girls", store: new RedisStore }))
  app.use(require('stylus').middleware({ src: __dirname + '/public' }))
  app.use(app.router)
  app.use(express.static(__dirname + '/public'))

app.configure 'development', () ->
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }))

app.configure 'production', () ->
  app.use(express.errorHandler())

app.helpers(helpers)

app.dynamicHelpers(dynamicHelpers)

# Middlewares
#
{ recentlyTopics } = require './middlewares'
topTags = require './middlewares/toptags'

#Middlewares
app.get '*', recentlyTopics
app.get '*', topTags

# Routes

['home', 'topics', 'users'].forEach (controller)->
  require('./controllers/'+controller)(app)

# Only listen on $ node app.js

if (!module.parent) 
  app.listen(3000)
  console.log('Express server listening on port %d', app.address().port)
