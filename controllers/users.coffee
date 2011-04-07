crypto = require('crypto')
users = db.users

encryptPassword = (password) ->
  sha1 = crypto.createHmac('sha1', 'sha1 key')
  md5 = crypto.createHmac('md5', 'md5 key')
  sha1.update(password)
  md5.update(sha1.digest('hex'))
  md5.digest('hex')

authenticate = (username, password, fn) ->
  users.findOne username: username, (err, user) ->
    if !user
      fn(new Error('Can not find user'))
    else if user.password is encryptPassword(password) 
      fn(null, user)
    else 
      fn(new Error('Wrong password'))

exports.getSignUp = (req, res) ->
  res.render('users/signup', title: 'Sign up')

exports.postSignUp = (req, res) ->
  users.save
    username: req.body.username
    email: req.body.email
    password: encryptPassword req.body.password
    createDate: new Date()
    , (err, user) ->
      console.log err.stack if err

      req.session.regenerate ()->
        req.session.user = user
        res.redirect(req.body.continue || '/user/profile')

exports.getLogin = (req, res) ->
  res.render('users/login', title: 'Login')

exports.postLogin = (req, res) ->
  authenticate req.body.username, req.body.password, (err, user) ->
    if err
      if req.is 'json'
        res.send {login: false, message: err.message}
      else 
        res.render 'users/login', 
          fail: true
          message: err.message
          title: 'Login'

    else if (user)
      req.session.user = user
      if (req.is('json')) 
        res.send({login: true})
      else 
        res.redirect(req.query.continue || '/')
    else 
      if (req.is('json')) 
        res.send({login: false})
      else 
        res.render 'users/login', 
          fail: true
          message: 'username or password is incorrect'
          username: req.body.username
          continue: req.body.continue || ''
          title : 'Login'

exports.getLogout = (req, res) ->
  req.session.destroy ()->
    res.redirect '/'

exports.getProfile = (req, res) ->
  res.render 'users/profile', 'title': 'Profile'

exports.postProfile = (req, res) ->

