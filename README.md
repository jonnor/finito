Finito State Machines
====================
An experiment in [Finite State Machines](http://en.wikipedia.org/wiki/Finite-state_machine)
(FSM) and [automata-based programming](http://en.wikipedia.org/wiki/Automata-based_programming).

Finito allows you to declare state machines for widely different devices and programming
languages, that are testable, introspectable at runtime, and visually programmable.

Currently supported targets are C/++ for microcontrollers etc. and [CoffeeScript](http://coffeescript.org/)
/JavaScript for browser and [Node.js](http://nodejs.org).
Finito aims to complement and integrate with the
[Flow-based Programming](http://en.wikipedia.org/wiki/Flow-based_programming)
(FBP) runtimes [MicroFlo](http://microflo.org) and [NoFlo](http://noflojs.org).


Status
-------
Experimental

Milestones
-----------
* 0.1.0: One can create components for MicroFlo using Finito
* x.0.0: One can visually create, introspect and debug state machines,
using standalone tool or in combination with Flowhub.io

License
--------
MIT

TODO
-----
* Handle more general cases in the the .fsm DSL
* Add interactive visualization that can show and follow current state of machine,
also when machine is "remote", like running on a microcontroller
* Allow state transitions to be triggered from outside for testing
* Allow state transitions in microcontroller to be persisted in ROM, read back out and replayed
* Support C++ methods as state actions and predicates
* Support JS methods as state actions and predicates
* Demonstrate integration of machines spanning microcontroller and web
* Add a UI for creating state machines visually
* Add support for hierarchical machines
* Add support for FPGAs targets using VHDL/Verilog
