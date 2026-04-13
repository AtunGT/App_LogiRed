package com.arthur.gloria.logired.features.account.presentation.ui

data class AccountUiState(
    val name: String = "",
    val lastname: String = "",
    val email: String = "",
    val phone: String = "",
    val imageUrl: String = "",
    val isLoading: Boolean = false,
    val loggedOut: Boolean = false
)