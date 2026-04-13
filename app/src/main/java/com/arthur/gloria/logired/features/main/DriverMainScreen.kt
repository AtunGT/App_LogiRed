package com.arthur.gloria.logired.features.main

import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.arthur.gloria.logired.features.account.presentation.screen.AccountScreen
import com.arthur.gloria.logired.features.account.presentation.screen.ChangePasswordScreen
import com.arthur.gloria.logired.features.account.presentation.screen.EditAccountScreen
import com.arthur.gloria.logired.features.navigation.Screen
import com.arthur.gloria.logired.features.trip.accepted.presentation.screen.AcceptedTripsScreen
import com.arthur.gloria.logired.features.trip.active.presentation.screen.ActiveTripScreen
import com.arthur.gloria.logired.features.trip.available.presentation.screen.AvailableTripsScreen
import com.arthur.gloria.logired.features.trip.dashboard.presentation.screen.DashboardScreen
import com.arthur.gloria.logired.features.trip.driverdetail.presentation.screen.DriverTripDetailScreen
import com.arthur.gloria.logired.features.trip.history.presentation.screen.TripHistoryScreen
import com.arthur.gloria.logired.features.trip.map.presentation.screen.TripMapScreen
import com.arthur.gloria.logired.features.vehicle.presentation.screen.CarScreen

@Composable
fun DriverMainScreen(onLogout: () -> Unit) {
    val innerNav = rememberNavController()
    val green = Color(0xFF1E7A5E)
    val greenLight = Color(0xFFE8F5F0)

    val items = listOf(
        BottomNavItem.Disponibles,
        BottomNavItem.Aceptadas,
        BottomNavItem.Vehiculos,
        BottomNavItem.Historial,
        BottomNavItem.Stats,
        BottomNavItem.Cuenta
    )

    Scaffold(
        bottomBar = {
            val navBackStack by innerNav.currentBackStackEntryAsState()
            val currentDest = navBackStack?.destination

            NavigationBar(
                containerColor = Color.White,
                contentColor   = green
            ) {
                items.forEach { item ->
                    val selected = currentDest?.hierarchy?.any { it.route == item.route } == true
                    NavigationBarItem(
                        selected = selected,
                        onClick  = {
                            innerNav.navigate(item.route) {
                                popUpTo(innerNav.graph.findStartDestination().id) { saveState = true }
                                launchSingleTop = true
                                restoreState    = true
                            }
                        },
                        icon  = { Icon(item.icon, contentDescription = item.label) },
                        label = { Text(item.label) },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor   = green,
                            selectedTextColor   = green,
                            indicatorColor      = greenLight,
                            unselectedIconColor = Color(0xFF9E9E9E),
                            unselectedTextColor = Color(0xFF9E9E9E)
                        )
                    )
                }
            }
        }
    ) { innerPadding ->
        NavHost(
            navController    = innerNav,
            startDestination = Screen.AvailableTrips.route,
            modifier         = Modifier.padding(innerPadding)
        ) {
            composable(Screen.AvailableTrips.route) {
                AvailableTripsScreen(
                    onBack       = {},
                    onLogout     = onLogout,
                    onViewDetail = { tripId -> innerNav.navigate(Screen.DriverTripDetail.createRoute(tripId)) }
                )
            }

            composable(Screen.AcceptedTrips.route) {
                AcceptedTripsScreen(
                    onBack           = {},
                    onViewMap        = { tripId -> innerNav.navigate(Screen.TripMap.createRoute(tripId)) },
                    onViewActiveTrip = { tripId -> innerNav.navigate(Screen.ActiveTrip.createRoute(tripId, true)) }
                )
            }

            composable(Screen.Vehicles.route) {
                CarScreen()
            }

            composable(Screen.TripHistory.route) {
                TripHistoryScreen(
                    userType  = 2,
                    onViewMap = { tripId -> innerNav.navigate(Screen.TripMap.createRoute(tripId)) }
                )
            }

            composable(Screen.Dashboard.route) {
                DashboardScreen(userType = 2)
            }

            composable(Screen.Account.route) {
                AccountScreen(
                    onLogout         = onLogout,
                    onEditAccount    = { innerNav.navigate(Screen.EditAccount.route) },
                    onChangePassword = { innerNav.navigate(Screen.ChangePassword.route) }
                )
            }

            composable(Screen.EditAccount.route) {
                EditAccountScreen(onBack = { innerNav.popBackStack() })
            }

            composable(Screen.ChangePassword.route) {
                ChangePasswordScreen(onBack = { innerNav.popBackStack() })
            }

            composable(
                route     = Screen.DriverTripDetail.route,
                arguments = Screen.DriverTripDetail.arguments
            ) { backStackEntry ->
                val tripId = backStackEntry.arguments?.getInt("tripId") ?: 0
                DriverTripDetailScreen(
                    tripId    = tripId,
                    onBack    = { innerNav.popBackStack() },
                    onViewMap = { innerNav.navigate(Screen.TripMap.createRoute(it)) }
                )
            }

            composable(
                route     = Screen.ActiveTrip.route,
                arguments = Screen.ActiveTrip.arguments
            ) { backStackEntry ->
                val tripId   = backStackEntry.arguments?.getInt("tripId") ?: 0
                val isDriver = backStackEntry.arguments?.getBoolean("isDriver") ?: false
                ActiveTripScreen(
                    tripId          = tripId,
                    isDriver        = isDriver,
                    onBack          = { innerNav.popBackStack() },
                    onTripCompleted = { innerNav.popBackStack() }
                )
            }

            composable(
                route     = Screen.TripMap.route,
                arguments = Screen.TripMap.arguments
            ) { backStackEntry ->
                val tripId = backStackEntry.arguments?.getInt("tripId") ?: 0
                TripMapScreen(tripId = tripId, onBack = { innerNav.popBackStack() })
            }
        }
    }
}