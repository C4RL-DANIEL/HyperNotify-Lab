package com.hypernotify.lab;

import android.content.Context;
import android.os.Build;

/**
 * HyperNotify Lab - HyperOS / Hyper Island detection helper.
 *
 * Xiaomi's Hyper Island / Super Island runs on top of the standard Android
 * notification system. Xiaomi's launcher (com.miui.home) decides which
 * notifications to promote to the island pill. We detect the Xiaomi / HyperOS
 * environment so the app can tailor notification behavior, and we ensure
 * notifications use importance + priority levels that make island promotion
 * possible (high/critical importance, sound, vibration, heads-up).
 *
 * Note: there is no stable public API to force a notification into Hyper
 * Island. We use the standard Android 16 notification APIs correctly so that
 * HyperOS can promote them, exactly as Xiaomi intends.
 */
public final class HyperOSUtils {

    private static final String XIAOMI_PACKAGE = "com.miui.home";

    private HyperOSUtils() {}

    /** Detect whether this device is a Xiaomi/Redmi/Poco running (Hyper)MIUI. */
    public static boolean isXiaomiDevice() {
        String brand = (Build.BRAND == null ? "" : Build.BRAND.toLowerCase());
        String manufacturer = (Build.MANUFACTURER == null ? "" : Build.MANUFACTURER.toLowerCase());
        return brand.contains("xiaomi")
                || brand.contains("redmi")
                || brand.contains("poco")
                || manufacturer.contains("xiaomi");
    }

    /** Likely HyperOS if Xiaomi hardware AND API 34+ (Android 14+ base of HyperOS 2). */
    public static boolean isHyperOS(Context context) {
        return isXiaomiDevice() && Build.VERSION.SDK_INT >= 34;
    }

    /** Returns a human readable device/OS summary for the UI. */
    public static String deviceSummary() {
        String brand = Build.BRAND == null ? "unknown" : Build.BRAND;
        String model = Build.MODEL == null ? "unknown" : Build.MODEL;
        int sdk = Build.VERSION.SDK_INT;
        String release = Build.VERSION.RELEASE == null ? "unknown" : Build.VERSION.RELEASE;
        return brand + " " + model
                + "\nAndroid " + release + " (API " + sdk + ")"
                + "\n" + (isXiaomiDevice() ? "Xiaomi / HyperOS detected" : "Not a Xiaomi device");
    }
}