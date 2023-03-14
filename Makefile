
SHELL	= /bin/bash -O extglob -c
CC	= g++
CXX	= g++
CFLAGS	= -Wall -Wextra -pedantic -pedantic-errors -g -O2 -DLINUX -DREDAX_BUILD_COMMIT='$(BUILD_COMMIT)' -std=c++17 -pthread $(shell pkg-config --cflags libmongocxx)
CPPFLAGS := $(CFLAGS)
LDFLAGS = -lCAENVME -lCAENDigitizer -lstdc++fs -llz4 -lblosc
#LDFLAGS_CC = ${LDFLAGS} -lexpect -ltcl8.6


SOURCES_SLAVE = main.cc conio.cc DAWDemoFunc.cc
OBJECTS_SLAVE = $(SOURCES_SLAVE:%.cc=%.o)
DEPS_SLAVE = $(OBJECTS_SLAVE:%.o=%.d)
EXEC_SLAVE = DAW_Demo

ifeq "$(IS_READER0)" "true"
	SOURCES_SLAVE += DDC10.cc
	CFLAGS += -DHASDDC10
	LDFLAGS += -lexpect -ltcl8.6
endif

all: $(EXEC_SLAVE)

$(EXEC_SLAVE) : $(OBJECTS_SLAVE)
	$(CC) $(OBJECTS_SLAVE) $(CFLAGS) $(LDFLAGS) -o $(EXEC_SLAVE)

%.d : %.cc
	@set -e; rm -f $@; \
	$(CC) -MM $(CFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

%.o : %.cc %.d
	$(CC) $(CFLAGS) -o $@ -c $<

.PHONY: clean

install:
	sudo ln -sf ./DAW_Demo /usr/bin/DAW_Demo
	$(shell if [ ! -e /etc/DAW_Demo ];then sudo  mkdir -p /etc/DAW_Demo; fi)
	sudo rm -rf /etc/DAW_Demo/DAW_Config.txt
	sudo cp ./DAW_Config.txt /etc/DAW_Demo/DAW_Config.txt


clean:
	rm -f *.o *.d
	rm -f $(EXEC_SLAVE)

include $(DEPS_SLAVE)

# The makefile is quite simple .. 

