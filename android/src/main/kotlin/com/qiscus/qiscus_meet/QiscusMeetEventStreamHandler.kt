package com.qiscus.qiscus_meet

import android.util.Log
import com.qiscus.qiscus_meet.QiscusMeetPlugin.Companion.QISCUS_PLUGIN_TAG
import io.flutter.plugin.common.EventChannel
import java.io.Serializable

/**
 * StreamHandler to listen to conference events and broadcast it back to Flutter
 */
class QiscusMeetEventStreamHandler private constructor() : EventChannel.StreamHandler, Serializable {
    companion object {
        val instance = QiscusMeetEventStreamHandler()
    }

    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
        Log.d(QISCUS_PLUGIN_TAG, "QiscusMeetEventStreamHandler.onListen")
        this.eventSink = eventSink
    }

    override fun onCancel(arguments: Any?) {
        Log.d(QISCUS_PLUGIN_TAG, "QiscusMeetEventStreamHandler.onCancel")
        eventSink = null
    }

    fun onConferenceWillJoin(data: MutableMap<String, Any>?) {
        Log.d(QISCUS_PLUGIN_TAG, "QiscusMeetEventStreamHandler.onConferenceWillJoin")
        data?.put("event", "onConferenceWillJoin")
        eventSink?.success(data)
    }

    fun onConferenceJoined(data: MutableMap<String, Any>?) {
        Log.d(QISCUS_PLUGIN_TAG, "QiscusMeetEventStreamHandler.onConferenceJoined")
        data?.put("event", "onConferenceJoined")
        eventSink?.success(data)
    }

    fun onConferenceTerminated(data: MutableMap<String, Any>?) {
        Log.d(QISCUS_PLUGIN_TAG, "QiscusMeetEventStreamHandler.onConferenceTerminated")
        data?.put("event", "onConferenceTerminated")
        eventSink?.success(data)
    }

    fun onPictureInPictureWillEnter() {
        Log.d(QISCUS_PLUGIN_TAG, "QiscusMeetEventStreamHandler.onPictureInPictureWillEnter")
        var data: HashMap<String, String> = HashMap<String, String>()
        data?.put("event", "onPictureInPictureWillEnter")
        eventSink?.success(data)
    }

    fun onPictureInPictureTerminated() {
        Log.d(QISCUS_PLUGIN_TAG, "QiscusMeetEventStreamHandler.onPictureInPictureTerminated")
        var data: HashMap<String, String> = HashMap<String, String>()
        data?.put("event", "onPictureInPictureTerminated")
        eventSink?.success(data)
    }

}