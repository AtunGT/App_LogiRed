package com.arthur.gloria.logired.features.trip.accepted.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.features.trip.accepted.presentation.viewmodel.AcceptedTripsViewModel
import com.arthur.gloria.logired.ui.components.TripCard

@Composable
fun AcceptedTripsScreen(
    onBack: () -> Unit = {},
    onViewMap: (Int) -> Unit = {},
    onViewActiveTrip: (Int) -> Unit = {},
    viewModel: AcceptedTripsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
    ) {
        Surface(color = Color.White, shadowElevation = 2.dp) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onBack) {
                    Icon(Icons.Filled.ArrowBack, null, tint = green)
                }
                Spacer(Modifier.width(8.dp))
                Text("Mis Viajes Aceptados", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
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
                    Text(uiState.error ?: "Error desconocido", color = Color.Red, fontSize = 16.sp)
                    Spacer(Modifier.height(24.dp))
                    Button(onClick = viewModel::loadTrips, colors = ButtonDefaults.buttonColors(containerColor = green)) {
                        Text("Reintentar")
                    }
                }
            }
            uiState.trips.isEmpty() -> {
                Column(
                    Modifier.fillMaxSize().padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Icon(Icons.Filled.CheckCircle, null, tint = Color(0xFF8A9A94), modifier = Modifier.size(80.dp))
                    Spacer(Modifier.height(16.dp))
                    Text("No tienes viajes aceptados", fontSize = 18.sp, fontWeight = FontWeight.Medium, color = Color(0xFF1A1A1A))
                    Spacer(Modifier.height(8.dp))
                    Text("Busca viajes disponibles y acéptalos", fontSize = 14.sp, color = Color(0xFF8A9A94))
                }
            }
            else -> {
                LazyColumn(
                    Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(uiState.trips) { trip ->
                        TripCard(trip = trip)
                        Spacer(Modifier.height(8.dp))
                        when (trip.status) {
                            1, 2, 3 -> {
                                Button(
                                    onClick  = { onViewActiveTrip(trip.id) },
                                    modifier = Modifier.fillMaxWidth().height(44.dp),
                                    shape    = RoundedCornerShape(10.dp),
                                    colors   = ButtonDefaults.buttonColors(containerColor = green)
                                ) {
                                    Icon(Icons.Filled.Navigation, null, modifier = Modifier.size(18.dp))
                                    Spacer(Modifier.width(8.dp))
                                    Text(
                                        if (trip.status == 1) "Iniciar viaje" else "Ver viaje activo",
                                        fontSize = 15.sp, fontWeight = FontWeight.SemiBold
                                    )
                                }
                            }
                            else -> {
                                OutlinedButton(
                                    onClick  = { onViewMap(trip.id) },
                                    modifier = Modifier.fillMaxWidth(),
                                    shape    = RoundedCornerShape(10.dp)
                                ) {
                                    Icon(Icons.Filled.Map, null, Modifier.size(16.dp))
                                    Spacer(Modifier.width(6.dp))
                                    Text("Ver en mapa")
                                }
                            }
                        }
                        Spacer(Modifier.height(4.dp))
                    }
                }
            }
        }
    }
}