#
# Copyright (C) 2023 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/xiaomi/fuxi

BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true

# A/B
AB_OTA_UPDATER := true

AB_OTA_PARTITIONS += \
    boot \
    dtbo \
    init_boot \
    odm \
    product \
    recovery \
    system \
    system_ext \
    system_dlkm \
    vbmeta \
    vbmeta_system \
    vendor \
    vendor_boot \
    vendor_dlkm

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv9-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a510

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := kalama
TARGET_NO_BOOTLOADER := true

# Assert
TARGET_OTA_ASSERT_DEVICE := fuxi,2211133C,2211133G

# Display
TARGET_SCREEN_DENSITY := 440
$(call soong_config_set, qtidisplay, use_ycrcb_camera_encode, true)

# Filesystem
TARGET_FS_CONFIG_GEN := $(DEVICE_PATH)/configs/config.fs

# Kernel
BOARD_KERNEL_PAGESIZE   := 4096
BOARD_KERNEL_BASE       := 0x00000000
BOARD_KERNEL_IMAGE_NAME := Image

BOARD_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)

BOARD_INIT_BOOT_HEADER_VERSION := 4
BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

BOARD_KERNEL_CMDLINE := \
    video=vfb:640x400,bpp=32,memsize=3072000 \
    disable_dma32=on \
    loop.max_part=7 \
    msm_rtb.filter=0x237 \
    pcie_ports=compat \
    service_locator.enable=1 \
    rcu_nocbs=all \
    rcutree.enable_rcu_lazy=1 \
    swinfo.fingerprint=$(LINEAGE_VERSION) \
    mtdoops.fingerprint=$(LINEAGE_VERSION)

BOARD_BOOTCONFIG := \
    androidboot.hardware=qcom \
    androidboot.memcg=1 \
    androidboot.usbcontroller=a600000.dwc3

BOARD_RAMDISK_USE_LZ4 := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true

TARGET_KERNEL_SOURCE := kernel/xiaomi/sm8550
TARGET_KERNEL_CONFIG := \
    gki_defconfig \
    vendor/kalama_GKI.config \
    vendor/fuxi_GKI.config

TARGET_KERNEL_EXT_MODULE_ROOT := kernel/xiaomi/sm8550-modules
TARGET_KERNEL_EXT_MODULES := \
	qcom/opensource/mmrm-driver \
	qcom/opensource/mm-drivers/hw_fence \
	qcom/opensource/mm-drivers/msm_ext_display \
	qcom/opensource/mm-drivers/sync_fence \
	qcom/opensource/audio-kernel \
	qcom/opensource/camera-kernel \
	qcom/opensource/dataipa/drivers/platform/msm \
	qcom/opensource/datarmnet/core \
	qcom/opensource/datarmnet-ext/aps \
	qcom/opensource/datarmnet-ext/offload \
	qcom/opensource/datarmnet-ext/shs \
	qcom/opensource/datarmnet-ext/perf \
	qcom/opensource/datarmnet-ext/perf_tether \
	qcom/opensource/datarmnet-ext/sch \
	qcom/opensource/datarmnet-ext/wlan \
	qcom/opensource/securemsm-kernel \
	qcom/opensource/display-drivers/msm \
	qcom/opensource/eva-kernel \
	qcom/opensource/video-driver \
	qcom/opensource/graphics-kernel \
	qcom/opensource/wlan/platform \
	qcom/opensource/wlan/qcacld-3.0/.kiwi_v2 \
	qcom/opensource/bt-kernel \
	qcom/opensource/eSE-driver \
	qcom/opensource/nfc-st-driver \
	qcom/opensource/touch-drivers \
	nxp/opensource/driver

