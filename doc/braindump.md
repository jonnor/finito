Related
========

Open source projects

* [Ragel](http://www.colm.net/open-source/ragel/), FSM based parsing framework with multi-language support
* [OOSMOS: The Object-Oriented State Machine Operating System](http://oosmos.com/?Action=HN)
* [Quantum Leaps QP](http://www.state-machine.com/), C/C++ FSM framework, GPLv3/commercial dual-licensed. Has freeware visual editor
* [SMC - The State Machine Compiler](http://smc.sourceforge.net/)

Open source Libraries

* [Akka FSM Actor](http://doc.akka.io/docs/akka/snapshot/scala/fsm.html), part of the actor-framework of Scala.
Don't how it is a subclass of Actor, though interesting in relationship to FBP.
Also include support for FSM logging / event tracing.
* [finite_machine](https://github.com/piotrmurach/finite_machine),
Ruby Gem including an embedded DSL, and programatic API. Well documented, looks well thought out.
* [Qt StateMachine](http://doc.qt.io/qt-4.8/statemachine-api.html), for C++.
Interestingly has built-in concept of parallel states/transitions. Centered around Qt events, and signals concept.
Some animation integrations.
* [Fluent-State-Machine](https://github.com/Real-Serious-Games/Fluent-State-Machine) for C#.
* [Stateless](https://github.com/dotnet-state-machine/stateless) for C#. Supports hierachical states (sub-states).

Javascript libraries

* [machina.js](https://github.com/ifandelse/machina.js).
Looks mature, actively developed at least 2012-2015. Includes support for hierarchical FSM.
Also has `BehavioralFsm`, which operates on external state.
API makes no separation between FSM definition and implementation.
* [state.js](https://github.com/steelbreeze/state.js/blob/master/README.md).
Very classical OOP API, verbose with explicit `new State` foo... Also implementations in C#.
* [st8](https://www.npmjs.com/package/st8). Active from, 40 releases.
* [javascript-state-machine](https://www.npmjs.com/package/javascript-state-machine).
Event-driven, function for each event - that outside can call to attempt a transition.
Calls before/enter and leave/after functions via on#phase#eventname naming convention.
before/leave can cancel transition by returning falsy, so effectively are the guard predicates.
Hibernating since 2015.
* [fsm-as-promised](https://github.com/vstirbu/fsm-as-promised).
Focused on asyncrounous functions and transitions, using Promises. Also has a dot/graphviz renderer.
* [TypeState](https://github.com/eonarheim/TypeState), strongly typed FSM using TypeScript.

Standards

* [UML state machine diagrams](http://www.uml-diagrams.org/state-machine-diagrams.html)
* [States language](https://states-language.net/spec.html), project by Amazon. Defines a JSON format. Sadly has no JSON schema?

Tutorials/blogposts

* [Pretty state machines in Rust](https://hoverbear.org/2016/10/12/rust-state-machine-pattern/).
Uses algebraic types to define states and transitions, allowing the compiler to verify that
attempted transitions are valid.
* [A Guide to Managing Finite State Machine Using Django FSM](https://hashedin.com/2017/05/30/manage-finite-state-machine-using-django/?utm_source=HN&utm_campaign=Blog_SM). The state of the FSM is stored in relational databasa via ORM. Many data instances can exist.
Transitions declared as Python decorators on methods. Additional modules for admin pages and FSM transaction logs.
* [Implementing State Machines in PostgreSQ](http://felixge.de/2017/07/27/implementing-state-machines-in-postgresql.html).
Uses SQL to enforce valid state transitions, and stores all transition events. Custom aggregate used to reduce events to current state.
Also shows how can get analytics easily from event log.

Papers

* [Computation and State Machines](http://research.microsoft.com/en-us/um/people/lamport/pubs/state-machine.pdf),
describes using state machines for arbitrary computations.

Other uses

* [Index 1,600,000,000 Keys with Automata and Rust](http://blog.burntsushi.net/transducers/)


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

# Contracts programming as FSM

A function with a body, 
On preconditions passing, body executes.
On preconditions failing, errors (with reason).
If body passes postconditions, success.

    start = input
    exit = success, preconditionsfailed, postconditionsfailed
    input{enter=readarguments} =[checkpreconditions]> execute{enter=body}
    input =[!checkpreconditions]> preconditionsfailed{enter=returnerror}

    execute =[postconditionspass]> success{enter=pushresults}
    execute =[!postconditionspass]> postconditionsfailed{enter=returnerror}

# FSM as general purpose language

If one could demonstrate how one would do the equivalent of typical imperative language structures,
that would be a good indicator of the computing model being generic enough for general-purpose use?

For/while loop, continue/break, If/else..

Could one construct a general-purpose language using FSM + expressions?
Would need some memory model, and some load/store capability also?
Can one avoid assignments entirely, or enforce single-assignment?

Implicit? stack/register model. If bare-metal will need to transfer things into CPU registers anyhow

If this is possible, could be fun to have macros/meta-language which generates FSM/expressions.
Can for instance re-create above constructs from imperative languages.


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

Graphviz renderers

* [viz.js online demo](https://mdaines.github.io/viz.js/). Compiled to JS with Emscripten.
* [StackOverflow: Render using graphlib-dot and dagre-d3](http://stackoverflow.com/questions/22595493/reading-dot-files-in-javascript-d3). Native JavaScript.


# Testing

Ideas

* Log/collect state transitions, verify that each state has been visisted (by manual or automated test)
* Apply external stimuli to cause state transition, verify that it did happen
* Drive a state transition directly from test, verify that state actions were as expected
* Run machine in virtual/emulated environment, verify that no side-effects occur outside machine state
* Mutate constants/parameters/transitions order programatically from test, run program X times, evaluate failure rates statistically.
* allow warn/error on non-deterministic (multiple valid) transitions
* allow specifying a set of input data examples as [state-transition-table](https://en.wikipedia.org/wiki/State_transition_table)
* ensure that certain invariants in state hold regardless of path taken to the state

Work by others

* [Using PropEr to test FSMs](http://proper.softlab.ntua.gr/Tutorials/PropEr_testing_of_finite_state_machines.html).
PropEr is property-based testing for Erlang.
* [ACCU: Testing State Machines](https://accu.org/index.php/journals/1548), argues for separating out Actions as an interface,
and handing the implementation to the State Machine. Then one can use an implemtantion which records the actions/effects
when testing the state machine, and test the implementation of the actions separately.
Especially where the actions effects are considerable, ie affecting hardware in embedded system, external data store or networked service.
* [Model Based Testing - FSM based testing](http://people.cs.aau.dk/~bnielsen/TOV07/lektioner/tov-fsm-test.pdf), covers different testing strategies, like Transition testing, Object testing, FSM test coverage.
* [BuDDy - A Binary Decision Diagram Package](http://vlsicad.eecs.umich.edu/BK/Slots/cache/www.itu.dk/research/buddy/),
which has been used to verify large FSMs. See Verification of Large State/Event systems Using Compositionality and Dependency Analysis.
* [FSM-Based Test Case Generation Methods Applied to Test the Communication Software on Board the ITASAT University Satellite](https://www.researchgate.net/publication/287561626_FSM-Based_Test_Case_Generation_Methods_Applied_to_test_the_Communication_Software_on_board_the_ITASAT_University_Satellite_a_Case_Study).
Using Model-based Testing with FSM as the underlying formalism. `JPlavisFSM`, a GUI tool for creating, analyzing and testing FSMs.
Can report structural properties such as `complete`, `strongly connected`, `deterministic`.
Lists a number of methods that verify a FSM model against FSM implementation:
`W` (Chow, 1978), `UIO` (Sabnani and Dahbura, 1988), `UIOv` (Vuong, 1989), `Wp` (Fujiwara, 1991), `HSI` (Petrenko, 1993) and `SPY` (Simão, 2009)
* [Testing Software Design Modelled by Finite State Machines (Chow, 1978)](https://code.oregonstate.edu/svn/jdmcs362w10/papers/chow.pdf). Foundational paper. Defines a testing strategy `W`. Splits possible errors in an FSM implementation into "Operation Errors", "Transfer Errors", "Extra States", "Missing States".  Also defines test coverages, "Branch Cover", "Switch Cover", "Boundary-Interior Cover", "H-Language".


Others on Finite State Machines
===============================


> You may not like the idea of auto-generated code today,
> but I guarantee that once you program for a state machine framework,
> you'll see the benefits of the overall structure
> and be ready to move up a level in programming efficiency."
Michael Barr, http://www.embedded.com/electronics-blogs/barr-code/4372183/Trends-in-embedded-software-design

! Finito allows programming with state machines *without* generating code.

> Actually, the main issue isn’t so much designing the state machine, but rather implementing it.
> Even in 2015, we don’t really have a good, widely-accepted set of tools for working with state machines in languages like C or Java."
http://www.embeddedrelated.com/showarticle/723.php

> Now that you are using state machines for modelling,
> the next thing you will want to do is keeping track of all the state transitions over time.
> When you are starting out, you may be only interested in the current state of an object, 
> ut at some point the transition history will be an invaluable source of information.
https://www.shopify.com/technology/3383012-why-developers-should-be-force-fed-state-machines


>
>  > The humble state machine is a more important part of programming
>  > than people like to admit
> Here is where I feel a lot of OOP applications are “doing statefullness wrong.”
> Everyone gloms onto the popular GoF patterns, but explicit state machines are not nearly popular enough.

https://news.ycombinator.com/item?id=11189200


> Using techniques like these, CloudPlane maintains 100% line coverage.
> Maintaining 100% line coverage allows efficient location of most untested code in new patches.

https://www.citusdata.com/blog/2016/08/12/state-machines-to-run-databases/

## Semirelated

* [Finite state machines as data structure for representing ordered sets and maps](http://blog.burntsushi.net/transducers/)

## Relations to constraint programming

* An FSM can be [reduced to a boolean SAT problem](http://sahandsaba.com/understanding-sat-by-implementing-a-simple-sat-solver-in-python.html)

## Testcases
Cases that might be interesting to try to express with Finito.

* [elevator-kata](https://github.com/Pragmatists/elevator-kata). The requirements might suggest a hierachical state machine.
* [GameOfLife](http://codingdojo.org/cgi-bin/index.pl?KataGameOfLife). Each cell can be seen as a state machine.

Existing examples

* [Around 20 state-machine examples for Umple modelling tool](https://github.com/umple/umple/wiki/examples#state-machine-examples)

