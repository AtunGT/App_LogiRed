package com.arthur.gloria.logired.features.trip.request.presentation.screen

import android.Manifest
import android.content.pm.PackageManager
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.window.Dialog
import androidx.compose.ui.window.DialogProperties
import androidx.core.content.ContextCompat
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.features.trip.request.presentation.viewmodel.RequestTripViewModel
import com.arthur.gloria.logired.ui.components.RegisterField
import com.google.android.libraries.places.api.model.AutocompletePrediction
import java.util.Calendar

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun RequestTripScreen(
    onRequestSuccess: () -> Unit,
    onBack: () -> Unit,
    onLogout: () -> Unit,
    viewModel: RequestTripViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green   = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)
    val context = LocalContext.current

    var showDatePicker by remember { mutableStateOf(false) }
    var showTimePicker by remember { mutableStateOf(false) }

    val datePickerState = rememberDatePickerState(
        selectableDates = object : SelectableDates {
            override fun isSelectableDate(utcTimeMillis: Long): Boolean {
                return utcTimeMillis >= System.currentTimeMillis() - 86400000
            }
        }
    )

    val timePickerState = rememberTimePickerState(
        initialHour   = Calendar.getInstance().get(Calendar.HOUR_OF_DAY),
        initialMinute = Calendar.getInstance().get(Calendar.MINUTE),
        is24Hour      = false
    )

    val locationPermissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val granted = permissions[Manifest.permission.ACCESS_FINE_LOCATION] == true ||
                permissions[Manifest.permission.ACCESS_COARSE_LOCATION] == true
        if (granted) viewModel.fetchCurrentLocation()
    }

    fun requestLocation() {
        val fine   = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION)
        val coarse = ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION)
        if (fine == PackageManager.PERMISSION_GRANTED || coarse == PackageManager.PERMISSION_GRANTED) {
            viewModel.fetchCurrentLocation()
        } else {
            locationPermissionLauncher.launch(arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ))
        }
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
                                val cal   = Calendar.getInstance()
                                cal.timeInMillis = millis
                                val year  = cal.get(Calendar.YEAR)
                                val month = cal.get(Calendar.MONTH) + 1
                                val day   = cal.get(Calendar.DAY_OF_MONTH)
                                viewModel.onDateChange("%04d-%02d-%02d".format(year, month, day))
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

    if (showTimePicker) {
        Dialog(
            onDismissRequest = { showTimePicker = false },
            properties = DialogProperties(usePlatformDefaultWidth = false)
        ) {
            Surface(
                shape    = RoundedCornerShape(16.dp),
                color    = Color.White,
                modifier = Modifier.padding(16.dp)
            ) {
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.padding(16.dp)
                ) {
                    Text(
                        "Selecciona la hora",
                        fontSize = 14.sp,
                        color    = Color(0xFF7A9A8E),
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(bottom = 16.dp)
                    )
                    TimePicker(
                        state  = timePickerState,
                        colors = TimePickerDefaults.colors(
                            clockDialColor                          = Color(0xFFF0F7F4),
                            clockDialSelectedContentColor           = Color.White,
                            clockDialUnselectedContentColor         = Color(0xFF1A1A1A),
                            selectorColor                           = green,
                            containerColor                          = Color.White,
                            periodSelectorBorderColor               = green,
                            periodSelectorSelectedContainerColor    = green,
                            periodSelectorUnselectedContainerColor  = Color.White,
                            periodSelectorSelectedContentColor      = Color.White,
                            periodSelectorUnselectedContentColor    = green,
                            timeSelectorSelectedContainerColor      = green,
                            timeSelectorUnselectedContainerColor    = Color(0xFFE8F5F0),
                            timeSelectorSelectedContentColor        = Color.White,
                            timeSelectorUnselectedContentColor      = Color(0xFF1A1A1A)
                        )
                    )
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.End
                    ) {
                        TextButton(onClick = { showTimePicker = false }) {
                            Text("Cancelar", color = green)
                        }
                        Spacer(modifier = Modifier.width(8.dp))
                        TextButton(onClick = {
                            viewModel.onHourChange("%02d:%02d".format(timePickerState.hour, timePickerState.minute))
                            showTimePicker = false
                        }) {
                            Text("Aceptar", color = green)
                        }
                    }
                }
            }
        }
    }

    LaunchedEffect(uiState.requestSuccess) {
        if (uiState.requestSuccess) {
            onRequestSuccess()
            viewModel.onNavigationHandled()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
    ) {
        Surface(color = green, shadowElevation = 2.dp) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text("Solicitar Viaje", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = Color.White)
                    Text("Completa los detalles de tu mudanza", fontSize = 13.sp, color = Color.White.copy(alpha = 0.8f))
                }
            }
        }

        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(horizontal = 28.dp)
                .verticalScroll(rememberScrollState())
        ) {
            Spacer(Modifier.height(24.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Box(modifier = Modifier.weight(1f)) {
                    AutocompleteField(
                        label                = "Dirección de origen",
                        value                = uiState.origin,
                        onValueChange        = viewModel::onOriginChange,
                        suggestions          = uiState.originSuggestions,
                        showSuggestions      = uiState.showOriginSuggestions,
                        onSuggestionSelected = { viewModel.onOriginSuggestionSelected(it) },
                        onDismiss            = viewModel::dismissOriginSuggestions,
                        icon                 = Icons.Filled.LocationOn,
                        green                = green
                    )
                }
                IconButton(
                    onClick  = { requestLocation() },
                    modifier = Modifier
                        .size(52.dp)
                        .background(green, RoundedCornerShape(12.dp))
                ) {
                    if (uiState.isLocating) {
                        CircularProgressIndicator(color = Color.White, modifier = Modifier.size(20.dp), strokeWidth = 2.dp)
                    } else {
                        Icon(Icons.Filled.MyLocation, null, tint = Color.White)
                    }
                }
            }

            Spacer(Modifier.height(16.dp))
            RegisterField("Ciudad de origen", uiState.originCity, viewModel::onOriginCityChange, Icons.Filled.LocationCity, green)
            Spacer(Modifier.height(16.dp))

            AutocompleteField(
                label                = "Dirección de destino",
                value                = uiState.destination,
                onValueChange        = viewModel::onDestinationChange,
                suggestions          = uiState.destinationSuggestions,
                showSuggestions      = uiState.showDestinationSuggestions,
                onSuggestionSelected = { viewModel.onDestinationSuggestionSelected(it) },
                onDismiss            = viewModel::dismissDestinationSuggestions,
                icon                 = Icons.Filled.Flag,
                green                = green
            )

            Spacer(Modifier.height(16.dp))

            Surface(
                modifier = Modifier.fillMaxWidth().clickable { showDatePicker = true },
                shape    = RoundedCornerShape(14.dp),
                color    = Color.Transparent
            ) {
                OutlinedTextField(
                    value         = uiState.date.ifBlank { "" },
                    onValueChange = {},
                    enabled       = false,
                    label         = { Text("Fecha", color = if (uiState.date.isBlank()) Color(0xFF666666) else green) },
                    leadingIcon   = { Icon(Icons.Filled.CalendarMonth, null, tint = green) },
                    trailingIcon  = { Icon(Icons.Filled.EditCalendar, null, tint = green) },
                    placeholder   = { Text("Selecciona una fecha") },
                    modifier      = Modifier.fillMaxWidth(),
                    shape         = RoundedCornerShape(14.dp),
                    colors        = OutlinedTextFieldDefaults.colors(
                        disabledBorderColor       = if (uiState.date.isBlank()) Color(0xFFB0BEC5) else green,
                        disabledLabelColor        = if (uiState.date.isBlank()) Color(0xFF666666) else green,
                        disabledLeadingIconColor  = green,
                        disabledTrailingIconColor = green,
                        disabledTextColor         = Color(0xFF1A1A1A)
                    )
                )
            }

            Spacer(Modifier.height(16.dp))

            Surface(
                modifier = Modifier.fillMaxWidth().clickable { showTimePicker = true },
                shape    = RoundedCornerShape(14.dp),
                color    = Color.Transparent
            ) {
                OutlinedTextField(
                    value         = uiState.hour.ifBlank { "" },
                    onValueChange = {},
                    enabled       = false,
                    label         = { Text("Hora", color = if (uiState.hour.isBlank()) Color(0xFF666666) else green) },
                    leadingIcon   = { Icon(Icons.Filled.Schedule, null, tint = green) },
                    trailingIcon  = { Icon(Icons.Filled.AccessTime, null, tint = green) },
                    placeholder   = { Text("Selecciona la hora") },
                    modifier      = Modifier.fillMaxWidth(),
                    shape         = RoundedCornerShape(14.dp),
                    colors        = OutlinedTextFieldDefaults.colors(
                        disabledBorderColor       = if (uiState.hour.isBlank()) Color(0xFFB0BEC5) else green,
                        disabledLabelColor        = if (uiState.hour.isBlank()) Color(0xFF666666) else green,
                        disabledLeadingIconColor  = green,
                        disabledTrailingIconColor = green,
                        disabledTextColor         = Color(0xFF1A1A1A)
                    )
                )
            }

            Spacer(Modifier.height(16.dp))
            RegisterField("Peso aproximado (kg)", uiState.approxWeight, viewModel::onApproxWeightChange, Icons.Filled.Scale, green, KeyboardType.Number)
            Spacer(Modifier.height(16.dp))
            RegisterField("Descripción de la carga", uiState.description, viewModel::onDescriptionChange, Icons.Filled.Description, green)

            uiState.error?.let {
                Spacer(Modifier.height(8.dp))
                Text(it, color = Color.Red, fontSize = 13.sp)
            }

            Spacer(Modifier.height(32.dp))

            Button(
                onClick  = viewModel::onRequestClick,
                modifier = Modifier.fillMaxWidth().height(52.dp),
                shape    = RoundedCornerShape(14.dp),
                colors   = ButtonDefaults.buttonColors(containerColor = green),
                enabled  = !uiState.isLoading
            ) {
                if (uiState.isLoading) {
                    CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                } else {
                    Text("Solicitar Viaje", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                }
            }

            Spacer(Modifier.height(32.dp))
        }
    }
}

