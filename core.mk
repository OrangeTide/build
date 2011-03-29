## build system
# Author: Jon Mayo <jon.mayo@gmail.com>
# Date: Dec 7 2010
# Set COPYING.txt for license

## sanity checks
ifeq ($(TOP),)
$(error TOP must be set - recommended in top Makefile)
endif

## Cancel built-in rules

% : %.o
% : %.c
% : %.cc
% : %.C
% : %.F
% : %.f
% : %.p
% : %.s
%.o : %.c
%.o : %.cc
%.o : %.C
%.o : %.F
%.o : %.f
%.o : %.p
%.o : %.s
%.o : %.S
%.c : %.y
%.c : %.l
%.r : %.l

## Macros

# Macro: log
# Returns: echo shell command string if Q is unset, else empty string
# Usage: $(call log,your message)
log = $(if $Q,@echo $1,)

# Macro: this-dir
# Returns: directory of current makefile
# Usage: $(this-dir)
this-dir = $(dir $(lastword $(MAKEFILE_LIST)))

# Macro: prev-makefile
# Returns: filename of previously included makefile
# Usage: $(prev-makefile)
# Description: to be used in included makefiles
prev-makefile = $(lastword $(filter-out $(lastword $(MAKEFILE_LIST)),$(MAKEFILE_LIST)))

# Macro: map
# Returns: function applied to each element of list
# Usage: $(call map,<function>,<list...>)
map = $(foreach a,$2,$(call $1,$a))

# Macro: reverse
# Returns: word list in reverse order
# Usage: $(call reverse,$(foo))
reverse = $(if $1,$(call reverse,$(wordlist 2,$(words $1),$1)) $(firstword $1))

# Macro: exec-path
# Returns: prefix applied to each element of list
# Usage: $(call exec-path,<list...>)
exec-path = $(addprefix $(OUTDIR)exec/$(MODULE)/,$1)

# Macro: obj-path
# Returns: prefix applied to each element of list for object files
# Usage: $(call exec-path,<list...>)
obj-path = $(addprefix $(OUTDIR)objs/$(MODULE)/,$1)

# Macro: static-lib-path
# Returns: prefix applied to each element of list for static libs
# Usage: $(call static-lib-path,<list...>)
static-lib-path = $(patsubst %,$(OUTDIR)libs/$(MODULE)/lib%.a,$1)

# Macro: shared-lib-path
# Returns: prefix applied to each element of list for static libs
# Usage: $(call shared-lib-path,<module names...>)
shared-lib-path = $(patsubst %,$(OUTDIR)libs/$(MODULE)/lib%.so,$1)

# Macro: dep-path
# Returns: source file names translated to dependency paths
# Usage: $(call exec-path,<files...>)
dep-path = $(patsubst %,$(OUTDIR)deps/$(MODULE)/%.d,$1)

# Macro: target-pkg-config-cflags
# Returns: list of compiler flags for target
# Usage: $(call target-pkg-config-cflags,pkgname)
target-pkg-config-cflags = $(shell $(TARGET_PKGCONFIG) --cflags $1)

# Macro: target-pkg-config-libs
# Returns: list of linker flags for target
# Usage: $(call target-pkg-config-libs,pkgname)
target-pkg-config-libs = $(shell $(TARGET_PKGCONFIG) --libs $1)

# Macro: use-cxx
# Returns: first option if C++ compiler need, second option otherwise
# Description: detect if C++ sources are used
# Usage: $(call use-cxx,$(SRCS),<true-expr>,<false-expr>)
use-cxx = $(if $(filter $(CXX_PATTERNS),$1),$2,$3)

# Macro : libversion
# Returns: linker arguments to pass CC to set library version
# Usage: $(call libversion,<lib-file-name>,<version>)
libversion = -Wl,-soname,$1.$2

