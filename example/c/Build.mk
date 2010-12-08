LOCAL_PATH := $(call this-dir)
MODULE := c
SRCS += c.c
SHARED_LIBRARIES += e
include $(BUILD_EXECUTABLE)
