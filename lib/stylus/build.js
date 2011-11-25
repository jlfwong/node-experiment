var fs = require('fs');
var path = require('path');
var stylus = require('stylus');
var tsLog = require('../util').tsLog;
var waitForChange = require('../watch').waitForChange;

var build = exports.build = function(job, cb) {
  try {
    var contents = fs.readFileSync(job.source, 'utf8');
  } catch(e) {
    tsLog({
      type: 'stylus',
      color: 'red',
      msg: 'Failed to read ' + path.resolve(job.source)
    });
    return;
  }

  stylus(contents).render(function(err, css) {
    if (err) {
      tsLog({
        type: 'stylus',
        color: 'red',
        msg: 'Failed to compile ' + path.resolve(job.source)
      });
      console.error(err.stack);
    } else {
      fs.writeFileSync(job.targetFile, css);
    }
    cb();
  });
};

var continuousBuild = exports.continuousBuild = function(job) {
  var basename = path.basename(job.source, '.styl');

  job.targetFile = path.resolve(job.targetDir, basename + '.css')

  build(job, function() {
    tsLog({
      type: 'stylus',
      color: 'green',
      msg: 'Finished building ' + path.resolve(job.targetFile)
    });

    waitForChange([job.source], function() {
      continuousBuild(job);
    });
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
