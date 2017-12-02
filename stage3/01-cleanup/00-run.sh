#!/bin/bash -e

#docs
rm -rf ${ROOTFS_DIR}/usr/share/locale/*
rm -rf ${ROOTFS_DIR}/usr/share/man/*
rm -rf ${ROOTFS_DIR}/usr/share/groff/*
rm -rf ${ROOTFS_DIR}/usr/share/info/*
rm -rf ${ROOTFS_DIR}/usr/share/lintian/*
rm -rf ${ROOTFS_DIR}/usr/share/linda/*
rm -rf ${ROOTFS_DIR}/var/cache/man/*
find ${ROOTFS_DIR}/usr/share/doc/* \! -name 'copyright' -delete || true
find ${ROOTFS_DIR}/usr/share/doc/* -type d -empty -delete || true

#unnessecary fallback kernel (hardcoded)
rm -rf ${ROOTFS_DIR}/boot/kernel.img
rm -rf ${ROOTFS_DIR}/lib/modules/4.9.35+/
