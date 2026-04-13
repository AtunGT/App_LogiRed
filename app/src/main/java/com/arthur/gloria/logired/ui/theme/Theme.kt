package com.arthur.gloria.logired.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable

private val LightColorScheme = lightColorScheme(
    primary = LogiRedGreen,
    background = LogiRedBackground,
    surface = LogiRedGreenLight,
    onPrimary = androidx.compose.ui.graphics.Color.White,
    onBackground = LogiRedTextPrimary,
    onSurface = LogiRedTextPrimary
)

@Composable
fun LogiRedTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColorScheme,
        typography = LogiRedTypography,
        content = content
    )


}
