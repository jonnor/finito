# Finito - Finite State Machines 
# Copyright (c) 2014 Jon Nordby <jononor@gmail.com>
# Finito may be freely distributed under the MIT license
##


exports.isBrowser = ->
    return not (typeof process isnt 'undefined' and process.execPath and process.execPath.indexOf('node') isnt -1)

if not exports.isBrowser()
    pkginfo = (require 'pkginfo')(module)
events = require 'events'


class Machine extends events.EventEmitter

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
                a = number if not number is NaN
                args.push a

    return {'function': fun, 'args': args}

normalizeMachineDefinition = (def) ->
    id = 0
    for name, state of def.states
        # Assign a numerical ID
        def.states[name].id = id++
        def.states[name].enum = def.name+'_'+name

        # Default run function to name if no enter or leave specified
        run = state.run
        if not run and not (state.enter or state.leave)
            run = state.name
        def.states[name].run = extractFunctionNameAndArgs run
        def.states[name].enter = extractFunctionNameAndArgs state.enter
        def.states[name].leave = extractFunctionNameAndArgs state.leave

    for i in [0...def.transitions.length]
        t = def.transitions[i]

        # Attatch to state
        if not def.states[t.from].transitions?
            def.states[t.from].transitions = []
        def.states[t.from].transitions.push t

        # Transition name
        name = t.name || t.when
        def.transitions[i].name = name

        # Function predicate
        def.transitions[i].when = extractFunctionNameAndArgs def.transitions[i].when

    def.context = def.context || def.name

nameToEnum = (name, values) ->
    return values[name].enum

nameToId = (name, values) ->
    return values[name].id

idToName = (id, values) ->
    for name, val of values
        if val.id == id
            return name

# TODO: allow to calculate all impossible paths, for a given state and whole machine
# TODO: support extracting description from source file
class Definition
    constructor: (data) ->
        @data = data
        normalizeMachineDefinition @data

    toDot: () ->
        indent = "    "
        r = "digraph #{} {\n"
        r += indent+"rankdir=LR;\n    ranksep=\"0.02\"\n"
        for t in @data.transitions
            r += indent+"#{t.from} -> #{t.to} [label=\"#{t.name}\", minlen=0.2];\n"
        # Mark the inital state
        r += indent+"__start [style = invis, shape = none, label = \"\", width = 0, height = 0];\n"
        r += indent+"__start -> #{@data.initial.state}"
#        for state, val of @data.states
#            r += indent+"start -> #{state} [label=\"\", style=invis];\n"
        r += "}";
        return r


Definition.fromJSON = (content) ->
    d = JSON.parse content
    return new Definition d

Definition.fromFSM = (content) ->
    peg = require 'pegjs'
    fs = require 'fs'
    fsm = peg.buildParser fs.readFileSync 'fsm.peg', {encoding: 'utf-8'}
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


# IDEA: split C codegen out into common library, share with MicroFlo?
generateEnum = (name, prefix, enums) ->
    if Object.keys(enums).length == 0
        return ""
    indent = "\n    "

    out = "enum " + name + " {";
    a = []
    for e, val of enums
        v = if (val.id != undefined) then " = " + val.id else ""
        a.push (indent + prefix + e + v)
    out += a.join ","
    out += "\n};\n"

    return out

normalizeCArgs = (args, def, readwrite) ->
    ref = if readwrite then "" else "const "
    ctx = "(#{ref}#{def.context} *)(context)"
    newargs = [ctx]
    for a in args
        if a
            newargs.push a

    return newargs.join ','

