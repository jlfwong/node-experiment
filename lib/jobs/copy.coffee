child_process   = require("child_process")
fs              = require("fs")
path            = require("path")
{tsLog}         = require("../util")
{waitForChange} = require("../watch")

listFilesRecursive = (fileOrDirPath) ->
  stat = fs.statSync(fileOrDirPath)
  fileList = []
  if stat.isFile()
    fileList = [ path.resolve(fileOrDirPath) ]
  else if stat.isDirectory()
    fs.readdirSync(fileOrDirPath).forEach (filename) ->
      subpath = path.resolve(fileOrDirPath, filename)
      fileList = fileList.concat(listFilesRecursive(subpath))

  return fileList

copy = exports.copy = (src, dst, cb) ->
  child_process.exec "cp -R '#{src}' '#{dst}'", (error, stdout, stderr) ->
    if error
      tsLog {
        type: "copy"
        color: "red"
        msg: stderr
      }

    cb?()

continuousCopy = exports.continuousCopy = (src, dst) ->
  copy src, dst, ->
    tsLog {
      type: "copy"
      color: "green"
      msg: "Finished copying #{src} to #{path.resolve(dst)}"
    }

    fileList = listFilesRecursive(src)
    waitForChange fileList, ->
      continuousCopy job

exports.startJob = (job) ->
  if job.source
    job.sources = [job.source]

  job.sources.forEach (source) ->
    continuousCopy source, job.targetDir
