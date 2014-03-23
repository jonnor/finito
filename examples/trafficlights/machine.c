#include <stdbool.h>
#include <stdio.h>

#include "finito.c"

static long g_current_time = 0;
long current_time() {
    return g_current_time;
}

// State actions
void set_lights(bool red, bool yellow, bool green) {
    printf("[%s]\n[%s]\n[%s]\n",
            red ? "*" : "",
            yellow ? "*" : "",
            green ? "*" : ""
    );
}
void reset_time(long *time) {
    *time = current_time();
}

// Transitions predicates
bool seconds_passed(long seconds, long since) {
    return (current_time() >= since+seconds);
}

// State
typedef struct _TrafficLight {
    long time;
} TrafficLight;

#include "machine-gen.c"

int main(int argc, char *argv[]) {
    TrafficLight s;
    FinitoMachine m;
    finito_machine_init(&m, &TrafficLight_def, &s);
    m.on_state_change = finito_debug_print_transition;

    for (int i=0; i<30; i++) {
        g_current_time+=1; // Fast-forward time
        finito_machine_run(&m);
    }

    return 0;
}
