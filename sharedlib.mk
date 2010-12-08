CURR_BUILD_MK := $(prev-makefile)
$(eval $(call build-objs,-fpic))
$(eval $(call build-shared-lib))
