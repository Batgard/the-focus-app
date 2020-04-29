package fr.batgard.thefocusapp.core.presentation

import android.content.res.Resources

interface StringResourceProvider {
    fun getSimple(resourceId: String): String
}

class StringResourceProviderImpl(
        private val resourceProvider: Resources,
        private val resourceMapper: ResourceMapper<Int>
) : StringResourceProvider {
    
    override fun getSimple(resourceId: String): String {
        val resource = resourceMapper.getId(resourceId)
        resource?.let {
            return resourceProvider.getString(it)
        } ?: throw IllegalArgumentException("$resourceId does not match entry entry in the mapper")
    }
    
}