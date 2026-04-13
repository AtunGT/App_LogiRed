package com.arthur.gloria.logired.features.trip.driverdetail.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.features.trip.driverdetail.presentation.viewmodel.DriverTripDetailViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DriverTripDetailScreen(
    tripId: Int,
    onBack: () -> Unit,
    onViewMap: (Int) -> Unit,
    viewModel: DriverTripDetailViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green   = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)
    var carExpanded by remember { mutableStateOf(false) }

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
            uiState.error != null && uiState.trip == null -> {
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

                    SectionCard(title = "Ubicación", green = green) {
                        DetailRow(Icons.Filled.LocationOn,   "Origen",  trip.origin.ifBlank { "—" },      green)
                        Spacer(Modifier.height(4.dp))
                        DetailRow(Icons.Filled.LocationCity, "Ciudad",  trip.origin_city.ifBlank { "—" }, green)
                        HorizontalDivider(modifier = Modifier.padding(vertical = 12.dp), color = Color(0xFFF0F0F0))
                        DetailRow(Icons.Filled.Flag,         "Destino", trip.destination.ifBlank { "—" }, green)
                    }

                    Spacer(Modifier.height(12.dp))

                    SectionCard(title = "Fecha y hora", green = green) {
                        DetailRow(Icons.Filled.CalendarMonth, "Fecha", trip.date.take(10).ifBlank { "—" }, green)
                        Spacer(Modifier.height(4.dp))
                        DetailRow(Icons.Filled.Schedule,      "Hora",  trip.hour.ifBlank { "—" },          green)
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

                    Spacer(Modifier.height(24.dp))

                    if (uiState.proposalSent) {
                        Card(
                            modifier  = Modifier.fillMaxWidth(),
                            shape     = RoundedCornerShape(14.dp),
                            colors    = CardDefaults.cardColors(containerColor = Color(0xFFE8F5F0)),
                            elevation = CardDefaults.cardElevation(2.dp)
                        ) {
                            Column(modifier = Modifier.padding(16.dp)) {
                                Row(verticalAlignment = Alignment.CenterVertically) {
                                    Icon(Icons.Filled.CheckCircle, null, tint = green, modifier = Modifier.size(24.dp))
                                    Spacer(Modifier.width(8.dp))
                                    Text("Oferta enviada", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = green)
                                }
                                Spacer(Modifier.height(12.dp))
                                HorizontalDivider(color = green.copy(alpha = 0.2f))
                                Spacer(Modifier.height(12.dp))
                                DetailRow(Icons.Filled.AttachMoney,  "Costo",       "$${uiState.sentPrice}", green)
                                Spacer(Modifier.height(8.dp))
                                DetailRow(Icons.Filled.DirectionsCar, "Vehículo",   uiState.sentCarName,     green)
                                if (uiState.sentComment.isNotBlank()) {
                                    Spacer(Modifier.height(8.dp))
                                    DetailRow(Icons.Filled.Description, "Descripción", uiState.sentComment,  green)
                                }
                            }
                        }
                    } else {
                        Text("Enviar oferta", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))

                        Spacer(Modifier.height(12.dp))

                        OutlinedTextField(
                            value           = uiState.price,
                            onValueChange   = viewModel::onPriceChange,
                            label           = { Text("Costo ($)") },
                            leadingIcon     = { Icon(Icons.Filled.AttachMoney, null, tint = green) },
                            modifier        = Modifier.fillMaxWidth(),
                            shape           = RoundedCornerShape(12.dp),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                            colors          = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor   = green,
                                unfocusedBorderColor = Color(0xFFB0CFCA),
                                focusedLabelColor    = green,
                                cursorColor          = green
                            )
                        )

                        Spacer(Modifier.height(12.dp))

                        ExposedDropdownMenuBox(
                            expanded         = carExpanded,
                            onExpandedChange = { carExpanded = !carExpanded }
                        ) {
                            OutlinedTextField(
                                value         = uiState.selectedCar?.let { "${it.brand} ${it.model} - ${it.color}" } ?: "Selecciona un vehículo",
                                onValueChange = {},
                                readOnly      = true,
                                label         = { Text("Vehículo") },
                                leadingIcon   = { Icon(Icons.Filled.DirectionsCar, null, tint = green) },
                                trailingIcon  = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = carExpanded) },
                                modifier      = Modifier.fillMaxWidth().menuAnchor(),
                                shape         = RoundedCornerShape(12.dp),
                                colors        = OutlinedTextFieldDefaults.colors(
                                    focusedBorderColor   = green,
                                    unfocusedBorderColor = Color(0xFFB0CFCA),
                                    focusedLabelColor    = green
                                )
                            )
                            ExposedDropdownMenu(
                                expanded         = carExpanded,
                                onDismissRequest = { carExpanded = false }
                            ) {
                                if (uiState.cars.isEmpty()) {
                                    DropdownMenuItem(
                                        text    = { Text("No tienes vehículos registrados") },
                                        onClick = { carExpanded = false }
                                    )
                                } else {
                                    uiState.cars.forEach { car ->
                                        DropdownMenuItem(
                                            text = {
                                                Column {
                                                    Text("${car.brand} ${car.model}", fontWeight = FontWeight.Medium, fontSize = 14.sp)
                                                    Text("${car.color} · ${car.carRegistration}", fontSize = 12.sp, color = Color(0xFF8A9A94))
                                                }
                                            },
                                            onClick = {
                                                viewModel.onCarSelected(car)
                                                carExpanded = false
                                            }
                                        )
                                    }
                                }
                            }
                        }

                        Spacer(Modifier.height(12.dp))

                        OutlinedTextField(
                            value         = uiState.comment,
                            onValueChange = viewModel::onCommentChange,
                            label         = { Text("Descripción") },
                            leadingIcon   = { Icon(Icons.Filled.Description, null, tint = green) },
                            modifier      = Modifier.fillMaxWidth().height(120.dp),
                            shape         = RoundedCornerShape(12.dp),
                            maxLines      = 5,
                            colors        = OutlinedTextFieldDefaults.colors(
                                focusedBorderColor   = green,
                                unfocusedBorderColor = Color(0xFFB0CFCA),
                                focusedLabelColor    = green,
                                cursorColor          = green
                            )
                        )

                        uiState.error?.let {
                            Spacer(Modifier.height(8.dp))
                            Text(it, color = Color.Red, fontSize = 13.sp)
                        }

                        Spacer(Modifier.height(16.dp))

                        Button(
                            onClick  = viewModel::onSendProposal,
                            modifier = Modifier.fillMaxWidth().height(52.dp),
                            shape    = RoundedCornerShape(14.dp),
                            colors   = ButtonDefaults.buttonColors(containerColor = green),
                            enabled  = !uiState.isSending
                        ) {
                            if (uiState.isSending) {
                                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
                            } else {
                                Icon(Icons.Filled.Send, null, modifier = Modifier.size(20.dp))
                                Spacer(Modifier.width(8.dp))
                                Text("Enviar oferta", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
                            }
                        }
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