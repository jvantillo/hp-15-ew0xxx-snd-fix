#!/bin/bash

# see https://www.collabora.com/news-and-blog/blog/2021/05/05/quick-hack-patching-kernel-module-using-dkms/

# make the script stop on error
set -e

BIN_ABSPATH="$(dirname "$(readlink -f "${0}")")"

KERNEL_MODULE_NAME='snd-hda-scodec-cs35l41'
DKMS_MODULE_VERSION='0.1'

if [[ ! $EUID = 0 ]]; then
  echo "Only root can perform this setup. Aborting."
  exit 1
fi

# set up the actual DKMS module -------------------------------------------------------------------

"${BIN_ABSPATH}/dkms-module_create.sh" "${KERNEL_MODULE_NAME}" "${DKMS_MODULE_VERSION}"

# create the patch file to apply to the source of the snd-hda-scodec-cs35l41 kernel module
tee "/usr/src/${KERNEL_MODULE_NAME}-${DKMS_MODULE_VERSION}/cs35l41_hda.patch" <<'EOF'
--- sound/pci/hda/cs35l41_hda.c.orig	2024-02-08 21:04:31.873567500 +0100
+++ sound/pci/hda/cs35l41_hda.c	2024-02-08 21:24:32.768596507 +0100
@@ -1611,6 +1611,26 @@
 
 	property = "cirrus,dev-index";
 	ret = device_property_count_u32(physdev, property);
+	if (ret <= 0) {
+		if (strncmp(hid, "CSC3551", 7) == 0) {
+			cs35l41->index = id == 0x40 ? 0 : 1;
+			cs35l41->channel_index = 0;
+			cs35l41->reset_gpio = gpiod_get_index(physdev, NULL, 0, GPIOD_OUT_HIGH);
+			cs35l41->speaker_id = cs35l41_get_speaker_id(physdev, 0, 0, 2);
+			hw_cfg->spk_pos = cs35l41->index;
+			hw_cfg->gpio2.func = CS35L41_INTERRUPT;
+			hw_cfg->gpio2.valid = true;
+			hw_cfg->valid = true;
+
+			hw_cfg->bst_type = CS35L41_EXT_BOOST;
+			hw_cfg->gpio1.func = CS35l41_VSPK_SWITCH;
+			hw_cfg->gpio1.valid = true;
+
+			ret = 0;
+			goto put_physdev;
+ 		}
+	}
+
 	if (ret <= 0)
 		goto err;
 
EOF

"${BIN_ABSPATH}/dkms-module_build.sh" "${KERNEL_MODULE_NAME}" "${DKMS_MODULE_VERSION}"
