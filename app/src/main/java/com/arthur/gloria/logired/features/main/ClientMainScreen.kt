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
import com.arthur.gloria.logired.features.trip.active.presentation.screen.ActiveTripScreen
import com.arthur.gloria.logired.features.trip.dashboard.presentation.screen.DashboardScreen
import com.arthur.gloria.logired.features.trip.detail.presentation.screen.TripDetailScreen
import com.arthur.gloria.logired.features.trip.history.presentation.screen.TripHistoryScreen
import com.arthur.gloria.logired.features.trip.map.presentation.screen.TripMapScreen
import com.arthur.gloria.logired.features.trip.mytrips.presentation.screen.MyTripsScreen
import com.arthur.gloria.logired.features.trip.proposals.presentation.screen.TripProposalsScreen
import com.arthur.gloria.logired.features.trip.request.presentation.screen.RequestTripScreen

@Composable
fun ClientMainScreen(onLogout: () -> Unit) {
    val innerNav = rememberNavController()
    val green = Color(0xFF1E7A5E)
    val greenLight = Color(0xFFE8F5F0)

    val items = listOf(
        BottomNavItem.Solicitar,
        BottomNavItem.MisMudanzas,
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
            startDestination = Screen.RequestTrip.route,
            modifier         = Modifier.padding(innerPadding)
        ) {
            composable(Screen.RequestTrip.route) {
                RequestTripScreen(
                    onRequestSuccess = {
                        innerNav.navigate(Screen.MyTrips.route) {
                            popUpTo(Screen.RequestTrip.route) { inclusive = true }
                        }
                    },
                    onBack   = {},
                    onLogout = onLogout
                )
            }

            composable(Screen.MyTrips.route) {
                MyTripsScreen(
                    onBack           = {},
                    onViewDetails    = { tripId -> innerNav.navigate(Screen.TripDetail.createRoute(tripId)) },
                    onViewProposals  = { tripId -> innerNav.navigate(Screen.TripProposals.createRoute(tripId)) },
                    onViewActiveTrip = { tripId -> innerNav.navigate(Screen.ActiveTrip.createRoute(tripId, false)) }
                )
            }

            composable(Screen.TripHistory.route) {
                TripHistoryScreen(
                    userType  = 1,
                    onViewMap = { tripId -> innerNav.navigate(Screen.TripMap.createRoute(tripId)) }
                )
            }

            composable(Screen.Dashboard.route) {
                DashboardScreen(userType = 1)
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
                route     = Screen.TripDetail.route,
                arguments = Screen.TripDetail.arguments
            ) { backStackEntry ->
                val tripId = backStackEntry.arguments?.getInt("tripId") ?: 0
                TripDetailScreen(
                    tripId    = tripId,
                    onBack    = { innerNav.popBackStack() },
                    onViewMap = { innerNav.navigate(Screen.TripMap.createRoute(it)) }
                )
            }

            composable(
                route     = Screen.TripProposals.route,
                arguments = Screen.TripProposals.arguments
            ) { backStackEntry ->
                val tripId = backStackEntry.arguments?.getInt("tripId") ?: 0
                TripProposalsScreen(
                    tripId = tripId,
                    onBack = { innerNav.popBackStack() }
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
                TripMapScreen(
                    tripId = tripId,
                    onBack = { innerNav.popBackStack() }
                )
            }
        }
    }
}