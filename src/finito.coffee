# Finito - Finite State Machines 
# Copyright (c) 2014 Jon Nordby <jononor@gmail.com>
# Finito may be freely distributed under the MIT license

Definition = require './definition'
common = require './common'
main = require './main'

exports.isBrowser = common.isBrowser

exports.targets =
  c: require '../targets/c/generate'
  js: require '../targets/js/machine'

exports.Machine = exports.targets.js
exports.Definition = Definition

exports.main = () ->

    commander = require 'commander'
    fs = require 'fs'
    path = require 'path'
    pkginfo = (require 'pkginfo')(module)

    commander
        .version module.exports.version

    commander
        .command 'generate'
        .option '-o, --output <FILE>', 'Output file'
        .description 'Generate (only needed for some target languages like C)'
        .action (infile, env) ->
            outfile = env.output || path.basename infile + '-gen.c'
            Definition.fromFile infile, (err, d) ->
                if err
                    throw err

                generateCMachine = exports.targets.c
                fs.writeFileSync outfile, generateCMachine d.data

    # TODO: support --format pdf,svg,png etc. Should use `dot` or whatever
    # TODO: support --format display, for automatically displaying output. Need to check which programs exist, and use that (or warn)
    #  | xdot -
    #  | dot -Tsvg | display
    #  | dot -Tsvg | inkscape /dev/stdin 
    commander
        .command 'dot'
        .option '-o, --output <FILE>', 'Output file'
        .description 'Generate DOT visualization of machine'
        .action (infile, env) ->
            outfile = env.output || path.basename infile + 'fsm.dot'
            Definition.fromFile infile, (err, d) ->
                if err
                    throw err

                dot = d.toDot()
                if env.output
                    fs.writeFileSync outfile, dot
                else
                    console.log dot

    commander.parse process.argv
