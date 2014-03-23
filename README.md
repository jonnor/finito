Finito State Machines
====================
An experiment in [Finite State Machines](http://en.wikipedia.org/wiki/Finite-state_machine)
(FSM) and [automata-based programming](http://en.wikipedia.org/wiki/Automata-based_programming).

Finito allows you to declare state machines for widely different devices and programming
languages, that are testable, introspectable at runtime, and visually programmable.

Currently supported targets are C for microcontrollers++ and [CoffeeScript](http://coffeescript.org/)
/JavaScript for browser and [Node.js](http://nodejs.org).
Finito aims to complement and integrate with the
[Flow-based Programming](http://en.wikipedia.org/wiki/Flow-based_programming)
(FBP) runtimes [MicroFlo](http://microflo.org) and [NoFlo](http://noflojs.org).


Status
-------
Experimental

Milestones
-----------
0.0.1: Statemachines for C/C++ can defined by .json, execute and be introspected
0.1.0: One can create components for MicroFlo using Finito

License
--------
MIT

TODO
-----
* Add interactive visualization that can show current state of machine
* Allow state transitions to be triggered from outside for testing
* Support C++ methods as state actions and predicates
* Demonstrate integration of machines spanning microcontroller and web
* Add support for hierarchical machines
* Add support for FPGAs targets using VHDL/Verilog