# Kernel modules
BOARD_SYSTEM_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/configs/modules/modules.load.system_dlkm))
BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE := $(TARGET_KERNEL_SOURCE)/modules.vendor_blocklist.msm.kalama
BOARD_VENDOR_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/configs/modules/modules.load))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(BOARD_VENDOR_KERNEL_MODULES_BLOCKLIST_FILE)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/configs/modules/modules.load.vendor_boot))
BOARD_VENDOR_RAMDISK_RECOVERY_KERNEL_MODULES_LOAD := $(strip $(shell cat $(DEVICE_PATH)/configs/modules/modules.load.recovery))
BOOT_KERNEL_MODULES := $(strip $(shell cat $(DEVICE_PATH)/configs/modules/modules.load.recovery $(DEVICE_PATH)/configs/modules/modules.include.vendor_ramdisk))

# Init
TARGET_INIT_VENDOR_LIB := //$(DEVICE_PATH):libinit_fuxi
TARGET_RECOVERY_DEVICE_MODULES := libinit_fuxi

# Dtb/o
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_USES_QCOM_MERGE_DTBS_SCRIPT := true
TARGET_NEEDS_DTBOIMAGE := true
TARGET_MERGE_DTBS_WILDCARD ?= kalama*base

# Lineage Health
TARGET_HEALTH_CHARGING_CONTROL_CHARGING_PATH := /sys/class/qcom-battery/input_suspend
TARGET_HEALTH_CHARGING_CONTROL_CHARGING_ENABLED := 0
TARGET_HEALTH_CHARGING_CONTROL_CHARGING_DISABLED := 1
TARGET_HEALTH_CHARGING_CONTROL_SUPPORTS_BYPASS := false

# Metadata
BOARD_USES_METADATA_PARTITION := true

# Partitions
BOARD_PRODUCTIMAGE_MINIMAL_PARTITION_RESERVED_SIZE := false
-include vendor/lineage/config/BoardConfigReservedSize.mk

BOARD_FLASH_BLOCK_SIZE := 262144
BOARD_DTBOIMG_PARTITION_SIZE := 25165824
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_BOOTIMAGE_PARTITION_SIZE := 201326592
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 104857600
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 100663296

BOARD_SUPER_PARTITION_SIZE := 9653190656
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 9648996352
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := system system_ext system_dlkm product vendor vendor_dlkm odm

BOARD_PARTITION_LIST := $(call to-upper, $(BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST))
$(foreach p, $(BOARD_PARTITION_LIST), $(eval BOARD_$(p)IMAGE_FILE_SYSTEM_TYPE := ext4))
$(foreach p, $(BOARD_PARTITION_LIST), $(eval TARGET_COPY_OUT_$(p) := $(call to-lower, $(p))))

# Audio
AUDIO_FEATURE_ENABLED_DLKM := true
AUDIO_FEATURE_ENABLED_GEF_SUPPORT := true
AUDIO_FEATURE_ENABLED_GKI := true
AUDIO_FEATURE_ENABLED_INSTANCE_ID := true
AUDIO_FEATURE_ENABLED_AGM_HIDL := true
AUDIO_FEATURE_ENABLED_LSM_HIDL := true
AUDIO_FEATURE_ENABLED_PAL_HIDL := true
AUDIO_FEATURE_ENABLED_PROXY_DEVICE := true
AUDIO_FEATURE_ENABLED_SSR := true
AUDIO_FEATURE_ENABLED_SVA_MULTI_STAGE := true
BOARD_SUPPORTS_OPENSOURCE_STHAL := false
BOARD_SUPPORTS_SOUND_TRIGGER := true
BOARD_USES_ALSA_AUDIO := true
TARGET_USES_QCOM_MM_AUDIO := true
AUDIO_FEATURE_ENABLED_DTS_EAGLE := false
AUDIO_FEATURE_ENABLED_HW_ACCELERATED_EFFECTS := false

TARGET_USES_QCOM_MM_AUDIO := true

# Platform
TARGET_BOARD_PLATFORM := kalama
TARGET_BOARD_PLATFORM_GPU := qcom-adreno740
BOARD_USES_QCOM_HARDWARE := true

