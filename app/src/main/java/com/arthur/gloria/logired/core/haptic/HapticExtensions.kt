package com.arthur.gloria.logired.core.haptic

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.platform.LocalContext
import androidx.hilt.navigation.compose.hiltViewModel


@Composable
fun rememberHapticManager(): HapticManager {
    val context = LocalContext.current
    return remember(context) { HapticManager(context) }
}

