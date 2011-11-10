var tsLog = require('./util').tsLog;

var handlers = {
  'modulr' : require('./modulr/build'),
  'jade'   : require('./jade/build'),
  'server' : require('./server'),
  'stylus' : require('./stylus/build')
};

exports.handle = function(job) {
  var type = job.type;

  var handler = handlers[type];

  if (handler) {
    handler.startJob(job);
  } else {
    tsLog({
      type: 'error',
      color: 'red',
      msg: 'ERROR: Unknown job type "' + type + '"'
    });
  }
};
