# Finito - Finite State Machines 
# Copyright (c) 2014 Jon Nordby <jononor@gmail.com>
# Finito may be freely distributed under the MIT license
##

if typeof process isnt 'undefined' and process.execPath and process.execPath.indexOf('node') isnt -1
    finito = require '../lib/js/finito'
    chai = require('chai');
else
    finito = require '../build/finito'
    chai = window.chai

describe 'Machine', ->
    d =
        name: "MyMachine"
        states: 
            'on': {}
            starting: {}
            'off': {}
        transitions: [
            {from: "off", to: "starting", 'when': "condition"}
            {from: "starting", "to": "on", 'when': "condition"}
            {from: "on", to: "off", 'when': "condition"}
        ]
        initial:
            state: "off"
    f = 
        'off': () ->
        starting: () ->
        'on': () ->
        condition: () -> return false
    m = null

    describe 'creating new Machine', ->
        m = new finito.Machine (new finito.Definition d), f
        it 'initial state should be "off"', ->
            chai.expect(m.state).to.equal 'off'

