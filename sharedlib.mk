CURR_BUILD_MK := $(prev-makefile)
$(eval $(call build-objs,-fpic))
$(eval $(call build-shared-lib,$(call shared-lib-path,$(if $(OUTPUT_NAME),$(OUTPUT_NAME),$(MODULE)))))
