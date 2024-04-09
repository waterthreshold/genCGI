TARGET_DIR ?= $(shell echo "${HOME}/bin")
install:
	@echo $(TARGET_DIR)
	@cp -f genDoC.sh addFXCN_cgi.sh curl_indoorv2.sh $(TARGET_DIR)
