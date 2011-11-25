argv = require('optimist')
  .check( (argv) ->
    if argv._.length == 0
      throw ""
  )
  .usage('Usage: $0 [run|new|help]')
  .argv

readJsonFile = require('../lib/util').readJsonFile

if argv._[0] == 'run'
  buildJobs = readJsonFile('jobs.json')

  if not buildJobs?
    process.exit(1)

  jobs = buildJobs.jobs
  defaults = buildJobs.defaults

  jobs.forEach (job) ->
    for prop of defaults
      if not job[prop]?
        job[prop] = defaults[prop];

  jobs.forEach (job) ->
    require('../lib/job').handle(job)
