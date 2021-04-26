package com.qiscus.qiscus_meet

import android.app.KeyguardManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.res.Configuration
import android.os.Build
import android.os.Bundle
import android.util.Log
import android.view.WindowManager
import com.qiscus.qiscus_meet.QiscusMeetPlugin.Companion.QISCUS_MEETING_CLOSE
import com.qiscus.qiscus_meet.QiscusMeetPlugin.Companion.QISCUS_PLUGIN_TAG
import org.jitsi.meet.sdk.JitsiMeetActivity
import org.jitsi.meet.sdk.JitsiMeetConferenceOptions
import java.util.HashMap

/**
 * Activity extending JitsiMeetActivity in order to override the conference events
 */
class QiscusMeetPluginActivity : JitsiMeetActivity() {
    companion object {
        @JvmStatic
        fun launchActivity(context: Context?,
                           options: JitsiMeetConferenceOptions) {
            var intent = Intent(context, QiscusMeetPluginActivity::class.java).apply {
                action = "org.jitsi.meet.CONFERENCE"
                putExtra("JitsiMeetConferenceOptions", options)
            }
            context?.startActivity(intent)
        }
    }

    var onStopCalled: Boolean = false;

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration?) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)

        if (isInPictureInPictureMode){
            QiscusMeetEventStreamHandler.instance.onPictureInPictureWillEnter()
        }
        else {
            QiscusMeetEventStreamHandler.instance.onPictureInPictureTerminated()
        }

        if (isInPictureInPictureMode == false && onStopCalled) {
            // Picture-in-Picture mode has been closed, we can (should !) end the call
            getJitsiView().leave()
        }
    }

    private val myReceiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            when (intent?.action) {
               QISCUS_MEETING_CLOSE -> finish()
            }
        }
    }

    override fun onStop() {
        super.onStop()
        onStopCalled = true;
        unregisterReceiver(myReceiver)
    }

    override fun onResume() {
        super.onResume()
        onStopCalled = false
        registerReceiver(myReceiver, IntentFilter(QISCUS_MEETING_CLOSE))
    }

//    override fun onConferenceWillJoin(data: MutableMap<String, Any>?) {
//
//        super.onConferenceWillJoin(data)
//    }

    override fun onConferenceWillJoin(extraData: HashMap<String, Any>?) {
        Log.d(QISCUS_PLUGIN_TAG, String.format("JitsiMeetPluginActivity.onConferenceWillJoin: %s", extraData))
        QiscusMeetEventStreamHandler.instance.onConferenceWillJoin(extraData)
        super.onConferenceWillJoin(extraData)
    }
//    override fun onConferenceJoined(data: MutableMap<String, Any>?) {
//        Log.d(JITSI_PLUGIN_TAG, String.format("JitsiMeetPluginActivity.onConferenceJoined: %s", data))
//        JitsiMeetEventStreamHandler.instance.onConferenceJoined(data)
//        super.onConferenceJoined(data)
//    }

    override fun onConferenceJoined(extraData: HashMap<String, Any>?) {
        Log.d(QISCUS_PLUGIN_TAG, String.format("JitsiMeetPluginActivity.onConferenceJoined: %s", extraData))
        QiscusMeetEventStreamHandler.instance.onConferenceJoined(extraData)
        super.onConferenceJoined(extraData)
    }

    override fun onConferenceTerminated(extraData: HashMap<String, Any>?) {
        Log.d(QISCUS_PLUGIN_TAG, String.format("JitsiMeetPluginActivity.onConferenceTerminated: %s", extraData))
        QiscusMeetEventStreamHandler.instance.onConferenceTerminated(extraData)
        super.onConferenceTerminated(extraData)
    }
     override fun onParticipantJoined(extraData: HashMap<String, Any>?) {
        Log.d(QISCUS_PLUGIN_TAG, String.format("JitsiMeetPluginActivity.onParticipantJoined: %s", extraData))
        QiscusMeetEventStreamHandler.instance.onParticipantJoined(extraData)
        super.onParticipantJoined(extraData)
    }
     override fun onParticipantLeft(extraData: HashMap<String, Any>?) {
        Log.d(QISCUS_PLUGIN_TAG, String.format("JitsiMeetPluginActivity.onParticipantLeft: %s", extraData))
        QiscusMeetEventStreamHandler.instance.onParticipantLeft(extraData)
        super.onParticipantLeft(extraData)
    }

//    override fun onConferenceTerminated(data: MutableMap<String, Any>?) {
//
//        Log.d(JITSI_PLUGIN_TAG, String.format("JitsiMeetPluginActivity.onConferenceTerminated: %s", data))
//        JitsiMeetEventStreamHandler.instance.onConferenceTerminated(data)
//        super.onConferenceTerminated(data)
//    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        turnScreenOnAndKeyguardOff();
    }

    override fun onDestroy() {
        super.onDestroy()
        turnScreenOffAndKeyguardOn();
    }

    private fun turnScreenOnAndKeyguardOff() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            // For newer than Android Oreo: call setShowWhenLocked, setTurnScreenOn
            setShowWhenLocked(true)
            setTurnScreenOn(true)

            // If you want to display the keyguard to prompt the user to unlock the phone:
            val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
            keyguardManager?.requestDismissKeyguard(this, null)
        } else {
            // For older versions, do it as you did before.
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                    or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                    or WindowManager.LayoutParams.FLAG_FULLSCREEN
                    or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                    or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                    or WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON)
        }
    }

    private fun turnScreenOffAndKeyguardOn() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        } else {
            window.clearFlags(
                    WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                            or WindowManager.LayoutParams.FLAG_FULLSCREEN
                            or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                            or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                            or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                            or WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
            )
        }
    }
}
