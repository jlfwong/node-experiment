var fs = require('fs');
var tsLog = require('./util').tsLog;

var getMTimes = exports.getMTimes = function(filePaths) {
  var mtimes = {};
  filePaths.forEach(function(filePath) {
    mtimes[filePath] = fs.statSync(filePath).mtime.getTime();
  });
  return mtimes;
};

var _waitForChange =  function(mTimes, cb) {
  var filePaths = Object.keys(mTimes);

  var newMTimes = getMTimes(filePaths);
  var changed = false;

  filePaths.forEach(function(filePath) {
    if (newMTimes[filePath] !== mTimes[filePath]) {
      tsLog({
        type: 'watch',
        msg: filePath + ' changed'
      });
      changed = true;
    }
  });

  if (changed) {
    cb();
  } else {
    setTimeout(function() {
      _waitForChange(mTimes, cb);
    }, 1000);
  }
};


var waitForChange = exports.waitForChange = function(filePaths, cb) {
  _waitForChange(getMTimes(filePaths), cb);
}
