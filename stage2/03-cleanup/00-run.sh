#!/bin/bash -e

rm -rf ${ROOTFS_DIR}/usr/share/locale/*
rm -rf ${ROOTFS_DIR}/usr/share/man/*
find ${ROOTFS_DIR}/usr/share/doc/* \! -name 'copyright' -delete 
find ${ROOTFS_DIR}/usr/share/doc/* -type d -empty -delete
