package com.arthur.gloria.logired.core.presentation

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.local.TokenManager
import com.arthur.gloria.logired.features.navigation.Screen
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.firstOrNull
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(
    private val tokenManager: TokenManager
) : ViewModel() {

    private val _startDestination = MutableStateFlow<String?>(null)
    val startDestination: StateFlow<String?> = _startDestination.asStateFlow()

    init {
        viewModelScope.launch {
            val token = tokenManager.token.firstOrNull()
            val type  = tokenManager.userType.firstOrNull()

            _startDestination.value = when {
                !token.isNullOrEmpty() && type == 2 -> Screen.DriverMain.route
                !token.isNullOrEmpty() && type == 1 -> Screen.ClientMain.route
                else                                -> Screen.RoleSelection.route
            }
        }
    }

    fun logout() {
        viewModelScope.launch {
            tokenManager.clearData()
        }
    }
}