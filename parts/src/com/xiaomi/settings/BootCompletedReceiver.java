/*
 * Copyright (C) 2023 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xiaomi.settings;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.hardware.display.DisplayManager;
import android.os.IBinder;
import android.os.UserHandle;
import android.util.Log;
import android.view.Display;
import android.view.Display.HdrCapabilities;

import com.xiaomi.settings.display.ColorModeService;
import com.xiaomi.settings.doze.PocketDetectionService;
import com.xiaomi.settings.touch.AlwaysOnFingerprintService;
import com.xiaomi.settings.touch.TouchPollingRateService;

public class BootCompletedReceiver extends BroadcastReceiver {

    private static final String TAG = "XiaomiParts";
    private static final boolean DEBUG = true;

    @Override
    public void onReceive(final Context context, Intent intent) {
        if (!intent.getAction().equals(Intent.ACTION_BOOT_COMPLETED)) {
            return;
        }
        if (DEBUG) Log.d(TAG, "Received boot completed intent");

        // Display
        context.startServiceAsUser(new Intent(context, ColorModeService.class),
                UserHandle.CURRENT);

        // Pocket
        context.startServiceAsUser(new Intent(context, PocketDetectionService.class),
                UserHandle.CURRENT);

        // Touchscreen
        context.startServiceAsUser(new Intent(context, AlwaysOnFingerprintService.class),
                UserHandle.CURRENT);
        context.startServiceAsUser(new Intent(context, TouchPollingRateService.class),
                UserHandle.CURRENT);

        // Override HDR types
        final DisplayManager displayManager = context.getSystemService(DisplayManager.class);
        displayManager.overrideHdrTypes(Display.DEFAULT_DISPLAY, new int[]{
                HdrCapabilities.HDR_TYPE_DOLBY_VISION, HdrCapabilities.HDR_TYPE_HDR10,
                HdrCapabilities.HDR_TYPE_HLG, HdrCapabilities.HDR_TYPE_HDR10_PLUS});
    }
}
