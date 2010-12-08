LOCAL_PATH := $(call this-dir)
MODULE := d
DESCRIPTION := example static library
SRCS := d.c
PROVIDE_CFLAGS := -I$(LOCAL_PATH)
include $(BUILD_STATIC_LIBRARY)
