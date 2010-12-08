CURR_BUILD_MK := $(prev-makefile)
$(eval $(call build-objs))
$(eval $(call build-exec))
