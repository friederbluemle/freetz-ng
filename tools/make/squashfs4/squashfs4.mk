SQUASHFS4_VERSION:=4.3
SQUASHFS4_SOURCE:=squashfs$(SQUASHFS4_VERSION).tar.gz
SQUASHFS4_SOURCE_MD5:=d92ab59aabf5173f2a59089531e30dbf
SQUASHFS4_SITE:=@SF/squashfs

SQUASHFS4_MAKE_DIR:=$(TOOLS_DIR)/make/squashfs4
SQUASHFS4_DIR:=$(TOOLS_SOURCE_DIR)/squashfs$(SQUASHFS4_VERSION)
SQUASHFS4_BUILD_DIR:=$(SQUASHFS4_DIR)/squashfs-tools

SQUASHFS4_TOOLS:=unsquashfs
SQUASHFS4_TOOLS_BUILD_DIR:=$(addprefix $(SQUASHFS4_BUILD_DIR)/,$(SQUASHFS4_TOOLS))
SQUASHFS4_TOOLS_TARGET_DIR:=$(SQUASHFS4_TOOLS:%=$(TOOLS_DIR)/%4-lzma)

squashfs4-source: $(DL_DIR)/$(SQUASHFS4_SOURCE)
$(DL_DIR)/$(SQUASHFS4_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SQUASHFS4_SOURCE) $(SQUASHFS4_SITE) $(SQUASHFS4_SOURCE_MD5)

squashfs4-unpacked: $(SQUASHFS4_DIR)/.unpacked
$(SQUASHFS4_DIR)/.unpacked: $(DL_DIR)/$(SQUASHFS4_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(SQUASHFS4_SOURCE),$(TOOLS_SOURCE_DIR))
	$(call APPLY_PATCHES,$(SQUASHFS4_MAKE_DIR)/patches,$(SQUASHFS4_DIR))
	touch $@

$(SQUASHFS4_TOOLS_BUILD_DIR): $(SQUASHFS4_DIR)/.unpacked $(LZMA2_DIR)/liblzma.a
	$(MAKE) CC="$(TOOLS_CC)" XZ_DIR="$(abspath $(LZMA2_DIR))" \
		-C $(SQUASHFS4_BUILD_DIR)  $(SQUASHFS4_TOOLS)
	touch -c $@

$(SQUASHFS4_TOOLS_TARGET_DIR): $(TOOLS_DIR)/%4-lzma: $(SQUASHFS4_BUILD_DIR)/%
	$(INSTALL_FILE)
	strip $@

squashfs4: $(SQUASHFS4_TOOLS_TARGET_DIR)

squashfs4-clean:
	-$(MAKE) -C $(SQUASHFS4_BUILD_DIR) clean

squashfs4-dirclean:
	$(RM) -r $(SQUASHFS4_DIR)

squashfs4-distclean: squashfs4-dirclean
	$(RM) $(SQUASHFS4_TOOLS_TARGET_DIR)
