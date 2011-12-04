fs              = require("fs")
jade            = require("jade")
path            = require("path")

{watchCompile}  = require("../watch_compile")
{forEachSource} = require("../job")

build = exports.build = (job, cb) ->
  basename = path.basename(job.source, ".jade")

  job.targetFile ?= path.resolve(job.targetDir, basename + ".html")

  try
    contents = fs.readFileSync(job.source, "utf8")
    html = jade.compile(contents)()
    fs.writeFileSync job.targetFile, html
    cb null, {watchPaths: [job.source]}
  catch err
    cb err, {watchPaths: [job.source]}
    return

exports.startJob = (job) ->
  forEachSource job, (sourceJob) ->
    watchCompile {
      job   : sourceJob
      using : build
    }
