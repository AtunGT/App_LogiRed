package com.arthur.gloria.logired.features.main

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Assignment
import androidx.compose.material.icons.filled.BarChart
import androidx.compose.material.icons.filled.DirectionsCar
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.LocalShipping
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.TwoWheeler
import androidx.compose.ui.graphics.vector.ImageVector
import com.arthur.gloria.logired.features.navigation.Screen

sealed class BottomNavItem(
    val route: String,
    val label: String,
    val icon: ImageVector
) {
    object Solicitar   : BottomNavItem(Screen.RequestTrip.route,    "Solicitar",  Icons.Filled.Home)
    object MisMudanzas : BottomNavItem(Screen.MyTrips.route,        "Mis viajes", Icons.Filled.LocalShipping)
    object Disponibles : BottomNavItem(Screen.AvailableTrips.route, "Disponibles",Icons.Filled.DirectionsCar)
    object Aceptadas   : BottomNavItem(Screen.AcceptedTrips.route,  "Aceptadas",  Icons.Filled.Assignment)
    object Vehiculos   : BottomNavItem(Screen.Vehicles.route,       "Vehículos",  Icons.Filled.TwoWheeler)
    object Historial   : BottomNavItem(Screen.TripHistory.route,    "Historial",  Icons.Filled.History)
    object Stats       : BottomNavItem(Screen.Dashboard.route,      "Dashboard",  Icons.Filled.BarChart)
    object Cuenta      : BottomNavItem(Screen.Account.route,        "Cuenta",     Icons.Filled.Person)
}