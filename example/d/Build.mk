LOCAL_PATH := $(call this-dir)
MODULE := d
OUTPUT_NAME := zyx
DESCRIPTION := example static library with alternate name
SRCS := d.c
PROVIDE_CFLAGS := -I$(LOCAL_PATH)
include $(BUILD_STATIC_LIBRARY)
