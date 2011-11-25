fs      = require("fs")
path    = require("path")
{tsLog} = require("./util")

loadJobs = (dirPath, handlers) ->
  jobProcessors = fs.readdirSync(dirPath)
  jobProcessors.forEach (jobProcessor) ->
    ext = path.extname(jobProcessor)
    return unless ext == ".js" or ext == ".coffee"

    jobType = path.basename(jobProcessor, ext)
    handlers[jobType] = require(path.resolve(dirPath, jobProcessor))

handlers = {}
loadJobs path.join(__dirname, "jobs"), handlers

exports.handle = (job) ->
  type = job.type
  handler = handlers[type]

  if handler?
    handler.startJob job
  else
    tsLog {
      type: "error"
      color: "red"
      msg: "ERROR: Unknown job type \"" + type + "\""
    }
