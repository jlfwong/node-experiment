fs              = require("fs")
modulr          = require("modulr")
path            = require("path")

{readJsonFile}  = require("../util")
{watchCompile}  = require("../watch_compile")
{forEachSource} = require("../job")

build = exports.build = (job, cb) ->
  package = readJsonFile(path.join(job.source, "package.json"))

  if not package
    cb "Couldn't read package.json", {}
    return

  job.targetFile ?= path.join(job.targetDir, "#{package.name}.js")

  modulr.buildFromPackage job.source, (err, result) ->
    if err
      errMsg = (err.longDesc or err.stack or '').replace /'/g, '"'
      fs.writeFileSync job.targetFile, """
        console.error('[modulr] Failed to build #{job.targetFile}');
        console.error('#{JSON.stringify(errMsg)}');
      """
      cb err, {}

    else
      fs.writeFileSync job.targetFile, result.output

      cb null, {
        watchPaths: (module.fullPath for id, module of result.modules)
      }

exports.startJob = (job) ->
  forEachSource job, (sourceJob) ->
    watchCompile {
      job   : sourceJob
      using : build
    }
