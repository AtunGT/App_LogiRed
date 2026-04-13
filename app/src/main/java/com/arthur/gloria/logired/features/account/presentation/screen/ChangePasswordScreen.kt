package com.arthur.gloria.logired.features.account.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.features.account.presentation.viewmodel.ChangePasswordViewModel

@Composable
fun ChangePasswordScreen(
    onBack: () -> Unit,
    viewModel: ChangePasswordViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)
    var oldVisible by remember { mutableStateOf(false) }
    var newVisible by remember { mutableStateOf(false) }
    var confirmVisible by remember { mutableStateOf(false) }

    LaunchedEffect(uiState.success) {
        if (uiState.success) onBack()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
            .padding(horizontal = 24.dp)
    ) {
        Spacer(modifier = Modifier.height(48.dp))

        IconButton(onClick = onBack) {
            Icon(Icons.Filled.ArrowBack, contentDescription = null, tint = green)
        }

        Spacer(modifier = Modifier.height(8.dp))

        Text("Cambiar contraseña", fontSize = 26.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
        Text("Ingresa tu contraseña actual y la nueva", fontSize = 14.sp, color = Color(0xFF7A9A8E), modifier = Modifier.padding(top = 6.dp))

        Spacer(modifier = Modifier.height(32.dp))

        PasswordField(
            label       = "Contraseña actual",
            value       = uiState.oldPassword,
            visible     = oldVisible,
            onToggle    = { oldVisible = !oldVisible },
            onValueChange = viewModel::onOldPasswordChange,
            green       = green
        )

        Spacer(modifier = Modifier.height(16.dp))

        PasswordField(
            label       = "Nueva contraseña",
            value       = uiState.newPassword,
            visible     = newVisible,
            onToggle    = { newVisible = !newVisible },
            onValueChange = viewModel::onNewPasswordChange,
            green       = green
        )

        Spacer(modifier = Modifier.height(16.dp))

        PasswordField(
            label       = "Confirmar nueva contraseña",
            value       = uiState.confirmPassword,
            visible     = confirmVisible,
            onToggle    = { confirmVisible = !confirmVisible },
            onValueChange = viewModel::onConfirmPasswordChange,
            green       = green
        )

        uiState.error?.let {
            Spacer(modifier = Modifier.height(8.dp))
            Text(it, color = Color.Red, fontSize = 13.sp)
        }

        Spacer(modifier = Modifier.height(32.dp))

        Button(
            onClick  = viewModel::onSaveClick,
            modifier = Modifier.fillMaxWidth().height(52.dp),
            shape    = RoundedCornerShape(14.dp),
            colors   = ButtonDefaults.buttonColors(containerColor = green),
            enabled  = !uiState.isLoading
        ) {
            if (uiState.isLoading) {
                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
            } else {
                Text("Guardar contraseña", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
            }
        }
    }
}

@Composable
private fun PasswordField(
    label: String,
    value: String,
    visible: Boolean,
    onToggle: () -> Unit,
    onValueChange: (String) -> Unit,
    green: Color
) {
    OutlinedTextField(
        value         = value,
        onValueChange = onValueChange,
        label         = { Text(label) },
        leadingIcon   = { Icon(Icons.Filled.Lock, null, tint = green) },
        trailingIcon  = {
            IconButton(onClick = onToggle) {
                Icon(
                    if (visible) Icons.Filled.VisibilityOff else Icons.Filled.Visibility,
                    contentDescription = null,
                    tint = green
                )
            }
        },
        modifier             = Modifier.fillMaxWidth(),
        shape                = RoundedCornerShape(14.dp),
        visualTransformation = if (visible) VisualTransformation.None else PasswordVisualTransformation(),
        keyboardOptions      = KeyboardOptions(keyboardType = KeyboardType.Password),
        colors               = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = green,
            focusedLabelColor  = green,
            cursorColor        = green
        )
    )
}