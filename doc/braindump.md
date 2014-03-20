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

Tool should be able to run in browser (JavaScript) and have web UI. Usable standalone or integrated into NoFlo UI
Even allow created STMs to run in the browser, when possible.

Make testing easy, also of C/C++ based code. Have a set of typical test-classes one ones to perform.
Do testing by default, if possible. Can one expose a useful interface in a high-level language (JS/CS)?
Problem: for most tests, will need to manipulate inputs, and can't wrap those automatically

* http://www.cse.ohio-state.edu/~lee/english/pdf/ieee-proceeding-survey.pdf
* http://en.wikipedia.org/wiki/UML_state_machine#Orthogonal_regions

