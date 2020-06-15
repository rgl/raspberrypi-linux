#!/bin/bash
set -euxo pipefail

# see https://www.raspberrypi.org/documentation/linux/kernel/building.md

# install depdencies.
cd ~
apt-get install -y bc bison flex libssl-dev make libc6-dev libncurses5-dev
git clone --depth 1 https://github.com/raspberrypi/tools tools
git clone --depth 1 --branch rpi-5.4.y https://github.com/raspberrypi/linux
