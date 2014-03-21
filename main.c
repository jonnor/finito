
#include "stdio.h"

#include "fsm.c"
#include "examples/first/states.c"
#include "mymachine-gen.c"



// FIXME: look up full human readable info
void print_transition(FsmStateMachine *fsm,
                      FsmStateId old, FsmStateId new_state) {

    const char * o = fsm_state_machine_statename(fsm, old);
    const char * n = fsm_state_machine_statename(fsm, new_state);
    printf("statechange %s %s\n", o, n);
}

int main(int argc, char *argv[]) {
    FsmStateMachine m;
    fsm_state_machine_init(&m, MyMachine_run, MyMachine_initial, MyMachine_statenames);
    m.change_cb = print_transition;

    fsm_state_machine_run(&m);
    fsm_state_machine_run(&m);
    fsm_state_machine_run(&m);

    return 0;
}
