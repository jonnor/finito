EventEmitter = require('events').EventEmitter

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

module.exports = Machine
