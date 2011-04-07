TagInfo = db.taginfo

module.exports = (req, res, next) ->
  TagInfo.findItems {},{limit: 20, sort: [['count', -1]]}, (err, tagInfos) ->
    req.topTags = tagInfos
    next()
