#!/usr/bin/env node
'use strict';

var cli = require('cli').enable('status', 'help', 'version', 'glob', 'timeout');
var Environmental = require('../lib/environmental');

cli.parse({
  'file': [false, 'Environment file to capture e.g. envs/production.sh', 'file'],
  'format': [false, "Out format e.g. 'json' or 'space'", 'string', 'json']
});

cli.main(function (args, options) {
  var config = {};

  // Camelcase cli arguments into config object to instantiate environmental
  for (var key in options) {
    var camelCased = key.replace(/-(.)/g, function (g) {
      return g[1].toUpperCase();
    });
    config[camelCased] = options[key];
  }
  if (!config.file) {
    return cli.fatal('File argument is required.');
  }

  // Instantiate
  var environmental = new Environmental(config);

  // Capture
  environmental.capture(config.file, function (err, flat) {
    if (err) {
      console.error('Error. ' + err);
      process.exit(1);
    }

    // Collect bash encoded output
    var output = [];
    for (var _key in flat) {
      var val = '' + flat[_key];
      if (val.indexOf(' ') > -1 || val.indexOf('\t') > -1 || !val) {
        // Quote when necessary
        val = '"' + val + '"';
      }
      output.push(_key + '=' + val);
    }

    // Decide on format
    if (config.format === 'json') {
      console.log(JSON.stringify(flat));
    } else if (config.format === 'space') {
      console.log(output.join(' '));
    } else if (config.format === 'newline') {
      console.log(output.join('\n'));
    } else {
      return cli.fatal('Unknown output format ' + config.format);
    }
  });
});
//# sourceMappingURL=cli.js.map