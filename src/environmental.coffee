#!/usr/bin/env bash
# Environmental. Copyright (c) 2014, Kevin van Zonneveld (kvz.io)
exec      = require("child_process").exec
unflatten = require('flat').unflatten

class Environmental
  constructor: (@config) ->
    @config ?= {}
    @config.ignore ?= [
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

    try
      nested = unflatten lowerEnv,
        object   : true
        delimiter: "_"
    catch e
      console.log
        error   : "Could not unflatten this object"
        lowerEnv: lowerEnv
      throw e

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
        if @config.ignore.indexOf(key) isnt -1 or not key
          continue
        flat[key] = val

      cb null, flat

module.exports = Environmental
