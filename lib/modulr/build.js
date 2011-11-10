var fs = require('fs');
var getMTimes = require('../watch').getMTimes;
var waitForChange = require('../watch').waitForChange;
var jsGraph = require('./graph');
var modulr = require('modulr');
var path = require('path');
var tsLog = require('../util').tsLog;

var build = exports.build = function(job, cb) {
  modulr.buildFromPackage(job.source, function(err, result) {
    if (err && err.longDesc) {
      console.log(err.longDesc);
    } else {
      fs.writeFileSync(job.target, result.output);
      result.targetPath = job.target;
      cb && cb(result);
    }
  });
};

var continuousBuild = exports.continuousBuild = function(job) {
  build(job, function(results) {
    tsLog({
      type: 'modulr',
      color: 'green',
      msg: 'Finished building ' + path.resolve(results.targetPath)
    });

    jsGraph.getDependencyPaths(job.source, function(dependencyPaths) {
      waitForChange(getMTimes(dependencyPaths), function() {
        continuousBuild(job);
      });
    });
  });
};

exports.startJob = function(job) {
  continuousBuild(job);
};
