ifneq ($(OS),)
# the windows way
HOST_OS := $(strip $(OS))
else
# the unix way
HOST_OS := $(shell uname -s)
HOST_OS_TYPE := x11
endif

# cygwin uname
ifneq ($(findstring $(HOST_OS),CYGWIN),)
HOST_OS := Windows_NT
HOST_OS_TYPE := win32
endif

# check Darwin verus Mac OS X
ifeq ($(HOST_OS),Darwin)
ifeq ($(shell sw_vers -productName),Mac OS X)
HOST_OS_TYPE := cocoa
endif
endif

# HOST_OS values:
#  Windows_NT
#  Linux
#  Darwin
# HOST_OS_TYPE values:
#  win32
#  cocoa
#  x11
