#!/usr/bin/env bash
# Environmental. Copyright (c) 2014, Kevin van Zonneveld (kvz.io)
exec      = require("child_process").exec
unflatten = require('flat').unflatten

class Environmental
  constructor: ({
    @ignore
  } = {}) ->
    @ignore ?= [
      "PWD"
      "SHLVL"
      "_"
    ]

  @config: (flat, filter) ->
    flat   ?= process.env
    filter ?= process.env.NODE_APP_PREFIX
    filter ?= false

    lowerEnv = {}
    for key, val of flat
      lowerEnv[key.toLowerCase()] = val

    nested = unflatten lowerEnv,
      overwrite: true
      object   : true
      delimiter: "_"

    if filter isnt false
      return nested[filter.toLowerCase()]

    return nested

  capture: (file, cb) ->
    stdout  = []
    stderr  = []
    flat    = {}
    options =
      env:
        {}

    cmd = exec "bash -c 'source #{file} && env'", options, (err, stdout, stderr) =>
      if err
        return cb "Error while running #{file}. #{err}. #{stderr}"

      for item in stdout.split "\n"
        parts = item.split "="
        key   = parts.shift()
        val   = parts.join "="
        if not key or key in @ignore
          continue
        flat[key] = val

      cb null, flat

module.exports = Environmental
