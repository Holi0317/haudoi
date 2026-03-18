package com.github.holi0317.haudoi

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
                    val event: ArchiveActionEvent

                    try {
                        event = ArchiveActionEvent.fromMethodCall(call)
                    } catch (e: IllegalArgumentException) {
                        logger.warning("openLinkWithArchiveAction invalid args ${e.message}")
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Expected url and linkId arguments: ${e.message}",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    logger.fine("launch custom tab request $event")
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
        val pendingIntent = ArchiveActionReceiver.makePendingIntent(this, event)

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
