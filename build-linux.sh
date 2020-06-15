#!/bin/bash
set -euxo pipefail

# see https://www.raspberrypi.org/documentation/linux/kernel/
# see https://www.raspberrypi.org/documentation/linux/kernel/building.md

# build.
cd ~/linux
ARCH=arm
# ARCH=arm64 # XXX does not yet work... there are no dt files created. or are they built with arm arch?
if [ "$ARCH" == "arm" ]; then
    kernel_make_target=zImage # see arch/arm64/Makefile
    export PATH="$PATH:$HOME/tools/arm-bcm2708/arm-linux-gnueabihf/bin"
    export CROSS_COMPILE=arm-linux-gnueabihf-
    export CONFIG_LOCALVERSION="-v7l-rgl"
elif [ "$ARCH" == "arm64" ]; then
    apt-get install -y gcc-aarch64-linux-gnu
    kernel_make_target=Image.gz # see arch/arm64/Makefile
    export CROSS_COMPILE=aarch64-linux-gnu-
    export CONFIG_LOCALVERSION="-v8-rgl"
fi
MAKEARGS="ARCH=$ARCH -j $(nproc)"
time make $MAKEARGS bcm2711_defconfig
time make $MAKEARGS $kernel_make_target modules dtbs

# package.
kernel_version="$(make $MAKEARGS -f /vagrant/print.Makefile -f Makefile print-KERNELVERSION)"
kernel=vmlinux
target=$PWD/target
rm -rf $target
mkdir -p $target/boot/overlays
make $MAKEARGS INSTALL_MOD_PATH=$target modules_install
cp arch/$ARCH/boot/$kernel_make_target $target/boot/$kernel
cp arch/$ARCH/boot/dts/*.dtb $target/boot
cp arch/$ARCH/boot/dts/overlays/*.dtb* $target/boot/overlays
cp arch/$ARCH/boot/dts/overlays/README $target/boot/overlays
mkdir -p /vagrant/tmp
tar czf /vagrant/tmp/raspberrypi-linux-$kernel_version.tgz -C $target --xform 's,^\./,,' .
ls -laF /vagrant/tmp/raspberrypi-linux-$kernel_version.tgz