# Macro: compile-xxx
# Returns: template for compiling something
# Usage: $(eval $(call compile-xxx,<source-file>,<obj-file>,<dep-path>,<cmd>,<log-msg>)
# Uses: LOCAL_PATH, STATIC_LIBRARIES, MODULE
# Side-effect: adds objects to _OBJS
define compile-xxx
# compile rule
$2 : $1 | $$(dir $2)
	$$(call log,$5)
	$Q$4 -o $$@ $$<
_OBJS += $2
CLEAN_FILES += $2
# dependency generation
ALL_DEPENDENCIES += $3
CLEAN_ALL_FILES += $3
ifeq ($(filter $(MAKECMDGOALS),help clean clean-all),)
$3 : $1 | $$(dir $3)
	$(call log,Dependency $$(notdir $$<))
	$Q$4 -MM -MG -MF $$@ -MT $2 $$<
include $3
endif
endef

# Macro: compile-c
# Returns: template for compiling C source
# Usage: $(eval $(call compile-c,onefile.c,<cflags>)
# Uses: LOCAL_PATH, STATIC_LIBRARIES, MODULE
# Side-effect: adds objects to _OBJS
define compile-c
$(call compile-xxx,$$(LOCAL_PATH)$1,$$(call obj-path,$(1:.c=.o)),$$(call dep-path,$1),$$(CROSS_COMPILE)$(CC) $2 $(TARGET_CFLAGS) $(CFLAGS) $(CPPFLAGS) $$(foreach v,$(STATIC_LIBRARIES) $(SHARED_LIBRARIES),$$(_libcflags_$$v)) -c,Compile $$<)
endef

# Macro: compile-cxx
# Returns: template for compiling C++ source
# Usage: $(eval $(call compile-cxx,onefile.cxx,<cflags>)
# Uses: LOCAL_PATH, STATIC_LIBRARIES, MODULE
# Side-effect: adds objects to _OBJS
define compile-cxx
$(call compile-xxx,$$(LOCAL_PATH)$1,$$(call obj-path,$(foreach p,$(CXX_PATTERNS),$(patsubst $p,%.o,$(filter $p,$1)))),$$(call dep-path,$1),$$(CROSS_COMPILE)$(CXX) $2 $(TARGET_CFLAGS) $(TARGET_CXXFLAGS) $(CFLAGS) $(CXXFLAGS) $(CPPFLAGS) $$(foreach v,$(STATIC_LIBRARIES) $(SHARED_LIBRARIES),$$(_libcflags_$$v)) -c,Compile $$<)
endef

# Macro: build-objs
# Description: wraps up compile-c, compile-s, compile-cxx, ...
# Returns:
# Uses: SRCS and anything compile-X uses
# Usage: $(eval $(call build-objs,<cflags>))
# See Also: compile-c, compile-s, compile-cxx
define build-objs
$(if $(MODULE),,$(error MODULE is not set in $(prev-makefile)))
$(if $(filter $(MODULE),$(ALL_MODULES)),$(error duplicate MODULE name in $(prev-makefile)))
$(if $(filter %.o %.a %.so,$(SRCS)),$(error Binaries in the SRCS list for $(MODULE)!))
$(foreach s,$(filter %.c,$(SRCS)),$(call compile-c,$s,$1))
$(foreach s,$(filter %.s %.S,$(SRCS)),$(call compile-s,$s,$1))
$(foreach s,$(filter $(CXX_PATTERNS),$(SRCS)),$(call compile-cxx,$s,$1))
# force rebuild of objects if Build.mk changes
$$(_OBJS) : $$(CURR_BUILD_MK)
# DESCRIPTION field is common to all actions(sharedlib, staticlib, and exec):
ifneq ($(DESCRIPTION),)
_desc_$(MODULE) := $(DESCRIPTION)
endif
ALL_MODULES += $(MODULE)
endef

# Macro: clear-vars
# Returns: N/A
# Description: clears variables used in Build.mk
# Usage: $(eval $(call clear-vars))
define clear-vars
MODULE :=#
DESCRIPTION :=#
CFLAGS :=#
CPPFLAGS :=#
LDFLAGS :=#
LDLIBS :=#
SRCS :=#
_OBJS :=#
STATIC_LIBRARIES :=#
SHARED_LIBRARIES :=#
OUTPUT_NAME :=#
LIBVERSION :=#

