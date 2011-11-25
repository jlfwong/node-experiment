var fs = require('fs');
var child_process = require('child_process');
var modulr = require('modulr');
var path = require('path');

var readJsonFile = exports.readJsonFile = function(filePath) {
  if (!path.existsSync(filePath)) {
    console.log('File not found: ' + filePath);
    return false;
  }

  if (!path.existsSync(filePath)) {
    console.log('File not found: ' + filePath);
    return false;
  }

  try {
    var rawContents = fs.readFileSync(filePath, 'utf8');
  } catch(e) {
    console.log('Failed to read file ' + filePath, e.stack);
    return false;
  }

  try {
    var contents = JSON.parse(rawContents);
  } catch(e) {
    console.log('Invalid JSON in ' + filePath, rawContents, e.stack);
    return false;
  }

  return contents;
};

require('colors');
var tsLog = exports.tsLog = function(options) {
  var type = options.type;
  var color = options.color;
  var msg = options.msg;

  while(type.length < 6) {
    type = ' ' + type;
  }

  var output = ('[' + (new Date().toLocaleTimeString()) + '] ' +
    '(' + type + ') ' +
    msg);

  if (color) {
    output = output[color];
  }

  console.log(output);
};
