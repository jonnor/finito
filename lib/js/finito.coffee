# Finito - Finite State Machines 
# Copyright (c) 2014 Jon Nordby <jononor@gmail.com>
# Finito may be freely distributed under the MIT license
##

# TODO: allow to calculate all impossible paths, for a given state and whole machine

# TODO: allow machine definition together with states
# FIXME: support a context object

pkginfo = (require 'pkginfo')(module)

events = require 'events'


class Machine extends events.EventEmitter

    constructor: (def, code) ->
        @def = def
        @state = def.initial.state
        @code = code

    run: () =>
        @execute @state

        for transition in @def.transitions
            if @state == transition.from and @execute transition.when
                @changeState transition.to
                break

    execute: (name) =>
        return @code[name]()

    changeState: (newState) =>
        # TODO: support enter/leave states
        @emit 'statechange', @state, newState
        @state = newState

extractFunctionNameAndArgs = (fun) ->
    args = []
    tok = fun.split '('
    if tok.length > 1
        fun = tok[0]
        args = (tok[1][0..-2]).split ','
    return [fun, args]

normalizeMachineDefinition = (def) ->
    id = 0
    for name, state of def.states
        # Assign a numerical ID
        def.states[name].id = id++
        def.states[name].enum = def.name+'_'+name

        # Function to use
        fun = state.function || name
        fun_args = extractFunctionNameAndArgs fun
        def.states[name].function = fun_args[0]
        def.states[name].args = fun_args[1]

    for i in [0...def.transitions.length]
        t = def.transitions[i]

        # Transition name
        name = t.name || t.when
        def.transitions[i].name = name

        # Function predicate
        fun_args = extractFunctionNameAndArgs def.transitions[i].when
        def.transitions[i].when =
            function: fun_args[0]
            args: fun_args[1]

nameToEnum = (name, values) ->
    return values[name].enum

nameToId = (name, values) ->
    return values[name].id

idToName = (id, values) ->
    for name, val of values
        if val.id == id
            return name

# TODO: support a domain-specific language
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
        r += indent+"start [style = invis, shape = none, label = \"\", width = 0, height = 0];\n"
        r += indent+"start -> #{@data.initial.state}"
#        for state, val of @data.states
#            r += indent+"start -> #{state} [label=\"\", style=invis];\n"
        r += "}";
        return r


Definition.fromJSON = (content) ->
    d = JSON.parse content
    return new Definition d

Definition.fromFile = (file, callback) ->
    fs = require 'fs'
    fs.readFile file, (err, content) ->
        callback null, Definition.fromJSON content


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

# IDEA: add a C machine definition based on function pointers that does not require any code generation
# TODO: support callbacks in addition to polling transition functions
# TODO: support enter/leave functions
generateRunFunction = (name, def) ->
    indent = "    "
    r = "FinitoStateId " + name + "(FinitoStateId current_state) {\n"

    r += indent + "// Running state \n"
    r += indent + "switch (current_state) {\n"
    for name, state of def.states
        stateId = nameToEnum name, def.states
        args = state.args.join ','
        r+= indent + "case #{stateId}: #{state.function}(#{args}); break; \n"
    r += indent + "}\n"
    r += indent + "\n"

    r += indent + "// Checking transition predicates \n"
    for transition in def.transitions
        fromId = nameToEnum transition.from, def.states
        toId = nameToEnum transition.to, def.states
        func = transition.when.function
        args = transition.when.args.join ','
        r += indent+"if (current_state == #{fromId} && #{func}(#{args}) ) return #{toId};\n"

    r += indent + "return current_state;\n"
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
                dot = d.toDot()
                if env.output
                    fs.writeFileSync outfile, dot
                else
                    console.log dot

    commander.parse process.argv
