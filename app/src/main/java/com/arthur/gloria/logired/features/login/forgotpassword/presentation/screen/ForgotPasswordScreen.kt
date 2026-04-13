package com.arthur.gloria.logired.features.login.forgotpassword.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Email
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.features.login.forgotpassword.presentation.viewmodel.ForgotPasswordViewModel

@Composable
fun ForgotPasswordScreen(
    onBack: () -> Unit,
    viewModel: ForgotPasswordViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)

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

        Text("Recuperar contraseña", fontSize = 26.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
        Text("Te enviaremos un correo para restablecer tu contraseña", fontSize = 14.sp, color = Color(0xFF7A9A8E), modifier = Modifier.padding(top = 6.dp))

        Spacer(modifier = Modifier.height(40.dp))

        if (uiState.emailSent) {
            Box(modifier = Modifier.fillMaxWidth(), contentAlignment = Alignment.Center) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("✅", fontSize = 48.sp)
                    Spacer(modifier = Modifier.height(16.dp))
                    Text("Correo enviado", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = green)
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        "Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.",
                        fontSize = 14.sp,
                        color = Color(0xFF7A9A8E),
                        textAlign = TextAlign.Center
                    )
                    Spacer(modifier = Modifier.height(32.dp))
                    Button(
                        onClick = onBack,
                        shape = RoundedCornerShape(14.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = green)
                    ) {
                        Text("Volver al inicio de sesión")
                    }
                }
            }
        } else {
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

            uiState.error?.let {
                Spacer(modifier = Modifier.height(8.dp))
                Text(it, color = Color.Red, fontSize = 13.sp)
            }

            Spacer(modifier = Modifier.height(32.dp))

            Button(
                onClick  = viewModel::onSendClick,
                modifier = Modifier.fillMaxWidth().height(52.dp),
                shape    = RoundedCornerShape(14.dp),
                colors   = ButtonDefaults.buttonColors(containerColor = green),
                enabled  = !uiState.isLoading
            ) {
                if (uiState.isLoading) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                } else {
                    Text("Enviar correo", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}