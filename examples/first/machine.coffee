# States
exports.off = () ->
    console.log "  Off"

exports.starting = () ->
    console.log "  Starting"

exports.on = () ->
    console.log "  On"

# Transition predicates
exports.button_on = () ->
    return true

exports.button_off = () ->
    return true

exports.boot_done = () ->
    return true

finito = require '../../lib/js/finito'
fs = require 'fs'
path = require 'path'
main = () ->
    # Machine
    d = JSON.parse fs.readFileSync path.resolve __dirname, 'machine.json'
    m = new finito.Machine d, exports

    m.on 'statechange', (n, old) ->
        console.log 'statechange', n, old

    m.run()
    m.run()
    m.run()

main()
