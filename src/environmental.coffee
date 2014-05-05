#!/usr/bin/env bash
# Environmental. Copyright (c) 2014, Kevin van Zonneveld (kvz.io)
exec      = require("child_process").exec
unflatten = require('flat').unflatten

class Environmental
  constructor: (@ignore) ->
    @ignore ?= [
      "PWD"
      "SHLVL"
      "_"
    ]

  nested: (flat, filter) ->
    lowerEnv = {}
    for key, val of flat
      lowerEnv[key.toLowerCase()] = val
    nested = unflatten lowerEnv, delimiter: "_"

    if filter
      return nested[filter.toLowerCase()]

    return nested

  capture: (file, cb) ->
    stdout  = []
    stderr  = []
    flat    = {}
    options =
      env:
        {}

    cmd = exec "source #{file} && env", options, (err, stdout, stderr) =>
      if err
        return cb ("Error while running #{file}. #{err}. #{stderr}")

      for item in stdout.split("\n")
        parts = item.split("=")
        key   = parts.shift()
        val   = parts.join("=")
        continue  if @ignore.indexOf(key) isnt -1 or not key
        flat[key] = val

      cb null, flat

module.exports = Environmental
