fs = require("fs")
tsLog = require("./util").tsLog

getMTimes = (filePaths) ->
  mtimes = {}
  filePaths.forEach (filePath) ->
    mtimes[filePath] = fs.statSync(filePath).mtime.getTime()

  return mtimes

_waitForChange = (mTimes, cb) ->
  filePaths = Object.keys(mTimes)
  newMTimes = getMTimes(filePaths)
  changed = false
  filePaths.forEach (filePath) ->
    if newMTimes[filePath] != mTimes[filePath]
      tsLog {
        type: "watch"
        msg: filePath + " changed"
      }

      changed = true

  if changed
    cb()
  else
    setTimeout (->
      _waitForChange mTimes, cb
    ), 1000

waitForChange = exports.waitForChange = (filePaths, cb) ->
  _waitForChange getMTimes(filePaths), cb
