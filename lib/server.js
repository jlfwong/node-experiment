var FileServer = require('node-static').Server;
var path = require('path');
var tsLog = require('./util').tsLog;

exports.startJob = function(job) {
  var port = job.port;
  var root = job.root;

  if (!port) {
    tsLog({
      type: 'server',
      color: 'red',
      msg: 'No port specified for server - exiting'
    });
    return;
  }

  var root = job.root;
  if (!root) {
    tsLog({
      type: 'server',
      color: 'red',
      msg: 'No root specified for server - exiting'
    });
    return;
  }

  var fileServer = new FileServer(root);

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
    msg: 'Serving ' + path.resolve(root) + ' on http://localhost:' + port
  });
};
