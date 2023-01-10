/*
 * Copyright (C) 2018 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.lineageos.settings.powershare;

import android.content.Context;
import android.os.Bundle;
import androidx.preference.Preference;
import androidx.preference.Preference.OnPreferenceChangeListener;
import androidx.preference.PreferenceFragment;
import androidx.preference.SwitchPreference;

import org.lineageos.settings.R;
import org.lineageos.settings.utils.FileUtils;

public class PowerShareSettingsFragment extends PreferenceFragment implements
        OnPreferenceChangeListener {

    private SwitchPreference mPowerSharePreference;
    private static final String POWERSHARE_ENABLE_KEY = "powershare_enable";
    private static final String POWERSHARE_NODE = "/sys/class/power_supply/wireless/reverse_chg_mode";

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        addPreferencesFromResource(R.xml.powershare_settings);
        mPowerSharePreference = (SwitchPreference) findPreference(POWERSHARE_ENABLE_KEY);
        mPowerSharePreference.setEnabled(true);
        mPowerSharePreference.setOnPreferenceChangeListener(this);
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        if (POWERSHARE_ENABLE_KEY.equals(preference.getKey())) {
            FileUtils.writeLine(POWERSHARE_NODE, (Boolean) newValue ? "1":"0");
        }
        return true;
    }
}
