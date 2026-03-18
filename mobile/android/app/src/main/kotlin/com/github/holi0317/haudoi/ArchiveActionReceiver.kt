package com.github.holi0317.haudoi

import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import java.util.logging.Logger

/**
 * Receives the archive action callback from chrome custom tabs. See ArchiveActionSupport.kt for the flow and contract.
 */
class ArchiveActionReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent?) {
        logger.fine("callback receiver onReceive action=${intent?.action}")
        if (intent?.action != ArchiveActionContract.ACTION_ARCHIVE_LINK) {
            logger.warning("callback receiver ignore action=${intent?.action}")
            return
        }

        val linkId = intent.getIntExtra(ArchiveActionContract.EXTRA_LINK_ID, -1)
        if (linkId == -1) {
            logger.warning("callback receiver missing linkId action=${intent.action}")
            return
        }

        val event = ArchiveActionEvent(
            linkId = linkId,
            url = intent.getStringExtra(ArchiveActionContract.EXTRA_URL),
        )
        logger.fine("callback receiver received ${event.summary()}")

        // Persist first, then resume the app. Flutter may not be ready yet, so the
        // queue is the real handoff boundary. See ArchiveActionSupport.kt for the flow.
        ArchiveActionStore.enqueue(context, event)

        logger.fine("starting main activity")
        context.startActivity(Intent(context, MainActivity::class.java).apply {
            // NEW_TASK is required from a BroadcastReceiver. MainActivity's singleTask
            // manifest launchMode handles reuse/resume of the existing app task.
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
        })
    }

    companion object {
        private val logger = Logger.getLogger(ArchiveActionReceiver::class.java.getName())

        /**
         * Create a [PendingIntent] for the archive action callback.
         */
        internal fun makePendingIntent(context: Context, event: ArchiveActionEvent): PendingIntent {
            // The toolbar action does not talk to Flutter directly. It fires a broadcast
            // PendingIntent so Android can enqueue the event even when the app is backgrounded.
            // See ArchiveActionSupport.kt for the full callback flow.
            val archiveIntent = Intent(context, ArchiveActionReceiver::class.java).apply {
                action = ArchiveActionContract.ACTION_ARCHIVE_LINK
                putExtra(ArchiveActionContract.EXTRA_LINK_ID, event.linkId)
                putExtra(ArchiveActionContract.EXTRA_URL, event.url)
            }

            logger.fine("launch custom tab create archive broadcast PendingIntent requestCode=${event.linkId} ${event.summary()}")
            return PendingIntent.getBroadcast(
                context,
                event.linkId,
                archiveIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
    }
}
