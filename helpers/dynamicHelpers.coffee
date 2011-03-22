module.exports = 

  user: (req) ->
    req.session.user

  recentlyTopics: (req) ->
    req.recentlyTopics

  topTags: (req) ->
    req.topTags

