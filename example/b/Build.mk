LOCAL_PATH := $(call this-dir)
MODULE := b
DESCRIPTION := executable using a static library
SRCS += b.c
STATIC_LIBRARIES += d
include $(BUILD_EXECUTABLE)
