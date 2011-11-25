fs              = require("fs")
jade            = require("jade")
path            = require("path")
{tsLog}         = require("../util")
{waitForChange} = require("../watch")

build = exports.build = (job, cb) ->
  try
    contents = fs.readFileSync(job.source, "utf8")
  catch e
    tsLog {
      type: "jade"
      color: "red"
      msg: "Failed to read #{path.resolve(job.source)}"
    }

    return

  html = jade.compile(contents)()
  fs.writeFileSync job.targetFile, html

continuousBuild = exports.continuousBuild = (job) ->
  basename = path.basename(job.source, ".jade")
  job.targetFile = path.resolve(job.targetDir, basename + ".html")
  build job

  tsLog {
    type: "jade"
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
