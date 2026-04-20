package com.arthur.gloria.logired.features.trip.available.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
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
import com.google.accompanist.swiperefresh.SwipeRefresh
import com.google.accompanist.swiperefresh.SwipeRefreshIndicator
import com.google.accompanist.swiperefresh.rememberSwipeRefreshState
import com.arthur.gloria.logired.features.trip.available.presentation.viewmodel.AvailableTripsViewModel
import com.arthur.gloria.logired.ui.components.TripCard

@Composable
fun AvailableTripsScreen(
    onBack: () -> Unit,
    onLogout: () -> Unit,
    onViewDetail: (Int) -> Unit = {},
    viewModel: AvailableTripsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)

    val swipeRefreshState = rememberSwipeRefreshState(isRefreshing = uiState.isLoading)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
            .systemBarsPadding()
    ) {
        Surface(color = Color.White, shadowElevation = 2.dp) {
            Column {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Viajes Disponibles", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
                }

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp)
                        .padding(bottom = 12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Icon(Icons.Filled.LocationCity, null, tint = green, modifier = Modifier.size(18.dp))
                    Text("Ciudad de trabajo: ", fontSize = 13.sp, color = Color(0xFF7A9A8E))
                    Text(uiState.city.ifBlank { "—" }, fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = Color(0xFF1A1A1A))
                }
            }
        }

        SwipeRefresh(
            state    = swipeRefreshState,
            onRefresh = { viewModel.refresh() },
            indicator = { state, trigger ->
                SwipeRefreshIndicator(
                    state                  = state,
                    refreshTriggerDistance = trigger,
                    contentColor           = green
                )
            },
            modifier = Modifier.fillMaxSize()
        ) {
            when {
                uiState.isLoading && uiState.trips.isEmpty() -> {
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
                    }
                }
                uiState.trips.isEmpty() -> {
                    LazyColumn(
                        Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        item {
                            Column(
                                Modifier.fillParentMaxSize(),
                                horizontalAlignment = Alignment.CenterHorizontally,
                                verticalArrangement = Arrangement.Center
                            ) {
                                Icon(Icons.Filled.LocalShipping, null, tint = Color(0xFF8A9A94), modifier = Modifier.size(80.dp))
                                Spacer(Modifier.height(16.dp))
                                Text("No hay viajes disponibles", fontSize = 18.sp, fontWeight = FontWeight.Medium, color = Color(0xFF1A1A1A))
                                Spacer(Modifier.height(8.dp))
                                Text("Desliza hacia abajo para actualizar", fontSize = 14.sp, color = Color(0xFF8A9A94))
                            }
                        }
                    }
                }
                else -> {
                    LazyColumn(
                        Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        items(uiState.trips) { trip ->
                            TripCard(
                                trip             = trip,
                                showActionButton = true,
                                actionButtonText = "Ver detalles",
                                onActionClick    = { onViewDetail(trip.id) }
                            )
                        }
                    }
                }
            }
        }
    }
}