FileServer = require("node-static").Server
path       = require("path")
{tsLog}    = require("../util")

exports.startJob = (job) ->
  port = job.port
  targetDir = job.targetDir

  unless port
    tsLog {
      type: "server"
      color: "red"
      msg: "No port specified for server - exiting"
    }

    return

  targetDir = job.targetDir

  unless targetDir
    tsLog {
      type: "server"
      color: "red"
      msg: "No targetDir specified for server - exiting"
    }

    return

  fileServer = new FileServer(targetDir)

  require("http").createServer((request, response) ->
    request.addListener "end", ->
      tsLog {
        type: "server"
        msg: request.url
      }

      fileServer.serve request, response

  ).listen(port)

  tsLog {
    type: "server"
    color: "green"
    msg: "Serving " + path.resolve(targetDir) + " on http://localhost:" + port
  }
