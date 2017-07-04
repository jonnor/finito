
Definition = require './definition'

# Fluent API for creating a definition
class MachineBuilder
  constructor: (name) ->
    @data =
      name: name
      initial: undefined
      exit: undefined
      states: {}
      transitions: []
    @transitions = [] # TransitionBuilder instances
    @states = {} # StateBuilder instances
    @dead = false

  initial: (id) ->
    @data.initial = id
    return this

  state: (id) ->
    s = new StateBuilder this, id
    @states[id] = s
    return s

  transition: (name) ->
    t = new TransitionBuilder this, name
    @transitions.push t
    return t

  done: () ->
    throw new Error "MachineBuilder.done() called multiple times" if @dead
    @dead = true

    for t in @transitions
      @data.transitions.push t.data
    for id, s of @states
      @data.states[id] = s.data
    return new Definition @data


addMachineChainedMethods = (obj) ->
  # Calling these methods on Transition/State should invoke that of the containing Machine
  machineChainedFunctions = [
    'done', 'state', 'transition', 'initial'
  ]

  machineChainedFunctions.forEach (name) ->
    machine = obj.machine
    obj[name] = () ->
      ret = machine[name].apply machine, arguments
      return ret

class TransitionBuilder
  constructor: (@machine, name) ->
    addMachineChainedMethods this
    @data =
      from: undefined
      to: undefined
      name: name

  # Transition properties
  from: (s) ->
    @data.from = s
    return this
  to: (s) ->
    @data.to = s
    return this
  # when is a reserved keyword in CoffeeScript
  '_when': (s) ->
    return @when s
  'when': (s) ->
    @data['when'] = s
    return this

class StateBuilder
  constructor: (@machine, @id) ->
    addMachineChainedMethods this
    @data = 
      enter: undefined
      leave: undefined
      run: undefined

  # State properties
  enter: (func) ->
    @data.enter = func
    return this
  leave: (func) ->
    @data.leave = func
    return this
  run: (func) ->
    @data.run = func
    return this

  # create transitions with this state as implicit target
  from: (s) ->
    return @machine.transition().from(s).to(@id)
  to: (s) ->
    return @machine.transition().from(@id).to(s)


module.exports = MachineBuilder
