Overview
========

Features and Misfeatures
------------------------
* error messages report which module file(Build.mk) has the bug!
* supported executables, static libraries and shared libraries
* recursive make, it always knows what to build in what order.
* 'make help' shows all modules and a short description
* make <modulename> builds just that bit and its dependencies (shared and static libraries)
* cannot call external autoconf scripts or Makefiles, must write a Build.mk from scratch to add 3rd party stuff.
* output binaries are separate from source code - theoretically multiple passes with different TARGET_OS or OUTDIR settings possible
* 'make all' builds everything
* 'make clean-all' removes each file individually, then removes each directory individually leaving a perfectly clean tree
* use of OUTDIR allows output to be outside of the tree, anywhere on your filesystem
* every module must be given a unique name so you can type 'make foo' and get a foo. if there are duplicates an error will be reported.
* build system can be located anywhere, a git-submodule, a symlink, or hardcoded global directory
* dependency generate from source files
* C++ support - automatically use $(CXX) to link if a project has any .cpp files
* MODULE and output file name can be independent, but default is MODULE as name.
* using a different MODULE name for shared and static, but same OUTPUT_NAME is possible.
* changing a Build.mk force rebuilds which propagate through the system

Bugs & Missing Features
-----------------------
* no install rule - ideally each module would populate a private root filesystem so packaging becomes easy
* cross compile support is incomplete
* no provisions for building host-based tools like parser generators.
* no real MacOSX support (can't build .app bundles)
* TBD: ccache and distcc
* going to _out/exec/yourthing to run something is annoying
* making both a shared and static library version of something is tedious.
* no per component namespace for temporary variables defined.
* many sections of macros are repetively defined because of Make limitations.
* changing global configuration or command-line options won't force rebuild

Usage
=====

Config.mk
---------
Optional file at the top of a project, it is included after HOST_OS is set but
before defaults for TARGET_OS are set or package macros are loaded.

TARGET_PKGCONFIG
	command that performs the functionality of the 'pkg-config' utility

CROSS_COMPILE
	prefix on target build utilities

OUTDIR
	output directory for binaries. default is $(TOP)_out/

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
	must set once per file at the top

MODULE
	must set for each target

OUTPUT_NAME
	optionally use a different output name, uses MODULE if not set

LIBVERSION - shared libraries only
	apply a version identifier to the library such as -soname

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

