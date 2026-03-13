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


private data class ArchiveActionEvent(val linkId: Int, val url: String? = null) {
    fun toMap(): Map<String, Any> = buildMap {
        put("linkId", linkId)
        url?.let { put("url", it) }
    }
}

class MainActivity : FlutterActivity() {
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        )

        methodChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "openLinkWithArchiveAction" -> {
                    val url = call.argument<String>("url")
                    val linkId = call.argument<Int>("linkId")
                    if (url == null || linkId == null) {
                        result.error(
                            "INVALID_ARGUMENTS",
                            "Expected non-null url and linkId arguments",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    val event = ArchiveActionEvent(linkId = linkId, url = url)

                    openCustomTabWithArchiveAction(event)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        processArchiveIntent(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        processArchiveIntent(intent)
    }

    private fun openCustomTabWithArchiveAction(event: ArchiveActionEvent) {
        val archiveIntent = Intent(this, MainActivity::class.java).apply {
            action = ACTION_ARCHIVE_LINK
            putExtra(EXTRA_LINK_ID, event.linkId)
            putExtra(EXTRA_URL, event.url)
            addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        val pendingIntentFlags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE

        val pendingIntent = PendingIntent.getActivity(
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

        customTabsIntent.intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        customTabsIntent.launchUrl(this, event.url!!.toUri())
    }

    private fun processArchiveIntent(intent: Intent?) {
        if (intent?.action != ACTION_ARCHIVE_LINK) {
            return
        }

        val linkId = intent.getIntExtra(EXTRA_LINK_ID, -1)
        if (linkId == -1) {
            return
        }

        val payload = ArchiveActionEvent(
            linkId = linkId,
            url = intent.getStringExtra(EXTRA_URL),
        )

        dispatchArchiveAction(payload)

        // Clear action to avoid duplicate handling if the activity is recreated.
        intent.action = null
    }

    private fun dispatchArchiveAction(payload: ArchiveActionEvent) {
        val channel = methodChannel
            ?: throw IllegalStateException("MethodChannel is not initialized. Cannot dispatch archive action.")

        channel.invokeMethod("onArchiveAction", payload.toMap())
    }

    companion object {
        private const val CHANNEL = "com.github.holi0317.haudoi/custom_tabs"
        private const val ACTION_ARCHIVE_LINK = "com.github.holi0317.haudoi.action.ARCHIVE_LINK"
        private const val EXTRA_LINK_ID = "linkId"
        private const val EXTRA_URL = "url"
    }
}
