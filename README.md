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

    TODO: document defining a machine using programmatic API
    TODO: document how to implement+run in Javascript/browser
    TODO: document how to implement+run in C/microcontroller

License
--------
MIT

## TODO

### v0.1 "minimally useful"

Data model

* Allow multiple exit/final states
* Find alternate way of doing 'parametrized' functions

DSL/API

* Add tests for fluent JS API
* Remove .fsm DSL in favor of embedded JS API

Targets

* C: Add some tests
* JS: Support methods as state actions and predicates?

Tools

* Allow dot renderer to output svg/png directly?
* Demonstrate integration of machines spanning microcontroller and web


### Later

* Add interactive visualization that can show and follow current state of machine,
also when machine is "remote", like running on a microcontroller
* Allow state transitions in microcontroller to be persisted in ROM, read back out and replayed
* Add support for hierarchical machines
* Add a UI for creating state machines visually
* targets: Add support for FPGAs using VHDL/Verilog
* Add a C++ target, with support methods as state actions and predicates
