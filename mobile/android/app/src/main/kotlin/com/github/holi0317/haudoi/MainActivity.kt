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
                "openLink" -> {
                    val event: ArchiveActionEvent

                    val archiveButton = call.argument<Boolean>("archiveButton") ?: false

                    try {
                        event = ArchiveActionEvent.fromMethodCall(call)
                    } catch (e: IllegalArgumentException) {
                        logger.warning("openLink invalid args ${e.message}")
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Expected url and linkId arguments: ${e.message}",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    logger.fine("launch custom tab request $event")
                    openCustomTab(event, archiveButton)
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

    private fun openCustomTab(event: ArchiveActionEvent, archiveButton: Boolean) {
        val pendingIntent = ArchiveActionReceiver.makePendingIntent(this, event)

        var builder = CustomTabsIntent.Builder()
            .setShowTitle(true)

        if (archiveButton) {
            val archiveIcon = ResourcesCompat.getDrawable(
                context.resources,
                R.drawable.ic_archive,
                null
            )!!.toBitmap()

            builder = builder.setActionButton(archiveIcon, "Archive", pendingIntent, true)
        }

        logger.fine("launch custom tab url=${event.url}")
        builder.build().launchUrl(this, event.url!!.toUri())
    }

    companion object {
        private const val CHANNEL = "com.github.holi0317.haudoi/custom_tabs"
    }
}
