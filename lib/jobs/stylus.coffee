fs              = require("fs")
path            = require("path")
stylus          = require("stylus")
tsLog           = require("../util").tsLog
{waitForChange} = require("../watch")

build = exports.build = (job, cb) ->
  try
    contents = fs.readFileSync(job.source, "utf8")
  catch e
    tsLog {
      type: "stylus"
      color: "red"
      msg: "Failed to read #{path.resolve(job.source)}"
    }

    return

  stylus(contents).render (err, css) ->
    if err
      tsLog {
        type: "stylus"
        color: "red"
        msg: "Failed to compile #{path.resolve(job.source)}"
      }

      console.error err.stack
    else
      fs.writeFileSync job.targetFile, css

    cb()

continuousBuild = exports.continuousBuild = (job) ->
  basename = path.basename(job.source, ".styl")
  job.targetFile = path.resolve(job.targetDir, basename + ".css")
  build job, ->
    tsLog {
      type: "stylus"
      color: "green"
      msg: "Finished building #{path.resolve(job.targetFile)}"
    }

    waitForChange [ job.source ], ->
      continuousBuild job

exports.startJob = (job) ->
  job.sources.map (source) ->
    continuousBuild {
      source: source
      targetDir: job.targetDir
    }
