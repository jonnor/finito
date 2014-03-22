#!/bin/bash -xe

EXAMPLE="examples/first/machine"
node bin/finito generate -o ${EXAMPLE}-gen.c ${EXAMPLE}.json
cat ${EXAMPLE}-gen.c
gcc -o ${EXAMPLE} -Wall -Werror -std=c99 -g -I./lib/c ${EXAMPLE}.c
./${EXAMPLE}
