## build system
# Author: Jon Mayo <jon.mayo@gmail.com>
# Date: Dec 7 2010
# Set COPYING.txt for license

## sanity checks
ifeq ($(TOP),)
$(error TOP must be set - recommended in top Makefile)
endif

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
# Usage: $(call shared-lib-path,<list...>)
shared-lib-path = $(patsubst %,$(OUTDIR)libs/$(MODULE)/lib%.so,$1)

# Macro: target-pkg-config-cflags
# Returns: list of compiler flags for target
# Usage: $(call target-pkg-config-cflags,pkgname)
target-pkg-config-cflags = $(shell $(TARGET_PKGCONFIG) --cflags $1)

# Macro: target-pkg-config-libs
# Returns: list of linker flags for target
# Usage: $(call target-pkg-config-libs,pkgname)
target-pkg-config-libs = $(shell $(TARGET_PKGCONFIG) --libs $1)

# Macro: compile-c
# Returns: template for compiling C source
# Usage: $(eval $(call compile-c,onefile.c,<cflags>)
# Uses: LOCAL_PATH, STATIC_LIBRARIES, MODULE
# Side-effect: adds objects to _OBJS
define compile-c
S := $$(LOCAL_PATH)$1
O := $$(call obj-path,$(1:.c=.o))
$$O : $$S | $$(dir $$O)
	$(call log,Compile $$<)
	$Q$$(CC) $(strip $2 $(TARGET_CFLAGS) $(CFLAGS) $(CPPFLAGS)) \
	$$(foreach v,$(STATIC_LIBRARIES) $(SHARED_LIBRARIES),$$(_libcflags_$$v)) \
	-c -o $$@ $$<
_OBJS += $$O
CLEAN_FILES += $$O

endef

# Macro: build-objs
# Description: wraps up compile-c, compile-s, compile-cxx, ...
# Returns:
# Uses: SRCS and anything compile-X uses
# Usage: $(eval $(call build-objs,<cflags>))
# See Also: compile-c, compile-s, compile-cxx
define build-objs
$(if $(MODULE),,$(error MODULE is not set in $(prev-makefile)))
$(if $(filter %.o %.a %.so,$(SRCS)),$(error Binaries in the SRCS list for $(MODULE)!))
$(foreach s,$(filter %.c,$(SRCS)),$(call compile-c,$s,$1))
$(foreach s,$(filter %.s %.S,$(SRCS)),$(call compile-s,$s,$1))
$(foreach s,$(filter %.cc %.cxx %.cpp,$(SRCS)),$(call compile-cxx,$s,$1))
# a setup that is common to all actions(sharedlib, staticlib, and exec):
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

endef

# Macro: build-exec
# Returns: template for linking .o files into an executable
# Usage: $(eval $(call build-exec))
# Uses: _OBJS, LOCAL_PATH, STATIC_LIBRARIES, MODULE
# Side-effect: add directories to ALL_DIRS
# TODO: use different flags if any C++ sources were used
define build-exec
M := $$(call exec-path,$$(MODULE))
# Add PROVIDE_LDFLAGS for every STATIC_LIBRARIES and SHARED_LIBRARIES
# Add -Llibpath -l$(MODULE) for every SHARED_LIBRARIES
$$M : $$(_OBJS) $$(foreach v,$(STATIC_LIBRARIES) $(SHARED_LIBRARIES),$$$$(_libpath_$$v)) | $$(dir $$M)
	$(call log,Executable $$@)
	$Q$$(CC) $(strip $(TARGET_CFLAGS) $(LDFLAGS)) \
	$$(foreach v,$(STATIC_LIBRARIES) $(SHARED_LIBRARIES),$$(_libldflags_$$v)) \
	$$(foreach v,$(SHARED_LIBRARIES),-L$$(dir $$(_libpath_$$v)) -l$$v) \
	-o $$@ $$(filter %.o %.a,$$^) $(LDLIBS)
all : $$M
$$(MODULE) : $$M
ALL_DIRS := $$(sort $$(ALL_DIRS) $$(dir $$(_OBJS) $$M))
CLEAN_ALL_FILES += $$M
$$(eval $$(call clear-vars))

endef

# Macro: build-static-lib
# Returns: template for linking .o files into a static library
# Usage: $(eval $(call build-static-lib))
# Uses: _OBJS, LOCAL_PATH, STATIC_LIBRARIES, MODULE
# Side-effect: add directories to ALL_DIRS
# TODO: use different flags if any C++ sources were used
define build-static-lib
L := $$(call static-lib-path,$$(MODULE))
# make sure the library name is related to special archive pattern
$$L : $$L($$(_OBJS))
# invoke the pattern rule for (%) : %
.INTERMEDIATE : $$(_OBJS)
$$L($$(_OBJS)) : $$(_OBJS) | $$(dir $$L)
all : $$L
$$(MODULE) : $$L
_libldflags_$$(MODULE) := $$(PROVIDE_LDFLAGS)
_libcflags_$$(MODULE) := $$(PROVIDE_CFLAGS)
_libpath_$$(MODULE) := $$L
ALL_DIRS := $$(sort $$(ALL_DIRS) $$(dir $$(_OBJS) $$L))
CLEAN_ALL_FILES += $$L
$$(eval $$(call clear-vars))

endef

# Macro: build-shared-lib
# Returns: template for linking .o files into a shared library
# Usage: $(eval $(call build-shared-lib))
# Uses: _OBJS, LOCAL_PATH, STATIC_LIBRARIES, MODULE
# Side-effect: add directories to ALL_DIRS
# TODO: use different flags if any C++ sources were used
define build-shared-lib
L := $$(call shared-lib-path,$$(MODULE))
$$L : $$(_OBJS) | $$(dir $$L)
	$(call log,Shared library $$@)
	$Q$$(CC) -shared $(strip $(TARGET_CFLAGS) $(LDFLAGS)) \
	$(foreach v,$(STATIC_LIBRARIES) $(SHARED_LIBRARIES),$$(_libldflags_$v)) \
	-o $$@ $$^ $(LDLIBS)
all : $$L
$$(MODULE) : $$L
_libldflags_$$(MODULE) := $$(PROVIDE_LDFLAGS)
_libcflags_$$(MODULE) := $$(PROVIDE_CFLAGS)
_libpath_$$(MODULE) := $$L
ALL_DIRS := $$(sort $$(ALL_DIRS) $$(dir $$(_OBJS) $$L))
CLEAN_ALL_FILES += $$L
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

OUTDIR ?= $(TOP)_out/

# directory holding this file
B := $(this-dir)

# quiet mode
Q := $(if $V,,@)

# detect OS
include $Bosdetect.mk

# optional configuration for this project - for configuring TARGET_OS
include $(wildcard $(CURDIR)/Config.mk)

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
ALL_DIRS := $(OUTDIR) $(OUTDIR)objs/ $(OUTDIR)exec/ $(OUTDIR)libs/
LOCAL_PATH :=#
$(eval $(call clear-vars))
include $(CURDIR)/Build.mk

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
