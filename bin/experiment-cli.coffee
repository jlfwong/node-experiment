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

    # Let argv overrite defaults, e.g.
    #
    #     experiment run --watch=false
    #
    # Will add {watch:'false'} to the default params of every job
    for prop of argv
      if prop[0] == '$' or prop == '_'
        continue
      defaults[prop] = argv[prop]

    # Merge the default properties into each job if they aren't specifically
    # specified in the job
    jobs.forEach (job) ->
      for prop of defaults
        if not job[prop]?
          job[prop] = defaults[prop]

    # Handle each job
    jobs.forEach (job) ->
      handleJob job

  when 'new'
    # Copy the skeleton to the targetDirectory
    targetDir = argv._[1]

    if targetDir?
      newExperiment targetDir
    else
      optimist.showHelp()

  else
    optimist.showHelp()
