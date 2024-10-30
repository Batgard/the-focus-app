package fr.batgard.thefocusapp.core.presentation

interface ResourceMapper<T> {
    fun addEntry(key: String, value: T)
    fun getId(stringId: String): T?
}