@Composable
private fun AutocompleteField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    suggestions: List<AutocompletePrediction>,
    showSuggestions: Boolean,
    onSuggestionSelected: (AutocompletePrediction) -> Unit,
    onDismiss: () -> Unit,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    green: Color,
    modifier: Modifier = Modifier
) {
    Column(modifier = modifier) {
        OutlinedTextField(
            value         = value,
            onValueChange = onValueChange,
            label         = { Text(label) },
            leadingIcon   = { Icon(icon, null, tint = green) },
            modifier      = Modifier.fillMaxWidth(),
            shape         = RoundedCornerShape(14.dp),
            colors        = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = green,
                focusedLabelColor  = green,
                cursorColor        = green
            ),
            singleLine = true
        )

        if (showSuggestions && suggestions.isNotEmpty()) {
            Card(
                modifier  = Modifier.fillMaxWidth(),
                elevation = CardDefaults.cardElevation(8.dp),
                colors    = CardDefaults.cardColors(containerColor = Color.White),
                shape     = RoundedCornerShape(bottomStart = 12.dp, bottomEnd = 12.dp)
            ) {
                Column {
                    suggestions.take(5).forEach { prediction ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable {
                                    onSuggestionSelected(prediction)
                                    onDismiss()
                                }
                                .padding(horizontal = 16.dp, vertical = 12.dp),
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(12.dp)
                        ) {
                            Icon(Icons.Filled.LocationOn, null, tint = Color(0xFF9A9A9A), modifier = Modifier.size(18.dp))
                            Column {
                                Text(prediction.getPrimaryText(null).toString(), fontSize = 14.sp, fontWeight = FontWeight.Medium, color = Color(0xFF1A1A1A))
                                Text(prediction.getSecondaryText(null).toString(), fontSize = 12.sp, color = Color(0xFF9A9A9A))
                            }
                        }
                        if (prediction != suggestions.take(5).last()) {
                            HorizontalDivider(color = Color(0xFFF0F0F0))
                        }
                    }
                }
            }
        }
    }
}