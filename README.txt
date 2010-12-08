Config.mk
---------
Optional file at the top of a project, it is included after HOST_OS is set but
before defaults for TARGET_OS are set or package macros are loaded.

TARGET_PKGCONFIG
	command that performs the functionality of the 'pkg-config' utility

CROSS_COMPILE
	prefix on target build utilities

Variables
---------

These can be checked in Build.mk files for conditional options:

HOST_OS or TARGET_OS
	Windows_NT
	Darwin
	Linux

HOST_OS_TYPE or TARGET_OS_TYPE
	win32
	cocoa
	x11

Build.mk Options
----------------

LOCAL_PATH
	must set once per file

MODULE
	must set for each target

SRCS
	list of source files for target

STATIC_LIBRARIES
	list of static libraries (other MODULE names)

SHARED_LIBRARIES
	list of static libraries (other MODULE names)

CPPFLAGS
	preprocessor flags

CFLAGS
	compile flags

LDFLAGS
	linker flags

LDLIBS
	linker flags

PROVIDE_CFLAGS - libraries only
	dependents of this library automatically get these flags added

PROVIDE_LDFLAGS - libraries only
	dependents of this library automatically get these flags added

CLEAN_ALL_FILES
	files to remove on 'clean-all'

CLEAN_FILES
	files to remove on 'clean'


Targets
-------
include $(BUILD_EXECUTABLE)
	create an executable

include $(BUILD_STATIC_LIBRARY)
	create a static library

include $(BUILD_SHARED_LIBRARY)
	create a shared library
