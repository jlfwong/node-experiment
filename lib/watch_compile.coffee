path            = require("path")

{tsLog}         = require("./util")
{waitForChange} = require("./watch")

watchCompile = exports.watchCompile = ({job, using: build, lastErr}) ->
  build job, (err, {watchPaths}) ->
    if err
      errMsg = err.longDesc or err.stack or err
      if errMsg != lastErr
        tsLog {
          type: job.type
          color: "red"
          msg: "Failed to build #{path.resolve(job.source)}"
        }

        console.error "\n#{errMsg}\n".red

      setTimeout (->
        watchCompile {job, using: build, lastErr: errMsg}
      ), 1000

    else
      tsLog {
        type: job.type
        color: "green"
        msg: "Finished building #{path.resolve(job.targetFile)}"
      }

      waitForChange watchPaths, ->
        watchCompile {job, using: build, lastErr: errMsg}
