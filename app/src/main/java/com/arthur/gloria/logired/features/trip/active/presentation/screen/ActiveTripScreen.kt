package com.arthur.gloria.logired.features.trip.active.presentation.screen

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.R
import com.arthur.gloria.logired.features.trip.active.presentation.ui.RouteStep
import com.arthur.gloria.logired.features.trip.active.presentation.ui.TripPhase
import com.arthur.gloria.logired.features.trip.active.presentation.viewmodel.ActiveTripViewModel
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.BitmapDescriptor
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLngBounds
import com.google.maps.android.compose.*
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import kotlin.math.roundToInt

private val NavGreen = Color(0xFF1B5E47)
private val NavGreenLight = Color(0xFF2E7D5F)

@Composable
fun ActiveTripScreen(
    tripId: Int,
    isDriver: Boolean,
    onBack: () -> Unit,
    onTripCompleted: () -> Unit,
    viewModel: ActiveTripViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green = Color(0xFF1E7A5E)
    val context = LocalContext.current

    var hasLocationPermission by remember {
        mutableStateOf(
            ContextCompat.checkSelfPermission(
                context, Manifest.permission.ACCESS_FINE_LOCATION
            ) == PackageManager.PERMISSION_GRANTED ||
                    ContextCompat.checkSelfPermission(
                        context, Manifest.permission.ACCESS_COARSE_LOCATION
                    ) == PackageManager.PERMISSION_GRANTED
        )
    }

    val permissionLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val granted = permissions[Manifest.permission.ACCESS_FINE_LOCATION] == true ||
                permissions[Manifest.permission.ACCESS_COARSE_LOCATION] == true
        hasLocationPermission = granted
        if (granted) viewModel.onLocationPermissionGranted()
    }

    LaunchedEffect(Unit) {
        if (!hasLocationPermission) {
            permissionLauncher.launch(
                arrayOf(
                    Manifest.permission.ACCESS_FINE_LOCATION,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                )
            )
        }
    }

    LaunchedEffect(tripId, isDriver, hasLocationPermission) {
        if (hasLocationPermission) viewModel.initialize(tripId, isDriver)
    }
    LaunchedEffect(uiState.tripCompleted) { if (uiState.tripCompleted) onTripCompleted() }

    val cameraPositionState = rememberCameraPositionState()

    LaunchedEffect(
        uiState.driverLatLng,
        uiState.driverBearing,
        uiState.isLoading,
        uiState.phase,
        uiState.isFollowingDriver
    ) {
        if (uiState.isLoading) return@LaunchedEffect
        if (!uiState.isFollowingDriver) return@LaunchedEffect

        val driver = uiState.driverLatLng
        val origin = uiState.originLatLng
        val dest = uiState.destinationLatLng

        when (uiState.phase) {
            TripPhase.GOING_TO_ORIGIN,
            TripPhase.IN_TRANSIT -> {
                val target = driver ?: origin
                if (target != null) {
                    cameraPositionState.animate(
                        CameraUpdateFactory.newCameraPosition(
                            CameraPosition.Builder()
                                .target(target)
                                .zoom(18f)
                                .tilt(65f)
                                .bearing(uiState.driverBearing)
                                .build()
                        ),
                        durationMs = 800
                    )
                }
            }
            TripPhase.AT_ORIGIN -> {
                if (origin != null) {
                    cameraPositionState.animate(
                        CameraUpdateFactory.newCameraPosition(
                            CameraPosition.Builder()
                                .target(origin)
                                .zoom(18f)
                                .tilt(45f)
                                .build()
                        ),
                        durationMs = 800
                    )
                }
            }
            TripPhase.COMPLETED -> {
                if (origin != null && dest != null) {
                    val bounds = LatLngBounds.builder().include(origin).include(dest).build()
                    cameraPositionState.animate(CameraUpdateFactory.newLatLngBounds(bounds, 120))
                }
            }
        }
    }

    val showNavCard = isDriver && uiState.tripStatus == 3 && uiState.steps.isNotEmpty() &&
            uiState.phase != TripPhase.AT_ORIGIN && uiState.phase != TripPhase.COMPLETED

    val showBottomInfo = isDriver && uiState.tripStatus == 3 &&
            uiState.driverLatLng != null &&
            (uiState.phase == TripPhase.GOING_TO_ORIGIN || uiState.phase == TripPhase.IN_TRANSIT)

    Box(modifier = Modifier.fillMaxSize().background(Color(0xFFF5F5F5))) {
        when {
            !hasLocationPermission -> {
                Column(
                    Modifier.fillMaxSize().padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Icon(Icons.Filled.LocationOff, null, tint = Color(0xFFE65100), modifier = Modifier.size(64.dp))
                    Spacer(Modifier.height(16.dp))
                    Text(
                        "Permiso de ubicación requerido",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF1A1A1A)
                    )
                    Spacer(Modifier.height(8.dp))
                    Text(
                        "Necesitamos tu ubicación para mostrar la ruta y compartirla durante el viaje.",
                        fontSize = 14.sp,
                        color = Color(0xFF757575)
                    )
                    Spacer(Modifier.height(20.dp))
                    Button(
                        onClick = {
                            permissionLauncher.launch(
                                arrayOf(
                                    Manifest.permission.ACCESS_FINE_LOCATION,
                                    Manifest.permission.ACCESS_COARSE_LOCATION
                                )
                            )
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = green)
                    ) {
                        Text("Otorgar permiso", fontSize = 15.sp)
                    }
                }
            }
            uiState.isLoading -> {
                Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        CircularProgressIndicator(color = green, modifier = Modifier.size(48.dp))
                        Spacer(Modifier.height(16.dp))
                        Text("Cargando viaje...", color = Color(0xFF1A1A1A), fontSize = 14.sp)
                    }
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
                    Text(uiState.error!!, color = Color.Red, fontSize = 15.sp)
                }
            }
            else -> {
                GoogleMap(
                    modifier = Modifier.fillMaxSize(),
                    cameraPositionState = cameraPositionState,
                    uiSettings = MapUiSettings(
                        zoomControlsEnabled = false,
                        myLocationButtonEnabled = false,
                        compassEnabled = false,
                        mapToolbarEnabled = false,
                        rotationGesturesEnabled = true
                    ),
                    properties = MapProperties(
                        isTrafficEnabled = true,
                        mapType = MapType.NORMAL
                    ),
                    onMapClick = { viewModel.onUserInteractedWithMap() }
                ) {
                    uiState.originLatLng?.let { pos ->
                        Marker(
                            state = MarkerState(position = pos),
                            title = "Origen",
                            snippet = uiState.trip?.origin ?: "",
                            icon = BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_GREEN)
                        )
                    }
                    uiState.destinationLatLng?.let { pos ->
                        Marker(
                            state = MarkerState(position = pos),
                            title = "Destino",
                            snippet = uiState.trip?.destination ?: "",
                            icon = BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_RED)
                        )
                    }
                    uiState.driverLatLng?.let { pos ->
                        val arrowIcon = remember { bitmapFromVector(context, R.drawable.ic_navigation_arrow) }
                        Marker(
                            state = MarkerState(position = pos),
                            title = "Conductor",
                            icon = arrowIcon ?: BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_AZURE),
                            rotation = uiState.driverBearing,
                            anchor = Offset(0.5f, 0.5f),
                            flat = true
                        )
                    }
                    if (uiState.routePoints.size > 1) {
                        Polyline(
                            points = uiState.routePoints,
                            color = Color(0xFF00BCD4),
                            width = 16f
                        )
                    }
                }

                AnimatedVisibility(
                    visible = showNavCard,
                    enter = slideInVertically { -it } + fadeIn(),
                    exit = slideOutVertically { -it } + fadeOut(),
                    modifier = Modifier.align(Alignment.TopCenter)
                ) {
                    GoogleMapsNavCard(
                        currentStep = uiState.steps.getOrNull(uiState.currentStepIndex),
                        nextStep = uiState.steps.getOrNull(uiState.currentStepIndex + 1)
                    )
                }

                val backTopPad = if (showNavCard) 150.dp else 48.dp
                Box(
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .padding(top = backTopPad, start = 12.dp)
                        .shadow(4.dp, CircleShape)
                        .background(Color.White, CircleShape)
                        .size(44.dp),
                    contentAlignment = Alignment.Center
                ) {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Filled.ArrowBack, null, tint = Color(0xFF1A1A1A), modifier = Modifier.size(22.dp))
                    }
                }

                if (isDriver && uiState.tripStatus == 3) {
                    Column(
                        modifier = Modifier
                            .align(Alignment.CenterEnd)
                            .padding(end = 12.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        CircleMapButton(
                            icon = if (uiState.isSpeakerOn) Icons.Filled.VolumeUp else Icons.Filled.VolumeOff,
                            tint = if (uiState.isSpeakerOn) green else Color(0xFFE65100),
                            bg = if (uiState.isSpeakerOn) Color.White else Color(0xFFFFF3E0),
                            onClick = viewModel::toggleSpeaker
                        )
                        CircleMapButton(
                            icon = Icons.Filled.Navigation,
                            tint = green,
                            bg = Color.White,
                            onClick = viewModel::centerOnDriver
                        )
                    }
                }

                Column(modifier = Modifier.align(Alignment.BottomCenter)) {

                    if (!uiState.wsConnected && uiState.tripStatus == 3) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .background(Color(0xFFFFF9C4))
                                .padding(horizontal = 16.dp, vertical = 8.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(Icons.Filled.WifiOff, null, tint = Color(0xFFF57F17), modifier = Modifier.size(16.dp))
                            Spacer(Modifier.width(8.dp))
                            Text("Reconectando...", color = Color(0xFFF57F17), fontSize = 13.sp, fontWeight = FontWeight.Medium)
                        }
                    }

                    AnimatedVisibility(
                        visible = showBottomInfo,
                        enter = slideInVertically { it } + fadeIn(),
                        exit = slideOutVertically { it } + fadeOut()
                    ) {
                        GoogleMapsBottomInfo(
                            time = uiState.timeRemaining.ifBlank { "Calculando" },
                            distance = uiState.distanceRemaining.ifBlank { "--" },
                            eta = if (uiState.timeRemaining.isNotBlank()) computeEta(uiState.timeRemaining) else "--:--"
                        )
                    }

                    if (isDriver) {
                        DriverBottomPanel(
                            phase = uiState.phase,
                            status = uiState.tripStatus,
                            green = green,
                            onStartTrip = viewModel::onStartTrip,
                            onArrivedAtOrigin = viewModel::onArrivedAtOrigin,
                            onStartJourney = viewModel::onStartJourney,
                            onArrivedAtDestination = viewModel::onArrivedAtDestination
                        )
                    } else {
                        ClientBottomPanel(
                            message = uiState.statusMessage,
                            phase = uiState.phase,
                            status = uiState.tripStatus,
                            green = green
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun CircleMapButton(
    icon: ImageVector,
    tint: Color,
    bg: Color,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .shadow(4.dp, CircleShape)
            .background(bg, CircleShape)
            .size(46.dp),
        contentAlignment = Alignment.Center
    ) {
        IconButton(onClick = onClick) {
            Icon(icon, null, tint = tint, modifier = Modifier.size(22.dp))
        }
    }
}

@Composable
private fun GoogleMapsNavCard(
    currentStep: RouteStep?,
    nextStep: RouteStep?
) {
    if (currentStep == null) return

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .statusBarsPadding()
            .padding(horizontal = 10.dp, vertical = 8.dp)
    ) {
        Surface(
            modifier = Modifier.fillMaxWidth(),
            color = NavGreen,
            shape = RoundedCornerShape(14.dp),
            shadowElevation = 8.dp
        ) {
            Row(
                modifier = Modifier.padding(horizontal = 14.dp, vertical = 14.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Icon(
                    imageVector = maneuverIcon(currentStep.maneuver),
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(44.dp)
                )
                Spacer(Modifier.width(14.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = currentStep.distanceText,
                        color = Color.White.copy(alpha = 0.85f),
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium
                    )
                    Text(
                        text = currentStep.instruction,
                        color = Color.White,
                        fontSize = 17.sp,
                        fontWeight = FontWeight.Bold,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis,
                        lineHeight = 20.sp
                    )
                }
            }
        }

        if (nextStep != null) {
            Spacer(Modifier.height(6.dp))
            Surface(
                modifier = Modifier
                    .padding(start = 12.dp)
                    .wrapContentWidth(),
                color = NavGreenLight,
                shape = RoundedCornerShape(bottomStart = 12.dp, bottomEnd = 12.dp),
                shadowElevation = 4.dp
            ) {
                Row(
                    modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text(
                        "Luego",
                        color = Color.White.copy(alpha = 0.85f),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium
                    )
                    Spacer(Modifier.width(8.dp))
                    Icon(
                        imageVector = maneuverIcon(nextStep.maneuver),
                        contentDescription = null,
                        tint = Color.White,
                        modifier = Modifier.size(16.dp)
                    )
                }
            }
        }
    }
}

@Composable
private fun GoogleMapsBottomInfo(
    time: String,
    distance: String,
    eta: String
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 12.dp, vertical = 6.dp),
        color = Color(0xFF1E1E1E),
        shape = RoundedCornerShape(16.dp),
        shadowElevation = 8.dp
    ) {
        Row(
            modifier = Modifier.padding(horizontal = 18.dp, vertical = 12.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .background(Color(0xFF2E2E2E), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Filled.Close,
                    null,
                    tint = Color.White,
                    modifier = Modifier.size(20.dp)
                )
            }
            Spacer(Modifier.width(14.dp))
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = time,
                    color = Color(0xFF4CAF50),
                    fontSize = 22.sp,
                    fontWeight = FontWeight.Bold,
                    lineHeight = 24.sp
                )
                Spacer(Modifier.height(2.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = distance,
                        color = Color.White.copy(alpha = 0.85f),
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium
                    )
                    Text(
                        text = "  ·  ",
                        color = Color.White.copy(alpha = 0.6f),
                        fontSize = 13.sp
                    )
                    Text(
                        text = eta,
                        color = Color.White.copy(alpha = 0.85f),
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Medium
                    )
                }
            }
            Box(
                modifier = Modifier
                    .size(40.dp)
                    .background(Color(0xFF2E2E2E), CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Filled.AltRoute,
                    null,
                    tint = Color.White,
                    modifier = Modifier.size(20.dp)
                )
            }
        }
    }
}

