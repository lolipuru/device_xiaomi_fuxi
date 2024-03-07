/*
 * Copyright (C) 2023-2024 Paranoid Android
 *
 * SPDX-License-Identifier: Apache-2.0
 */

package com.xiaomi.settings.touch;

import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.ContentResolver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.ContentObserver;
import android.net.Uri;
import android.os.Handler;
import android.os.IBinder;
import android.os.Looper;
import android.os.ServiceManager;
import android.os.SystemProperties;
import android.os.UserHandle;
import android.provider.Settings;
import android.util.Log;
import android.view.Display;

import com.xiaomi.settings.utils.FileUtils;

public class AlwaysOnFingerprintService extends Service {

    private static final String TAG = "XiaomiPartsAlwaysOnFingerprintService";
    private static final boolean DEBUG = true;

    private static final String SECURE_KEY_TAP = "doze_tap_gesture";
    private static final String SECURE_KEY_UDFPS = "screen_off_udfps_enabled";

    private static final String FOD_PRESS_STATUS_PATH = "/sys/class/touch/touch_dev/fod_press_status";

    private boolean mIsAofEnabled;

    private ContentResolver mContentResolver;
    private ScreenStateReceiver mScreenStateReceiver;
    private SettingsObserver mSettingsObserver;
    private final Handler mHandler = new Handler();

    @Override
    public void onCreate() {
        super.onCreate();
        if (DEBUG) Log.d(TAG, "Creating service");
        mContentResolver = getContentResolver();
        mScreenStateReceiver = new ScreenStateReceiver();
        mSettingsObserver = new SettingsObserver(mHandler);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startid) {
        if (DEBUG) Log.d(TAG, "Starting service");
        mScreenStateReceiver.register();
        mSettingsObserver.register();
        mSettingsObserver.update();
        return START_STICKY;
    }

    @Override
    public void onDestroy() {
        if (DEBUG) Log.d(TAG, "Destroying service");
        super.onDestroy();
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private final class ScreenStateReceiver extends BroadcastReceiver {
        public void register() {
            if (DEBUG) Log.d(TAG, "ScreenStateReceiver: register");
            registerReceiver(mScreenStateReceiver, new IntentFilter(Intent.ACTION_DISPLAY_STATE_CHANGED));
            registerReceiver(mScreenStateReceiver, new IntentFilter(Intent.ACTION_SCREEN_ON));
            registerReceiver(mScreenStateReceiver, new IntentFilter(Intent.ACTION_SCREEN_OFF));
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            if (DEBUG) Log.d(TAG, "onReceive: " + intent.getAction());
            int displayState = getDisplay().getState();
            boolean displayStateAof = displayState != Display.STATE_ON && mIsAofEnabled;
            boolean displayStateDoze = displayState == Display.STATE_DOZE || displayState == Display.STATE_DOZE_SUSPEND;
            if (FileUtils.readLineInt(FOD_PRESS_STATUS_PATH) == 1) {
                if (DEBUG) Log.d(TAG, "onReceive: FOD active, dont update TOUCH_FOD_ENABLE!");
            } else {
                TfWrapper.setTouchFeature(
                        new TfWrapper.TfParams(/*TOUCH_FOD_ENABLE*/ 10, displayStateAof ? 1 : 0));
            }
            TfWrapper.setTouchFeature(
                    new TfWrapper.TfParams(/*TOUCH_AOD_ENABLE*/ 11, displayStateDoze ? 1 : 0));
        }
    }

    private final class SettingsObserver extends ContentObserver {
        SettingsObserver(Handler handler) {
            super(handler);
        }

        public void register() {
            if (DEBUG) Log.d(TAG, "SettingsObserver: register");
            mContentResolver.registerContentObserver(
                    Settings.Secure.getUriFor(SECURE_KEY_TAP), false, this);
            mContentResolver.registerContentObserver(
                    Settings.Secure.getUriFor(SECURE_KEY_UDFPS), false, this);
        }

        void update() {
            boolean st2w = Settings.Secure.getInt(mContentResolver, SECURE_KEY_TAP, 1) != 0;
            boolean udfps = Settings.Secure.getInt(mContentResolver, SECURE_KEY_UDFPS, 0) != 0;
            if (DEBUG) Log.d(TAG, "SettingsObserver: SECURE_KEY_TAP: " + st2w + ", SECURE_KEY_UDFPS: " + udfps);
            mIsAofEnabled = st2w || udfps;
        }

        @Override
        public void onChange(boolean selfChange, Uri uri) {
            if (DEBUG) Log.d(TAG, "SettingsObserver: onChange: " + uri.toString());
            if (uri.equals(Settings.Secure.getUriFor(SECURE_KEY_TAP))
                    || uri.equals(Settings.Secure.getUriFor(SECURE_KEY_UDFPS))) {
                update();
            }
        }
    }
}