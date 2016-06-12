
if typeof process isnt 'undefined' and process.execPath and process.execPath.indexOf('node') isnt -1
    finito = require '../'
    chai = require 'chai'
    path = require 'path'
else
    finito = require '../build/finito'
    chai = window.chai

bluebird = require 'bluebird'
dot = require 'graphlib-dot'

child_process = require 'child_process'
fs = require 'fs'
execFile = bluebird.promisify child_process.execFile
statFile = bluebird.promisify fs.stat

runFinito = (args, options) ->

  for k, v of options
    args.push "--{k}={v}"
  prog = path.join __dirname, '../bin/finito'

  processOptions = {}
  cmd = ([ prog ].concat args).join ' '
  #console.log cmd 
  return execFile(prog, args, processOptions)

renderDot = (dotgraph, type, outfile) ->
  prog = 'dot'
  outpath = outfile+".#{type}"
  args = ["-T#{type}", '-o', outpath]
  cmd = ([ prog ].concat args).join ' '
  console.log cmd
  return new Promise (fufill, reject) ->
    child = child_process.execFile prog, args, (err, stdout, stderr) ->
      return reject err if err
      return fufill outpath
    child.stdin.end dotgraph

exampleTests = (name) ->
  file = path.join __dirname, '../examples', name
  dotoutput = null

  describe "#{name}", ->

    it 'should output valid graphviz', (done) ->
      runFinito(['dot', file], {})
      .then (a) ->
        dotoutput = a
        graph = dot.read a
        chai.expect(graph._isDirected).to.equal true
        chai.expect(graph._nodeCount).to.be.above 1
        chai.expect(graph._edgeCount).to.be.above 1
        return done()
      .catch done
    it 'should contain all states'
    it 'should contain all edges'

    it 'should render correctly with dot', (done) ->
      renderDot(dotoutput, 'svg', file)
      .then (path) ->
        return statFile(path)
      .then (stat) ->
        chai.expect(stat.size).to.be.above 100
        return done()
      .catch done

examples = [
  'nofloprocess/network.fsm'
  'nofloprocess/component.fsm'
  'nofloprocess/execution.fsm'
]
describe 'graphviz generation', ->
  describe 'examples', ->
    examples.forEach exampleTests




  

