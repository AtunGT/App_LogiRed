package com.arthur.gloria.logired.features.roleselection.presentation.screen

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.DirectionsCar
import androidx.compose.material.icons.filled.Login
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.R
import com.arthur.gloria.logired.features.roleselection.presentation.viewmodel.RoleSelectionViewModel

@Composable
fun RoleSelectionScreen(
    onClientSelected: () -> Unit,
    onDriverSelected: () -> Unit,
    onLoginSelected: () -> Unit,
    viewModel: RoleSelectionViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(uiState.navigateToClient) {
        if (uiState.navigateToClient) {
            onClientSelected()
            viewModel.onNavigationHandled()
        }
    }
    LaunchedEffect(uiState.navigateToDriver) {
        if (uiState.navigateToDriver) {
            onDriverSelected()
            viewModel.onNavigationHandled()
        }
    }
    LaunchedEffect(uiState.navigateToLogin) {
        if (uiState.navigateToLogin) {
            onLoginSelected()
            viewModel.onNavigationHandled()
        }
    }

    val green = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
            .padding(horizontal = 28.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.weight(1f))

        Image(
            painter = painterResource(id = R.drawable.logo_sin_fondo),
            contentDescription = "Logo LogiRed",
            modifier = Modifier
                .size(200.dp)
                .clip(RoundedCornerShape(22.dp)),
            contentScale = ContentScale.Fit
        )

        Spacer(modifier = Modifier.height(20.dp))

        Text(
            text = "LogiRed",
            fontSize = 32.sp,
            fontWeight = FontWeight.Bold,
            color = Color(0xFF1A1A1A)
        )
        Text(
            text = "Logística moderna y confiable",
            fontSize = 15.sp,
            color = Color(0xFF7A9A8E),
            modifier = Modifier.padding(top = 6.dp)
        )

        Spacer(modifier = Modifier.weight(1f))

        Card(
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(20.dp),
            colors = CardDefaults.cardColors(containerColor = Color.White),
            elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
        ) {
            Column(modifier = Modifier.padding(8.dp)) {
                RoleItem(
                    icon = Icons.Filled.Person,
                    title = "Soy Cliente",
                    subtitle = "Solicita tu mudanza o transporte",
                    accentColor = green,
                    onClick = viewModel::onClientSelected
                )
                HorizontalDivider(
                    modifier = Modifier.padding(horizontal = 16.dp),
                    color = Color(0xFFEEEEEE)
                )
                RoleItem(
                    icon = Icons.Filled.DirectionsCar,
                    title = "Soy Conductor",
                    subtitle = "Gana dinero transportando",
                    accentColor = green,
                    onClick = viewModel::onDriverSelected
                )
                HorizontalDivider(
                    modifier = Modifier.padding(horizontal = 16.dp),
                    color = Color(0xFFEEEEEE)
                )
                RoleItem(
                    icon = Icons.Filled.Login,
                    title = "Iniciar Sesión",
                    subtitle = "Ya tengo una cuenta",
                    accentColor = green,
                    onClick = viewModel::onLoginSelected
                )
            }
        }

        Spacer(modifier = Modifier.weight(1f))


    }
}

@Composable
private fun RoleItem(
    icon: ImageVector,
    title: String,
    subtitle: String,
    accentColor: Color,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 18.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(48.dp)
                .clip(RoundedCornerShape(14.dp))
                .background(accentColor.copy(alpha = 0.12f)),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = accentColor,
                modifier = Modifier.size(26.dp)
            )
        }
        Spacer(modifier = Modifier.width(16.dp))
        Column {
            Text(
                text = title,
                fontSize = 17.sp,
                fontWeight = FontWeight.SemiBold,
                color = Color(0xFF1A1A1A)
            )
            Text(
                text = subtitle,
                fontSize = 13.sp,
                color = Color(0xFF8A9A94),
                modifier = Modifier.padding(top = 2.dp)
            )
        }
    }
}