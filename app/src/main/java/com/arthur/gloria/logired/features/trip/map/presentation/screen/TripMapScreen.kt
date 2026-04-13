package com.arthur.gloria.logired.features.trip.map.presentation.screen

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.features.trip.map.presentation.viewmodel.TripMapViewModel
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.LatLngBounds
import com.google.maps.android.compose.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TripMapScreen(
    tripId: Int,
    onBack: () -> Unit,
    viewModel: TripMapViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()

    LaunchedEffect(tripId) { viewModel.loadTrip(tripId) }

    val cameraPositionState = rememberCameraPositionState()

    LaunchedEffect(uiState.originLatLng, uiState.destinationLatLng) {
        val origin = uiState.originLatLng
        val dest   = uiState.destinationLatLng
        if (origin != null && dest != null) {
            val bounds = LatLngBounds.builder()
                .include(origin)
                .include(dest)
                .build()
            cameraPositionState.animate(CameraUpdateFactory.newLatLngBounds(bounds, 120))
        } else if (origin != null) {
            cameraPositionState.animate(CameraUpdateFactory.newLatLngZoom(origin, 13f))
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Mapa de mudanza", fontWeight = FontWeight.SemiBold)
                        uiState.trip?.let {
                            Text(
                                text  = "Mudanza #${it.id}",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Default.ArrowBack, "Volver")
                    }
                }
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
        ) {
            when {
                uiState.isLoading -> {
                    CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                }
                uiState.error != null -> {
                    Text(
                        text     = uiState.error!!,
                        color    = MaterialTheme.colorScheme.error,
                        modifier = Modifier.align(Alignment.Center)
                    )
                }
                else -> {
                    GoogleMap(
                        modifier            = Modifier.fillMaxSize(),
                        cameraPositionState = cameraPositionState,
                        uiSettings          = MapUiSettings(zoomControlsEnabled = true)
                    ) {
                        uiState.originLatLng?.let { pos ->
                            Marker(
                                state   = MarkerState(position = pos),
                                title   = "Origen",
                                snippet = uiState.trip?.origin ?: "",
                                icon    = BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN)
                            )
                        }
                        uiState.destinationLatLng?.let { pos ->
                            Marker(
                                state   = MarkerState(position = pos),
                                title   = "Destino",
                                snippet = uiState.trip?.destination ?: "",
                                icon    = BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED)
                            )
                        }
                        if (uiState.routePoints.size > 1) {
                            Polyline(
                                points = uiState.routePoints,
                                color  = MaterialTheme.colorScheme.primary,
                                width  = 8f
                            )
                        } else if (uiState.originLatLng != null && uiState.destinationLatLng != null) {
                            Polyline(
                                points = listOf(uiState.originLatLng!!, uiState.destinationLatLng!!),
                                color  = MaterialTheme.colorScheme.primary,
                                width  = 8f
                            )
                        }
                    }
                }
            }
        }
    }
}