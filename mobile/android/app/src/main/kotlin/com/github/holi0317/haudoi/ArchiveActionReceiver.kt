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
        ArchiveActionStore.enqueue(context, event)
    }
}

