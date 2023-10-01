/*
 * Copyright (C) 2023 Paranoid Android
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
import android.os.SystemProperties;
import android.os.UserHandle;
import android.provider.Settings.Secure;
import android.util.Log;

public class AlwaysOnFingerprintService extends Service {

    private static final String TAG = "XiaomiPartsAlwaysOnFingerprintService";
    private static final boolean DEBUG = true;

    private static final String SECURE_KEY_TAP = "doze_tap_gesture";
    private static final String SECURE_KEY_UDFPS = "screen_off_udfps_enabled";

    private static boolean mIsAofEnabled = false;

    private Context mContext;
    private Handler mHandler;
    private ContentResolver mContentResolver;
    private CustomBroadcastReceiver mCustomBroadcastReceiver;
    private CustomSettingsObserver mCustomSettingsObserver;

    @Override
    public void onCreate() {
        if (DEBUG) Log.d(TAG, "Creating service");
        mContentResolver = getContentResolver();
        mHandler = new Handler(Looper.getMainLooper());
        mCustomBroadcastReceiver = new CustomBroadcastReceiver();
        mCustomSettingsObserver = new CustomSettingsObserver(mHandler);
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startid) {
        if (DEBUG) Log.d(TAG, "Starting service");
        mCustomBroadcastReceiver.register();
        mCustomSettingsObserver.register();
        mCustomSettingsObserver.update();
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

    private class CustomBroadcastReceiver extends BroadcastReceiver {
        CustomBroadcastReceiver() {
            super();
        }

        public void register() {
            if (DEBUG) Log.d(TAG, "CustomBroadcastReceiver: register");
            registerReceiver(mCustomBroadcastReceiver, new IntentFilter(Intent.ACTION_SCREEN_ON));
            registerReceiver(mCustomBroadcastReceiver, new IntentFilter(Intent.ACTION_SCREEN_OFF));
        }

        void update(boolean enable) {
            if (DEBUG) Log.d(TAG, "CustomSettingsObserver: update");
            SystemProperties.set("persist.sys.fuxi.alwaysonudfps", enable ? "1" : "0");
        }

        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(Intent.ACTION_SCREEN_ON)) {
                if (DEBUG) Log.d(TAG, "CustomBroadcastReceiver: ACTION_SCREEN_ON");
                update(false);
            } else if (intent.getAction().equals(Intent.ACTION_SCREEN_OFF)) {
                if (DEBUG) Log.d(TAG, "CustomBroadcastReceiver: ACTION_SCREEN_OFF");
                update(mIsAofEnabled);
            }
        }
    }

    private class CustomSettingsObserver extends ContentObserver {
        CustomSettingsObserver(Handler handler) {
            super(handler);
        }

        public void register() {
            if (DEBUG) Log.d(TAG, "CustomSettingsObserver: register");
            mContentResolver.registerContentObserver(Secure.getUriFor(SECURE_KEY_TAP), false, this);
            mContentResolver.registerContentObserver(Secure.getUriFor(SECURE_KEY_UDFPS), false, this);
        }

        void update() {
            if (DEBUG) Log.d(TAG, "CustomSettingsObserver: update");
            boolean st2w = Secure.getInt(mContentResolver, SECURE_KEY_TAP, 0) != 0;
            boolean udfps = Secure.getInt(mContentResolver, SECURE_KEY_UDFPS, 0) != 0;
            if (DEBUG) Log.d(TAG, "CustomSettingsObserver: SECURE_KEY_TAP: " + st2w + ", SECURE_KEY_UDFPS: " + udfps);
            mIsAofEnabled = st2w || udfps;
        }

        @Override
        public void onChange(boolean selfChange, Uri uri) {
            if (DEBUG) Log.d(TAG, "CustomSettingsObserver: onChange: " + uri.toString());
            if (uri.equals(Secure.getUriFor(SECURE_KEY_TAP))
                    || uri.equals(Secure.getUriFor(SECURE_KEY_UDFPS))) {
                update();
            }
        }
    }
}