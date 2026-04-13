package com.arthur.gloria.logired.features.roleselection.presentation.viewmodel

import androidx.lifecycle.ViewModel
import com.arthur.gloria.logired.features.roleselection.presentation.ui.RoleSelectionUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import javax.inject.Inject

@HiltViewModel
class RoleSelectionViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(RoleSelectionUiState())
    val uiState: StateFlow<RoleSelectionUiState> = _uiState.asStateFlow()

    fun onClientSelected() {
        _uiState.update { it.copy(navigateToClient = true) }
    }

    fun onDriverSelected() {
        _uiState.update { it.copy(navigateToDriver = true) }
    }

    fun onLoginSelected() {
        _uiState.update { it.copy(navigateToLogin = true) }
    }

    fun onNavigationHandled() {
        _uiState.update {
            it.copy(
                navigateToClient = false,
                navigateToDriver = false,
                navigateToLogin = false
            )
        }
    }
}