fs              = require("fs")
{waitForChange} = require("../watch")
modulr          = require("modulr")
path            = require("path")
{tsLog}         = require("../util")
{readJsonFile}  = require("../util")

build = exports.build = (job, cb) ->
  package = readJsonFile(path.join(job.source, "package.json"))

  targetFile = path.join(job.targetDir, "#{package.name}.js")

  modulr.buildFromPackage job.source, (err, result) ->
    if err
      errMsg = err.longDesc or err.message
      fs.writeFileSync targetFile, """
        console.error('[modulr] Failed to build #{targetFile}');
        console.error(decodeURIComponent('#{encodeURIComponent(errMsg)}'));
      """
    else
      fs.writeFileSync targetFile, result.output

    result.targetFile = targetFile
    cb?(err, result)

continuousBuild = exports.continuousBuild = (job, options={}) ->
  build job, (err, result) ->
    if err
      errMsg = err.longDesc or err.stack
      if errMsg != options.lastErr
        tsLog {
          type: "modulr"
          color: "red"
          msg: "Failed to build #{path.resolve(result.targetFile)}"
        }

        console.error "\n#{errMsg.red}\n"

      setTimeout (->
        continuousBuild job, lastErr: errMsg
      ), 1000

    else
      tsLog {
        type: "modulr"
        color: "green"
        msg: "Finished building #{path.resolve(result.targetFile)}"
      }

      paths = (module.fullPath for id, module of result.modules)

      waitForChange paths, ->
        continuousBuild job

exports.startJob = (job) ->
  job.sources.map (source) ->
    continuousBuild {
      source: source
      targetDir: job.targetDir
    }
