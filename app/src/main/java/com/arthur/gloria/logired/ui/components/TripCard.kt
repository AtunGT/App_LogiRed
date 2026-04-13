package com.arthur.gloria.logired.ui.components

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.arthur.gloria.logired.core.network.model.Trip

@Composable
fun TripCard(
    trip: Trip,
    modifier: Modifier = Modifier,
    showActionButton: Boolean = false,
    actionButtonText: String = "",
    onActionClick: (() -> Unit)? = null
) {
    val green = Color(0xFF1E7A5E)
    val lightGreen = Color(0xFFE8F5F0)

    val statusLabel = when (trip.status) {
        1 -> "Agendado"; 2 -> "En camino"; 3 -> "En proceso"
        4 -> "Cancelado"; 5 -> "Completado"; 6 -> "Publicado"
        else -> "Estado ${trip.status}"
    }

    val statusBgColor = when (trip.status) {
        1 -> Color(0xFFCFE2FF); 2 -> lightGreen; 3 -> Color(0xFFFFF3CD)
        4 -> Color(0xFFFFE0E0); 5 -> lightGreen; 6 -> Color(0xFFFFF3CD)
        else -> Color.LightGray
    }

    val statusTextColor = when (trip.status) {
        1 -> Color(0xFF084298); 2 -> green; 3 -> Color(0xFF856404)
        4 -> Color.Red; 5 -> green; 6 -> Color(0xFF856404)
        else -> Color.DarkGray
    }

    Card(
        modifier  = modifier.fillMaxWidth(),
        shape     = RoundedCornerShape(16.dp),
        colors    = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text("Viaje", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
                Surface(shape = RoundedCornerShape(8.dp), color = statusBgColor) {
                    Text(
                        statusLabel,
                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                        fontSize = 12.sp,
                        fontWeight = FontWeight.Medium,
                        color = statusTextColor
                    )
                }
            }

            Spacer(Modifier.height(16.dp))

            Row(verticalAlignment = Alignment.Top) {
                Icon(Icons.Filled.LocationOn, null, tint = green, modifier = Modifier.size(20.dp))
                Spacer(Modifier.width(8.dp))
                Column {
                    Text("Origen", fontSize = 12.sp, color = Color(0xFF8A9A94))
                    Text(trip.origin.ifBlank { "—" }, fontSize = 14.sp, color = Color(0xFF1A1A1A), fontWeight = FontWeight.Medium)
                    Text(trip.origin_city.ifBlank { "—" }, fontSize = 12.sp, color = Color(0xFF8A9A94))
                }
            }

            Spacer(Modifier.height(12.dp))

            Row(verticalAlignment = Alignment.Top) {
                Icon(Icons.Filled.Flag, null, tint = green, modifier = Modifier.size(20.dp))
                Spacer(Modifier.width(8.dp))
                Column {
                    Text("Destino", fontSize = 12.sp, color = Color(0xFF8A9A94))
                    Text(trip.destination.ifBlank { "—" }, fontSize = 14.sp, color = Color(0xFF1A1A1A), fontWeight = FontWeight.Medium)
                }
            }

            Spacer(Modifier.height(12.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Filled.CalendarMonth, null, tint = green, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(6.dp))
                    Text(trip.date.take(10).ifBlank { "—" }, fontSize = 13.sp, color = Color(0xFF1A1A1A))
                }
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Filled.Schedule, null, tint = green, modifier = Modifier.size(18.dp))
                    Spacer(Modifier.width(6.dp))
                    Text(trip.hour.take(5).ifBlank { "—" }, fontSize = 13.sp, color = Color(0xFF1A1A1A))
                }
            }

            if (showActionButton && onActionClick != null) {
                Spacer(Modifier.height(16.dp))
                Button(
                    onClick  = onActionClick,
                    modifier = Modifier.fillMaxWidth().height(44.dp),
                    shape    = RoundedCornerShape(12.dp),
                    colors   = ButtonDefaults.buttonColors(containerColor = green)
                ) {
                    Text(actionButtonText, fontSize = 15.sp, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}