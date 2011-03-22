require './date.format'

module.exports = 

  formatSeconds: (s, def=null) ->
    if s < 120
      return 'Just now'
    m = Math.floor s/60
    if m < 60
      return m+' minutes ago'
    h = Math.floor m/60
    if h is 1
      return h + ' hour ago'
    if h < 24
      return h + ' hours ago'
    d = Math.floor h/24
    if d is 1
      return d + ' day ago'
    if d < 11
      return d + ' days ago'
    return def

  humanizeDate: (date) ->
    now = new Date()
    delta = now - date
    s = delta / 1000
    if now.getDate() is date.getDate() and s < 24 * 3600
      format = 'HH:MM'
    else if now.getYear() is date.getYear()
      format = 'mm-dd'
    else 
      centuryNow = Math.floor now.getFullYear()/100
      centuryDate = Math.floor date.getFullYear()/100
      if centuryNow is centuryDate
        format = 'yy-mm-dd'
      else
        format = 'yyyy-mm-dd'
    s = @formatSeconds(s)
    if s
      return date.format(format) + "(#{s})"
    return date.format(format)

  urlRemoveTag: (tagInfos, tagName)->
    '/tag/' + ( tag.name for tag in tagInfos when tag.name isnt tagName ).join('+')

  urlAddTag: (tagInfos, tagName)->
    tags = []
    tags.push tag.name for tag in tagInfos
    tags.push tagName
    '/tag/' + tags.join('+')

