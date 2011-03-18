token_key = '__any_auth_token'
exports.cookieUser = (req, res, next) ->
  token = req.cookies[token_key]

exports.loggedIn = (req, res, next) ->
  if req.session.user
    next()
  else
    req.session.error = "Access denied"
    res.redirect "/user/login?continue=" + encodeURIComponent(req.url)

exports.role = (role) ->
  (req, res, next) ->
    if role in req.session.user.roles
      next()
    else
      next new Error "Unauthorized"
