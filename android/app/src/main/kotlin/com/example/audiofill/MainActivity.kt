package com.example.audiofill

import android.Manifest
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.math.abs
import kotlin.math.log

class MainActivity : FlutterActivity() {
    private val CHANNEL = "8t61YpeA5stzji20ibgyRUSbt29LWH56ea0VZdk5lxoaUzGwoMKfiSdVyAaD";

    override fun onDestroy() {
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        configureAudioSignal();
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (checkPermission())
                if (call.method == "getSignalLevel") {
                    val res = getSignalLevel();

                    if (res is Double) {
                        result.success(res)
                    } else {
                        result.error("ERROR", "Не верный тип выходных данных.", null)
                    }
                } else {
                    result.notImplemented()
                }
        }
    }

    private fun getPermission() {
        if (!checkPermission()) {
            val permissions = arrayOf(android.Manifest.permission.RECORD_AUDIO, android.Manifest.permission.WRITE_EXTERNAL_STORAGE, android.Manifest.permission.READ_EXTERNAL_STORAGE)
            ActivityCompat.requestPermissions(this, permissions, 0)
        }
    }

    private fun checkPermission(): Boolean {
        return (ContextCompat.checkSelfPermission(this,
                Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(this,
                Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED)
    }

    private fun configureAudioSignal(): Boolean {
        getPermission()
        return true;
    }

    //private var record: AudioRecord? = null
    private val sampleRate = 44100
    private var bufferSize = 6400 * 2; /// Magical number!
    private val maxAmplitude = 32767 // same as 2^15

    private fun getSignalLevel(): Double {
        var record: AudioRecord? = null
        if(checkPermission())
        {
            val audioSource = MediaRecorder.AudioSource.VOICE_RECOGNITION;
            val channelConfig = AudioFormat.CHANNEL_IN_MONO
            bufferSize = AudioRecord.getMinBufferSize(sampleRate,AudioFormat.CHANNEL_IN_MONO,AudioFormat.ENCODING_PCM_16BIT)
            val audioFormat = AudioFormat.ENCODING_PCM_16BIT;
            record = AudioRecord(audioSource,sampleRate,channelConfig,audioFormat,bufferSize)
            if (record.state != AudioRecord.STATE_INITIALIZED) {
                Log.e("OUT", "Аудио устройстройство захвата звука неактивно")
                return 0.0
            }
            record.startRecording()
            Thread.sleep(10L)
            val audioBuffer = ShortArray(bufferSize)
            if(record.read(audioBuffer, 0, audioBuffer.size) < 0) return 0.0
            record.stop()
            record.release()
            var _out: Double = 0.0
            var _sum: Double = 0.0
            val _maxA: Double = (0x8000).toDouble()
            for(tik in audioBuffer)
                _sum += abs(tik.toDouble())
            _out = _sum/audioBuffer.size.toDouble()
            _out = 20.0 * log( _out/_maxA,10.0)
            Log.i("OUT","size: ${audioBuffer.size},sum: ${_sum},min: ${audioBuffer.min()},max: ${audioBuffer.max()},ret: ${_out} ")
            return _out
        }
        
        return 0.0
    }
}

