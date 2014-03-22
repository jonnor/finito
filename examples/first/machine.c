#include <stdbool.h>
#include <stdio.h>

// States
void on() {
    printf("\tOn\n");
}
void starting() {
    printf("\tStarting\n");
}
void off() {
    printf("\tOff\n");
}

// Transitions predicates
bool button_on() {
    return true;
}
bool boot_done() {
    return true;
}
bool button_off() {
    return true;
}


#include "finito.c"
#include "machine-gen.c"

void print_transition(FinitoMachine *fsm,
                      FinitoStateId old, FinitoStateId new_state) {

    const char * o = finito_machine_statename(fsm, old);
    const char * n = finito_machine_statename(fsm, new_state);
    printf("statechange %s %s\n", o, n);
}

int main(int argc, char *argv[]) {
    FinitoMachine m;
    finito_machine_init(&m, Machine_run, Machine_initial, Machine_statenames);
    m.change_cb = print_transition;

    finito_machine_run(&m);
    finito_machine_run(&m);
    finito_machine_run(&m);

    return 0;
}
