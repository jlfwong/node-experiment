fs      = require("fs")
path    = require("path")
{tsLog} = require("./util")

handlers = {}

exports.handleJob = (job) ->
  type = job.type
  handler = handlers[type]

  if handler?
    handler.startJob job
  else
    tsLog {
      type: "error"
      color: "red"
      msg: "ERROR: Unknown job type \"#{type}\""
    }

exports.forEachSource = (job, cb) ->
  job.sources.forEach (source) ->
    sourceJob = {source}
    for key of job
      if key != "sources"
        sourceJob[key] = job[key]

    cb sourceJob

exports.loadJobs = (dirPath) ->
  jobProcessors = fs.readdirSync(dirPath)
  jobProcessors.forEach (jobProcessor) ->
    ext = path.extname(jobProcessor)
    return unless ext == ".js" or ext == ".coffee"

    jobType = path.basename(jobProcessor, ext)
    handlers[jobType] = require(path.resolve(dirPath, jobProcessor))
