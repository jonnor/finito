#include <stdbool.h>
#include <stdio.h>
#include <unistd.h>

// States
void green() {
    printf("\t%s\n", __PRETTY_FUNCTION__);
}
void yellow() {
    printf("\tyellow\n");
}
void yellow_and_red() {
    printf("\tyellow+red\n");
}
void red() {
    printf("\t%s\n", __PRETTY_FUNCTION__);
}

// Transitions predicates
bool seconds_passed(int seconds) {
    sleep(seconds);
    return true;
}
bool go_red() {
    return true;
}
bool go_green() {
    return true;
}

#include "finito.c"
#include "machine-gen.c"

void print_transition(FinitoMachine *fsm,
                      FinitoStateId old, FinitoStateId new_state) {

    printf("statechange %s -> %s\n",
        finito_definition_statename(fsm->def, old),
        finito_definition_statename(fsm->def, new_state)
    );
}

int main(int argc, char *argv[]) {
    FinitoMachine m;
    finito_machine_init(&m, &TrafficLight_def);
    m.on_state_change = print_transition;

    for (int i=0; i<5; i++) {
        finito_machine_run(&m);
    }

    return 0;
}
