var FileServer = require('node-static').Server;
var path = require('path');
var tsLog = require('./util').tsLog;

exports.startJob = function(job) {
  var port = job.port;
  var targetDir = job.targetDir;

  if (!port) {
    tsLog({
      type: 'server',
      color: 'red',
      msg: 'No port specified for server - exiting'
    });
    return;
  }

  var targetDir = job.targetDir;
  if (!targetDir) {
    tsLog({
      type: 'server',
      color: 'red',
      msg: 'No targetDir specified for server - exiting'
    });
    return;
  }

  var fileServer = new FileServer(targetDir);

  require('http').createServer(function (request, response) {
    request.addListener('end', function () {
      tsLog({
        type: 'server',
        msg: request.url
      });
      fileServer.serve(request, response);
    });
  }).listen(port);

  tsLog({
    type: 'server',
    color: 'green',
    msg: 'Serving ' + path.resolve(targetDir) + ' on http://localhost:' + port
  });
};
