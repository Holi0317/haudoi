package com.github.holi0317.haudoi

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import java.util.logging.Logger

class ArchiveActionActivity : Activity() {
    private val logger = Logger.getLogger(ArchiveActionActivity::class.java.getName())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        logger.fine("callback activity onCreate action=${intent?.action}")
        handleArchiveAction(intent)
        finish()
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        logger.fine("callback activity onNewIntent action=${intent.action}")
        handleArchiveAction(intent)
        finish()
    }

    private fun handleArchiveAction(intent: Intent?) {
        if (intent?.action != ArchiveActionContract.ACTION_ARCHIVE_LINK) {
            logger.warning("callback activity ignore action=${intent?.action}")
            return
        }

        val linkId = intent.getIntExtra(ArchiveActionContract.EXTRA_LINK_ID, -1)
        if (linkId == -1) {
            logger.warning("callback activity missing linkId action=${intent.action}")
            return
        }

        val event = ArchiveActionEvent(
            linkId = linkId,
            url = intent.getStringExtra(ArchiveActionContract.EXTRA_URL),
        )
        logger.fine("callback activity received ${event.summary()}")

        ArchiveActionStore.enqueue(this, event)

        logger.fine("callback activity hand off to MainActivity ${event.summary()}")
        startActivity(Intent(this, MainActivity::class.java))
    }
}
