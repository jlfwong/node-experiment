optimist = require 'optimist'

{newExperiment} = require '../lib/generator'

argv = optimist
  .check( (argv) ->
    if argv._.length == 0
      throw ""
  )
  .usage('Usage: $0 [run|new|help]')
  .argv
path = require('path')

{readJsonFile} = require('../lib/util')
{loadJobs, handleJob} = require('../lib/job')

switch argv._[0]
  when 'run'
    buildJobs = readJsonFile('jobs.json')

    if not buildJobs?
      process.exit(1)

    jobs = buildJobs.jobs
    defaults = buildJobs.defaults

    loadJobs path.join(__dirname, "..", "lib", "jobs")

    jobs.forEach (job) ->
      for prop of defaults
        if not job[prop]?
          job[prop] = defaults[prop];

    jobs.forEach (job) ->
      handleJob job
  when 'new'
    targetDir = argv._[1]

    if targetDir?
      newExperiment targetDir
    else
      optimist.showHelp()

  else
    optimist.showHelp()
