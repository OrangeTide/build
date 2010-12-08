LOCAL_PATH := $(call this-dir)
MODULE := c
DESCRIPTION := executable using a shared library
SRCS += c.c
SHARED_LIBRARIES += e
include $(BUILD_EXECUTABLE)
