package com.arthur.gloria.logired.features.login.registerdriver.presentation.screen

import android.Manifest
import android.content.pm.PackageManager
import android.location.Geocoder
import android.net.Uri
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
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
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.core.content.ContextCompat
import androidx.core.content.FileProvider
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import coil.request.CachePolicy
import coil.request.ImageRequest
import com.arthur.gloria.logired.features.login.registerdriver.presentation.viewmodel.RegisterDriverViewModel
import com.arthur.gloria.logired.ui.components.RegisterField
import com.google.android.gms.location.LocationServices
import kotlinx.coroutines.launch
import java.io.File
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RegisterDriverScreen(
    onRegisterSuccess: () -> Unit,
    onVerifyEmail: (String) -> Unit,
    onBack: () -> Unit,
    viewModel: RegisterDriverViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)
    val context = LocalContext.current
    val scope = rememberCoroutineScope()

    var photoUri by remember { mutableStateOf<Uri?>(null) }
    var showPhotoDialog by remember { mutableStateOf(false) }
    var cameraUri by remember { mutableStateOf<Uri?>(null) }
    var isLocating by remember { mutableStateOf(false) }
    var locationError by remember { mutableStateOf<String?>(null) }
    var showDatePicker by remember { mutableStateOf(false) }
    var showPassword by remember { mutableStateOf(false) }
    var showConfirmPassword by remember { mutableStateOf(false) }

    val datePickerState = rememberDatePickerState(
        initialSelectedDateMillis = run {
            try {
                SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).parse(uiState.birthdate)?.time
            } catch (e: Exception) { null }
        } ?: System.currentTimeMillis()
    )

    val fusedLocationClient = remember { LocationServices.getFusedLocationProviderClient(context) }

    val galleryLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.GetContent()
    ) { uri -> uri?.let { photoUri = it; viewModel.onImageSelected(it) } }

    val cameraLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.TakePicture()
    ) { success -> if (success) cameraUri?.let { photoUri = it; viewModel.onImageSelected(it) } }

    val cameraPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            val file = File(context.filesDir, "profile_${System.currentTimeMillis()}.jpg")
            val uri = FileProvider.getUriForFile(context, "${context.packageName}.provider", file)
            cameraUri = uri
            cameraLauncher.launch(uri)
        }
    }

    val locationPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val granted = permissions[Manifest.permission.ACCESS_FINE_LOCATION] == true ||
                permissions[Manifest.permission.ACCESS_COARSE_LOCATION] == true
        if (granted) {
            isLocating = true
            fusedLocationClient.lastLocation.addOnSuccessListener { location ->
                if (location != null) {
                    scope.launch {
                        try {
                            @Suppress("DEPRECATION")
                            val results = Geocoder(context, Locale.getDefault())
                                .getFromLocation(location.latitude, location.longitude, 1)
                            val address = results?.firstOrNull()
                            if (address != null) {
                                val city = address.locality ?: address.subAdminArea ?: ""
                                val state = address.adminArea ?: ""
                                viewModel.onCityworkChange("$city, $state")
                            } else {
                                locationError = "No se pudo obtener la ciudad"
                            }
                        } catch (e: Exception) {
                            locationError = "Error al obtener ubicación"
                        } finally {
                            isLocating = false
                        }
                    }
                } else {
                    locationError = "Activa el GPS e intenta de nuevo"
                    isLocating = false
                }
            }
        } else {
            locationError = "Permiso de ubicación denegado"
        }
    }

    fun openCamera() {
        val granted = ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED
        if (granted) {
            val file = File(context.filesDir, "profile_${System.currentTimeMillis()}.jpg")
            val uri = FileProvider.getUriForFile(context, "${context.packageName}.provider", file)
            cameraUri = uri
            cameraLauncher.launch(uri)
        } else {
            cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }

    fun requestLocation() {
        val fineGranted = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
        val coarseGranted = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED
        if (fineGranted || coarseGranted) {
            isLocating = true
            locationError = null
            fusedLocationClient.lastLocation.addOnSuccessListener { location ->
                if (location != null) {
                    scope.launch {
                        try {
                            @Suppress("DEPRECATION")
                            val results = Geocoder(context, Locale.getDefault())
                                .getFromLocation(location.latitude, location.longitude, 1)
                            val address = results?.firstOrNull()
                            if (address != null) {
                                val city = address.locality ?: address.subAdminArea ?: ""
                                val state = address.adminArea ?: ""
                                viewModel.onCityworkChange("$city, $state")
                            } else {
                                locationError = "No se pudo obtener la ciudad"
                            }
                        } catch (e: Exception) {
                            locationError = "Error al obtener ubicación"
                        } finally {
                            isLocating = false
                        }
                    }
                } else {
                    locationError = "Activa el GPS e intenta de nuevo"
                    isLocating = false
                }
            }.addOnFailureListener {
                locationError = "Error al obtener ubicación"
                isLocating = false
            }
        } else {
            locationPermissionLauncher.launch(arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ))
        }
    }

    LaunchedEffect(uiState.registerSuccess) {
        if (uiState.registerSuccess) { onRegisterSuccess(); viewModel.onNavigationHandled() }
    }
    LaunchedEffect(uiState.emailVerificationSent) {
        if (uiState.emailVerificationSent) { onVerifyEmail(uiState.email); viewModel.onNavigationHandled() }
    }

    if (showDatePicker) {
        Dialog(
            onDismissRequest = { showDatePicker = false },
            properties = DialogProperties(usePlatformDefaultWidth = false)
        ) {
            Surface(
                shape = RoundedCornerShape(16.dp),
                color = Color.White,
                modifier = Modifier.padding(16.dp)
            ) {
                Column {
                    DatePicker(
                        state = datePickerState,
                        colors = DatePickerDefaults.colors(
                            containerColor                = Color.White,
                            titleContentColor             = green,
                            headlineContentColor          = green,
                            weekdayContentColor           = green,
                            selectedDayContainerColor     = green,
                            selectedDayContentColor       = Color.White,
                            todayDateBorderColor          = green,
                            todayContentColor             = green
                        )
                    )
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 8.dp),
                        horizontalArrangement = Arrangement.End
                    ) {
                        TextButton(onClick = { showDatePicker = false }) {
                            Text("Cancelar", color = green)
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                        TextButton(onClick = {
                            datePickerState.selectedDateMillis?.let { millis ->
                                val formatted = SimpleDateFormat("yyyy-MM-dd", Locale.getDefault()).format(Date(millis))
                                viewModel.onBirthdateChange(formatted)
                            }
                            showDatePicker = false
                        }) {
                            Text("Aceptar", color = green)
                        }
                    }
                }
            }
        }
    }

    if (showPhotoDialog) {
        AlertDialog(
            onDismissRequest = { showPhotoDialog = false },
            title = { Text("Foto de perfil", fontWeight = FontWeight.Bold) },
            text = { Text("Elige una foto tuya de frente, con buena iluminación. No se permiten fotos de objetos o paisajes.") },
            confirmButton = {
                TextButton(onClick = { showPhotoDialog = false; openCamera() }) {
                    Icon(Icons.Filled.CameraAlt, null, tint = green)
                    Spacer(Modifier.width(4.dp))
                    Text("Cámara", color = green)
                }
            },
            dismissButton = {
                TextButton(onClick = { showPhotoDialog = false; galleryLauncher.launch("image/*") }) {
                    Icon(Icons.Filled.PhotoLibrary, null, tint = green)
                    Spacer(Modifier.width(4.dp))
                    Text("Galería", color = green)
                }
            }
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
            .padding(horizontal = 28.dp)
            .verticalScroll(rememberScrollState())
    ) {
        Spacer(modifier = Modifier.height(56.dp))
        IconButton(onClick = onBack) {
            Icon(Icons.Filled.ArrowBack, contentDescription = null, tint = green)
        }
        Spacer(modifier = Modifier.height(16.dp))
        Text("Registro Conductor", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
        Text("Únete y empieza a ganar dinero", fontSize = 15.sp, color = Color(0xFF7A9A8E), modifier = Modifier.padding(top = 6.dp))
        Spacer(modifier = Modifier.height(28.dp))

        Column(modifier = Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
            Box(
                modifier = Modifier
                    .size(110.dp)
                    .clip(CircleShape)
                    .background(Color(0xFFD8EDE6))
                    .border(2.dp, green, CircleShape)
                    .clickable { showPhotoDialog = true },
                contentAlignment = Alignment.Center
            ) {
                if (photoUri != null) {
                    AsyncImage(
                        model = ImageRequest.Builder(context)
                            .data(photoUri)
                            .memoryCachePolicy(CachePolicy.DISABLED)
                            .diskCachePolicy(CachePolicy.DISABLED)
                            .crossfade(true)
                            .build(),
                        contentDescription = null,
                        modifier = Modifier.fillMaxSize(),
                        contentScale = ContentScale.Crop
                    )
                } else {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(Icons.Filled.Person, null, tint = green, modifier = Modifier.size(40.dp))
                        Text("Foto", fontSize = 11.sp, color = green)
                    }
                }
            }
            Spacer(Modifier.height(8.dp))
            TextButton(onClick = { showPhotoDialog = true }) {
                Icon(Icons.Filled.CameraAlt, null, tint = green, modifier = Modifier.size(16.dp))
                Spacer(Modifier.width(4.dp))
                Text(if (photoUri == null) "Agregar foto de perfil" else "Cambiar foto", color = green, fontSize = 13.sp)
            }
            Text("Usa una foto tuya de frente", fontSize = 11.sp, color = Color(0xFF9A9A9A), textAlign = TextAlign.Center)
        }

        Spacer(modifier = Modifier.height(24.dp))

        RegisterField("Nombre", uiState.name, viewModel::onNameChange, Icons.Filled.Person, green)
        Spacer(modifier = Modifier.height(16.dp))
        RegisterField("Apellido", uiState.lastname, viewModel::onLastnameChange, Icons.Filled.Person, green)
        Spacer(modifier = Modifier.height(16.dp))
        RegisterField("Correo electrónico", uiState.email, viewModel::onEmailChange, Icons.Filled.Email, green, KeyboardType.Email)
        Spacer(modifier = Modifier.height(16.dp))
        RegisterField(
            "Teléfono (10 dígitos)", uiState.numberPhone,
            { if (it.length <= 10 && it.all { c -> c.isDigit() }) viewModel.onPhoneChange(it) },
            Icons.Filled.Phone, green, KeyboardType.Phone
        )
        Spacer(modifier = Modifier.height(16.dp))

        Box(modifier = Modifier.fillMaxWidth()) {
            OutlinedTextField(
                value = uiState.birthdate,
                onValueChange = {},
                readOnly = true,
                label = { Text("Fecha de nacimiento") },
                leadingIcon = { Icon(Icons.Filled.CalendarMonth, null, tint = green) },
                trailingIcon = { Icon(Icons.Filled.EditCalendar, "Seleccionar fecha", tint = green) },
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(12.dp),
                colors = OutlinedTextFieldDefaults.colors(
                    focusedBorderColor   = green,
                    unfocusedBorderColor = Color(0xFFB0CFCA),
                    focusedLabelColor    = green
                )
            )
            Box(modifier = Modifier.matchParentSize().clickable { showDatePicker = true })
        }

        Spacer(modifier = Modifier.height(16.dp))

        RegisterField("Ciudad de trabajo", uiState.citywork, viewModel::onCityworkChange, Icons.Filled.LocationCity, green)
        Spacer(modifier = Modifier.height(8.dp))
        OutlinedButton(
            onClick  = { requestLocation() },
            modifier = Modifier.fillMaxWidth().height(46.dp),
            shape    = RoundedCornerShape(12.dp),
            colors   = ButtonDefaults.outlinedButtonColors(contentColor = green),
            enabled  = !isLocating
        ) {
            if (isLocating) {
                CircularProgressIndicator(modifier = Modifier.size(18.dp), color = green, strokeWidth = 2.dp)
                Spacer(Modifier.width(8.dp))
                Text("Obteniendo ubicación...", fontSize = 14.sp)
            } else {
                Icon(Icons.Filled.MyLocation, null, modifier = Modifier.size(18.dp))
                Spacer(Modifier.width(8.dp))
                Text("Usar mi ubicación actual", fontSize = 14.sp)
            }
        }
        locationError?.let {
            Spacer(modifier = Modifier.height(4.dp))
            Text(it, color = Color.Red, fontSize = 13.sp)
        }

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = uiState.password,
            onValueChange = viewModel::onPasswordChange,
            label = { Text("Contraseña") },
            leadingIcon = { Icon(Icons.Filled.Lock, null, tint = green) },
            trailingIcon = {
                IconButton(onClick = { showPassword = !showPassword }) {
                    Icon(
                        if (showPassword) Icons.Filled.VisibilityOff else Icons.Filled.Visibility,
                        contentDescription = if (showPassword) "Ocultar" else "Mostrar",
                        tint = green
                    )
                }
            },
            visualTransformation = if (showPassword) VisualTransformation.None else PasswordVisualTransformation(),
            keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(keyboardType = KeyboardType.Password),
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor   = green,
                unfocusedBorderColor = Color(0xFFB0CFCA),
                focusedLabelColor    = green
            )
        )

        Spacer(modifier = Modifier.height(4.dp))
        Text("Mínimo 8 caracteres, una mayúscula y un carácter especial", fontSize = 11.sp, color = Color(0xFF9A9A9A))
        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = uiState.confirmPassword,
            onValueChange = viewModel::onConfirmPasswordChange,
            label = { Text("Repetir contraseña") },
            leadingIcon = { Icon(Icons.Filled.Lock, null, tint = green) },
            trailingIcon = {
                IconButton(onClick = { showConfirmPassword = !showConfirmPassword }) {
                    Icon(
                        if (showConfirmPassword) Icons.Filled.VisibilityOff else Icons.Filled.Visibility,
                        contentDescription = if (showConfirmPassword) "Ocultar" else "Mostrar",
                        tint = green
                    )
                }
            },
            visualTransformation = if (showConfirmPassword) VisualTransformation.None else PasswordVisualTransformation(),
            keyboardOptions = androidx.compose.foundation.text.KeyboardOptions(keyboardType = KeyboardType.Password),
            modifier = Modifier.fillMaxWidth(),
            shape = RoundedCornerShape(12.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor   = green,
                unfocusedBorderColor = Color(0xFFB0CFCA),
                focusedLabelColor    = green
            )
        )

        uiState.error?.let {
            Spacer(modifier = Modifier.height(8.dp))
            Text(it, color = Color.Red, fontSize = 13.sp)
        }

        Spacer(modifier = Modifier.height(32.dp))

        Button(
            onClick  = viewModel::onRegisterClick,
            modifier = Modifier.fillMaxWidth().height(52.dp),
            shape    = RoundedCornerShape(14.dp),
            colors   = ButtonDefaults.buttonColors(containerColor = green),
            enabled  = !uiState.isLoading
        ) {
            if (uiState.isLoading) {
                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
            } else {
                Text("Registrarme como Conductor", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
            }
        }

        Spacer(modifier = Modifier.height(32.dp))
    }
}