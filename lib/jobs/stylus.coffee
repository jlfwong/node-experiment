fs              = require("fs")
path            = require("path")
stylus          = require("stylus")

{watchCompile}  = require("../watch_compile")
{forEachSource} = require("../job")

build = exports.build = (job, cb) ->
  basename = path.basename(job.source, ".styl")
  job.targetFile ?= path.resolve(job.targetDir, basename + ".css")

  try
    contents = fs.readFileSync(job.source, "utf8")
  catch err
    cb err, {watchPaths: [job.source]}
    return

  stylus(contents).render (err, css) ->
    if err
      fs.writeFileSync job.targetFile, """
        body {
          color: red;
          font-size: 30pt;
        }

        body:before {
          content: "Failed to build #{job.targetFile}"
        }
      """
    else
      fs.writeFileSync job.targetFile, css

    cb err, {watchPaths: [job.source]}

exports.startJob = (job) ->
  forEachSource job, (sourceJob) ->
    watchCompile {
      job   : sourceJob
      using : build
    }
