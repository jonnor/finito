Related
========

* [Ragel](http://www.colm.net/open-source/ragel/), FSM based parsing framework with multi-language support

Finite State Machines & Flow-based programming
==============================================

TODO: check for prior art around this design pattern. Ask on FBP mailing list

Consider the StateMachine (SM) as a FBP component, containing one flows/graphs for
each of the possible states.

All the in and outports of the contained graphs are exposed on the SM,
and it routes packets to the appropriate state sub-flow depending on current state.

A set of nodes listening to data from inports (and/or intermediate nodes of state flows)
acts as predicates, and decides when to transition to a new state.

Enter/leave is modeled by special messages (or special ports),
sent by the SM to state sub-flows on transitions.

It may or may not be desirable to be able to visualize the setup in the traditional FSM way,
a graph with circular nodes for states, directed edges for transitions.

It is desirable that the ST is easily testable. We at least want to be able to
* Mock the input and check succesful transition
* Assert that after a set of functional tests, all states have been visited
* Assert that there are no ambigious transitions

It is desirable that one can easily introspect the ST at runtime,
both get current state and subscribe to state transitions.

Related to this high-level FSM, it would be nice to be able to create small FBP components
using a structured/visual FSM, for cases where a dynamic ST is not performant enough.
It may be neccesary to do code-generation to realize this, and that predicates and enter/leave/run
functions are standard C++ code.
Challenges:
* Having a sensible mapping from C++ code back to model definition, especially for debugging
* Injecting code snippets into the appropriate context when generating, so they have access to the state/data needed

Finito State Machines
---------------
Should probably be a project of its own

* High-level definition of machine: states,transitions (action,predicates)
* Do we need to specify inputs? For C/C++, should it include the type?
* JSON as canonical format, possibly a DSL over time (ala .FBP)
* Use a naming convention for mapping, but allow to be overriden

* Absolutely minimal amount of code generation.
For embedded C/C++, just the transition function (predicate checking) and runtime introspection data
In higher-level languages, just interpret the FSM definition at runtime
* Generated code go into separate file, that can be included together with framework/library import
* The code that is wired together into a state machine have no dependencies/knowledge of the STM

Question: which FSM style? one or multiple? I want to have at least an event-driven FSM

Support multiple output targets:
* C (state as context pointers)
* C++ (method calls on instance)
* Python, JavaScript
* FBP

How should the STM input be encoded and passed to actions/predicates?.
It will need to be (one or more) generic type. Just a pointer/reference?
Is it acceptable to have only one?
Disadvantages: 
* implicit dependencies in actions
* reduces encapsulation, actions can grab anything they'd like
* may need to create temporary objects, change signatures of existing functions
Should probably allow multiple, opt-in

Allow in MicroFlo to easily create a component which uses FSM (actions+predicates plain C/C++)
Allow in NoFlo to make a subgraph/component which uses FSM (no code gen, action+predicates are sub-flows)

Even allow created STMs to run in the browser, when possible.

Make testing easy, also of C/C++ based code. Have a set of typical test-classes one ones to perform.
Do testing by default, if possible. Can one expose a useful interface in a high-level language (JS/CS)?
Problem: for most tests, will need to manipulate inputs, and can't wrap those automatically

* http://www.cse.ohio-state.edu/~lee/english/pdf/ieee-proceeding-survey.pdf
* http://en.wikipedia.org/wiki/UML_state_machine#Orthogonal_regions

Reusable state machine components
===================================

Allow parametrization
For a power-up/down sequence, one should be to not have to generate one set of state+transition functions
for every power in the sequece. Instead should be able to define that the different states use the same functions,
but with different parameters.

Allow boolean expressions
If a transition predicate is just a boolean combination of predicate functions,
it would be nice to express thisdirectly in the graph.
Of course this neccitates a DSL definition and parser for the expressions,
as well as a transator which makes it into valid target code.
MicroFlo could then expose expressions on Packets?

Can one have general, reusable components for state machines?
To avoid having to always write own states and predicates
    wait(x seconds): transitions to next state after X seconds
Can they be implement as sub-machines, using enter/leave or dedicated init/exit states?

Allow widely different implementations of same machine for different "runtimes"
'wait' on microcontroller, periodically checks current time against time to wait for, or uses an interrupt
'wait' on browser, uses a callback for the setTimeout JavaScript API
Both cases need to capture some data when initially activated, possibly run a number of times in normal state, then do cleanup


Relation to HW/UI/interaction prototyping
==============================

http://snips.net/blog/posts/2014/05-04-fast-interactive_prototyping_with_d3_js_II.html


FSM DSL
========
Current idea, inspired by .fbp DSL

Machine definition

    machine = "My Machine"

State definition

    machine.On(on_state_function, "Machine is On")

Transition definition & usage
    
    machine.turn_on[turn_on_predicate, "On button pressed"]
    machine.Off turn_on=> machine.Booting

Shorthands

    _ = "My machine"
    Off() [button_on]=> Booting() [boot_done]=> On() [button_off]=> Off
    # states/transition implicitly binds to the '_' machine
    # _ can be reassigned during one file
    # Description and function defaults to name of transition

TODO:
* Enter/leave states
* Hierarchical state machine composition
* Parametrized predicate/state functions
* Boolean expressions in predicates


GUI
----
Tool should be able to run in browser (JavaScript) and have web UI. Usable standalone or integrated into NoFlo UI

Resources
* https://github.com/cpettitt/dagre-d3, http://jsfiddle.net/Qh9X5/1502/
* http://cytoscape.github.io/cytoscape.js/
* http://bl.ocks.org/rkirsling/5001347
* https://github.com/laxatives/Edit-Arbor.js
* http://visjs.org/docs/graph.html


Testing
----------
* Log state transitions, verify that each state has been visisted (by manual or automated test)
* Apply external stimuli to cause state transition, verify that it did happen
* Drive a state transition directly from test, verify that state actions were as expected
* Run machine in virtual/emulated environment, verify that no side-effects occur outside machine state
* Modify constants/parameters/transitions order programatically from test,
    run program X times, evaluate failure rates statistically



Others on Finite State Machines
===============================


"You may not like the idea of auto-generated code today,
but I guarantee that once you program for a state machine framework,
you'll see the benefits of the overall structure
and be ready to move up a level in programming efficiency."
- Michael Barr, http://www.embedded.com/electronics-blogs/barr-code/4372183/Trends-in-embedded-software-design

! Finito allows programming with state machines *without* generating code.