private fun computeEta(timeRemaining: String): String {
    val minutes = Regex("(\\d+)").find(timeRemaining)?.value?.toIntOrNull() ?: return "--:--"
    val cal = Calendar.getInstance()
    cal.add(Calendar.MINUTE, minutes)
    return SimpleDateFormat("HH:mm", Locale.getDefault()).format(cal.time)
}

@Composable
private fun DriverBottomPanel(
    phase: TripPhase,
    status: Int,
    green: Color,
    onStartTrip: () -> Unit,
    onArrivedAtOrigin: () -> Unit,
    onStartJourney: () -> Unit,
    onArrivedAtDestination: () -> Unit
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = Color.White,
        shadowElevation = 12.dp,
        shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)
    ) {
        Column(modifier = Modifier.padding(horizontal = 20.dp, vertical = 18.dp)) {
            Box(
                modifier = Modifier
                    .width(40.dp)
                    .height(4.dp)
                    .background(Color(0xFFE0E0E0), RoundedCornerShape(2.dp))
                    .align(Alignment.CenterHorizontally)
            )
            Spacer(Modifier.height(16.dp))

            when {
                status == 1 -> {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(42.dp)
                                .background(green.copy(alpha = 0.1f), CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Filled.DirectionsCar, null, tint = green, modifier = Modifier.size(22.dp))
                        }
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Text("Viaje agendado", fontSize = 17.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
                            Text("Presiona cuando estés listo para salir", fontSize = 13.sp, color = Color(0xFF757575))
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    Button(
                        onClick = onStartTrip,
                        modifier = Modifier.fillMaxWidth().height(54.dp),
                        shape = RoundedCornerShape(14.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = green)
                    ) {
                        Icon(Icons.Filled.Navigation, null, modifier = Modifier.size(20.dp))
                        Spacer(Modifier.width(10.dp))
                        Text("Iniciar viaje", fontSize = 17.sp, fontWeight = FontWeight.SemiBold)
                    }
                }
                phase == TripPhase.GOING_TO_ORIGIN -> {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(42.dp)
                                .background(green.copy(alpha = 0.1f), CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Filled.Navigation, null, tint = green, modifier = Modifier.size(22.dp))
                        }
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Text("En camino al origen", fontSize = 17.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
                            Text("Desliza al llegar al origen del cliente", fontSize = 13.sp, color = Color(0xFF757575))
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    SwipeSlider(text = "Llegué al origen", color = green, onSlideComplete = onArrivedAtOrigin)
                }
                phase == TripPhase.AT_ORIGIN -> {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(42.dp)
                                .background(Color(0xFF1565C0).copy(alpha = 0.1f), CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Filled.LocationOn, null, tint = Color(0xFF1565C0), modifier = Modifier.size(22.dp))
                        }
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Text("En el origen", fontSize = 17.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
                            Text("Desliza cuando terminen de cargar", fontSize = 13.sp, color = Color(0xFF757575))
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    SwipeSlider(text = "Iniciar trayecto", color = Color(0xFF1565C0), onSlideComplete = onStartJourney)
                }
                phase == TripPhase.IN_TRANSIT -> {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Box(
                            modifier = Modifier
                                .size(42.dp)
                                .background(Color(0xFFC62828).copy(alpha = 0.1f), CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Filled.LocalShipping, null, tint = Color(0xFFC62828), modifier = Modifier.size(22.dp))
                        }
                        Spacer(Modifier.width(12.dp))
                        Column {
                            Text("Viaje en progreso", fontSize = 17.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
                            Text("Desliza al llegar al destino", fontSize = 13.sp, color = Color(0xFF757575))
                        }
                    }
                    Spacer(Modifier.height(16.dp))
                    SwipeSlider(text = "Llegué al destino", color = Color(0xFFC62828), onSlideComplete = onArrivedAtDestination)
                }
                else -> {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier.padding(vertical = 8.dp)
                    ) {
                        Box(
                            modifier = Modifier
                                .size(48.dp)
                                .background(green.copy(alpha = 0.1f), CircleShape),
                            contentAlignment = Alignment.Center
                        ) {
                            Icon(Icons.Filled.CheckCircle, null, tint = green, modifier = Modifier.size(28.dp))
                        }
                        Spacer(Modifier.width(14.dp))
                        Column {
                            Text("Viaje completado", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = green)
                            Text("Gracias por usar LogiRed", fontSize = 13.sp, color = Color(0xFF757575))
                        }
                    }
                }
            }
            Spacer(Modifier.height(4.dp))
        }
    }
}

