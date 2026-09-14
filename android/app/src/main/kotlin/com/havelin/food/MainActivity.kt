package com.havelin.food

import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.content.Context
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.havelin.food/vibrate"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "vibrate") {
                val duration = call.argument<Int>("duration") ?: 50
                val amplitude = call.argument<Int>("amplitude") ?: 200
                triggerNativeVibration(duration, amplitude)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun triggerNativeVibration(durationMs: Int, amplitude: Int) {
        try {
            val vibrator = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as VibratorManager
                vibratorManager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }

            if (vibrator.hasVibrator()) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    val safeAmp = amplitude.coerceIn(1, 255)
                    vibrator.vibrate(VibrationEffect.createOneShot(durationMs.toLong(), safeAmp))
                } else {
                    @Suppress("DEPRECATION")
                    vibrator.vibrate(durationMs.toLong())
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
}
