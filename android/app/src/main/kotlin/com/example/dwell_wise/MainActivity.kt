package com.example.dwell_wise

import android.content.pm.PackageManager
import android.util.Log
import androidx.biometric.BiometricManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth's Android BiometricPrompt integration requires a
// FragmentActivity host, so this can't be a plain FlutterActivity.
class MainActivity : FlutterFragmentActivity() {
    // local_auth's Android layer only ever reports the BiometricManager
    // authenticator *strength* class (BIOMETRIC_STRONG / BIOMETRIC_WEAK,
    // surfaced in Dart as BiometricType.strong/.weak) -- Android's
    // BiometricManager API has no public method for "which sensor is this",
    // so BiometricType.fingerprint/.face are never returned on Android.
    // This channel answers "is a fingerprint specifically enrolled" instead.
    //
    // On Samsung phones (verified via `adb shell dumpsys biometric` on a
    // Galaxy M32 running One UI/Android 13), the fingerprint sensor is
    // registered as modality FINGERPRINT at strength STRONG, while Samsung's
    // camera-based face unlock is registered as modality FACE but at a
    // strength Android's own CDD rules push below BIOMETRIC_WEAK (it isn't
    // spoof-resistant enough to qualify) -- so canAuthenticate(BIOMETRIC_
    // STRONG) succeeding is driven by the fingerprint sensor alone whenever
    // a fingerprint is enrolled, even if face is also enrolled. The legacy
    // android.hardware.fingerprint.FingerprintManager / FingerprintManagerCompat
    // API queries a different, older service that Samsung's own
    // "SemFingerprint30" HAL provider does not reliably back, which is why
    // that approach failed on-device even with fingerprints enrolled.
    private val fingerprintChannel = "dwellwise.fingerprint/availability"
    private val logTag = "FingerprintUnlock"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, fingerprintChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasEnrolledFingerprint" -> result.success(hasEnrolledFingerprint())
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasEnrolledFingerprint(): Boolean {
        return try {
            val hasFingerprintHardware =
                packageManager.hasSystemFeature(PackageManager.FEATURE_FINGERPRINT)
            if (!hasFingerprintHardware) {
                Log.d(logTag, "No FEATURE_FINGERPRINT on this device")
                return false
            }

            val biometricManager = BiometricManager.from(applicationContext)
            val canAuthenticateStrong =
                biometricManager.canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)
            val available = canAuthenticateStrong == BiometricManager.BIOMETRIC_SUCCESS
            Log.d(
                logTag,
                "hasFingerprintHardware=$hasFingerprintHardware " +
                    "canAuthenticate(STRONG)=$canAuthenticateStrong available=$available",
            )
            available
        } catch (e: Exception) {
            Log.e(logTag, "hasEnrolledFingerprint failed", e)
            false
        }
    }
}
