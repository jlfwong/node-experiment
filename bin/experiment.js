#!/usr/bin/env node

var argv = require('optimist')
  .check(function(argv) {
    if (argv._.length === 0) {
      throw "";
    }
  })
  .usage('Usage: $0 [run|new|help]')
  .argv;

var readJsonFile = require('../lib/util').readJsonFile;

if (argv._[0] === 'run') {
  var buildJobs = readJsonFile('jobs.json');

  if (!buildJobs) {
    process.exit(1);
  }

  var jobs = buildJobs.jobs;
  var defaults = buildJobs.defaults;

  jobs.forEach(function(job) {
    for (var prop in defaults) {
      if (!defaults.hasOwnProperty(prop)) {
        continue;
      }

      if (typeof job[prop] === 'undefined') {
        job[prop] = defaults[prop];
      }
    }
  });

  jobs.forEach(function(job) {
    require('../lib/job').handle(job);
  });
}

// vim: ft=javascript
