#!/bin/bash -xe

EXAMPLE="examples/trafficlights/machine"
node bin/finito generate -o ${EXAMPLE}-gen.c ${EXAMPLE}.json
cat ${EXAMPLE}-gen.c
g++ -o ${EXAMPLE} -Wall -Werror -g -I./lib/c -Iexamples/trafficlights examples/trafficlights/src/machine.cpp
./${EXAMPLE}
