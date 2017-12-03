#!/bin/bash -e

# set up wifi-menu
install -v -d                                           ${ROOTFS_DIR}/usr/lib/netctl
install -v -m 755 files/globals                         ${ROOTFS_DIR}/usr/lib/netctl/
install -v -m 755 files/rfkill                          ${ROOTFS_DIR}/usr/lib/netctl/
install -v -m 755 files/wpa                             ${ROOTFS_DIR}/usr/lib/netctl/
install -v -m 755 files/interface                       ${ROOTFS_DIR}/usr/lib/netctl/

install -v -m 755 files/wifi-menu                       ${ROOTFS_DIR}/usr/bin/

install -v -d                                           ${ROOTFS_DIR}/usr/share/doc/netctl
install -v -m 644 files/copyright                       ${ROOTFS_DIR}/usr/share/doc/netctl/
