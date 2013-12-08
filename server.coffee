CONFIG = require './config'
express = require 'express'

Starbound = require './starbound'
ClientController = require './server/controllers/client'

sessionStore = new express.session.MemoryStore()

app = express()
app.use express.bodyParser()
app.use express.cookieParser()
app.use express.static('public')
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'

Starbound.init (err) ->
  if not err?
    ClientController.init(app)
    console.log "Server listening on port #{CONFIG.PORT}"
    app.listen CONFIG.PORT
  else
    console.log "Error initializing Starbind client:"
    console.log err

