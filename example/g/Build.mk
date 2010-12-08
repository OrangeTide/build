LOCAL_PATH := $(call this-dir)
MODULE := g
DESCRIPTION := example of multiple files, mixed C and C++
SRCS += g1.c g2.c gmain.cpp
include $(BUILD_EXECUTABLE)
