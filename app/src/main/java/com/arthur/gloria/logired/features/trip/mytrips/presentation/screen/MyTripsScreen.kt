package com.arthur.gloria.logired.features.trip.mytrips.presentation.screen

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
import com.arthur.gloria.logired.core.network.model.Trip
import com.google.accompanist.swiperefresh.SwipeRefresh
import com.google.accompanist.swiperefresh.SwipeRefreshIndicator
import com.google.accompanist.swiperefresh.rememberSwipeRefreshState
import com.arthur.gloria.logired.features.trip.mytrips.presentation.viewmodel.MyTripsViewModel
import kotlinx.coroutines.delay

@Composable
fun MyTripsScreen(
    onBack: () -> Unit = {},
    onViewDetails: (Int) -> Unit = {},
    onViewProposals: (Int) -> Unit = {},
    onViewActiveTrip: (Int) -> Unit = {},
    viewModel: MyTripsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green   = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)

    if (uiState.showCancelDialog != null) {
        AlertDialog(
            onDismissRequest = viewModel::hideCancelDialog,
            title = { Text("Cancelar viaje", fontWeight = FontWeight.Bold) },
            text  = { Text("¿Estás seguro de que deseas cancelar este viaje? Esta acción no se puede deshacer.") },
            confirmButton = {
                TextButton(onClick = { viewModel.cancelTrip(uiState.showCancelDialog!!) }) {
                    Text("Cancelar viaje", color = Color.Red)
                }
            },
            dismissButton = {
                TextButton(onClick = viewModel::hideCancelDialog) {
                    Text("Mantener", color = green)
                }
            }
        )
    }

    Column(modifier = Modifier.fillMaxSize().background(bgColor)) {
        Surface(color = green, shadowElevation = 2.dp) {
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("Mis Viajes", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    Text("Tus mudanzas solicitadas", fontSize = 13.sp, color = Color.White.copy(alpha = 0.8f))
                }
                Box(modifier = Modifier.size(48.dp))
            }
        }

        uiState.successMessage?.let {
            LaunchedEffect(it) {
                delay(2000)
                viewModel.clearMessages()
            }
            Card(
                modifier = Modifier.fillMaxWidth().padding(16.dp),
                colors   = CardDefaults.cardColors(containerColor = Color(0xFF4CAF50).copy(alpha = 0.15f))
            ) {
                Row(Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Filled.CheckCircle, null, tint = Color(0xFF4CAF50), modifier = Modifier.size(20.dp))
                    Spacer(Modifier.width(8.dp))
                    Text(it, color = Color(0xFF2E7D32), fontWeight = FontWeight.Medium)
                }
            }
        }

        val swipeRefreshState = rememberSwipeRefreshState(isRefreshing = uiState.isLoading)

        SwipeRefresh(
            state     = swipeRefreshState,
            onRefresh = { viewModel.loadTrips() },
            indicator = { state, trigger ->
                SwipeRefreshIndicator(state = state, refreshTriggerDistance = trigger, contentColor = green)
            },
            modifier = Modifier.fillMaxSize()
        ) {
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
                        Icon(
                            Icons.Filled.ErrorOutline,
                            null,
                            tint = Color.Red,
                            modifier = Modifier.size(64.dp)
                        )
                        Spacer(Modifier.height(16.dp))
                        Text(uiState.error!!, color = Color.Red, fontSize = 16.sp)
                        Spacer(Modifier.height(24.dp))
                        Button(
                            onClick = viewModel::loadTrips,
                            colors = ButtonDefaults.buttonColors(containerColor = green)
                        ) {
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
                        Icon(
                            Icons.Filled.LocalShipping,
                            null,
                            tint = Color(0xFF8A9A94),
                            modifier = Modifier.size(80.dp)
                        )
                        Spacer(Modifier.height(16.dp))
                        Text(
                            "No tienes viajes solicitados",
                            fontSize = 18.sp,
                            fontWeight = FontWeight.Medium,
                            color = Color(0xFF1A1A1A)
                        )
                        Spacer(Modifier.height(8.dp))
                        Text(
                            "Solicita tu primer viaje de mudanza",
                            fontSize = 14.sp,
                            color = Color(0xFF8A9A94)
                        )
                    }
                }

                else -> {
                    LazyColumn(
                        Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        items(uiState.trips, key = { it.id }) { trip ->
                            MyTripCard(
                                trip = trip,
                                green = green,
                                onViewDetails = { onViewDetails(trip.id) },
                                onViewProposals = { onViewProposals(trip.id) },
                                onViewActiveTrip = { onViewActiveTrip(trip.id) },
                                onCancel = { viewModel.showCancelDialog(trip.id) },
                                proposalCount = uiState.proposalCounts[trip.id] ?: 0
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun MyTripCard(
    trip: Trip,
    green: Color,
    onViewDetails: () -> Unit,
    onViewProposals: () -> Unit,
    onViewActiveTrip: () -> Unit,
    onCancel: () -> Unit,
    proposalCount: Int
) {
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
    val canCancel = trip.status == 6 || trip.status == 1

    Card(
        modifier  = Modifier.fillMaxWidth(),
        shape     = RoundedCornerShape(16.dp),
        colors    = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Surface(shape = RoundedCornerShape(8.dp), color = statusBg) {
                    Text(
                        statusLabel,
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                        color = statusColor
                    )
                }
            }

            Spacer(Modifier.height(12.dp))

            Row(verticalAlignment = Alignment.Top) {
                Icon(Icons.Filled.LocationOn, null, tint = green, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(6.dp))
                Column {
                    Text("Origen", fontSize = 11.sp, color = Color(0xFF8A9A94))
                    Text(trip.origin.ifBlank { "—" }, fontSize = 13.sp, color = Color(0xFF1A1A1A), fontWeight = FontWeight.Medium)
                }
            }

            Spacer(Modifier.height(8.dp))

            Row(verticalAlignment = Alignment.Top) {
                Icon(Icons.Filled.Flag, null, tint = green, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(6.dp))
                Column {
                    Text("Destino", fontSize = 11.sp, color = Color(0xFF8A9A94))
                    Text(trip.destination.ifBlank { "—" }, fontSize = 13.sp, color = Color(0xFF1A1A1A), fontWeight = FontWeight.Medium)
                }
            }

            Spacer(Modifier.height(8.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Filled.CalendarMonth, null, tint = green, modifier = Modifier.size(14.dp))
                Spacer(Modifier.width(4.dp))
                Text(trip.date.take(10).ifBlank { "—" }, fontSize = 12.sp, color = Color(0xFF1A1A1A))
                Spacer(Modifier.width(12.dp))
                Icon(Icons.Filled.Schedule, null, tint = green, modifier = Modifier.size(14.dp))
                Spacer(Modifier.width(4.dp))
                Text(trip.hour.take(5).ifBlank { "—" }, fontSize = 12.sp, color = Color(0xFF1A1A1A))
            }

            Spacer(Modifier.height(14.dp))

            when (trip.status) {
                6 -> {
                    Button(
                        onClick  = onViewProposals,
                        modifier = Modifier.fillMaxWidth().height(42.dp),
                        shape    = RoundedCornerShape(10.dp),
                        colors   = ButtonDefaults.buttonColors(containerColor = Color(0xFF1A5276))
                    ) {
                        Icon(Icons.Filled.LocalOffer, null, modifier = Modifier.size(16.dp))
                        Spacer(Modifier.width(6.dp))
                        Text(
                            if (proposalCount > 0) "Ver ofertas disponibles ($proposalCount)" else "Ver ofertas disponibles",
                            fontSize = 13.sp, fontWeight = FontWeight.SemiBold
                        )
                    }
                }
                1, 2, 3 -> {
                    Button(
                        onClick  = onViewActiveTrip,
                        modifier = Modifier.fillMaxWidth().height(42.dp),
                        shape    = RoundedCornerShape(10.dp),
                        colors   = ButtonDefaults.buttonColors(containerColor = green)
                    ) {
                        Icon(Icons.Filled.Navigation, null, modifier = Modifier.size(16.dp))
                        Spacer(Modifier.width(6.dp))
                        Text(
                            when (trip.status) {
                                1    -> "Ver viaje agendado"
                                2    -> "Ver conductor en tiempo real"
                                else -> "Ver progreso del viaje"
                            },
                            fontSize = 13.sp, fontWeight = FontWeight.SemiBold
                        )
                    }
                }
            }

            Spacer(Modifier.height(8.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                OutlinedButton(
                    onClick  = onViewDetails,
                    modifier = Modifier.weight(1f),
                    shape    = RoundedCornerShape(10.dp),
                    colors   = ButtonDefaults.outlinedButtonColors(contentColor = green)
                ) {
                    Icon(Icons.Filled.Info, null, modifier = Modifier.size(15.dp))
                    Spacer(Modifier.width(4.dp))
                    Text("Ver detalles", fontSize = 13.sp)
                }

                if (canCancel) {
                    OutlinedButton(
                        onClick  = onCancel,
                        modifier = Modifier.weight(1f),
                        shape    = RoundedCornerShape(10.dp),
                        colors   = ButtonDefaults.outlinedButtonColors(contentColor = Color.Red)
                    ) {
                        Icon(Icons.Filled.Cancel, null, modifier = Modifier.size(15.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("Cancelar", fontSize = 13.sp)
                    }
                }
            }
        }
    }
}