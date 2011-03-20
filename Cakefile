{exec, spawn} = require "child_process"

task "build", ->
  console.log 'build...'
  exec "coffee -o ./build -c ./" , (err) ->
    if err
      console.log err.stack
    else
      console.log 'done'

task "test", ->
  console.log 'test...'
  require("./test").run()

task "run", ->
  invoke 'build'
  server = spawn 'coffee', ['app.coffee']
  server.stdout.on 'data', (data) ->
    process.stdout.write data
  server.stderr.on 'data', (data) ->
    process.stderr.write data

task "drop", ->
  config = require './config'
  config.db.open (err, db)->
    if db 
      db.dropDatabase (err, db) ->
        if not err
          console.log 'database dropped'
          invoke 'run'
