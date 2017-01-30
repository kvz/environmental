#!/usr/bin/env node
const cli           = require('cli').enable('status', 'help', 'version', 'glob', 'timeout')
const Environmental = require('./environmental')

cli.parse({
  'file'  : [false,  'Environment file to capture e.g. envs/production.sh', 'file'],
  'format': [false, "Out format e.g. 'json' or 'space'", 'string', 'json'],
})

cli.main(function (args, options) {
  const config = {}

  // Camelcase cli arguments into config object to instantiate environmental
  for (const key in options) {
    const camelCased = key.replace(/-(.)/g, g => g[1].toUpperCase())
    config[camelCased] = options[key]
  }
  if (!config.file) {
    return cli.fatal('File argument is required.')
  }

  // Instantiate
  const environmental = new Environmental(config)

  // Capture
  environmental.capture(config.file, (err, flat) => {
    if (err) {
      console.error(`Error. ${err}`)
      process.exit(1)
    }

    // Collect bash encoded output
    const output = []
    for (const key in flat) {
      let val = (`${flat[key]}`)
      if (val.indexOf(' ') > -1 || val.indexOf('\t') > -1 || !val) {
        // Quote when necessary
        val = `"${val}"`
      }
      output.push(`${key}=${val}`)
    }

    // Decide on format
    if (config.format === 'json') {
      console.log(JSON.stringify(flat))
    } else if (config.format === 'space') {
      console.log(output.join(' '))
    } else if (config.format === 'newline') {
      console.log(output.join('\n'))
    } else {
      return cli.fatal(`Unknown output format ${config.format}`)
    }
  })
})
