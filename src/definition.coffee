# Finito - Finite State Machines 
# Copyright (c) 2014-2016 Jon Nordby <jononor@gmail.com>
# Finito may be freely distributed under the MIT license

common = require './common'
schemas = require './schemas'

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
    grammarfile = path.join __dirname, '../fsm.peg'
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

    if common.isBrowser
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

module.exports = Definition
