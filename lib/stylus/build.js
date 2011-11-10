var fs = require('fs');
var getMTimes = require('../watch').getMTimes;
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
        msg: 'Failed to read ' + path.resolve(job.source)
      });
      console.log(err);
    } else {
      fs.writeFileSync(job.target, css);
    }
    cb();
  });

};

var continuousBuild = exports.continuousBuild = function(job) {
  build(job, function() {
    tsLog({
      type: 'stylus',
      color: 'green',
      msg: 'Finished building ' + path.resolve(job.target)
    });

    waitForChange(getMTimes([job.source]), function() {
      continuousBuild(job);
    });
  });
};

exports.startJob = function(job) {
  continuousBuild(job);
};
