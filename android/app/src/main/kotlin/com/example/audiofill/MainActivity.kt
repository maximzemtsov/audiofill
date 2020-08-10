package com.example.audiofill

import android.Manifest
import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "audiofill/audiorecord";
    private var beginCount = 10;

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        configureAudioSignal();
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAudioSignal") {
                val res = getAudioSignal()

                if (res is String) {
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
         if(! checkPermission()){
            val permissions = arrayOf(android.Manifest.permission.RECORD_AUDIO, android.Manifest.permission.WRITE_EXTERNAL_STORAGE, android.Manifest.permission.READ_EXTERNAL_STORAGE)
            ActivityCompat.requestPermissions(this, permissions, 0)
        }
    }

    private fun checkPermission(): Boolean
    {
        return (ContextCompat.checkSelfPermission(this,
                        Manifest.permission.RECORD_AUDIO) == PackageManager.PERMISSION_GRANTED && ContextCompat.checkSelfPermission(this,
                        Manifest.permission.WRITE_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED)
    }

    private fun configureAudioSignal(): Boolean {
        getPermission()
        beginCount = 7;
        return true;
    }


    private val sampleRate = 44100
    private var bufferSize = 6400 * 2; /// Magical number!
    private val maxAmplitude = 32767 // same as 2^15
    /// Variables (i.e. will change value)
    private var eventSink: EventChannel.EventSink? = null
    private var recording = false

    /**
     * Starts recording and streaming audio data from the mic.
     * Uses a buffer array of size 512. Whenever buffer is full, the content is sent to Flutter.
     *
     *
     * Source:
     * https://www.newventuresoftware.com/blog/record-play-and-visualize-raw-audio-data-in-android
     */
    @SuppressLint("NewApi")
    private fun streamMicData() {
        //Thread(Runnable {
        //    android.os.Process.setThreadPriority(android.os.Process.THREAD_PRIORITY_AUDIO)

            val audioBuffer = ShortArray(bufferSize / 2)
            val record = AudioRecord(
                    MediaRecorder.AudioSource.DEFAULT,
                    sampleRate,
                    AudioFormat.CHANNEL_IN_MONO,
                    AudioFormat.ENCODING_PCM_16BIT,
                    bufferSize)
            if (record.state != AudioRecord.STATE_INITIALIZED) {
                Log.e(null, "Аудио устройстройство захвата звука неактивно")
                //return@Runnable
            }
            /** Start recording loop  */
            record.startRecording()
            recording = true
            while (recording) {
                /** Read data into buffer  */
                record.read(audioBuffer, 0, audioBuffer.size)
                Handler(Looper.getMainLooper()).post {
                    /// Convert to list in order to send via EventChannel.
                    val audioBufferList = ArrayList<Double>()
                    for (impulse in audioBuffer) {
                        val normalizedImpulse = impulse.toDouble() / maxAmplitude.toDouble()
                        Log.i(null, "Impulse value:= ${normalizedImpulse}" )
                        audioBufferList.add(normalizedImpulse)
                    }
                    eventSink!!.success(audioBufferList)
                }

            }
            record.stop()
            record.release()
        //}).start()
    }

    private fun getAudioSignal(): String {
        if(checkPermission())
        {
            streamMicData()
        }
        Log.i(null, "Function AudioSignal is running")
        return "Signal is changed ${(beginCount++)}";
    }
}
