LOCAL_PATH := $(call this-dir)
MODULE := e
SRCS := e.c
PROVIDE_CFLAGS := -I$(LOCAL_PATH)
include $(BUILD_SHARED_LIBRARY)