# IDEA: add a C machine definition based on function pointers that does not require any code generation
# TODO: support callbacks in addition to polling transition functions
generateRunFunction = (name, def) ->
    indent = "    "
    r = "FinitoStateId " + name + "(FinitoStateId current_state, void *context) {\n"

    r += indent + "FinitoStateId new_state = current_state;\n\n"
    r += indent + "// Running state \n"
    r += indent + "switch (current_state) {\n"
    for name, state of def.states
        stateId = nameToEnum name, def.states
        r+= indent + "case #{stateId}: \n"

        # Transition predicate
        for transition in state.transitions
            fromId = nameToEnum transition.from, def.states
            toId = nameToEnum transition.to, def.states
            func = transition.when.function
            args = normalizeCArgs transition.when.args, def
            predicate = if func == "true" or func == "false" then func else "#{func}(#{args})"
            r += indent+indent+"if (#{predicate}) new_state = #{toId}; break;\n"

    r += indent+"default: break;\n"
    r += indent + "}\n"
    r += indent + "\n"

    r += indent+"if (new_state != current_state) {\n"

    r += indent + "// Leave\n"
    r += indent + "switch (current_state) {\n"
    for name, state of def.states
        stateId = nameToEnum name, def.states
        fun = state.leave.function
        if fun
            args = normalizeCArgs state.leave.args, def, true
            predicate = if fun == "true" or fun == "false" then fun else "#{fun}(#{args})"
            r+= indent+"case #{stateId}: #{predicate}; break;\n"
    r += indent+"default: break;\n"
    r += indent + "}\n"

    r += indent + "// Enter\n"
    r += indent + "switch (new_state) {\n"
    for name, state of def.states
        stateId = nameToEnum name, def.states
        fun = state.enter.function
        if fun
            args = normalizeCArgs state.enter.args, def, true
            r+= indent+"case #{stateId}: #{fun}(#{args}); break; \n"
    r += indent+"default: break;\n"
    r += indent + "}\n"

    r += indent + "}\n"

    # TODO: only run if no state transition?
    r += indent + "// Run\n"
    r += indent + "switch (new_state) {\n"
    for name, state of def.states
        stateId = nameToEnum name, def.states
        fun = state.run.function
        if fun
            args = normalizeCArgs state.run.args, def, true
            r+= indent+"case #{stateId}: #{func}(#{args}); break; \n"
    r += indent+"default: break;\n"
    r += indent + "}\n"

    r += indent + "return new_state;\n"
    r += "}\n"
    return r

generateInitial = (name, def) ->
    return 'const FinitoStateId ' + name + " = " + nameToId(def.initial.state, def.states) + ";\n"

generateStringMap = (mapname, values) ->
    indent = "    "
    r = "static const char *#{mapname}[] = {\n"
    for name, val of values
        r += indent+"\"#{name}\",\n"
    r.trim ","

    r+= "};\n"
    return r

generateDefinition = (name, def) ->
    indent = "   "
    r = "FinitoDefinition #{name}_def = {\n"
    initial = nameToId(def.initial.state, def.states)
    r += indent+"#{initial}, #{name}_run, #{name}_statenames\n"
    r += "};\n"
    return r

# TODO: generate id -> char * map for transitions
generateCMachine = (def) ->
    name = def.name
    g = "// Generated by Finito State Machine\n"
    g += generateEnum name+'States', name+'_', def.states
    g += generateStringMap name+'_statenames', def.states
    g += generateRunFunction name+'_run', def
    g += generateDefinition name, def
    return g


exports.Machine = Machine
exports.Definition = Definition

exports.main = () ->

    commander = require 'commander'
    fs = require 'fs'
    path = require 'path'

    commander
        .version module.exports.version

    commander
        .command 'generate'
        .option '-o, --output <FILE>', 'Output file'
        .description 'Generate (only needed for some target languages like C)'
        .action (infile, env) ->
            outfile = env.output || path.basename infile + '-gen.c'
            Definition.fromFile infile, (err, d) ->
                fs.writeFileSync outfile, generateCMachine d.data

    commander
        .command 'dot'
        .option '-o, --output <FILE>', 'Output file'
        .description 'Generate DOT visualization of machine'
        .action (infile, env) ->
            Definition.fromFile infile, (err, d) ->
                if err
                    throw err

                dot = d.toDot()
                if env.output
                    fs.writeFileSync outfile, dot
                else
                    console.log dot

    commander.parse process.argv
