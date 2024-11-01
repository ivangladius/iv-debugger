##
# Project Title
#
# @file
# @version 0.1
#
CC = gcc
CFLAGS = -Wextra -Wall -pedantic
SHARED_FLAGS = -fPIC -shared

all: libwait.so

libwait.so:
	$(CC) $(SHARED_FLAGS) -o libwait.so wait.c $(CFLAGS)


# end
