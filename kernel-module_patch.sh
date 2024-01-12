#!/bin/bash

# find out kernel version to use ------------------------------------------------------------------

KERNEL_VERSION=$kernelver

. kernel-version_get.sh

if [ -z $SOURCE_SUB_VERSION ]; then
  echo "Determining the kernel subversion not (yet) supported for your Linux distro. You might want to modify the distro-specific commands. Aborting."
  exit 4
fi

echo "Building for kernel version ${KERNEL_VERSION}"

# download kernel source and patch it -------------------------------------------------------------

# see https://www.collabora.com/news-and-blog/blog/2021/05/05/quick-hack-patching-kernel-module-using-dkms/

[ "${SOURCE_SUB_VERSION}" = '0' ] && unset SOURCE_SUB_VERSION
SOURCE_VERSION_STRING="${SOURCE_MAJOR_VERSION}.${SOURCE_MINOR_VERSION}$( [ -n "${SOURCE_SUB_VERSION}" ] && echo ".${SOURCE_SUB_VERSION}" )"

#echo "Downloading source ${SOURCE_VERSION_STRING} for installed kernel ${KERNEL_VERSION}"
#wget "https://mirrors.edge.kernel.org/pub/linux/kernel/v${SOURCE_MAJOR_VERSION}.x/linux-${SOURCE_VERSION_STRING}.tar.xz"

#echo "Extracting original source of the kernel module"
#pwd
#tar -xf "linux-${SOURCE_VERSION_STRING}.tar."* "linux-${SOURCE_VERSION_STRING}/${1}" "--xform=s,linux-${SOURCE_VERSION_STRING}/$1,.,"

pwd
rm -rf linux-hwe-6.2-6.2.0/
rm -f *.c *.h *.obj
apt-get -d source linux-image-unsigned-$(uname -r)   # todo: make this the real version
apt-get source linux-image-unsigned-$(uname -r) > /dev/null   # hide extract spam
#ls -la
#echo "Working to subdir ${1}"
#pwd
#whoami
#ls -la ./
#ls -la linux-hwe-6.2-6.2.0/${1}/
#echo "Copying from 'linux-hwe-6.2-6.2.0/${1}/*' to '$(pwd)'"
cp -R linux-hwe-6.2-6.2.0/${1}/* ./
ls -la

for i in `ls *.patch`; do
  echo "Applying $i"
  patch < $i
done