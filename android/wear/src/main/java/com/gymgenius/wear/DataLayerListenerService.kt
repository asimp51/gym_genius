package com.gymgenius.wear

import com.google.android.gms.wearable.*
import org.json.JSONObject

/**
 * Listens for data and messages sent from the phone app via the
 * Google Play Services Wearable DataLayer API.
 *
 * The phone Flutter app uses a platform channel that writes to the
 * DataLayer; this service picks up those changes and forwards them
 * to the watch UI via a simple in-memory event bus.
 */
class DataLayerListenerService : WearableListenerService() {

    companion object {
        // Paths used for DataLayer communication.
        const val PATH_WORKOUT_STATE = "/workout_state"
        const val PATH_TEMPLATES = "/sync_templates"
        const val PATH_REST_TIMER = "/rest_timer_start"
        const val PATH_WORKOUT_COMPLETE = "/workout_complete"
        const val PATH_SET_COMPLETED = "/set_completed"
        const val PATH_HEART_RATE = "/heart_rate_update"

        // Simple in-memory event bus so the Compose UI can observe changes.
        // In a production app you would use a proper state management solution.
        var currentWorkoutState: WorkoutState? = null
            private set
        var templates: List<TemplateInfo> = emptyList()
            private set

        private val listeners = mutableListOf<() -> Unit>()

        fun addListener(listener: () -> Unit) {
            listeners.add(listener)
        }

        fun removeListener(listener: () -> Unit) {
            listeners.remove(listener)
        }

        private fun notifyListeners() {
            listeners.forEach { it() }
        }
    }

    override fun onDataChanged(dataEvents: DataEventBuffer) {
        for (event in dataEvents) {
            if (event.type == DataEvent.TYPE_CHANGED) {
                val item = event.dataItem
                when (item.uri.path) {
                    PATH_WORKOUT_STATE -> handleWorkoutState(item)
                    PATH_TEMPLATES -> handleTemplates(item)
                    PATH_WORKOUT_COMPLETE -> handleWorkoutComplete(item)
                }
            }
        }
        notifyListeners()
    }

    override fun onMessageReceived(event: MessageEvent) {
        val data = String(event.data)
        when (event.path) {
            PATH_REST_TIMER -> {
                val json = JSONObject(data)
                val duration = json.optInt("duration", 90)
                currentWorkoutState = currentWorkoutState?.copy(
                    isResting = true,
                    restSecondsRemaining = duration
                )
                notifyListeners()
            }
        }
    }

    private fun handleWorkoutState(item: DataItem) {
        val map = DataMapItem.fromDataItem(item).dataMap
        currentWorkoutState = WorkoutState(
            workoutName = map.getString("workoutName") ?: "",
            currentExercise = map.getString("currentExercise") ?: "",
            currentSet = map.getInt("currentSet"),
            totalSets = map.getInt("totalSets"),
            elapsedSeconds = map.getInt("elapsedSeconds"),
            isResting = map.getBoolean("isResting"),
            restSecondsRemaining = map.getInt("restSecondsRemaining")
        )
    }

    private fun handleTemplates(item: DataItem) {
        val map = DataMapItem.fromDataItem(item).dataMap
        val templatesJson = map.getString("templates") ?: "[]"
        // Parse templates JSON array.
        try {
            val arr = org.json.JSONArray(templatesJson)
            val list = mutableListOf<TemplateInfo>()
            for (i in 0 until arr.length()) {
                val obj = arr.getJSONObject(i)
                list.add(
                    TemplateInfo(
                        id = obj.optString("id", ""),
                        name = obj.optString("name", ""),
                        description = obj.optString("description", "")
                    )
                )
            }
            templates = list
        } catch (_: Exception) {}
    }

    private fun handleWorkoutComplete(item: DataItem) {
        currentWorkoutState = null
    }
}

/**
 * Represents the current state of an active workout, synced from the phone.
 */
data class WorkoutState(
    val workoutName: String,
    val currentExercise: String,
    val currentSet: Int,
    val totalSets: Int,
    val elapsedSeconds: Int,
    val isResting: Boolean,
    val restSecondsRemaining: Int
)

/**
 * A workout template synced from the phone for standalone selection.
 */
data class TemplateInfo(
    val id: String,
    val name: String,
    val description: String
)
