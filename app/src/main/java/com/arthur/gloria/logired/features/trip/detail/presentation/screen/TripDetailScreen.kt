package com.arthur.gloria.logired.features.trip.detail.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.features.trip.detail.presentation.viewmodel.TripDetailViewModel

@Composable
fun TripDetailScreen(
    tripId: Int,
    onBack: () -> Unit,
    onViewMap: (Int) -> Unit,
    viewModel: TripDetailViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green   = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)

    LaunchedEffect(tripId) { viewModel.loadTrip(tripId) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
    ) {
        Surface(color = Color.White, shadowElevation = 2.dp) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 8.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onBack) {
                    Icon(Icons.Filled.ArrowBack, null, tint = green)
                }
                Text("Detalle del Viaje", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
            }
        }

        when {
            uiState.isLoading -> {
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = green)
                }
            }
            uiState.error != null -> {
                Column(
                    Modifier.fillMaxSize().padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Icon(Icons.Filled.ErrorOutline, null, tint = Color.Red, modifier = Modifier.size(64.dp))
                    Spacer(Modifier.height(16.dp))
                    Text(uiState.error!!, color = Color.Red, fontSize = 16.sp)
                    Spacer(Modifier.height(16.dp))
                    Button(onClick = { viewModel.loadTrip(tripId) }, colors = ButtonDefaults.buttonColors(containerColor = green)) {
                        Text("Reintentar")
                    }
                }
            }
            uiState.trip != null -> {
                val trip = uiState.trip!!

                val statusLabel = when (trip.status) {
                    1 -> "Agendado"; 2 -> "En camino"; 3 -> "En proceso"
                    4 -> "Cancelado"; 5 -> "Completado"; 6 -> "Publicado"
                    else -> "Estado ${trip.status}"
                }
                val statusBg = when (trip.status) {
                    1 -> Color(0xFFCFE2FF); 2 -> Color(0xFFE8F5F0); 3 -> Color(0xFFFFF3CD)
                    4 -> Color(0xFFFFE0E0); 5 -> Color(0xFFE8F5F0); 6 -> Color(0xFFFFF3CD)
                    else -> Color.LightGray
                }
                val statusColor = when (trip.status) {
                    1 -> Color(0xFF084298); 2 -> green; 3 -> Color(0xFF856404)
                    4 -> Color.Red; 5 -> green; 6 -> Color(0xFF856404)
                    else -> Color.DarkGray
                }

                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .verticalScroll(rememberScrollState())
                        .padding(horizontal = 20.dp)
                ) {
                    Spacer(Modifier.height(20.dp))

                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween,
                        verticalAlignment = Alignment.Top
                    ) {
                        Column {
                            Text("Viaje", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
                            Text("ID: ${trip.id}", fontSize = 12.sp, color = Color(0xFF8A9A94))
                        }
                        Surface(shape = RoundedCornerShape(8.dp), color = statusBg) {
                            Text(
                                statusLabel,
                                modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Medium,
                                color = statusColor
                            )
                        }
                    }

                    Spacer(Modifier.height(24.dp))

                    SectionCard(title = "Ubicacion", green = green) {
                        DetailRow(Icons.Filled.LocationOn, "Origen", trip.origin.ifBlank { "—" }, green)
                        Spacer(Modifier.height(4.dp))
                        DetailRow(Icons.Filled.LocationCity, "Ciudad", trip.origin_city.ifBlank { "—" }, green)
                        HorizontalDivider(modifier = Modifier.padding(vertical = 12.dp), color = Color(0xFFF0F0F0))
                        DetailRow(Icons.Filled.Flag, "Destino", trip.destination.ifBlank { "—" }, green)
                    }

                    Spacer(Modifier.height(12.dp))

                    SectionCard(title = "Fecha y hora", green = green) {
                        DetailRow(Icons.Filled.CalendarMonth, "Fecha", trip.date.take(10).ifBlank { "—" }, green)
                        Spacer(Modifier.height(4.dp))
                        DetailRow(Icons.Filled.Schedule, "Hora", trip.hour.ifBlank { "—" }, green)
                    }

                    Spacer(Modifier.height(12.dp))

                    SectionCard(title = "Carga", green = green) {
                        DetailRow(Icons.Filled.Scale, "Peso aprox.", "${trip.approx_weight} kg", green)
                        if (trip.description.isNotBlank()) {
                            Spacer(Modifier.height(4.dp))
                            DetailRow(Icons.Filled.Description, "Descripción", trip.description, green)
                        }
                    }

                    Spacer(Modifier.height(24.dp))

                    Button(
                        onClick  = { onViewMap(trip.id) },
                        modifier = Modifier.fillMaxWidth().height(52.dp),
                        shape    = RoundedCornerShape(14.dp),
                        colors   = ButtonDefaults.buttonColors(containerColor = green)
                    ) {
                        Icon(Icons.Filled.Map, null, modifier = Modifier.size(20.dp))
                        Spacer(Modifier.width(8.dp))
                        Text("Ver en mapa", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                    }

                    Spacer(Modifier.height(32.dp))
                }
            }
        }
    }
}

@Composable
private fun SectionCard(title: String, green: Color, content: @Composable ColumnScope.() -> Unit) {
    Card(
        modifier  = Modifier.fillMaxWidth(),
        shape     = RoundedCornerShape(14.dp),
        colors    = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(title, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = green)
            Spacer(Modifier.height(10.dp))
            content()
        }
    }
}

@Composable
private fun DetailRow(icon: ImageVector, label: String, value: String, green: Color) {
    Row(verticalAlignment = Alignment.Top) {
        Icon(icon, null, tint = green, modifier = Modifier.size(18.dp).padding(top = 2.dp))
        Spacer(Modifier.width(10.dp))
        Column {
            Text(label, fontSize = 11.sp, color = Color(0xFF8A9A94))
            Text(value, fontSize = 14.sp, color = Color(0xFF1A1A1A), fontWeight = FontWeight.Medium)
        }
    }
}