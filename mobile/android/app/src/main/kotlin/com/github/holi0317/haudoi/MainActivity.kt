package com.github.holi0317.haudoi

import android.app.PendingIntent
import android.content.Intent
import androidx.browser.customtabs.CustomTabsIntent
import androidx.core.content.res.ResourcesCompat
import androidx.core.graphics.drawable.toBitmap
import androidx.core.net.toUri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.logging.Logger

class MainActivity : FlutterActivity() {
    private val logger = Logger.getLogger(MainActivity::class.java.getName())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Flutter calls into this channel to open a custom tab and later drain queued
        // archive callbacks. For the end-to-end flow, see ArchiveActionSupport.kt.
        logger.fine("configureFlutterEngine register channel=$CHANNEL")
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            logger.fine("channel call method=${call.method}")
            when (call.method) {
                "openLinkWithArchiveAction" -> {
                    val url = call.argument<String>("url")
                    val linkId = call.argument<Int>("linkId")
                    if (url == null || linkId == null) {
                        logger.warning("openLinkWithArchiveAction invalid args url=$url linkId=$linkId")
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Expected non-null url and linkId arguments",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    val event = ArchiveActionEvent(linkId = linkId, url = url)
                    logger.fine("launch custom tab request ${event.summary()}")
                    openCustomTabWithArchiveAction(event)
                    result.success(null)
                }

                "drainPendingArchiveActions" -> {
                    val drainedEvents = ArchiveActionStore.drain(this)
                    logger.fine("bridge drainPendingArchiveActions count=${drainedEvents.size}")
                    result.success(drainedEvents.map(ArchiveActionEvent::toMap))
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun openCustomTabWithArchiveAction(event: ArchiveActionEvent) {
        // The toolbar action does not talk to Flutter directly. It fires a broadcast
        // PendingIntent so Android can enqueue the event even when the app is backgrounded.
        // See ArchiveActionSupport.kt for the full callback flow.
        val archiveIntent = Intent(this, ArchiveActionReceiver::class.java).apply {
            action = ArchiveActionContract.ACTION_ARCHIVE_LINK
            putExtra(ArchiveActionContract.EXTRA_LINK_ID, event.linkId)
            putExtra(ArchiveActionContract.EXTRA_URL, event.url)
        }

        val pendingIntentFlags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        logger.fine("launch custom tab create archive broadcast PendingIntent requestCode=${event.linkId} ${event.summary()}")
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            event.linkId,
            archiveIntent,
            pendingIntentFlags,
        )

        val archiveIcon = ResourcesCompat.getDrawable(
            context.resources,
            R.drawable.ic_archive,
            null
        )!!.toBitmap()

        val customTabsIntent = CustomTabsIntent.Builder()
            .setShowTitle(true)
            .setActionButton(archiveIcon, "Archive", pendingIntent, true)
            .build()

        logger.fine("launch custom tab url=${event.url}")
        customTabsIntent.launchUrl(this, event.url!!.toUri())
    }

    companion object {
        private const val CHANNEL = "com.github.holi0317.haudoi/custom_tabs"
    }
}
