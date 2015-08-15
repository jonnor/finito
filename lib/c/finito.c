/* Finito - Finite State Machines 
 * Copyright (c) 2014 Jon Nordby <jononor@gmail.com>
 * Finito may be freely distributed under the MIT license
 */

// Common
typedef int FinitoStateId;
struct _FinitoDefinition;
struct _FinitoMachine;

// Definition
typedef FinitoStateId (*FinitoRunFunction)
    (FinitoStateId current_state, void *context);
typedef struct _FinitoDefinition {
    FinitoStateId initial_state;
    FinitoStateId exit_state;
    FinitoRunFunction run_function;
    const char **statenames;
} FinitoDefinition;

const char *
finito_definition_statename(FinitoDefinition *self, FinitoStateId id) {
    return self->statenames[id];
}

// Machine
typedef void (*FinitoStateChangeFunction)
    (struct _FinitoMachine *Finito, FinitoStateId old, FinitoStateId newState);

typedef struct _FinitoMachine {
    FinitoDefinition *def;
    void *context;
    FinitoStateId state;
    FinitoStateChangeFunction on_state_change;
} FinitoMachine;

static void
change_state(FinitoMachine *self, FinitoStateId new_state) {
    if (self->on_state_change) {
        self->on_state_change(self, self->state, new_state);
    }
    self->state = new_state;
}

void
finito_machine_init(FinitoMachine *self, FinitoDefinition *def, void *context) {
    self->def = def;
    self->context = context;
    self->on_state_change = 0;
    self->state = self->def->initial_state;
}

void
finito_machine_run(FinitoMachine *self) {
    const FinitoStateId new_state = self->def->run_function(self->state, self->context);
    if (new_state != self->state) {
        change_state(self, new_state);
    }
}

// XXX: use a proper bool type, or at least abstraction
int
finito_machine_running(FinitoMachine *self) {
    return (self->state > -1 && self->state != self->def->exit_state) ? 1 : 0;
}


// Debugging
void
finito_debug_print_transition(FinitoMachine *fsm,
                              FinitoStateId old,
                              FinitoStateId new_state) {
#ifdef ARDUINO
    Serial.print(old);
    Serial.print(" to ");
    Serial.println(new_state);
#else
    printf("state changed: %s -> %s\n",
        finito_definition_statename(fsm->def, old),
        finito_definition_statename(fsm->def, new_state)
    );
#endif
}

