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

ifneq ($(CROSS_COMPILE),)
# TODO: check for both cc and gcc names?
_MACH := $(shell $(CROSS_COMPILE)$(CC) -dumpmachine)
ifeq ($(_MACH),i586-mingw32msvc)
TARGET_OS ?= Windows_NT
TARGET_OS_TYPE ?= win32
$(info TARGET_OS=$(TARGET_OS))
$(info TARGET_OS_TYPE=$(TARGET_OS_TYPE))
endif
endif

# set up target if not configured
TARGET_OS ?= $(HOST_OS)
TARGET_OS_TYPE ?= $(HOST_OS_TYPE)