# Disable sparse on all filesystem images
TARGET_USERIMAGES_SPARSE_EROFS_DISABLED := true
TARGET_USERIMAGES_SPARSE_EXT_DISABLED := true
TARGET_USERIMAGES_SPARSE_F2FS_DISABLED := true

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/configs/properties/odm.prop
TARGET_PRODUCT_PROP += $(DEVICE_PATH)/configs/properties/product.prop
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/configs/properties/system.prop
TARGET_SYSTEM_EXT_PROP += $(DEVICE_PATH)/configs/properties/system_ext.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/configs/properties/vendor.prop

# Recovery
$(call soong_config_set, ufsbsg, ufsframework, bsg)
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.qcom
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# RIL
ENABLE_VENDOR_RIL_SERVICE := true

# Vendor boot
PRODUCT_COPY_FILES += $(DEVICE_PATH)/rootdir/etc/fstab.qcom:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.qcom

# Security patch level
BOOT_SECURITY_PATCH := 2023-10-01
VENDOR_SECURITY_PATCH := $(BOOT_SECURITY_PATCH)

# Sensors
$(call soong_config_set, SENSORS_XIAOMI, USES_SINGLE_TAP_SENSOR, true)
$(call soong_config_set, SENSORS_XIAOMI, USES_DOUBLE_TAP_SENSOR, true)
$(call soong_config_set, SENSORS_XIAOMI, USES_UDFPS_SENSOR, true)

# Sepolicy
include device/qcom/sepolicy_vndr/SEPolicy.mk
include device/lineage/sepolicy/libperfmgr/sepolicy.mk
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/public
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS += --flags 3
BOARD_MOVE_GSI_AVB_KEYS_TO_VENDOR_BOOT := true

BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 1

BOARD_AVB_VBMETA_SYSTEM := system system_ext system_dlkm product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 2

# VINTF
DEVICE_MANIFEST_SKUS := kalama
DEVICE_MATRIX_FILE := hardware/qcom-caf/common/compatibility_matrix.xml
DEVICE_MANIFEST_KALAMA_FILES := \
    $(DEVICE_PATH)/configs/vintf/manifest_kalama.xml \
    $(DEVICE_PATH)/configs/vintf/manifest_xiaomi.xml
DEVICE_FRAMEWORK_MANIFEST_FILE += $(DEVICE_PATH)/configs/vintf/framework_manifest.xml
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE := \
    $(DEVICE_PATH)/configs/vintf/compatibility_matrix.device.xml \
    $(DEVICE_PATH)/configs/vintf/compatibility_matrix.xiaomi.xml \
    vendor/lineage/config/device_framework_matrix.xml

# Vibrator
$(call soong_config_set, XIAOMI_VIBRATOR, USE_EFFECT_STREAM, true)

# WiFi
BOARD_WLAN_DEVICE := qcwcn
BOARD_HOSTAPD_DRIVER := NL80211
BOARD_HOSTAPD_PRIVATE_LIB := lib_driver_cmd_$(BOARD_WLAN_DEVICE)
BOARD_WPA_SUPPLICANT_DRIVER := $(BOARD_HOSTAPD_DRIVER)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := $(BOARD_HOSTAPD_PRIVATE_LIB)
BOARD_WPA_SUPPLICANT_PRIVATE_LIB_EVENT := "ON"
CONFIG_IEEE80211AX := true
WIFI_DRIVER_STATE_CTRL_PARAM := "/dev/wlan"
WIFI_DRIVER_STATE_OFF := "OFF"
WIFI_DRIVER_STATE_ON := "ON"
WIFI_HIDL_FEATURE_DUAL_INTERFACE := true
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
WPA_SUPPLICANT_VERSION := VER_0_8_X

# PowerShare
$(call soong_config_set, XIAOMI_POWERSHARE, WIRELESS_TX_ENABLE_PATH, /sys/class/qcom-battery/reverse_chg_mode)
