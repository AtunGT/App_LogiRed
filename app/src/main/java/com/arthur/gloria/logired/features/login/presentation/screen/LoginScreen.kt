package com.arthur.gloria.logired.features.login.presentation.screen

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.features.login.presentation.viewmodel.LoginViewModel

@Composable
fun LoginScreen(
    onLoginSuccess: (Int) -> Unit,
    onBack: () -> Unit,
    onForgotPassword: () -> Unit,
    viewModel: LoginViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)
    var passwordVisible by remember { mutableStateOf(false) }
    val context = LocalContext.current

    LaunchedEffect(uiState.loginSuccess) {
        if (uiState.loginSuccess) {
            onLoginSuccess(uiState.userType)
            viewModel.onNavigationHandled()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
            .padding(horizontal = 28.dp)
    ) {
        Spacer(modifier = Modifier.height(56.dp))

        IconButton(onClick = onBack) {
            Icon(Icons.Filled.ArrowBack, contentDescription = null, tint = green)
        }

        Spacer(modifier = Modifier.height(24.dp))

        Text("Bienvenido", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
        Text("Inicia sesión para continuar", fontSize = 15.sp, color = Color(0xFF7A9A8E), modifier = Modifier.padding(top = 6.dp))

        Spacer(modifier = Modifier.height(40.dp))

        OutlinedTextField(
            value         = uiState.email,
            onValueChange = viewModel::onEmailChange,
            label         = { Text("Correo electrónico") },
            leadingIcon   = { Icon(Icons.Filled.Email, null, tint = green) },
            modifier      = Modifier.fillMaxWidth(),
            shape         = RoundedCornerShape(14.dp),
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
            colors        = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = green,
                focusedLabelColor  = green,
                cursorColor        = green
            )
        )

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value         = uiState.password,
            onValueChange = viewModel::onPasswordChange,
            label         = { Text("Contraseña") },
            leadingIcon   = { Icon(Icons.Filled.Lock, null, tint = green) },
            trailingIcon  = {
                IconButton(onClick = { passwordVisible = !passwordVisible }) {
                    Icon(
                        if (passwordVisible) Icons.Filled.VisibilityOff else Icons.Filled.Visibility,
                        contentDescription = if (passwordVisible) "Ocultar" else "Mostrar",
                        tint = green
                    )
                }
            },
            modifier             = Modifier.fillMaxWidth(),
            shape                = RoundedCornerShape(14.dp),
            visualTransformation = if (passwordVisible) VisualTransformation.None else PasswordVisualTransformation(),
            keyboardOptions      = KeyboardOptions(keyboardType = KeyboardType.Password),
            colors               = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = green,
                focusedLabelColor  = green,
                cursorColor        = green
            )
        )

        uiState.error?.let {
            Spacer(modifier = Modifier.height(8.dp))
            Text(it, color = Color.Red, fontSize = 13.sp)
        }

        Spacer(modifier = Modifier.height(32.dp))

        Button(
            onClick  = viewModel::onLoginClick,
            modifier = Modifier.fillMaxWidth().height(52.dp),
            shape    = RoundedCornerShape(14.dp),
            colors   = ButtonDefaults.buttonColors(containerColor = green),
            enabled  = !uiState.isLoading
        ) {
            if (uiState.isLoading) {
                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
            } else {
                Text("Iniciar Sesión", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        TextButton(
            onClick  = onForgotPassword,
            modifier = Modifier.align(Alignment.CenterHorizontally)
        ) {
            Text("¿Olvidaste tu contraseña?", color = green)
        }
    }
}