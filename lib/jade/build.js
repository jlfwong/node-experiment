var fs = require('fs');
var getMTimes = require('../watch').getMTimes;
var jade = require('jade');
var path = require('path');
var tsLog = require('../util').tsLog;
var waitForChange = require('../watch').waitForChange;

var build = exports.build = function(job, cb) {
  try {
    var contents = fs.readFileSync(job.source, 'utf8');
  } catch(e) {
    tsLog({
      type: 'jade',
      color: 'red',
      msg: 'Failed to read ' + path.resolve(job.source)
    });
    return;
  }

  var html = jade.compile(contents)();

  fs.writeFileSync(job.target, html);
};

var continuousBuild = exports.continuousBuild = function(job) {
  build(job);

  tsLog({
    type: 'jade',
    color: 'green',
    msg: 'Finished building ' + path.resolve(job.target)
  });

  waitForChange(getMTimes([job.source]), function() {
    continuousBuild(job);
  });
};

exports.startJob = function(job) {
  continuousBuild(job);
};