@Composable
private fun ClientBottomPanel(
    message: String,
    phase: TripPhase,
    status: Int,
    green: Color
) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        color = Color.White,
        shadowElevation = 12.dp,
        shape = RoundedCornerShape(topStart = 20.dp, topEnd = 20.dp)
    ) {
        Column(modifier = Modifier.padding(horizontal = 20.dp, vertical = 18.dp)) {
            Box(
                modifier = Modifier
                    .width(40.dp)
                    .height(4.dp)
                    .background(Color(0xFFE0E0E0), RoundedCornerShape(2.dp))
                    .align(Alignment.CenterHorizontally)
            )
            Spacer(Modifier.height(16.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                val (iconRes, iconColor, bgColor) = when {
                    status == 1 -> Triple(Icons.Filled.Schedule, Color(0xFF757575), Color(0xFFF5F5F5))
                    phase == TripPhase.GOING_TO_ORIGIN -> Triple(Icons.Filled.Navigation, green, green.copy(alpha = 0.1f))
                    phase == TripPhase.AT_ORIGIN -> Triple(Icons.Filled.LocationOn, Color(0xFF1565C0), Color(0xFFE3F2FD))
                    phase == TripPhase.IN_TRANSIT -> Triple(Icons.Filled.LocalShipping, Color(0xFFF57F17), Color(0xFFFFF3E0))
                    else -> Triple(Icons.Filled.CheckCircle, green, green.copy(alpha = 0.1f))
                }

                Box(
                    modifier = Modifier
                        .size(52.dp)
                        .background(bgColor, CircleShape),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(iconRes, null, tint = iconColor, modifier = Modifier.size(28.dp))
                }
                Spacer(Modifier.width(14.dp))
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = when {
                            status == 1 -> "Esperando al conductor"
                            phase == TripPhase.GOING_TO_ORIGIN -> "Conductor en camino"
                            phase == TripPhase.AT_ORIGIN -> "Conductor llegó"
                            phase == TripPhase.IN_TRANSIT -> "Viaje en progreso"
                            else -> "Viaje completado ✅"
                        },
                        fontSize = 17.sp,
                        fontWeight = FontWeight.Bold,
                        color = Color(0xFF1A1A1A)
                    )
                    Spacer(Modifier.height(3.dp))
                    Text(
                        text = message,
                        fontSize = 13.sp,
                        color = Color(0xFF757575),
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis
                    )
                }
            }
            Spacer(Modifier.height(4.dp))
        }
    }
}

