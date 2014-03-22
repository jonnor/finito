/* Finito - Finite State Machines 
 * Copyright (c) 2014 Jon Nordby <jononor@gmail.com>
 * Finito may be freely distributed under the MIT license
 */

struct _FinitoMachine;

typedef int FinitoStateId;
typedef FinitoStateId (*FinitoRunFunction) (FinitoStateId current_state);
typedef void (*FinitoStateChangeFunction) (struct _FinitoMachine *Finito,
                                        FinitoStateId old, FinitoStateId newState);

typedef struct _FinitoMachine {
    FinitoStateId state;
    FinitoStateChangeFunction change_cb; // TODO: rename to on_state_change
    FinitoRunFunction run;
    const char **statenames;
} FinitoMachine;

static void
change_state(FinitoMachine *self, FinitoStateId new_state) {
    if (self->change_cb) {
        self->change_cb(self, self->state, new_state);
    }
    self->state = new_state;
}

// TODO: take full definition
void
finito_machine_init(FinitoMachine *self,
                       FinitoRunFunction run, FinitoStateId initial, const char **statenames) {
    self->change_cb = 0;
    self->run = run;
    self->state = initial;
    self->statenames = statenames;
}

void
finito_machine_run(FinitoMachine *self) {
    const FinitoStateId new_state = self->run(self->state);
    if (new_state != self->state) {
        change_state(self, new_state);
    }
}

const char *
finito_machine_statename(FinitoMachine *self, FinitoStateId id) {
    return self->statenames[id];
}