endef

# Macro: build-exec
# Returns: template for linking .o files into an executable
# Usage: $(eval $(call build-exec))
# Uses: _OBJS, LOCAL_PATH, STATIC_LIBRARIES, MODULE
# Side-effect: add directories to ALL_DIRS
# TODO: use different flags if any C++ sources were used
define build-exec
M := $$(call exec-path,$$(if $$(OUTPUT_NAME),$$(OUTPUT_NAME),$$(MODULE)))
# Add PROVIDE_LDFLAGS for every STATIC_LIBRARIES and SHARED_LIBRARIES
# Add -Llibpath -llibname for every SHARED_LIBRARIES
$$M : $$(_OBJS) $$(foreach v,$(STATIC_LIBRARIES) $(SHARED_LIBRARIES),$$$$(_libpath_$$v)) | $$(dir $$M)
	$(call log,Executable $$@)
	$Q$(call use-cxx,$(SRCS),$(CROSS_COMPILE)$(CXX),$(CROSS_COMPILE)$(CC)) $(strip $(TARGET_CFLAGS) $(LDFLAGS)) \
	$$(foreach v,$(STATIC_LIBRARIES) $(SHARED_LIBRARIES),$$(_libldflags_$$v)) \
	$$(foreach v,$(SHARED_LIBRARIES),-L$$(dir $$(_libpath_$$v)) -l$$(patsubst lib%.so,%,$$(notdir $$(_libpath_$$v)))) \
	-o $$@ $$(filter %.o %.a,$$^) $(LDLIBS)
all : $$M
$$(MODULE) : $$M
ALL_DIRS := $$(sort $$(ALL_DIRS) $$(dir $$(_OBJS) $$M))
CLEAN_ALL_FILES += $$M
$$(eval $$(call clear-vars))

endef

# Macro: build-static-lib
# Returns: template for linking .o files into a static library
# Usage: $(eval $(call build-static-lib,<lib-path>))
# Uses: _OBJS, LOCAL_PATH, STATIC_LIBRARIES, MODULE
# Side-effect: add directories to ALL_DIRS
# TODO: use different flags if any C++ sources were used
define build-static-lib
# make sure the library name is related to special archive pattern
$1 : $1($$(_OBJS))
# invoke the pattern rule for (%) : %
.INTERMEDIATE : $$(_OBJS)
$1($$(_OBJS)) : $$(_OBJS) | $$(dir $1)
all : $1
$$(MODULE) : $1
_libldflags_$$(MODULE) := $$(PROVIDE_LDFLAGS)
_libcflags_$$(MODULE) := $$(PROVIDE_CFLAGS)
_libpath_$$(MODULE) := $1
ALL_DIRS := $$(sort $$(ALL_DIRS) $$(dir $$(_OBJS) $1))
CLEAN_ALL_FILES += $1
$$(eval $$(call clear-vars))

endef

# Macro: build-shared-lib
# Returns: template for linking .o files into a shared library
# Usage: $(eval $(call build-shared-lib,<lib-path>))
# Uses: _OBJS, LOCAL_PATH, STATIC_LIBRARIES, MODULE, LIBVERSION
# Side-effect: add directories to ALL_DIRS
# TODO: use different flags if any C++ sources were used
define build-shared-lib
$1 : $$(_OBJS) | $$(dir $1)
	$(call log,Shared library $$@)
	$Q$$(CC) -shared $(strip $(TARGET_CFLAGS) $(LDFLAGS)) \
	$(foreach v,$(STATIC_LIBRARIES) $(SHARED_LIBRARIES),$$(_libldflags_$v)) \
	$(if $(LIBVERSION),$(call libversion,$(call shared-lib-path,$(if $(OUTPUT_NAME),$(OUTPUT_NAME),$(MODULE))),$(LIBVERSION))) -o $$@ $$^ $(LDLIBS)
