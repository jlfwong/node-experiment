var readJsonFile = require('../util').readJsonFile;
var moduleGrapher = require('module-grapher');
var path = require('path');

var getGraph = exports.getGraph = function (modulePath, cb) {
  var packageContents = readJsonFile(path.join(modulePath, 'package.json'));

  if (!packageContents) {
    return;
  }

  var paths = packageContents.modulr && packageContents.modulr.paths || [];

  if (paths.indexOf('.') < 0) {
    paths.push('.');
  }

  moduleGrapher.graph(packageContents.main, {
    paths: paths,
    root: modulePath,
    isPackageAware: true
  }, function(err, results) {
    if (err && err.longDesc) {
      console.log(err.longDesc);
    } else {
      cb(results);
    }
  });
};

var getDependencyPaths = exports.getDependencyPaths = function(modulePath, cb) {
  getGraph(modulePath, function(results) {
    var paths = [];
    var modules = results.modules;
    for (id in modules) {
      if (!modules.hasOwnProperty(id)) {
        continue;
      }

      var module = modules[id];
      paths.push(module.fullPath);
    }
    cb(paths);
  });
};
