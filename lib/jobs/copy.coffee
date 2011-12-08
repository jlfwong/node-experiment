child_process   = require "child_process"
fs              = require "fs"
path            = require "path"
{tsLog, mkdirP} = require "../util"
{waitForChange} = require "../watch"

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

copy = exports.copy = ({src, dst}, cb) ->
  mkdirP dst, ->
    child_process.exec "cp -R '#{src}' '#{dst}'", (error, stdout, stderr) ->
      if error
        tsLog {
          type: "copy"
          color: "red"
          msg: stderr
        }

      cb?()

continuousCopy = exports.continuousCopy = ({src, dst, job}) ->
  copy {src, dst}, ->
    tsLog {
      type: "copy"
      color: "green"
      msg: "Finished copying #{src} to #{path.resolve(dst)}"
    }

    fileList = listFilesRecursive(src)

    unless job.watch == 'false'
      waitForChange fileList, ->
        continuousCopy {src, dst, job}

exports.startJob = (job) ->
  if job.source
    job.sources = [job.source]

  job.sources.forEach (source) ->
    continuousCopy {
      src   : source
      dst   : job.targetDir
      job   : job
    }
