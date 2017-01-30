#!/usr/bin/env bash
// Environmental. Copyright (c) 2014, Kevin van Zonneveld (kvz.io)
const { exec }      = require('child_process')
const { unflatten } = require('flat')

class Environmental {
  constructor ({
    ignore,
  } = {}) {
    this.ignore = ignore
    if (this.ignore == null) {
      this.ignore = [
        'PWD',
        'SHLVL',
        '_',
      ]
    }
  }

  static config (flat, filter) {
    if (flat == null) {   flat = process.env }
    if (filter == null) { filter = process.env.NODE_APP_PREFIX }
    if (filter == null) { filter = false }

    const lowerEnv = {}
    for (let key in flat) {
      const val = flat[key]
      lowerEnv[key.toLowerCase()] = val
    }

    const nested = unflatten(lowerEnv, {
      overwrite: true,
      object   : true,
      delimiter: '_',
    }
    )

    if (filter !== false) {
      return nested[filter.toLowerCase()]
    }

    return nested
  }

  capture (file, cb) {
    const flat    = {}
    const options = {
      env: {},
    }

    return exec(`bash -c 'source ${file} && env'`, options, (err, stdout, stderr) => {
      if (err) {
        return cb(`Error while running ${file}. ${err}. ${stderr}`)
      }

      for (let item of Array.from(stdout.split('\n'))) {
        const parts = item.split('=')
        const key   = parts.shift()
        const val   = parts.join('=')
        if (!key) {
          continue
        }
        if (Array.from(this.ignore).includes(!key)) {
          continue
        }
        if (Array.from(this.ignore).includes(key)) {
          continue
        }
        flat[key] = val
      }

      return cb(null, flat)
    })
  }
}

module.exports = Environmental