all : $1
$$(MODULE) : $1
_libldflags_$$(MODULE) := $$(PROVIDE_LDFLAGS)
_libcflags_$$(MODULE) := $$(PROVIDE_CFLAGS)
_libpath_$$(MODULE) := $1
ALL_DIRS := $$(sort $$(ALL_DIRS) $$(dir $$(_OBJS) $1))
CLEAN_ALL_FILES += $1
$$(eval $$(call clear-vars))

endef

# Macro: print-module
# Description: prints a module
define print-module
@echo $1 - $(if $(_desc_$1),$(_desc_$1),Set DESCRIPTION to configure)

endef

## Generic rules

#Pattern for static libraries
(%) : %
	$(call log,Static library $@)
	$Qcd $(<D) ; $(AR) $(ARFLAGS) $(CURDIR)/$@ $(<F)

## Setup
.SECONDEXPANSION:

CLEAN_ALL_FILES :=#
CLEAN_FILES :=#
ALL_MODULES :=#
ALL_DEPENDENCIES :=#

OUTDIR ?= $(TOP)_out/

CXX_PATTERNS := %.cc %.cxx %.cpp

# directory holding this file
B := $(this-dir)

# quiet mode
Q := $(if $V,,@)

# detect OS
include $Bosdetect.mk

# optional configuration for this project - for configuring TARGET_OS
include $(wildcard $(TOP)Config.mk)

# set up target if not configured
TARGET_OS ?= $(HOST_OS)
TARGET_OS_TYPE ?= $(HOST_OS_TYPE)

TARGET_CFLAGS ?= -Wall -W -g
# TARGET_LDFALGS ?= -mwindows
TARGET_PKGCONFIG ?= $(CROSS_COMPILE)pkg-config

## Package macros - affected by TARGET_OS and TARGET_OS_TYPE
include $Bpackages.mk

# select default goal
.DEFAULT_GOAL := all
.PHONY : all clean clean-all help

## configure paths to build actions
BUILD_STATIC_LIBRARY := $Bstaticlib.mk
BUILD_SHARED_LIBRARY := $Bsharedlib.mk
BUILD_EXECUTABLE := $Bexec.mk
# BUILD_PLUGIN := $Bplugin.mk

## begin including Build.mk files
ALL_DIRS := $(OUTDIR) $(OUTDIR)objs/ $(OUTDIR)exec/ $(OUTDIR)libs/ $(OUTDIR)deps/
LOCAL_PATH :=#
$(eval $(call clear-vars))
include $(TOP)Build.mk

## Help text
help :
	@echo Actions:
	@echo all - build everything
	@echo clean - clean intermediate files
	@echo clean-all	- clean all output files
	@echo help - this help text
	@echo
	@echo Modules:
	$(foreach m,$(ALL_MODULES),$(call print-module,$m))

# add all dependency directories
ALL_DIRS := $(sort $(ALL_DIRS) $(dir $(ALL_DEPENDENCIES)))

## Make all necessary directories
$(ALL_DIRS) :
	$(call log,MkDir $@)
	$Qmkdir -p $@

## Clean rules
CLEAN_FILES := $(wildcard $(CLEAN_FILES))
CLEAN_ALL_FILES := $(wildcard $(CLEAN_ALL_FILES))
ALL_DIRS := $(wildcard $(call reverse,$(ALL_DIRS)))
clean :
	$(call log,Cleaning some files ... $(CLEAN_FILES))
	$Q$(if $(CLEAN_FILES),rm $(CLEAN_FILES))
clean-all : clean
	$(call log,Cleaning most files ... $(CLEAN_ALL_FILES))
	$Q$(if $(CLEAN_ALL_FILES),rm $(CLEAN_ALL_FILES))
	$(call log,Cleaning directories ... $(ALL_DIRS))
	$Q$(if $(ALL_DIRS),rmdir $(ALL_DIRS))
