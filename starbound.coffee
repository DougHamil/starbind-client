CONFIG = require './config'
Git = require 'gift'
path = require 'path'
fs = require 'fs'

repoPath = path.join CONFIG.STARBOUND_INSTALL_DIR, 'assets'

copyFile = (source, target, cb) ->
  cbCalled = false
  rd = fs.createReadStream(source)
  rd.on "error", (err) ->
    done(err)
  wr = fs.createWriteStream(target)
  wr.on "error", (err) ->
    done(err)
  wr.on "close", (ex) ->
    done()
  rd.pipe(wr)
  done = (err) ->
    if not cbCalled
      cb err
      cbCalled = true

module.exports =
  assetPath: repoPath
  getAssetPath: (prop) ->
    return path.join @assetPath, prop
  foundInstallDir: false
  init: (cb) ->
    # Validate the install directory was found
    @foundInstallDir = fs.existsSync(@assetPath)
    # Check if a git repo already exists in the install dir
    if not fs.existsSync(path.join(@assetPath, '.git'))
      console.log "No repository currently exists, will clone to initialize"
      @repo = null
    else
      console.log "Found existing repository at #{@assetPath}, will change remote origin to update"
      @repo = Git path.join(@assetPath, '.git')
    cb null
