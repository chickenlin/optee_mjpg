export V ?= 0

OUTPUT_DIR := $(CURDIR)/out

MJPG_LIST := $(subst /,,$(dir $(wildcard */Makefile)))

.PHONY: all
all: mjpg prepare-for-rootfs

.PHONY: clean
clean: mjpg-clean prepare-for-rootfs-clean

mjpg:
	@for mjpg in $(MJPG_LIST); do \
		$(MAKE) -C $$mjpg CROSS_COMPILE="$(HOST_CROSS_COMPILE)" || exit -1; \
	done

mjpg-clean:
	@for mjpg in $(MJPG_LIST); do \
		$(MAKE) -C $$mjpg clean || exit -1; \
	done

prepare-for-rootfs: mjpg
	@echo "Copying mjpg CA and TA binaries to $(OUTPUT_DIR)..."
	@mkdir -p $(OUTPUT_DIR)
	@mkdir -p $(OUTPUT_DIR)/ta
	@mkdir -p $(OUTPUT_DIR)/ca
	@for mjpg in $(MJPG_LIST); do \
		if [ -e $$mjpg/host/optee_$$mjpg ]; then \
			cp -p $$mjpg/host/optee_$$mjpg $(OUTPUT_DIR)/ca/; \
		fi; \
		cp -pr $$mjpg/ta/*.ta $(OUTPUT_DIR)/ta/; \
	done

prepare-for-rootfs-clean:
	@rm -rf $(OUTPUT_DIR)/ta
	@rm -rf $(OUTPUT_DIR)/ca
	@rmdir --ignore-fail-on-non-empty $(OUTPUT_DIR) || test ! -e $(OUTPUT_DIR)
