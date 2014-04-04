# Finito - Finite State Machines 
# Copyright (c) 2014 Jon Nordby <jononor@gmail.com>
# Finito may be freely distributed under the MIT license
##

if typeof process isnt 'undefined' and process.execPath and process.execPath.indexOf('node') isnt -1
    finito = require '../lib/js/finito'
else
    finito = require '../build/finito'

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
        m = new finito.Machine d, f
        it 'initial state should be "off"', ->
            chai.expect(m.state).to.equal 'off'

    describe 'loading ', ->
        m = new finito.Machine d, f
        it 'initial stat should be "off"', ->
            chai.expect(m.state).to.equal 'off'

###
main = () ->

    m.on 'statechange', (n, old) ->
        console.log 'statechange', n, old
    m.run()
    m.run()
    m.run()

main()
###
