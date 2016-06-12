EXAMPLE=examples/trafficlights/machine
TYPE=fsm

run:
	node bin/finito generate -o ${EXAMPLE}-gen.c ${EXAMPLE}.${TYPE}
	cat ${EXAMPLE}-gen.c
	g++ -o ${EXAMPLE} -Wall -Werror -g -I./targets/c -Iexamples/trafficlights examples/trafficlights/src/machine.cpp
	cd examples/trafficlights && ino build --cppflags="-I../../lib/c/ -I." -v -m nano328; cd -
	./${EXAMPLE}

all: run