@Composable
fun SwipeSlider(
    text: String,
    color: Color,
    onSlideComplete: () -> Unit
) {
    var offsetX by remember { mutableFloatStateOf(0f) }
    val maxOffset = 240f
    val progress = (offsetX / maxOffset).coerceIn(0f, 1f)
    val animatedProgress by animateFloatAsState(targetValue = progress, label = "slider")

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(58.dp)
            .clip(RoundedCornerShape(29.dp))
            .background(color.copy(alpha = 0.08f))
            .border(1.5.dp, color.copy(alpha = 0.4f), RoundedCornerShape(29.dp))
    ) {
        Box(
            modifier = Modifier
                .fillMaxHeight()
                .fillMaxWidth(animatedProgress)
                .background(color.copy(alpha = 0.15f))
        )
        Text(
            text = text,
            modifier = Modifier.align(Alignment.Center).padding(start = 60.dp),
            color = color,
            fontWeight = FontWeight.SemiBold,
            fontSize = 15.sp
        )
        Box(
            modifier = Modifier
                .offset { IntOffset(offsetX.roundToInt(), 0) }
                .padding(5.dp)
                .size(48.dp)
                .align(Alignment.CenterStart)
                .background(color, CircleShape)
                .pointerInput(Unit) {
                    detectHorizontalDragGestures(
                        onDragEnd = {
                            if (offsetX >= maxOffset * 0.85f) onSlideComplete()
                            offsetX = 0f
                        },
                        onDragCancel = { offsetX = 0f }
                    ) { _, dragAmount ->
                        offsetX = (offsetX + dragAmount).coerceIn(0f, maxOffset)
                    }
                },
            contentAlignment = Alignment.Center
        ) {
            Icon(
                Icons.Filled.ChevronRight,
                null,
                tint = Color.White,
                modifier = Modifier.size(30.dp)
            )
        }
    }
}

