/*
 * Copyright (C) 2023 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xiaomi.settings.touch;

import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.os.IBinder;
import android.os.UserHandle;
import android.util.Log;

public class TouchOrientationService extends Service {

    private static final String TAG = "XiaomiPartsTouchOrientationService";
    private static final boolean DEBUG = true;

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.d(TAG, "onStartCommand");
        updateOrientation();
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        Log.d(TAG, "onDestroy");
        super.onDestroy();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        Log.d(TAG, "onConfigurationChanged");
        updateOrientation();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private void updateOrientation() {
        final int rotation = getDisplay().getRotation();
        Log.d(TAG, "updateTpOrientation: rotation=" + rotation);

        // Lucky for us, Surface.ROTATION_* directly translates into touchpanel values
        TfWrapper.setTouchFeature(
                new TfWrapper.TfParams(/*TOUCH_PANEL_ORIENTATION*/ 8, rotation));
    }

}
