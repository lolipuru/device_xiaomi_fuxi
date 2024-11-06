#!/bin/bash
#
# SPDX-FileCopyrightText: 2016 The CyanogenMod Project
# SPDX-FileCopyrightText: 2017-2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

set -e

DEVICE=fuxi
VENDOR=xiaomi

# Load extract_utils and do some sanity checks
MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "${MY_DIR}" ]]; then MY_DIR="${PWD}"; fi

ANDROID_ROOT="${MY_DIR}/../../.."

export TARGET_ENABLE_CHECKELF=true

# If XML files don't have comments before the XML header, use this flag
# Can still be used with broken XML files by using blob_fixup
export TARGET_DISABLE_XML_FIXING=true

HELPER="${ANDROID_ROOT}/tools/extract-utils/extract_utils.sh"
if [ ! -f "${HELPER}" ]; then
    echo "Unable to find helper script at ${HELPER}"
    exit 1
fi
source "${HELPER}"

# Default to sanitizing the vendor folder before extraction
CLEAN_VENDOR=true

ONLY_FIRMWARE=
KANG=
SECTION=
CARRIER_SKIP_FILES=()

while [ "${#}" -gt 0 ]; do
    case "${1}" in
        --only-firmware)
            ONLY_FIRMWARE=true
            ;;
        -n | --no-cleanup)
            CLEAN_VENDOR=false
            ;;
        -k | --kang)
            KANG="--kang"
            ;;
        -s | --section)
            SECTION="${2}"
            shift
            CLEAN_VENDOR=false
            ;;
        *)
            SRC="${1}"
            ;;
    esac
    shift
done

if [ -z "${SRC}" ]; then
    SRC="adb"
fi

function blob_fixup() {
    case "${1}" in
        odm/etc/camera/enhance_motiontuning.xml|odm/etc/camera/enhance_motiontuning.xml)
            sed -i 's/xml=version/xml version/g' "${2}"
            ;;
        odm/etc/camera/motiontuning.xml|odm/etc/camera/motiontuning.xml)
            sed -i 's/xml=version/xml version/g' "${2}"
            ;;
        odm/etc/camera/night_motiontuning.xml|odm/etc/camera/night_motiontuning.xml)
            sed -i 's/xml=version/xml version/g' "${2}"
            ;;
        odm/lib64/hw/vendor.xiaomi.sensor.citsensorservice@2.0-impl.so)
            sed -i 's/_ZN13DisplayConfig10ClientImpl13ClientImplGetENSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEEPNS_14ConfigCallbackE/_ZN13DisplayConfig10ClientImpl4InitENSt3__112basic_stringIcNS1_11char_traitsIcEENS1_9allocatorIcEEEEPNS_14ConfigCallbackE\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0/g' "${2}"
            ;;
        odm/lib64/libmt@1.3.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --replace-needed "libcrypto.so" "libcrypto-v33.so" "${2}"
            ;;
        odm/etc/init/vendor.xiaomi.sensor.citsensorservice@2.0-service.rc)
            sed -i 's/group system input/group system input\n    task_profiles ServiceCapacityLow/' "${2}"
            ;;
        vendor/bin/hw/android.hardware.security.keymint-service-qti | vendor/lib64/libqtikeymint.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --add-needed android.hardware.security.rkp-V3-ndk.so "${2}"
            ;;
        vendor/bin/hw/dolbycodec2 | vendor/bin/hw/vendor.dolby.hardware.dms@2.0-service | vendor/bin/hw/vendor.dolby.media.c2@1.0-service)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --add-needed "libstagefright_foundation-v33.so" "${2}"
            ;;
        vendor/etc/seccomp_policy/qwesd@2.0.policy)
            [ "$2" = "" ] && return 0
            echo "pipe2: 1" >> "${2}"
            ;;
        vendor/etc/seccomp_policy/atfwd@2.0.policy | vendor/etc/seccomp_policy/modemManager.policy | vendor/etc/seccomp_policy/qwesd@2.0.policy | vendor/etc/seccomp_policy/wfdhdcphalservice.policy)
            [ "$2" = "" ] && return 0
            [ -n "$(tail -c 1 "${2}")" ] && echo >> "${2}"
            grep -q "gettid: 1" "${2}" || echo "gettid: 1" >> "${2}"
            ;;
        vendor/lib64/c2.dolby.client.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --add-needed "libcodec2_hidl_shim.so" "${2}"
            ;;
        vendor/lib64/libqcodec2_core.so)
            [ "$2" = "" ] && return 0
            grep -q "libcodec2_shim.so" "${2}" || "${PATCHELF}" --add-needed "libcodec2_shim.so" "${2}"
            ;;
        vendor/lib64/vendor.libdpmframework.so)
            [ "$2" = "" ] && return 0
            "${PATCHELF}" --add-needed "libhidlbase_shim.so" "${2}"
            ;;
        vendor/etc/media_codecs_pineapple.xml|vendor/etc/media_codecs_pineapple_vendor.xml)
            sed -Ei "/media_codecs_(google_audio|google_c2|google_telephony|google_video|vendor_audio)/d" "${2}"
            ;;
    esac

    return 0
}

function blob_fixup_dry() {
    blob_fixup "$1" ""
}

function prepare_firmware() {
    :
}

# Initialize the helper
setup_vendor "${DEVICE}" "${VENDOR}" "${ANDROID_ROOT}" false "${CLEAN_VENDOR}"

if [ -z "${ONLY_FIRMWARE}" ]; then
    extract "${MY_DIR}/proprietary-files.txt" "${SRC}" "${KANG}" --section "${SECTION}"
fi

if [ -z "${SECTION}" ]; then
    extract_firmware "${MY_DIR}/proprietary-firmware.txt" "${SRC}"
fi

"${MY_DIR}/setup-makefiles.sh"
