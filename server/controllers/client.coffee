CONFIG = require '../../config'
Starbound = require '../../starbound'
os = require 'os'
rimraf = require 'rimraf'
ncp = require 'ncp'
path = require 'path'
Git = require 'gift'
temp = require 'temp'

synchronize = (tmp, res) ->
  console.log tmp
  sourceDir = path.join tmp, '.git'
  destDir = path.join Starbound.assetPath, '.git'
  console.log "Copying #{sourceDir} to #{destDir}."
  ncp sourceDir, destDir, (err) ->
    console.log "Done."
    if err?
      console.log err
      res.send 500, err
    else
      # Create repo object
      repo = Git Starbound.assetPath
      console.log "Created repo at #{repo.path}"
      repo.git "reset", {hard:true}, null, (err) ->
        console.log arguments
        if err
          res.send 500, err
        else
          res.send 200, "done"
    # Delete temp directory
    console.log "Cleaning up #{tmp}"
    rimraf tmp, ->


exports.init = (app) ->
  app.get '/', (req,res) ->
    res.render 'client', {installFound:Starbound.foundInstallDir}

  app.post '/sync', (req, res) ->
    host = req.body.host
    username = req.body.username
    password = req.body.password

    if not host? or not username? or not password?
      res.send 400, "Expected 'host', 'username' and 'password'"
      return

    repoUrl = "http://#{username}:#{password}@#{host}/starbound-server.git"

    temp.mkdir 'starbind-clone', (err, tempDir) ->
      if not err?
        # Clone into temp directory
        console.log "Cloning #{repoUrl} to #{tempDir}"
        Git.clone repoUrl, tempDir, (err, _repo) ->
          if err?
            console.log "Error cloning repo"
            res.send 500, err
          else
            # Delete existing repo, if exists
            if Starbound.repo?
              rimraf Starbound.repo.path, (err) ->
                if not err?
                  Starbound.repo = null
                  synchronize tempDir, res
            else
              synchronize tempDir, res
      else
        res.send 500, err
