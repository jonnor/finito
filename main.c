
#include "stdio.h"

#include "fsm.c"
#include "examples/first/states.c"
#include "mymachine-gen.c"



// FIXME: look up full human readable info
void print_transition(FsmStateMachine *fsm,
                      FsmStateId old, FsmStateId new_state) {

    printf("statechange %d %d\n", old, new_state);
}

int main(int argc, char *argv[]) {
    FsmStateMachine m;
    fsm_state_machine_init(&m, MyMachine_run, MyMachine_initial);
    m.change_cb = print_transition;

    fsm_state_machine_run(&m);
    fsm_state_machine_run(&m);
    fsm_state_machine_run(&m);

    return 0;
}
