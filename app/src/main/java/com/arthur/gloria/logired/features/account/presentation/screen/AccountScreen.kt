package com.arthur.gloria.logired.features.account.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Logout
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.SubcomposeAsyncImage
import com.arthur.gloria.logired.features.account.presentation.viewmodel.AccountViewModel
import com.google.accompanist.swiperefresh.SwipeRefresh
import com.google.accompanist.swiperefresh.SwipeRefreshIndicator
import com.google.accompanist.swiperefresh.rememberSwipeRefreshState

@Composable
fun AccountScreen(
    onLogout: () -> Unit,
    onEditAccount: () -> Unit,
    onChangePassword: () -> Unit,
    viewModel: AccountViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)
    val swipeRefreshState = rememberSwipeRefreshState(isRefreshing = uiState.isLoading)
    var showLogoutDialog by remember { mutableStateOf(false) }

    LaunchedEffect(uiState.loggedOut) {
        if (uiState.loggedOut) onLogout()
    }

    if (showLogoutDialog) {
        AlertDialog(
            onDismissRequest = { showLogoutDialog = false },
            title = { Text("Cerrar sesión") },
            text  = { Text("¿Estás seguro que deseas cerrar sesión?") },
            confirmButton = {
                TextButton(onClick = { viewModel.onLogout() }) {
                    Text("Cerrar sesión", color = Color.Red)
                }
            },
            dismissButton = {
                TextButton(onClick = { showLogoutDialog = false }) {
                    Text("Cancelar", color = green)
                }
            }
        )
    }

    SwipeRefresh(
        state     = swipeRefreshState,
        onRefresh = { viewModel.loadUser() },
        indicator = { state, trigger ->
            SwipeRefreshIndicator(state = state, refreshTriggerDistance = trigger, contentColor = green)
        },
        modifier  = Modifier.fillMaxSize()
    ) {
        LazyColumn(
            modifier            = Modifier
                .fillMaxSize()
                .background(bgColor),
            contentPadding      = PaddingValues(horizontal = 24.dp, vertical = 48.dp),
            verticalArrangement = Arrangement.spacedBy(0.dp)
        ) {
            item {
                Column(
                    modifier            = Modifier.fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                Text("Mi cuenta", fontSize = 26.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A), modifier = Modifier.fillMaxWidth())

                Spacer(modifier = Modifier.height(32.dp))

                Box(
                    modifier = Modifier
                        .size(90.dp)
                        .clip(CircleShape)
                ) {
                    SubcomposeAsyncImage(
                        model              = uiState.imageUrl.ifBlank { null },
                        contentDescription = "Foto de perfil",
                        contentScale       = ContentScale.Crop,
                        modifier           = Modifier.fillMaxSize(),
                        loading = {
                            Box(
                                modifier = Modifier.fillMaxSize().background(Color.Gray),
                                contentAlignment = Alignment.Center
                            ) {
                                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                            }
                        },
                        error = {
                            Box(
                                modifier = Modifier.fillMaxSize().background(green),
                                contentAlignment = Alignment.Center
                            ) {
                                Icon(Icons.Filled.Person, contentDescription = null, tint = Color.White, modifier = Modifier.size(50.dp))
                            }
                        }
                    )
                }

                Spacer(modifier = Modifier.height(12.dp))

                Text(
                    text       = "${uiState.name} ${uiState.lastname}",
                    fontSize   = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color      = Color(0xFF1A1A1A),
                    modifier   = Modifier.fillMaxWidth(),
                    textAlign  = androidx.compose.ui.text.style.TextAlign.Center
                )

                Spacer(modifier = Modifier.height(32.dp))

                AccountInfoRow(icon = Icons.Filled.Email, label = "Correo",   value = uiState.email)
                Spacer(modifier = Modifier.height(12.dp))
                AccountInfoRow(icon = Icons.Filled.Phone, label = "Teléfono", value = uiState.phone)

                Spacer(modifier = Modifier.height(40.dp))

                Button(
                    onClick  = onEditAccount,
                    modifier = Modifier.fillMaxWidth().height(52.dp),
                    shape    = RoundedCornerShape(14.dp),
                    colors   = ButtonDefaults.buttonColors(containerColor = green)
                ) {
                    Text("Editar cuenta", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                }

                Spacer(modifier = Modifier.height(12.dp))

                OutlinedButton(
                    onClick  = onChangePassword,
                    modifier = Modifier.fillMaxWidth().height(52.dp),
                    shape    = RoundedCornerShape(14.dp),
                    colors   = ButtonDefaults.outlinedButtonColors(contentColor = green),
                    border   = androidx.compose.foundation.BorderStroke(1.dp, green)
                ) {
                    Icon(Icons.Filled.Lock, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Cambiar contraseña", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                }

                Spacer(modifier = Modifier.height(12.dp))

                OutlinedButton(
                    onClick  = { showLogoutDialog = true },
                    modifier = Modifier.fillMaxWidth().height(52.dp),
                    shape    = RoundedCornerShape(14.dp),
                    colors   = ButtonDefaults.outlinedButtonColors(contentColor = Color.Red),
                    border   = androidx.compose.foundation.BorderStroke(1.dp, Color.Red)
                ) {
                    Icon(Icons.Filled.Logout, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text("Cerrar sesión", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                }
                }
            }
        }
    }
}

@Composable
private fun AccountInfoRow(icon: ImageVector, label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(12.dp))
            .background(Color.White)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Icon(icon, contentDescription = null, tint = Color(0xFF1E7A5E), modifier = Modifier.size(22.dp))
        Spacer(modifier = Modifier.width(12.dp))
        Column {
            Text(label, fontSize = 12.sp, color = Color(0xFF7A9A8E))
            Text(value.ifBlank { "—" }, fontSize = 15.sp, fontWeight = FontWeight.Medium, color = Color(0xFF1A1A1A))
        }
    }
}