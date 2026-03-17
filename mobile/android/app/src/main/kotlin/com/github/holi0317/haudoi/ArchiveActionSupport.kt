package com.github.holi0317.haudoi

import android.content.Context
import androidx.core.content.edit
import org.json.JSONArray
import org.json.JSONObject
import java.util.logging.Logger

private val logger = Logger.getLogger("ArchiveActionSupport")

/**
 * Source of truth for the Android side of the archive callback flow.
 *
 * Data flow:
 * 1. Flutter calls `CustomTabsBridge.openLinkWithArchiveAction`.
 * 2. `MainActivity.openCustomTabWithArchiveAction` opens a custom tab and attaches a
 *    `PendingIntent` targeting `ArchiveActionReceiver`.
 * 3. When the user taps the archive action, the receiver stores an [ArchiveActionEvent]
 *    immediately in [ArchiveActionStore].
 * 4. The receiver resumes [MainActivity]. The event is persisted first so warm start,
 *    cold start, and delayed Flutter initialization all behave the same.
 * 5. Flutter later calls `drainPendingArchiveActions`, and `ArchiveActionWorkerWidget`
 *    turns drained events into app edit operations.
 *
 * Keep the contract keys and persistence shape here so Kotlin and Flutter stay aligned.
 */
internal data class ArchiveActionEvent(val linkId: Int, val url: String? = null) {
    fun toMap(): Map<String, Any> = buildMap {
        put("linkId", linkId)
        url?.let { put("url", it) }
    }

    fun toJson(): JSONObject = JSONObject().apply {
        put(ArchiveActionContract.EXTRA_LINK_ID, linkId)
        url?.let { put(ArchiveActionContract.EXTRA_URL, it) }
    }

    fun summary(): String = "linkId=$linkId url=${url ?: "<null>"}"

    companion object {
        fun fromJson(json: JSONObject): ArchiveActionEvent? {
            val linkId = json.optInt(ArchiveActionContract.EXTRA_LINK_ID, -1)
            if (linkId == -1) {
                logger.warning("drop malformed queued archive event: missing linkId json=$json")
                return null
            }

            val url = json.optString(ArchiveActionContract.EXTRA_URL).takeIf { it.isNotEmpty() }
            return ArchiveActionEvent(linkId = linkId, url = url)
        }
    }
}

internal object ArchiveActionContract {
    const val ACTION_ARCHIVE_LINK = "com.github.holi0317.haudoi.action.ARCHIVE_LINK"
    const val EXTRA_LINK_ID = "linkId"
    const val EXTRA_URL = "url"
}

internal object ArchiveActionStore {
    private const val PREFS_NAME = "custom_tabs_archive_actions"
    private const val KEY_PENDING_ARCHIVE_ACTIONS = "pending_archive_actions"

    @Synchronized
    fun enqueue(context: Context, event: ArchiveActionEvent) {
        val queue = readQueue(context)
        queue.put(event.toJson())
        persistQueue(context, queue)
        logger.fine("queue enqueue ${event.summary()} queueSize=${queue.length()}")
    }

    @Synchronized
    fun drain(context: Context): List<ArchiveActionEvent> {
        val queue = readQueue(context)
        clear(context)

        val drainedEvents = buildList {
            for (index in 0 until queue.length()) {
                val event = queue.optJSONObject(index)?.let(ArchiveActionEvent.Companion::fromJson)
                if (event != null) {
                    add(event)
                }
            }
        }

        logger.fine("queue drain count=${drainedEvents.size}")
        return drainedEvents
    }

    private fun clear(context: Context) {
        prefs(context).edit {
            remove(KEY_PENDING_ARCHIVE_ACTIONS)
        }
    }

    private fun persistQueue(context: Context, queue: JSONArray) {
        prefs(context).edit {
            putString(KEY_PENDING_ARCHIVE_ACTIONS, queue.toString())
        }
    }

    private fun readQueue(context: Context): JSONArray {
        val rawQueue =
            prefs(context).getString(KEY_PENDING_ARCHIVE_ACTIONS, null) ?: return JSONArray()
        return try {
            JSONArray(rawQueue)
        } catch (_: Exception) {
            logger.warning("reset malformed archive queue payload")
            JSONArray()
        }
    }

    private fun prefs(context: Context) =
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
}
