CURR_BUILD_MK := $(prev-makefile)
$(eval $(call build-objs))
$(eval $(call build-static-lib,$(call static-lib-path,$(if $(OUTPUT_NAME),$(OUTPUT_NAME),$(MODULE)))))
