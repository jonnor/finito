# Finito - Finite State Machines 
# Copyright (c) 2014 Jon Nordby <jononor@gmail.com>
# Finito may be freely distributed under the MIT license
##


exports.isBrowser = ->
    return not (typeof process isnt 'undefined' and process.execPath and process.execPath.indexOf('node') isnt -1)

EventEmitter = (require 'events').EventEmitter

class Machine extends EventEmitter

    constructor: (def, code, context) ->
        @def = def
        @state = null
        @code = code
        @context = context

        @changeState def.data.initial.state

    run: () =>
        @execute @def.data.states[@state].run

        for transition in @def.data.transitions
            if @state == transition.from and (@execute transition.when)
                @changeState transition.to
                break

    execute: (funcobj) =>
        return unless funcobj.function
        return true if funcobj.function == "true"
        # XXX: use proper function application with args
        return @code[funcobj.function](@context, funcobj.args[0], funcobj.args[1], funcobj.args[2], funcobj.args[3])

    changeState: (newState) =>
        if @state
            @execute @def.data.states[@state].leave
        @emit 'statechange', @state, newState
        @state = newState
        @execute @def.data.states[@state].enter

extractFunctionNameAndArgs = (fun) ->
    args = []
    if fun
        tok = fun.split '('
        if tok.length > 1
            fun = tok[0]
            tempargs = (tok[1][0..-2]).split ','
            for a in tempargs
                number = parseInt a
                if not isNaN number
                    args.push number
                else if a == "false" or a == "true"
                    args.push a == "true"
                else
                    if a.length > 0
                        args.push a

    return {'function': fun, 'args': args}

normalizeMachineDefinition = (def) ->
    def.initial = {} if not def.initial?
    def.initial.state = "" if not def.initial.state?
    def.exit = {} if not def.exit?
    def.exit.state = "" if not def.exit.state?

    state_id = 0
    for name, state of def.states
        # Assign a numerical ID
        def.states[name].id = state_id++
        def.states[name].enum = def.name+'_'+name

        # Default run function to name if no enter or leave specified
        run = state.run
        if not run and not (state.enter or state.leave)
            run = state.name
        def.states[name].transitions = [] # populated later
        def.states[name].run = extractFunctionNameAndArgs run
        def.states[name].enter = extractFunctionNameAndArgs state.enter
        def.states[name].leave = extractFunctionNameAndArgs state.leave

    for t in def.transitions
        # Attatch to state
        if not def.states[t.from].transitions?
            def.states[t.from].transitions = []
        def.states[t.from].transitions.push t

        # Transition name
        name = t.name || t.when
        t.name = name

        # Function predicate
        t.when = extractFunctionNameAndArgs t.when

    def.context = def.context || def.name

# TODO: allow to calculate all impossible paths, for a given state and whole machine
# TODO: support extracting description from source file
class Definition
    constructor: (data) ->
        @data = data
        normalizeMachineDefinition @data

    toDot: () ->
        indent = "    "
        r = "digraph #{} {\n"
        r += indent+"rankdir=LR;\n ranksep=\"0.07\"\n"
        r += indent+ "node [style=\"rounded,filled,bold\", width=0.4]"

        for state, val of @data.states
            opts = ''
            if state == @data.exit.state
              opts = 'shape=doublecircle, width=0.5, height=0.9'
            r += indent+"#{state} [#{opts}];\n"

        for t in @data.transitions
            r += indent+"#{t.from} -> #{t.to} [label=\"#{t.name}\"];\n"

        # Mark the inital state
        r += indent+"__start [fillcolor=black, shape=circle, label=\"\", width=0.25];\n"
        r += indent+"__start -> #{@data.initial.state}"

        r += "}";
        return r


Definition.fromJSON = (content) ->
    d = JSON.parse content
    return new Definition d

Definition.fromFSM = (content) ->
    peg = require 'pegjs'
    fs = require 'fs'
    path = require 'path'
    grammarfile = path.join __dirname, '..', '..', 'fsm.peg'
    fsm = peg.buildParser fs.readFileSync grammarfile, {encoding: 'utf-8'}
    #fsm = require '../../fsm.js'
    j = fsm.parse content
    return new Definition j

Definition.fromString = (content, type) ->
    if (type) == 'json'
        d = Definition.fromJSON content
    else if (type) == 'fsm'
        d = Definition.fromFSM content
    else
        throw new Error ("Unknown file type " + path.extname file + " for " + file)

    return d

Definition.fromFile = (file, callback) ->
    fs = require 'fs'
    path = require 'path'
    fs.readFile file, {encoding: 'utf-8'}, (err, content) ->
        if err
            callback err, null
        else
            try
                d = Definition.fromString content, (path.extname file)[1..]
            catch e
                return callback e, null

            return callback null, d

Definition.fromHttp = (url, callback) ->

    if exports.isBrowser
        req = new XMLHttpRequest
        req.onreadystatechange = ->
            return unless req.readyState is 4

            if req.status is not 200
                return callback new Error(""), null
            else
                try
                    # FIXME: support .fsm and others, either from filename in url or mimetype
                    d = Definition.fromString req.responseText, 'json'
                catch e
                    return callback e, null

                return callback null, d

        req.open 'GET', url, true
        req.send()

    else
        http = require 'http'
        throw new Error "HTTP GET not implemented on node.js"

        # FIXME: implement http GET for node.js

        if err
            callback err, null
        else
            try
                d = Definition.fromString content, (path.extname file)[1..]
            catch e
                return callback e, null

            return callback null, d


exports.targets =
  c: require '../../targets/c/generate'

exports.Machine = Machine
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
