#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>

// State actions
void set_lights(bool red, bool yellow, bool green) {
    printf("[%s]\n[%s]\n[%s]\n",
            red ? "*" : "",
            yellow ? "*" : "",
            green ? "*" : ""
    );
}

// Transitions predicates
bool seconds_passed(int seconds) {
    // FIXME: don't busy sleep
    sleep(seconds);
    return true;
}

#include "finito.c"
#include "machine-gen.c"

int main(int argc, char *argv[]) {
    FinitoMachine m;
    finito_machine_init(&m, &TrafficLight_def);
    m.on_state_change = finito_debug_print_transition;

    for (int i=0; i<5; i++) {
        finito_machine_run(&m);
    }

    return 0;
}
