var child_process = require('child_process');
var fs = require('fs');
var moduleGrapher = require('module-grapher');
var modulr = require('modulr');
var path = require('path');

var readPackage = exports.readPackage = function(modulePath) {
  var packagePath = path.join(modulePath, 'package.json');

  if (!path.existsSync(packagePath)) {
    console.log('File not found: ' + packagePath);
    return false;
  }

  try {
    var rawContents = fs.readFileSync(packagePath, 'utf8');
  } catch(e) {
    console.log('Failed to read file ' + packagePath, e, e.stack);
    return false;
  }

  try {
    var packageContents = JSON.parse(rawContents);
  } catch(e) {
    console.log('Invalid JSON in ' + packagePath, rawContents, e, e.stack);
    return false;
  }

  if (!(packageContents.modulr && packageContents.modulr.target_path)) {
    console.log('Missing target_path property in ' + packagePath);
    return false;
  }

  return packageContents;
};

var build = exports.build = function(modulePath, cb) {
  var packageContents = readPackage(modulePath);
  if (!packageContents) {
    return;
  }

  modulr.buildFromPackage(modulePath, function(err, result) {
    if (err && err.longDesc) {
      console.log(err.longDesc);
    } else {
      var targetPath = path.normalize(path.join(modulePath,
        packageContents.modulr.target_path,
        packageContents.name + '.js'));

      fs.writeFileSync(targetPath, result.output);
      result.targetPath = targetPath;
      cb(result);
    }
  });
};

var getGraph = exports.getGraph = function (modulePath, cb) {
  var packageContents = readPackage(modulePath);
  if (!packageContents) {
    return;
  }

  var paths = packageContents.modulr.paths;

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
