package com.arthur.gloria.logired.features.login.verifyemail.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.google.firebase.auth.FirebaseAuth
import kotlinx.coroutines.delay
import kotlinx.coroutines.tasks.await

@Composable
fun VerifyEmailScreen(
    email: String,
    onGoToLogin: () -> Unit
) {
    val green   = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)

    LaunchedEffect(Unit) {
        val auth = FirebaseAuth.getInstance()
        while (true) {
            delay(3000)
            try {
                auth.currentUser?.reload()?.await()
                if (auth.currentUser?.isEmailVerified == true) {
                    auth.signOut()
                    onGoToLogin()
                    break
                }
            } catch (e: Exception) {
            }
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Icon(
            Icons.Filled.Email,
            null,
            tint     = green,
            modifier = Modifier.size(80.dp)
        )

        Spacer(Modifier.height(24.dp))

        Text(
            "Verifica tu correo",
            fontSize   = 26.sp,
            fontWeight = FontWeight.Bold,
            color      = Color(0xFF1A1A1A)
        )

        Spacer(Modifier.height(12.dp))

        Text(
            "Enviamos un correo de verificación a:\n$email\n\nRevisa tu bandeja de entrada y haz clic en el enlace para activar tu cuenta.",
            fontSize   = 15.sp,
            color      = Color(0xFF7A9A8E),
            textAlign  = TextAlign.Center,
            lineHeight = 22.sp
        )

        Spacer(Modifier.height(32.dp))

        CircularProgressIndicator(color = green, modifier = Modifier.size(36.dp))

        Spacer(Modifier.height(16.dp))

        Text(
            "Esperando verificación...",
            fontSize = 13.sp,
            color    = Color(0xFF9A9A9A)
        )
    }
}