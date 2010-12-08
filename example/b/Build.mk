LOCAL_PATH := $(call this-dir)
MODULE := b
SRCS += b.c
STATIC_LIBRARIES += d
include $(BUILD_EXECUTABLE)
