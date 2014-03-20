#include <stdbool.h>

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
