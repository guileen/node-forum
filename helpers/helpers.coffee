module.exports = 

  urlRemoveTag: (tagInfos, tagName)->
    '/tag/' + ( tag.name for tag in tagInfos when tag.name isnt tagName ).join('+')

  urlAddTag: (tagInfos, tagName)->
    tags = []
    tags.push tag.name for tag in tagInfos
    tags.push tagName
    '/tag/' + tags.join('+')
