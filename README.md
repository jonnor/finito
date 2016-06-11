Finito State Machines
====================
[![Build Status](https://travis-ci.org/jonnor/finito.svg?branch=master)](https://travis-ci.org/jonnor/finito)

An experiment in [Finite State Machines](http://en.wikipedia.org/wiki/Finite-state_machine)
(FSM) and [automata-based programming](http://en.wikipedia.org/wiki/Automata-based_programming).

Finito allows you to declare state machines for widely different devices and programming
languages, that are testable, introspectable at runtime, and visually programmable.

Currently supported targets are C (C++ compatible) for microcontrollers etc.
and JavaScript for browser/[Node.js](http://nodejs.org).

Finito aims to complement and integrate with the
[Flow-based Programming](http://en.wikipedia.org/wiki/Flow-based_programming)
(FBP) runtimes [MicroFlo](http://microflo.org) and [NoFlo](http://noflojs.org).


## Status
*Experimental*

* Initial API, JSON format and .fsm DSL exists
* Can execute some very simple machines in browser and microcontroller
* `finito dot definition.fsm/json` can generate Graphviz for visualization
* Not used in a application yet


## Installing

Finito is on [NPM](http://npmjs.com/)

    npm install finitosm

## Usage

For now see the [examples](./examples) and [tests](./test)

    TODO: document defining a machine using JSON, .fsm DSL, and programmatic API
    TODO: document how to implement+run in Javascript/browser
    TODO: document how to implement+run in C/microcontroller

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
* Add a schema for the canonical JSON format, enforce in Definition
* Add tests for .dot rendering, using graphlib-dot parsing
* Allow dot renderer to output svg/png directly, using d3
* Allow multiple exit/final states
* Add a fluent API for building a Defintion programatically (in JavaScript/CoffeeScript)
* Move target-specific code out to separate directories, both for JS and C
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
