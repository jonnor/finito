
# TODO: allow to calculate all impossible paths, for a given state and whole machine

# TODO: allow machine definition together with states
# FIXME: support a context object

events = require 'events'

class StateMachine extends events.EventEmitter

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


exports.main = () ->
    c = require "./examples/first/states.coffee"
    d = require "./examples/first/machine.json"
    m = new StateMachine d, c

    m.on 'statechange', (n, old) ->
        console.log 'statechange', n, old

    m.run()
    m.run()
    m.run()

exports.main()
