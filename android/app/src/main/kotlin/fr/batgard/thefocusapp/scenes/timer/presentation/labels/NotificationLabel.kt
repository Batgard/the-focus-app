package fr.batgard.thefocusapp.scenes.timer.presentation.labels

enum class NotificationLabel(val resourceId: String) {
    ACTION_PAUSE("notification_action_title_pause"),
    ACTION_RESUME("notification_action_title_resume"),
    BODY_POMODORO("notification_body_pomodoro"),
    BODY_SHORT_BREAK("notification_body_short_break"),
    BODY_LONG_BREAK("notification_body_long_break"),
    BODY_ACTIVITY_PAUSED("notification_body_paused"),
    BODY_ACTIVITY_ON_GOING("notification_body_on_going")
}