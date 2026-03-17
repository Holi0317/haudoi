package com.github.holi0317.haudoi

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import java.util.logging.Logger

class ArchiveActionReceiver : BroadcastReceiver() {
    private val logger = Logger.getLogger(ArchiveActionReceiver::class.java.getName())

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
}
