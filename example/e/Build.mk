LOCAL_PATH := $(call this-dir)
MODULE := e
DESCRIPTION := example shared library
SRCS := e.c
PROVIDE_CFLAGS := -I$(LOCAL_PATH)
LIBVERSION := 1.0
include $(BUILD_SHARED_LIBRARY)
