#ifdef ARDUINO
#include <Arduino.h>
#else
#include <stdio.h>
#endif

#include "finito.c"

long g_current_time = 0;
const int redLed = 5, yellowLed = 4, greenLed = 3;

long current_time(void) {
#ifdef ARDUINO
    return millis()/1000;
#else
    return g_current_time;
#endif
}

// State
typedef struct _TrafficLight {
    long time;
} TrafficLight;

// State actions
void set_lights(TrafficLight *state, bool red, bool yellow, bool green) {
#ifdef ARDUINO
    digitalWrite(redLed, red);
    digitalWrite(yellowLed, yellow);
    digitalWrite(greenLed, green);
#else
    printf("[%s]\n[%s]\n[%s]\n\n",
            red ? "*" : "",
            yellow ? "*" : "",
            green ? "*" : ""
    );
#endif
}
void reset_time(TrafficLight *state) {
    state->time = current_time();
}

// Transitions predicates
bool seconds_passed(const TrafficLight *state, long seconds) {
    return (current_time() >= (state->time+seconds));
}

#include "machine-gen.c"

TrafficLight s;
FinitoMachine m;

void setup(void) {
    finito_machine_init(&m, &TrafficLight_def, &s);
#ifdef ARDUINO
    Serial.begin(9600);
    pinMode(redLed, OUTPUT);
    pinMode(yellowLed, OUTPUT);
    pinMode(greenLed, OUTPUT);
#endif
    m.on_state_change = finito_debug_print_transition;
}
void loop(void) {
    finito_machine_run(&m);
}

#ifndef ARDUINO
int main(int argc, char *argv[]) {
    setup();
    // Fast-forward time for 30 "seconds"
    for (int i=0; i<30; i++) {
        g_current_time+=1;
        loop();
    }
    return 0;
}
#endif
