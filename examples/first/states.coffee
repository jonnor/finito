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
