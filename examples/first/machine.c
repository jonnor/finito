#include <stdbool.h>
#include <stdio.h>

typedef struct {

} Machine;

// States
void on(Machine *s) {
    printf("\tOn\n");
}
void starting(Machine *s) {
    printf("\tStarting\n");
}
void off(Machine *s) {
    printf("\tOff\n");
}

// Transitions predicates
bool button_on(const Machine *s) {
    return true;
}
bool boot_done(const Machine *s) {
    return true;
}
bool button_off(const Machine *s) {
    return true;
}

#include "finito.c"
#include "machine-gen.c"

void print_transition(FinitoMachine *fsm,
                      FinitoStateId old, FinitoStateId new_state) {

    const char * o = finito_definition_statename(fsm->def, old);
    const char * n = finito_definition_statename(fsm->def, new_state);
    printf("statechange %s %s\n", o, n);
}

int main(int argc, char *argv[]) {
    FinitoMachine m;
    finito_machine_init(&m, &Machine_def, 0);
    m.on_state_change = print_transition;

    finito_machine_run(&m);
    finito_machine_run(&m);
    finito_machine_run(&m);

    return 0;
}
