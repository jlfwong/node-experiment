child_process   = require 'child_process'
{tsLog}         = require '../util'
{waitForChange} = require '../watch'

run = (job) ->
  ps = child_process.spawn job.command, job.args

  ps.stdout.on 'data', (data) ->
    tsLog {
      type  : 'superv'
      color : 'underline'
      msg   : "stdout from #{job.command} #{job.args.join(' ')}"
      nodup : true
    }
    console.log '' + data

  ps.stderr.on 'data', (data) ->
    tsLog {
      type  : 'superv'
      color : 'red'
      msg   : "stderr from #{job.command} #{job.args.join(' ')}"
      nodup : true
    }
    console.log '' + data

  return ps

supervise = (job) ->
  if job.watch == 'false'
    return

  ps = run job

  tsLog {
    type  : 'superv'
    color : 'green'
    msg   : "starting #{job.command} #{job.args.join(' ')}"
  }

  waitForChange job.sources, ->
    ps.kill()
    supervise job

exports.startJob = supervise
