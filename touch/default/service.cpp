//
// Copyright (C) 2023 Paranoid Android
//
// SPDX-License-Identifier: Apache-2.0
//

#include <android-base/logging.h>
#include <android/binder_manager.h>
#include <android/binder_process.h>
#include <binder/ProcessState.h>
#include <binder/IServiceManager.h>

#include "XiaomiTouch.h"

using ::aidl::vendor::lineage::xiaomitouch::XiaomiTouch;

template <class C>
static void registerAsService(std::shared_ptr<C> service, const char *inst) {
  const std::string instance = std::string() + C::descriptor + "/" + inst;
  binder_status_t status =
      AServiceManager_addService(service->asBinder().get(), instance.c_str());
  CHECK(status == STATUS_OK);
  if (!DISABLE_DEBUG) LOG(INFO) << "Register done for instance " << inst;
}

int main() {
  ABinderProcess_setThreadPoolMaxThreadCount(8);
  if (!DISABLE_DEBUG) LOG(INFO) << "Starting XiaomiTouch service";
  registerAsService(ndk::SharedRefBase::make<XiaomiTouch>(), "default");

  ABinderProcess_joinThreadPool();
  return -1; // should never get here
}