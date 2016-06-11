# Finito - Finite State Machines 
# Copyright (c) 2014 Jon Nordby <jononor@gmail.com>
# Finito may be freely distributed under the MIT license
##

if typeof process isnt 'undefined' and process.execPath and process.execPath.indexOf('node') isnt -1
    finito = require '../lib/js/finito'
    chai = require 'chai'
    path = require 'path'
else
    finito = require '../build/finito'
    chai = window.chai

# TODO: make possible to run in browser, fetching data using HTTP
add_equivalance_test = (basepath) ->

    fsmfile = path.join path.resolve __dirname, '..',  basepath+'.fsm'
    jsonfile = path.join path.resolve __dirname, '..',  basepath+'.json'

    describe 'FSM DSL: ' + basepath, ->
        json = null
        fsm = null

        before (finish) ->
            finito.Definition.fromFile fsmfile, (err, res) ->
                return finish err if err
                fsm = res
                finito.Definition.fromFile jsonfile, (err, res) ->
                    return finish err if err
                    json = res
                    return finish null

        describe 'parsing the .fsm and .json definitions', (finish) ->

            it 'initial state should be equal', ->
                chai.expect(fsm.data.initial.state).to.equal json.data.initial.state

            it 'number of states should be equal', ->
                chai.expect(fsm.data.states.length).to.equal json.data.states.length

            it 'number of transitions should be equal', ->
                chai.expect(fsm.data.transitions.length).to.equal json.data.transitions.length

# Data-driven tests
cases = [
    'examples/first/machine'
]

for data in cases
   add_equivalance_test data
