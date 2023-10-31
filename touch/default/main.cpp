//
// Copyright (C) 2023 Paranoid Android
//
// SPDX-License-Identifier: Apache-2.0
//

#define LOG_TAG "vendor.lineage.xiaomitouch-service"

#include <android-base/logging.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>

#include "XiaomiTouch.h"

using ::aidl::vendor::lineage::xiaomitouch::XiaomiTouch;

int main() {
    ABinderProcess_setThreadPoolMaxThreadCount(0);
    std::shared_ptr<XiaomiTouch> xiaomiTouch = ndk::SharedRefBase::make<XiaomiTouch>();
    if (!xiaomiTouch) {
        return EXIT_FAILURE;
    }

    const std::string instance = std::string(XiaomiTouch::descriptor) + "/default";
    binder_status_t status =
            AServiceManager_addService(xiaomiTouch->asBinder().get(), instance.c_str());
    CHECK(status == STATUS_OK);

    ABinderProcess_joinThreadPool();
    return EXIT_FAILURE; // should not reached
}
