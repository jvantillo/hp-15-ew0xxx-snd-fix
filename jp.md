
## Generate patch

```bash
# Prep folder
cd ~
mkdir -p ~/tmp
cd ~/tmp
rm -rf *

# Fetch source and unpack
apt-get -d source linux-image-unsigned-$(uname -r)   # todo: make this the real version
apt-get source linux-image-unsigned-$(uname -r) > /dev/null   # hide extract spam

## HDA patch

# Copy file to orig
(cd linux-hwe-6.5-6.5.0/sound/pci/hda && cp cs35l41_hda.c cs35l41_hda.c.orig && code .)

# (Now edit in VsCode the cs35l41_hda.c file and save)

# Generate patch file:
(cd ~/tmp/linux-hwe-6.5-6.5.0 && diff -u sound/pci/hda/cs35l41_hda.c.orig sound/pci/hda/cs35l41_hda.c) > cs35l41_hda.patch


## REALTEK patch
# Copy file to orig
(cd linux-hwe-6.5-6.5.0/sound/pci/hda && cp patch_realtek.c patch_realtek.c.orig && code .)

# (Now edit in VsCode the patch_realtek.c file and save)

# Generate patch file:
(cd ~/tmp/linux-hwe-6.5-6.5.0 && diff -u sound/pci/hda/patch_realtek.c.orig sound/pci/hda/patch_realtek.c) > patch_realtek.patch

```

## Remove modules

```bash
# To remove all:

sudo dkms remove snd-hda-codec-realtek/0.1 --all
sudo dkms remove snd-hda-scodec-cs35l41/0.1 --all


```