var fs = require('fs');
var getMTimes = require('../watch').getMTimes;
var waitForChange = require('../watch').waitForChange;
var jsGraph = require('./graph');
var modulr = require('modulr');
var path = require('path');
var tsLog = require('../util').tsLog;
var readJsonFile = require('../util').readJsonFile;

var build = exports.build = function(job, cb) {
  var package = readJsonFile(path.join(job.source, 'package.json'));

  var targetFile = path.join(job.targetDir, package.name + '.js');

  modulr.buildFromPackage(job.source, function(err, result) {

    if (err) {
      var errMsg = err.longDesc || err.message;

      fs.writeFileSync(targetFile, [
        "console.error('[modulr] Failed to build " +
          targetFile +
        "');",

        "console.error(decodeURIComponent('" +
          encodeURIComponent(errMsg) +
        "'));"
      ].join('\n'))
    } else {
      fs.writeFileSync(targetFile, result.output);
    }

    result.targetFile = targetFile;

    cb && cb(err, result);
  });
};

var continuousBuild = exports.continuousBuild = function(job, options) {
  if (typeof(options) === 'undefined') {
    options = {};
  }

  build(job, function(err, result) {
    if (err) {
      var errMsg = err.longDesc || err.stack;

      if (errMsg !== options.lastErr) {
        tsLog({
          type: 'modulr',
          color: 'red',
          msg: 'Failed to build ' + path.resolve(result.targetFile)
        });
        console.error('\n' + errMsg.red + '\n');
      }

      setTimeout(function() {
        continuousBuild(job, {lastErr:errMsg});
      }, 1000);

    } else {
      tsLog({
        type: 'modulr',
        color: 'green',
        msg: 'Finished building ' + path.resolve(result.targetFile)
      });

      jsGraph.getDependencyPaths(job.source, function(err, dependencyPaths) {
        waitForChange(getMTimes(dependencyPaths), function() {
          continuousBuild(job);
        });
      });
    }

  });
};

exports.startJob = function(job) {
  job.sources.map(function(source) {
    continuousBuild({
      source: source,
      targetDir: job.targetDir
    });
  });
};
