
// FIXME: change API prefix to finito_machine

struct _FsmStateMachine;

typedef int FsmStateId;
typedef FsmStateId (*FsmRunFunction) (FsmStateId current_state);
typedef void (*FsmStateChangeFunction) (struct _FsmStateMachine *fsm,
                                        FsmStateId old, FsmStateId newState);

typedef struct _FsmStateMachine {
    FsmStateId state;
    FsmStateChangeFunction change_cb;
    FsmRunFunction run;
} FsmStateMachine;

static void
change_state(FsmStateMachine *self, FsmStateId new_state) {
    if (self->change_cb) {
        self->change_cb(self, self->state, new_state);
    }
    self->state = new_state;
}

// TODO: take full definition
void
fsm_state_machine_init(FsmStateMachine *self, FsmRunFunction run, FsmStateId initial) {
    self->change_cb = 0;
    self->run = run;
    self->state = initial;
}


void
fsm_state_machine_run(FsmStateMachine *self) {
    const FsmStateId new_state = self->run(self->state);
    if (new_state != self->state) {
        change_state(self, new_state);
    }
}