private fun maneuverIcon(maneuver: String): ImageVector = when {
    maneuver.contains("turn-sharp-right") -> Icons.Filled.TurnRight
    maneuver.contains("turn-sharp-left") -> Icons.Filled.TurnLeft
    maneuver.contains("turn-slight-right") -> Icons.Filled.TurnSlightRight
    maneuver.contains("turn-slight-left") -> Icons.Filled.TurnSlightLeft
    maneuver.contains("turn-right") -> Icons.Filled.TurnRight
    maneuver.contains("turn-left") -> Icons.Filled.TurnLeft
    maneuver.contains("uturn-right") -> Icons.Filled.UTurnRight
    maneuver.contains("uturn-left") -> Icons.Filled.UTurnLeft
    maneuver.contains("roundabout") -> Icons.Filled.RotateRight
    maneuver.contains("merge") -> Icons.Filled.MergeType
    maneuver.contains("fork") -> Icons.Filled.AltRoute
    else -> Icons.Filled.ArrowUpward
}

private fun bitmapFromVector(context: android.content.Context, vectorResId: Int): BitmapDescriptor? {
    return try {
        com.google.android.gms.maps.MapsInitializer.initialize(context)
        val drawable = ContextCompat.getDrawable(context, vectorResId) ?: return null
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth,
            drawable.intrinsicHeight,
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        BitmapDescriptorFactory.fromBitmap(bitmap)
    } catch (e: Exception) {
        android.util.Log.e("TripRoute", "bitmapFromVector error: ${e.message}")
        null
    }
}