package com.arthur.gloria.logired.features.trip.proposals.presentation.screen

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.SubcomposeAsyncImage
import com.arthur.gloria.logired.core.network.model.ProposalWithDetails
import com.arthur.gloria.logired.features.trip.proposals.presentation.viewmodel.TripProposalsViewModel

@Composable
fun TripProposalsScreen(
    tripId: Int,
    onBack: () -> Unit,
    viewModel: TripProposalsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green   = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)

    LaunchedEffect(tripId) { viewModel.loadProposals(tripId) }

    LaunchedEffect(uiState.successMessage) {
        if (uiState.successMessage != null) {
            kotlinx.coroutines.delay(2000)
            viewModel.clearMessages()
        }
    }

    Column(modifier = Modifier.fillMaxSize().background(bgColor)) {
        Surface(color = Color.White, shadowElevation = 2.dp) {
            Row(
                modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onBack) {
                    Icon(Icons.Filled.ArrowBack, null, tint = green)
                }
                Column {
                    Text("Ofertas recibidas", fontSize = 20.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))
                    if (!uiState.isLoading) {
                        Text(
                            "${uiState.proposals.size} oferta${if (uiState.proposals.size != 1) "s" else ""}",
                            fontSize = 13.sp,
                            color = Color(0xFF7A9A8E)
                        )
                    }
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
                    Text(uiState.error!!, color = Color.Red, fontSize = 16.sp)
                    Spacer(Modifier.height(16.dp))
                    Button(onClick = { viewModel.loadProposals(tripId) }, colors = ButtonDefaults.buttonColors(containerColor = green)) {
                        Text("Reintentar")
                    }
                }
            }
            uiState.proposals.isEmpty() -> {
                Column(
                    Modifier.fillMaxSize().padding(24.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.Center
                ) {
                    Icon(Icons.Filled.Inbox, null, tint = Color(0xFF8A9A94), modifier = Modifier.size(80.dp))
                    Spacer(Modifier.height(16.dp))
                    Text("Sin ofertas aún", fontSize = 18.sp, fontWeight = FontWeight.Medium, color = Color(0xFF1A1A1A))
                    Spacer(Modifier.height(8.dp))
                    Text("Los conductores aún no han enviado ofertas", fontSize = 14.sp, color = Color(0xFF8A9A94))
                }
            }
            else -> {
                LazyColumn(
                    Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    items(uiState.proposals) { proposalWithDetails ->
                        val resolved = uiState.resolvedProposals[proposalWithDetails.proposal.id]
                        ProposalCard(
                            details   = proposalWithDetails,
                            green     = green,
                            resolved  = resolved,
                            onAccept  = { viewModel.acceptProposal(proposalWithDetails.proposal.id) },
                            onReject  = { viewModel.rejectProposal(proposalWithDetails.proposal.id) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ProposalCard(
    details: ProposalWithDetails,
    green: Color,
    resolved: Boolean?,
    onAccept: () -> Unit,
    onReject: () -> Unit
) {
    Card(
        modifier  = Modifier.fillMaxWidth(),
        shape     = RoundedCornerShape(16.dp),
        colors    = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(2.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {


            Text("Conductor", fontSize = 12.sp, color = Color(0xFF8A9A94), fontWeight = FontWeight.Medium)
            Spacer(Modifier.height(8.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier.size(48.dp).clip(CircleShape).background(green),
                    contentAlignment = Alignment.Center
                ) {
                    if (details.driverImage.isNotBlank()) {
                        SubcomposeAsyncImage(
                            model              = details.driverImage,
                            contentDescription = "Foto conductor",
                            contentScale       = ContentScale.Crop,
                            modifier           = Modifier.fillMaxSize(),
                            error = { Icon(Icons.Filled.Person, null, tint = Color.White, modifier = Modifier.size(28.dp)) }
                        )
                    } else {
                        Icon(Icons.Filled.Person, null, tint = Color.White, modifier = Modifier.size(28.dp))
                    }
                }
                Spacer(Modifier.width(10.dp))
                Text(details.driverName.ifBlank { "Conductor" }, fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = Color(0xFF1A1A1A))
            }

            Spacer(Modifier.height(12.dp))
            HorizontalDivider(color = Color(0xFFF0F0F0))
            Spacer(Modifier.height(12.dp))


            Text("Vehículo", fontSize = 12.sp, color = Color(0xFF8A9A94), fontWeight = FontWeight.Medium)
            Spacer(Modifier.height(8.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                if (details.carImage.isNotBlank()) {
                    SubcomposeAsyncImage(
                        model              = details.carImage,
                        contentDescription = "Foto carro",
                        contentScale       = ContentScale.Crop,
                        modifier           = Modifier.size(64.dp).clip(RoundedCornerShape(10.dp)).background(Color(0xFFF0F0F0)),
                        error = {
                            Box(modifier = Modifier.fillMaxSize().background(Color(0xFFE8F5F0)), contentAlignment = Alignment.Center) {
                                Icon(Icons.Filled.DirectionsCar, null, tint = green, modifier = Modifier.size(32.dp))
                            }
                        }
                    )
                } else {
                    Box(modifier = Modifier.size(64.dp).clip(RoundedCornerShape(10.dp)).background(Color(0xFFE8F5F0)), contentAlignment = Alignment.Center) {
                        Icon(Icons.Filled.DirectionsCar, null, tint = green, modifier = Modifier.size(32.dp))
                    }
                }
                Spacer(Modifier.width(12.dp))
                Column {
                    Text("${details.carBrand} ${details.carModel}".trim().ifBlank { "Vehículo" }, fontSize = 15.sp, fontWeight = FontWeight.SemiBold, color = Color(0xFF1A1A1A))
                    if (details.carColor.isNotBlank()) Text(details.carColor, fontSize = 13.sp, color = Color(0xFF7A9A8E))
                    if (details.carRegistration.isNotBlank()) Text(details.carRegistration, fontSize = 12.sp, color = Color(0xFF9A9A9A))
                }
            }

            Spacer(Modifier.height(12.dp))
            HorizontalDivider(color = Color(0xFFF0F0F0))
            Spacer(Modifier.height(12.dp))


            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Filled.AttachMoney, null, tint = green, modifier = Modifier.size(22.dp))
                    Text("${details.proposal.price}", fontSize = 22.sp, fontWeight = FontWeight.Bold, color = green)
                }
                Surface(shape = RoundedCornerShape(8.dp), color = Color(0xFFE8F5F0)) {
                    Text("Oferta #${details.proposal.id}", modifier = Modifier.padding(horizontal = 10.dp, vertical = 5.dp), fontSize = 12.sp, color = green, fontWeight = FontWeight.Medium)
                }
            }

            if (details.proposal.comment.isNotBlank()) {
                Spacer(Modifier.height(10.dp))
                Row(verticalAlignment = Alignment.Top) {
                    Icon(Icons.Filled.Description, null, tint = Color(0xFF8A9A94), modifier = Modifier.size(16.dp))
                    Spacer(Modifier.width(6.dp))
                    Column {
                        Text("Descripción", fontSize = 11.sp, color = Color(0xFF8A9A94))
                        Text(details.proposal.comment, fontSize = 14.sp, color = Color(0xFF1A1A1A))
                    }
                }
            }

            Spacer(Modifier.height(16.dp))


            when (resolved) {
                true -> {
                    Surface(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(10.dp), color = Color(0xFFE8F5F0)) {
                        Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Center) {
                            Icon(Icons.Filled.CheckCircle, null, tint = green, modifier = Modifier.size(20.dp))
                            Spacer(Modifier.width(8.dp))
                            Text("Oferta aceptada", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = green)
                        }
                    }
                }
                false -> {
                    Surface(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(10.dp), color = Color(0xFFFFE0E0)) {
                        Row(modifier = Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.Center) {
                            Icon(Icons.Filled.Cancel, null, tint = Color.Red, modifier = Modifier.size(20.dp))
                            Spacer(Modifier.width(8.dp))
                            Text("Oferta rechazada", fontSize = 14.sp, fontWeight = FontWeight.SemiBold, color = Color.Red)
                        }
                    }
                }
                null -> {
                    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        OutlinedButton(
                            onClick  = onReject,
                            modifier = Modifier.weight(1f).height(44.dp),
                            shape    = RoundedCornerShape(10.dp),
                            colors   = ButtonDefaults.outlinedButtonColors(contentColor = Color.Red),
                            border   = androidx.compose.foundation.BorderStroke(1.dp, Color.Red)
                        ) {
                            Icon(Icons.Filled.Close, null, modifier = Modifier.size(16.dp))
                            Spacer(Modifier.width(4.dp))
                            Text("Rechazar", fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                        }
                        Button(
                            onClick  = onAccept,
                            modifier = Modifier.weight(1f).height(44.dp),
                            shape    = RoundedCornerShape(10.dp),
                            colors   = ButtonDefaults.buttonColors(containerColor = green)
                        ) {
                            Icon(Icons.Filled.Check, null, modifier = Modifier.size(16.dp))
                            Spacer(Modifier.width(4.dp))
                            Text("Aceptar", fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                        }
                    }
                }
            }
        }
    }
}