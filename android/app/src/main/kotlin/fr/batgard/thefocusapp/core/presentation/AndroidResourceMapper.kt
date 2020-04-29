package fr.batgard.thefocusapp.core.presentation

class AndroidResourceMapper: ResourceMapper<Int> {

    private val map = mutableMapOf<String, Int>()

    override fun addEntry(key: String, value: Int) {
        map[key] = value
    }

    override fun getId(stringId: String): Int? = map[stringId]
}