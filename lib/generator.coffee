path   = require 'path'
{copy} = require './jobs/copy'

exports.newExperiment = (targetDir) ->
  sourceDir = path.resolve __dirname, '..', 'skeleton'
  copy sourceDir, targetDir, ->
    console.log "Finished making new project in #{targetDir}".green
