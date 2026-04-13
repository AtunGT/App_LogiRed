package com.arthur.gloria.logired.features.account.presentation.viewmodel

import android.util.Base64
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.local.TokenManager
import com.arthur.gloria.logired.core.network.ApiService
import com.arthur.gloria.logired.features.account.presentation.ui.AccountUiState
import com.google.firebase.auth.FirebaseAuth
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import org.json.JSONObject
import javax.inject.Inject

@HiltViewModel
class AccountViewModel @Inject constructor(
    private val apiService: ApiService,
    private val tokenManager: TokenManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(AccountUiState())
    val uiState: StateFlow<AccountUiState> = _uiState.asStateFlow()

    init {
        loadUser()
    }

    private fun loadUser() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            try {
                val token = tokenManager.token.first() ?: ""
                val userId = extractUserIdFromJwt(token)
                val response = apiService.getUserProfile(userId)
                if (response.isSuccessful) {
                    val user = response.body()
                    _uiState.update {
                        it.copy(
                            isLoading = false,
                            name      = user?.name?.trim() ?: "",
                            lastname  = user?.lastname?.trim() ?: "",
                            email     = user?.email?.trim() ?: "",
                            phone     = user?.number_phone?.trim() ?: "",
                            imageUrl  = user?.image_url?.trim() ?: ""
                        )
                    }
                } else {
                    _uiState.update { it.copy(isLoading = false) }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false) }
            }
        }
    }

    private fun extractUserIdFromJwt(token: String): Int {
        return try {
            val payload = token.split(".")[1]
            val decoded = Base64.decode(payload, Base64.URL_SAFE or Base64.NO_PADDING)
            JSONObject(String(decoded)).optInt("user_id", -1)
        } catch (e: Exception) {
            -1
        }
    }

    fun onLogout() {
        viewModelScope.launch {
            FirebaseAuth.getInstance().signOut()
            tokenManager.clearData()
            _uiState.update { it.copy(loggedOut = true) }
        }
    }
}