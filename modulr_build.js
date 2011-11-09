#!/usr/bin/env node

var argv = require('optimist').argv;
var fs = require('fs');
var modulr_util = require('./lib/util');
var colors = require('colors');

var modulePaths = ['.'];

if (argv._.length) {
  modulePaths = argv._;
}

var getMTimes = function(filePaths) {
  var mtimes = {};
  filePaths.forEach(function(filePath) {
    mtimes[filePath] = fs.statSync(filePath).mtime.getTime();
  });
  return mtimes;
};

var tsLog = function(msg) {
  console.log('[' + (new Date()).toLocaleTimeString() + '] ' + msg);
}

var build = function(modulePath) {
  modulr_util.build(modulePath, function(results) {
    tsLog(('Finished building ' + results.targetPath).green);
  });
};

var waitUntilChange = function(mTimes, cb) {
  var filePaths = Object.keys(mTimes);

  var newMTimes = getMTimes(filePaths);
  var changed = false;

  filePaths.forEach(function(filePath) {
    if (newMTimes[filePath] !== mTimes[filePath]) {
      tsLog(filePath + ' changed');
      changed = true;
    }
  });

  if (changed) {
    cb();
  } else {
    setTimeout(function() {
      waitUntilChange(mTimes, cb);
    }, 1000);
  }
};

var buildAndMaybeWatch = function(modulePath) {
  build(modulePath);

  if (argv.w) {
    // Watch mode
    modulr_util.getDependencyPaths(modulePath, function(dependencyPaths) {
      waitUntilChange(getMTimes(dependencyPaths), function() {
        buildAndMaybeWatch(modulePath);
      });
    });
  }
};

modulePaths.forEach(buildAndMaybeWatch);
