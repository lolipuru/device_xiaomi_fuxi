#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2024 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.fixups_lib import (
    lib_fixup_remove,
    lib_fixups,
    lib_fixups_user_type,
)
from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

namespace_imports = [
    "device/xiaomi/fuxi",
    "hardware/qcom-caf/sm8550",
    "hardware/qcom-caf/wlan",
    "hardware/xiaomi",
    "vendor/qcom/opensource/commonsys-intf/display",
    "vendor/qcom/opensource/dataservices",
]

def lib_fixup_vendor_suffix(lib: str, partition: str, *args, **kwargs):
    return f'{lib}-{partition}' if partition == 'vendor' else None

lib_fixups: lib_fixups_user_type = {
    **lib_fixups,
    (
        'vendor.qti.diaghal@1.0',
        'vendor.qti.imsrtpservice@3.0',
        'vendor.qti.imsrtpservice@3.1'
    ): lib_fixup_vendor_suffix,
    (
        'audio.primary.kalama',
        'libagmclient',
        'libagmmixer',
        'libpalclient',
        'libwpa_client',
        'vendor.qti.qspmhal@1.0'
    ): lib_fixup_remove,
}

blob_fixups: blob_fixups_user_type = {
    (
        'odm/etc/camera/enhance_motiontuning.xml',
        'odm/etc/camera/night_motiontuning.xml',
        'odm/etc/camera/motiontuning.xml'
    ): blob_fixup()
        .regex_replace('xml=version', 'xml version'),
    'odm/lib64/libmt@1.3.so': blob_fixup()
        .replace_needed('libcrypto.so', 'libcrypto-v33.so'),
    'odm/etc/init/vendor.xiaomi.sensor.citsensorservice@2.0-service.rc': blob_fixup()
        .regex_replace('s/group system input/group system input\n', 'task_profiles ServiceCapacityLow/'),
    (
        'vendor/bin/hw/android.hardware.security.keymint-service-qti',
        'vendor/lib64/libqtikeymint.so'
    ): blob_fixup()
        .add_needed('android.hardware.security.rkp-V3-ndk.so'),
    (
        'vendor/bin/hw/dolbycodec2',
        'vendor/bin/hw/vendor.dolby.hardware.dms@2.0-service',
        'vendor/bin/hw/vendor.dolby.media.c2@1.0-service',
    ): blob_fixup()
        .add_needed('libstagefright_foundation-v33.so'),
    'vendor/etc/seccomp_policy/qwesd@2.0.policy': blob_fixup()
        .add_line_if_missing('pipe2: 1')
        .add_line_if_missing('gettid: 1'),  
     (
        'vendor/etc/seccomp_policy/atfwd@2.0.policy',
        'vendor/etc/seccomp_policy/modemManager.policy',
        'vendor/etc/seccomp_policy/wfdhdcphalservice.policy',
    ): blob_fixup()
        .add_line_if_missing('gettid: 1'),  
    'vendor/lib64/c2.dolby.client.so': blob_fixup()
        .add_needed('libcodec2_hidl_shim.so'),
    'vendor/lib64/libqcodec2_core.so': blob_fixup()
        .add_needed('libcodec2_shim.so'),
    'vendor/lib64/vendor.libdpmframework.so': blob_fixup()
        .add_needed('libhidlbase_shim.so'),
    (
        'vendor/etc/media_codecs_kalama.xml',
        'vendor/etc/media_codecs_kalama_vendor.xml',
    ): blob_fixup()
        .regex_replace('.+media_codecs_(google_audio|google_c2|google_telephony|vendor_audio).+\n', ''),
}  # fmt: skip

module = ExtractUtilsModule(
    'fuxi',
    'xiaomi',
    blob_fixups=blob_fixups,
    lib_fixups=lib_fixups,
    namespace_imports=namespace_imports,
    add_firmware_proprietary_file=True,
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
