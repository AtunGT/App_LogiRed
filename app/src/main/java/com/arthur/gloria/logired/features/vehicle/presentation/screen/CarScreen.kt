package com.arthur.gloria.logired.features.vehicle.presentation.screen

import android.Manifest
import android.content.pm.PackageManager
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.arthur.gloria.logired.core.network.model.Car
import com.arthur.gloria.logired.features.vehicle.presentation.viewmodel.CarViewModel
import com.google.accompanist.swiperefresh.SwipeRefresh
import com.google.accompanist.swiperefresh.SwipeRefreshIndicator
import com.google.accompanist.swiperefresh.rememberSwipeRefreshState
import java.io.File

@Composable
fun CarScreen(viewModel: CarViewModel = hiltViewModel()) {
    val uiState by viewModel.uiState.collectAsState()
    val green = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)
    val swipeRefreshState = rememberSwipeRefreshState(isRefreshing = uiState.isLoading)

    LaunchedEffect(uiState.successMessage) {
        if (uiState.successMessage != null) {
            kotlinx.coroutines.delay(2000)
            viewModel.clearMessages()
        }
    }

    if (uiState.showDeleteDialog != null) {
        AlertDialog(
            onDismissRequest = viewModel::hideDeleteDialog,
            title = { Text("Eliminar vehículo", fontWeight = FontWeight.Bold) },
            text  = { Text("¿Estás seguro de que deseas eliminar este vehículo? Esta acción no se puede deshacer.") },
            confirmButton = {
                TextButton(onClick = { viewModel.onDelete(uiState.showDeleteDialog!!) }) {
                    Text("Eliminar", color = Color.Red)
                }
            },
            dismissButton = {
                TextButton(onClick = viewModel::hideDeleteDialog) {
                    Text("Cancelar", color = green)
                }
            }
        )
    }

    if (uiState.showForm) {
        CarFormSheet(viewModel = viewModel, green = green)
    } else {
        Column(modifier = Modifier.fillMaxSize().background(bgColor)) {
            Surface(color = Color.White, shadowElevation = 2.dp) {
                Row(
                    modifier = Modifier.fillMaxWidth().padding(horizontal = 16.dp, vertical = 16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Text("Mis Vehículos", fontSize = 24.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
                    Button(
                        onClick = viewModel::showCreateForm,
                        colors = ButtonDefaults.buttonColors(containerColor = green),
                        shape = RoundedCornerShape(10.dp)
                    ) {
                        Icon(Icons.Filled.Add, null, modifier = Modifier.size(18.dp))
                        Spacer(Modifier.width(4.dp))
                        Text("Agregar")
                    }
                }
            }

            uiState.successMessage?.let {
                Card(
                    modifier = Modifier.fillMaxWidth().padding(16.dp),
                    colors = CardDefaults.cardColors(containerColor = Color(0xFF4CAF50).copy(alpha = 0.15f))
                ) {
                    Row(Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Filled.CheckCircle, null, tint = Color(0xFF4CAF50), modifier = Modifier.size(20.dp))
                        Spacer(Modifier.width(8.dp))
                        Text(it, color = Color(0xFF2E7D32), fontWeight = FontWeight.Medium)
                    }
                }
            }

            SwipeRefresh(
                state     = swipeRefreshState,
                onRefresh = { viewModel.loadCars() },
                indicator = { state, trigger ->
                    SwipeRefreshIndicator(state = state, refreshTriggerDistance = trigger, contentColor = green)
                },
                modifier  = Modifier.fillMaxSize()
            ) {
                when {
                    uiState.error != null -> {
                        LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(24.dp)) {
                            item {
                                Column(
                                    Modifier.fillParentMaxSize(),
                                    horizontalAlignment = Alignment.CenterHorizontally,
                                    verticalArrangement = Arrangement.Center
                                ) {
                                    Icon(Icons.Filled.ErrorOutline, null, tint = Color.Red, modifier = Modifier.size(64.dp))
                                    Spacer(Modifier.height(16.dp))
                                    Text(uiState.error!!, color = Color.Red, fontSize = 16.sp)
                                    Spacer(Modifier.height(16.dp))
                                    Button(onClick = viewModel::loadCars, colors = ButtonDefaults.buttonColors(containerColor = green)) {
                                        Text("Reintentar")
                                    }
                                }
                            }
                        }
                    }
                    uiState.cars.isEmpty() -> {
                        LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(24.dp)) {
                            item {
                                Column(
                                    Modifier.fillParentMaxSize(),
                                    horizontalAlignment = Alignment.CenterHorizontally,
                                    verticalArrangement = Arrangement.Center
                                ) {
                                    Icon(Icons.Filled.DirectionsCar, null, tint = Color(0xFF8A9A94), modifier = Modifier.size(80.dp))
                                    Spacer(Modifier.height(16.dp))
                                    Text("No tienes vehículos registrados", fontSize = 18.sp, fontWeight = FontWeight.Medium, color = Color(0xFF1A1A1A))
                                    Spacer(Modifier.height(8.dp))
                                    Text("Agrega tu primer vehículo", fontSize = 14.sp, color = Color(0xFF8A9A94))
                                    Spacer(Modifier.height(24.dp))
                                    Button(onClick = viewModel::showCreateForm, colors = ButtonDefaults.buttonColors(containerColor = green)) {
                                        Icon(Icons.Filled.Add, null, modifier = Modifier.size(18.dp))
                                        Spacer(Modifier.width(4.dp))
                                        Text("Agregar vehículo")
                                    }
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
                            items(uiState.cars, key = { it.id }) { car ->
                                CarCard(
                                    car      = car,
                                    green    = green,
                                    onEdit   = { viewModel.showEditForm(car) },
                                    onDelete = { viewModel.showDeleteDialog(car.id) }
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun CarCard(car: Car, green: Color, onEdit: () -> Unit, onDelete: () -> Unit) {
    Card(
        modifier  = Modifier.fillMaxWidth(),
        elevation = CardDefaults.cardElevation(2.dp),
        colors    = CardDefaults.cardColors(containerColor = Color.White)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text("${car.brand} ${car.model}", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
                    Text(car.carRegistration, fontSize = 13.sp, color = Color(0xFF7A9A8E))
                }
                Row {
                    IconButton(onClick = onEdit)   { Icon(Icons.Filled.Edit,   null, tint = green) }
                    IconButton(onClick = onDelete) { Icon(Icons.Filled.Delete, null, tint = Color.Red) }
                }
            }

            Spacer(Modifier.height(8.dp))

            Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                InfoChip(Icons.Filled.Palette, car.color, green)
                InfoChip(Icons.Filled.Scale, "${car.maxCapacity} kg", green)
            }

            if (car.frontViewImage != null || car.platesImage != null) {
                Spacer(Modifier.height(12.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    car.frontViewImage?.let { CarImageThumb(url = it, label = "Frente") }
                    car.backViewImage?.let  { CarImageThumb(url = it, label = "Trasera") }
                    car.platesImage?.let    { CarImageThumb(url = it, label = "Placas") }
                    car.spacesImage?.let    { CarImageThumb(url = it, label = "Interior") }
                }
            }
        }
    }
}

@Composable
private fun InfoChip(icon: androidx.compose.ui.graphics.vector.ImageVector, text: String, green: Color) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        modifier = Modifier
            .background(green.copy(alpha = 0.08f), RoundedCornerShape(8.dp))
            .padding(horizontal = 8.dp, vertical = 4.dp)
    ) {
        Icon(icon, null, tint = green, modifier = Modifier.size(14.dp))
        Spacer(Modifier.width(4.dp))
        Text(text, fontSize = 12.sp, color = green, fontWeight = FontWeight.Medium)
    }
}

@Composable
private fun CarImageThumb(url: String, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        AsyncImage(
            model = url,
            contentDescription = label,
            modifier = Modifier
                .size(72.dp)
                .clip(RoundedCornerShape(8.dp))
                .border(1.dp, Color(0xFFE0E0E0), RoundedCornerShape(8.dp)),
            contentScale = ContentScale.Crop
        )
        Text(label, fontSize = 10.sp, color = Color(0xFF8A9A94))
    }
}

@Composable
private fun CarFormSheet(viewModel: CarViewModel, green: Color) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current

    val frontLauncher = rememberLauncherForActivityResult(ActivityResultContracts.TakePicture()) { success ->
        if (success) viewModel.getPendingFrontUri()?.let { viewModel.onFrontViewSelected(it) }
    }
    val backLauncher = rememberLauncherForActivityResult(ActivityResultContracts.TakePicture()) { success ->
        if (success) viewModel.getPendingBackUri()?.let { viewModel.onBackViewSelected(it) }
    }
    val platesLauncher = rememberLauncherForActivityResult(ActivityResultContracts.TakePicture()) { success ->
        if (success) viewModel.getPendingPlatesUri()?.let { viewModel.onPlatesSelected(it) }
    }
    val spacesLauncher = rememberLauncherForActivityResult(ActivityResultContracts.TakePicture()) { success ->
        if (success) viewModel.getPendingSpacesUri()?.let { viewModel.onSpacesSelected(it) }
    }

    val cameraPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { }

    fun createCameraUri(): Uri {
        val file = File(context.filesDir, "car_${System.currentTimeMillis()}.jpg")
        return FileProvider.getUriForFile(context, "${context.packageName}.provider", file)
    }

    fun launchCamera(setPending: (Uri) -> Unit, launch: (Uri) -> Unit) {
        val granted = ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED
        if (granted) {
            val uri = createCameraUri()
            setPending(uri)
            launch(uri)
        } else {
            cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }

    Column(modifier = Modifier.fillMaxSize().background(Color.White)) {
        Surface(color = Color.White, shadowElevation = 2.dp) {
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = viewModel::hideForm) {
                    Icon(Icons.Filled.ArrowBack, null, tint = Color(0xFF1A1A1A))
                }
                Text("Perfil del Vehículo", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
            }
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(horizontal = 20.dp)
        ) {
            Spacer(Modifier.height(24.dp))

            Text("Información del Vehículo", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
            Text("Completa los detalles de tu vehículo", fontSize = 13.sp, color = Color(0xFF9A9A9A))

            Spacer(Modifier.height(20.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                SimpleFormField("Marca",  uiState.brand, viewModel::onBrandChange, Modifier.weight(1f))
                SimpleFormField("Modelo", uiState.model, viewModel::onModelChange, Modifier.weight(1f))
            }

            Spacer(Modifier.height(12.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                SimpleFormField("Año",   uiState.year,  viewModel::onYearChange,  Modifier.weight(1f), KeyboardType.Number)
                SimpleFormField("Color", uiState.color, viewModel::onColorChange, Modifier.weight(1f))
            }

            Spacer(Modifier.height(12.dp))

            SimpleFormField("Placas", uiState.carRegistration, { viewModel.onCarRegistrationChange(it.uppercase()) }, Modifier.fillMaxWidth())

            Spacer(Modifier.height(12.dp))

            SimpleFormField("Capacidad máx. (kg)", uiState.maxCapacity, viewModel::onMaxCapacityChange, Modifier.fillMaxWidth(), KeyboardType.Number)

            Spacer(Modifier.height(28.dp))

            Text("Fotos del Vehículo", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))

            Spacer(Modifier.height(16.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                ImagePickerBox("Frontal", uiState.frontViewUri, green, Modifier.weight(1f)) {
                    launchCamera({ viewModel.setPendingFrontUri(it) }) { uri -> frontLauncher.launch(uri) }
                }
                ImagePickerBox("Trasera", uiState.backViewUri, green, Modifier.weight(1f)) {
                    launchCamera({ viewModel.setPendingBackUri(it) }) { uri -> backLauncher.launch(uri) }
                }
            }

            Spacer(Modifier.height(12.dp))

            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                ImagePickerBox("De costado", uiState.platesUri, green, Modifier.weight(1f)) {
                    launchCamera({ viewModel.setPendingPlatesUri(it) }) { uri -> platesLauncher.launch(uri) }
                }
                ImagePickerBox("Espacio de carga", uiState.spacesUri, green, Modifier.weight(1f)) {
                    launchCamera({ viewModel.setPendingSpacesUri(it) }) { uri -> spacesLauncher.launch(uri) }
                }
            }

            uiState.error?.let {
                Spacer(Modifier.height(12.dp))
                Text(it, color = Color.Red, fontSize = 13.sp)
            }

            Spacer(Modifier.height(32.dp))

            Button(
                onClick  = viewModel::onSave,
                modifier = Modifier.fillMaxWidth().height(52.dp),
                shape    = RoundedCornerShape(14.dp),
                colors   = ButtonDefaults.buttonColors(containerColor = green),
                enabled  = !uiState.isLoading
            ) {
                if (uiState.isLoading) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                } else {
                    Text(
                        if (uiState.editingCarId == null) "Registrar vehículo" else "Guardar cambios",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.SemiBold
                    )
                }
            }

            Spacer(Modifier.height(32.dp))
        }
    }
}

@Composable
private fun SimpleFormField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    modifier: Modifier = Modifier,
    keyboardType: KeyboardType = KeyboardType.Text
) {
    Column(modifier = modifier) {
        Text(label, fontSize = 13.sp, fontWeight = FontWeight.Medium, color = Color(0xFF1A1A1A), modifier = Modifier.padding(bottom = 6.dp))
        OutlinedTextField(
            value           = value,
            onValueChange   = onValueChange,
            modifier        = Modifier.fillMaxWidth(),
            shape           = RoundedCornerShape(10.dp),
            singleLine      = true,
            keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
            colors          = OutlinedTextFieldDefaults.colors(
                unfocusedBorderColor = Color(0xFFE0E0E0),
                focusedBorderColor   = Color(0xFF1E7A5E),
                cursorColor          = Color(0xFF1E7A5E)
            )
        )
    }
}

@Composable
private fun ImagePickerBox(
    label: String,
    uri: Uri?,
    green: Color,
    modifier: Modifier = Modifier,
    onClick: () -> Unit
) {
    Column(modifier = modifier, horizontalAlignment = Alignment.CenterHorizontally) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(90.dp)
                .clip(RoundedCornerShape(12.dp))
                .background(green.copy(alpha = 0.07f))
                .border(1.dp, green.copy(alpha = 0.3f), RoundedCornerShape(12.dp))
                .clickable { onClick() },
            contentAlignment = Alignment.Center
        ) {
            if (uri != null) {
                AsyncImage(
                    model = uri,
                    contentDescription = label,
                    modifier = Modifier.fillMaxSize().clip(RoundedCornerShape(12.dp)),
                    contentScale = ContentScale.Crop
                )
            } else {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(Icons.Filled.CameraAlt, null, tint = green, modifier = Modifier.size(28.dp))
                }
            }
        }
        Spacer(Modifier.height(4.dp))
        Text(label, fontSize = 11.sp, color = Color(0xFF7A9A8E))
    }
}