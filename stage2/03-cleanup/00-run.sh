#!/bin/bash -e

rm -rf ${ROOTFS_DIR}/usr/share/locale/*
rm -rf ${ROOTFS_DIR}/usr/share/man/*

# Remove contents of the doc dir but keep the copyright files for license reasons
CLEAN_DOC_DIR=${ROOTFS_DIR}/usr/share/clean_doc
mkdir -p ${CLEAN_DOC_DIR}
for DOC_DIR in ${ROOTFS_DIR}/usr/share/doc/*; do
	if [ -f ${DOC_DIR}/copyright ]; then
		mkdir ${CLEAN_DOC_DIR}/$(basename ${DOC_DIR})
		cp ${DOC_DIR}/copyright ${CLEAN_DOC_DIR}/$(basename ${DOC_DIR})/copyright
	fi
done
rm -rf ${ROOTFS_DIR}/usr/share/doc
mv ${CLEAN_DOC_DIR} ${ROOTFS_DIR}/usr/share/doc
