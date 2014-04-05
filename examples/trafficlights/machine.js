var g_current_time = 0; // seconds
var current_time = function() {
    return g_current_time;
}

var func = {};
func.set_lights = function(state, red, yellow, green) {
    state.trafficlight.getElementById("redlight").setAttributeNS(null, 'opacity', red ? '0' : '1');
    state.trafficlight.getElementById("yellowlight").setAttributeNS(null, 'opacity', yellow ? '0' : '1');
    state.trafficlight.getElementById("greenlight").setAttributeNS(null, 'opacity', green ? '0' : '1');
}
func.reset_time = function(state) {
    state.time = current_time();
}
func.seconds_passed = function(state, seconds) {
    var passed = current_time() >= state.time+seconds;
    return passed;
}

var main = function() {
    var finito = require('finito');

    var state = {
        time: undefined,
        trafficlight: document.getElementById("lights").contentDocument
    }
    finito.Definition.fromHttp("machine.json", function(err, def) {
        if (err)
            throw err
        machine = new finito.Machine(def, func, state);

        var ticksPerSecond = 10;
        // TODO: allow adjusting with a slider
        var timeFactor = 1;
        setInterval(function() {
            var increment = (1.0/ticksPerSecond)*timeFactor;
            g_current_time += increment;
            machine.run();
        }, 1000/ticksPerSecond);
    });
}

window.onload = function() {
    main();
}

