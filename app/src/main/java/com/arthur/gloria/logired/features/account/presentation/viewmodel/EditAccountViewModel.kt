package com.arthur.gloria.logired.features.account.presentation.viewmodel

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Base64
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.local.TokenManager
import com.arthur.gloria.logired.core.network.ApiService
import dagger.hilt.android.lifecycle.HiltViewModel
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import okhttp3.MediaType.Companion.toMediaTypeOrNull
import okhttp3.MultipartBody
import okhttp3.RequestBody
import okhttp3.RequestBody.Companion.asRequestBody
import okhttp3.RequestBody.Companion.toRequestBody
import org.json.JSONObject
import java.io.File
import java.io.FileOutputStream
import javax.inject.Inject

data class EditAccountUiState(
    val name: String = "",
    val lastname: String = "",
    val email: String = "",
    val phone: String = "",
    val birthdate: String = "",
    val citywork: String = "",
    val userType: Int = 1,
    val imageUri: Uri? = null,
    val isLoading: Boolean = false,
    val error: String? = null,
    val success: Boolean = false
)

@HiltViewModel
class EditAccountViewModel @Inject constructor(
    private val apiService: ApiService,
    private val tokenManager: TokenManager,
    @ApplicationContext private val context: Context
) : ViewModel() {

    private val _uiState = MutableStateFlow(EditAccountUiState())
    val uiState: StateFlow<EditAccountUiState> = _uiState.asStateFlow()

    private var userId = -1

    init { loadUser() }

    private fun loadUser() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            try {
                val token = tokenManager.token.first() ?: ""
                userId = extractUserIdFromJwt(token)
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
                            birthdate = user?.birthdate?.take(10) ?: "",
                            citywork  = user?.driver_info?.citywork ?: "",
                            userType  = user?.user_type ?: 1
                        )
                    }
                } else {
                    _uiState.update { it.copy(isLoading = false) }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = e.message) }
            }
        }
    }

    fun onNameChange(v: String)      = _uiState.update { it.copy(name = v) }
    fun onLastnameChange(v: String)  = _uiState.update { it.copy(lastname = v) }
    fun onEmailChange(v: String)     = _uiState.update { it.copy(email = v) }
    fun onPhoneChange(v: String)     = _uiState.update { it.copy(phone = v) }
    fun onBirthdateChange(v: String) = _uiState.update { it.copy(birthdate = v) }
    fun onCityworkChange(v: String)  = _uiState.update { it.copy(citywork = v) }
    fun onImageSelected(uri: Uri)    = _uiState.update { it.copy(imageUri = uri) }

    fun onSaveClick() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            val s = uiState.value
            try {
                val imagePart = s.imageUri?.let { uri ->
                    val inputStream = context.contentResolver.openInputStream(uri)
                    val bitmap = BitmapFactory.decodeStream(inputStream)
                    val file = File(context.cacheDir, "upload_${System.currentTimeMillis()}.jpg")
                    FileOutputStream(file).use { out -> bitmap.compress(Bitmap.CompressFormat.JPEG, 60, out) }
                    MultipartBody.Part.createFormData("image", file.name, file.asRequestBody("image/jpeg".toMediaTypeOrNull()))
                }

                val response = apiService.updateUser(
                    id          = userId,
                    name        = s.name.toTextBody(),
                    lastname    = s.lastname.toTextBody(),
                    birthdate   = s.birthdate.toTextBody(),
                    numberphone = s.phone.toTextBody(),
                    email       = s.email.toTextBody(),
                    image       = imagePart,
                    citywork    = if (s.userType == 2) s.citywork.toTextBody() else null
                )

                if (response.isSuccessful) {
                    _uiState.update { it.copy(isLoading = false, success = true) }
                } else {
                    _uiState.update { it.copy(isLoading = false, error = "Error al actualizar") }
                }
            } catch (e: Exception) {
                _uiState.update { it.copy(isLoading = false, error = e.message) }
            }
        }
    }

    private fun extractUserIdFromJwt(token: String): Int {
        return try {
            val payload = token.split(".")[1]
            val decoded = Base64.decode(payload, Base64.URL_SAFE or Base64.NO_PADDING)
            JSONObject(String(decoded)).optInt("user_id", -1)
        } catch (e: Exception) { -1 }
    }

    private fun String.toTextBody(): RequestBody =
        this.toRequestBody("text/plain".toMediaTypeOrNull())
}