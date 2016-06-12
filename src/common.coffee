# Finito - Finite State Machines 
# Copyright (c) 2014-2016 Jon Nordby <jononor@gmail.com>
# Finito may be freely distributed under the MIT license
##

exports.isBrowser = ->
    return not (typeof process isnt 'undefined' and process.execPath and process.execPath.indexOf('node') isnt -1)
