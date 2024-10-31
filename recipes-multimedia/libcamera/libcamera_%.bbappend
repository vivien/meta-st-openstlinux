FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
        file://0001-0.3.0-stm32mp-add-dcmipp-ipa.patch \
"

PACKAGECONFIG ?= "gst"

LIBCAMERA_PIPELINES = "dcmipp"
LIBCAMERA_IPAS = "dcmipp"

EXTRA_OEMESON += " \
    -Dipas=${LIBCAMERA_IPAS} \
"
