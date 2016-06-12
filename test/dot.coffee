
if typeof process isnt 'undefined' and process.execPath and process.execPath.indexOf('node') isnt -1
    finito = require '../lib/js/finito'
    chai = require 'chai'
    path = require 'path'
else
    finito = require '../build/finito'
    chai = window.chai

bluebird = require 'bluebird'
dot = require 'graphlib-dot'

runFinito = (args, options) ->
  child_process = require 'child_process'
  path = require 'path'
  execFile = bluebird.promisify child_process.execFile

  for k, v of options
    args.push "--{k}={v}"
  prog = path.join __dirname, '../bin/finito'

  processOptions = {}
  cmd = ([ prog ].concat args).join ' '
  #console.log cmd 
  return execFile(prog, args, processOptions)

exampleTests = (name) ->
  file = path.join __dirname, '../examples', name
  describe "#{name}", ->
  
    it 'should output valid graphviz', (done) ->
      runFinito(['dot', file], {})
      .then (a) ->
        graph = dot.read a
        chai.expect(graph._isDirected).to.equal true
        chai.expect(graph._nodeCount).to.be.above 1
        chai.expect(graph._edgeCount).to.be.above 1
        return done()
      .catch done

    it.skip 'should render correctly with dot', ->
      'dot -Tps filename.dot -o outfile.ps'

examples = [
  'nofloprocess/network.fsm'
  'nofloprocess/component.fsm'
  'nofloprocess/execution.fsm'
]
describe 'graphviz generation', ->
  describe 'examples', ->
    examples.forEach exampleTests




  

