//
// Copyright (C) 2023 Paranoid Android
//
// SPDX-License-Identifier: Apache-2.0
//

#pragma once

#include <aidl/vendor/lineage/xiaomitouch/BnXiaomiTouch.h>

#include <mutex>
#include <thread>

namespace aidl::vendor::lineage::xiaomitouch {

class XiaomiTouch : public BnXiaomiTouch {
    public:
        ndk::ScopedAStatus setModeValue(int mode, int value) override;
};

}
