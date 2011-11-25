var child_process = require('child_process');
var fs = require('fs');
var path = require('path');
var tsLog = require('./util').tsLog;
var waitForChange = require('./watch').waitForChange;

var copy = exports.copy = function(src, dst, cb) {
  child_process.exec(
    'cp -R "' + src + '" "' + dst + '"',
    function(error, stdout, stderr) {
      if (error) {
        tsLog({
          type: 'copy',
          color: 'red',
          msg: stderr
        });
      }

      cb();
    }
  );
};

function listFilesRecursive(fileOrDirPath) {
  var stat = fs.statSync(fileOrDirPath);

  var fileList = [];

  if (stat.isFile()) {
    fileList = [path.resolve(fileOrDirPath)];
  } else if (stat.isDirectory()) {
    fs.readdirSync(fileOrDirPath).forEach(function(filename) {
      var subpath = path.resolve(fileOrDirPath, filename);
      fileList = fileList.concat(listFilesRecursive(subpath));
    });
  }

  return fileList;
}

var continuousCopy = exports.continuousCopy = function(src, dst) {
  copy(src, dst, function() {
    tsLog({
      type: 'copy',
      color: 'green',
      msg: 'Finished copying ' + src + ' to ' + path.resolve(dst)
    });

    var fileList = listFilesRecursive(src);

    waitForChange(fileList, function() {
      continuousCopy(job);
    });
  });
};

exports.startJob = function(job) {
  if (job.source) {
    continuousCopy(job.source, job.target);
  } else if (job.sources) {
    job.sources.forEach(function(source) {
      continuousCopy(source, job.target);
    });
  }
};
