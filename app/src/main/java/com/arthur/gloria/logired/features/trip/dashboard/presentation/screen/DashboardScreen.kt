package com.arthur.gloria.logired.features.trip.dashboard.presentation.screen

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.LocalShipping
import androidx.compose.material.icons.filled.Place
import androidx.compose.material.icons.filled.Scale
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.ui.unit.sp
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.features.trip.dashboard.presentation.ui.DashboardUiState
import com.arthur.gloria.logired.features.trip.dashboard.presentation.viewmodel.DashboardViewModel

@Composable
fun DashboardScreen(
    userType: Int,
    viewModel: DashboardViewModel = hiltViewModel<DashboardViewModel>()
) {
    val uiState: DashboardUiState by viewModel.uiState.collectAsState()

    LaunchedEffect(userType) { viewModel.loadStats(userType) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
    ) {
        Surface(color = Color(0xFF1E7A5E), shadowElevation = 2.dp) {
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Dashboard",
                        fontSize = 22.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color.White
                    )
                    Text(
                        text = if (userType == 1) "Resumen de tus mudanzas" else "Tu actividad como conductor",
                        fontSize = 13.sp,
                        color = Color.White.copy(alpha = 0.8f)
                    )
                }
                Box(modifier = Modifier.size(48.dp))
            }
        }

        if (uiState.isLoading) {
            Box(Modifier.fillMaxWidth().height(200.dp), Alignment.Center) {
                CircularProgressIndicator()
            }
            return@Column
        }

        if (uiState.error != null) {
            Box(Modifier.fillMaxWidth().height(200.dp), Alignment.Center) {
                Text(uiState.error!!, color = MaterialTheme.colorScheme.error)
            }
            return@Column
        }

        Spacer(Modifier.height(16.dp))

        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            KpiCard(Modifier.weight(1f), "Total", uiState.totalTrips.toString(), Icons.Filled.LocalShipping, MaterialTheme.colorScheme.primary)
            KpiCard(Modifier.weight(1f), "Completadas", uiState.completedTrips.toString(), Icons.Filled.CheckCircle, MaterialTheme.colorScheme.secondary)
        }

        Spacer(Modifier.height(24.dp))

        Card(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            elevation = CardDefaults.cardElevation(2.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("Estado de mudanzas", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
                Spacer(Modifier.height(16.dp))
                StatusBarChart(uiState)
            }
        }

        Spacer(Modifier.height(24.dp))

        Card(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp),
            elevation = CardDefaults.cardElevation(2.dp)
        ) {
            Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text("Detalles", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold)
                InfoRow("Pendientes", uiState.pendingTrips.toString())
                InfoRow("Aceptadas", uiState.acceptedTrips.toString())
                InfoRow("Canceladas", uiState.cancelledTrips.toString())
                InfoRow("Último viaje", uiState.lastTripDate)
            }
        }

        Spacer(Modifier.height(24.dp))
    }
}

@Composable
private fun KpiCard(modifier: Modifier, label: String, value: String, icon: ImageVector, color: Color) {
    Card(
        modifier = modifier,
        elevation = CardDefaults.cardElevation(2.dp),
        colors = CardDefaults.cardColors(containerColor = color.copy(alpha = 0.1f))
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Icon(icon, null, tint = color, modifier = Modifier.size(24.dp))
            Spacer(Modifier.height(8.dp))
            Text(value, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold, color = color)
            Text(label, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }
}

@Composable
private fun InfoRow(label: String, value: String) {
    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween) {
        Text(label, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
        Text(value, style = MaterialTheme.typography.bodyMedium, fontWeight = FontWeight.Medium)
    }
}

@Composable
private fun StatusBarChart(uiState: DashboardUiState) {
    val bars = listOf(
        Triple("Pendientes", uiState.pendingTrips, Color(0xFFFF9800)),
        Triple("Aceptados", uiState.acceptedTrips, Color(0xFF2196F3)),
        Triple("Completados", uiState.completedTrips, Color(0xFF4CAF50)),
        Triple("Cancelados", uiState.cancelledTrips, Color(0xFFF44336))
    )
    val maxVal = (bars.maxOfOrNull { it.second } ?: 0).coerceAtLeast(1)

    Column {
        bars.forEach { (label, count, color) ->
            Row(verticalAlignment = Alignment.CenterVertically, modifier = Modifier.padding(vertical = 4.dp)) {
                Text(label, Modifier.width(90.dp), style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                Canvas(Modifier.weight(1f).height(20.dp)) {
                    val fraction = count.toFloat() / maxVal
                    drawRect(color = color.copy(alpha = 0.2f), size = size)
                    drawRect(color = color, topLeft = Offset.Zero, size = Size(size.width * fraction, size.height))
                }
                Text("  $count", style = MaterialTheme.typography.bodySmall, fontWeight = FontWeight.SemiBold, color = color, modifier = Modifier.width(28.dp))
            }
        }
    }
}