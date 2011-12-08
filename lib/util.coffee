fs            = require 'fs'
child_process = require 'child_process'
modulr        = require 'modulr'
path          = require 'path'

readJsonFile = exports.readJsonFile = (filePath) ->
  if not path.existsSync(filePath)
    console.error "File not found: #{filePath}"
    return false

  try
    rawContents = fs.readFileSync filePath, 'utf8'
  catch e
    console.error "Failed to read file #{filePath}", e.stack
    return false

  try
    contents = JSON.parse rawContents
  catch e
    console.error "Invalid JSON in #{filePath}", rawContents, e.stack
    return false

  return contents

require 'colors'

lastTsLogParams = {}
tsLog = exports.tsLog = ({type, color, msg, nodup}) ->
  if nodup
    {type: lastType, msg: lastMsg} = lastTsLogParams
    if type == lastType and msg == lastMsg
      return

  lastTsLogParams = {type, color, msg, nodup}

  while type.length < 6
    type = ' ' + type

  output = "[#{new Date().toLocaleTimeString()}] (#{type}) #{msg}"

  if color?
    output = output[color]

  console.log output
