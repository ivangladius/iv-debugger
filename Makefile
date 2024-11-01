##
# Hack the planet
#
# @file
# @version 0.1
#
.PHONY: all shared-libs clean

all: shared-libs

shared-libs:
	$(MAKE) -C shared-libs

clean:
	rm sharedlibs/libwait.so

# end
