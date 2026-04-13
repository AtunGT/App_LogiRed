package com.arthur.gloria.logired.features.navigation

import androidx.navigation.NavType
import androidx.navigation.navArgument

sealed class Screen(val route: String) {
    object RoleSelection  : Screen("role_selection")
    object Login          : Screen("login")
    object ForgotPassword : Screen("forgot_password")
    object RegisterClient : Screen("register_client")
    object RegisterDriver : Screen("register_driver")
    object ClientMain     : Screen("client_main")
    object DriverMain     : Screen("driver_main")
    object RequestTrip    : Screen("request_trip")
    object MyTrips        : Screen("my_trips")
    object AvailableTrips : Screen("available_trips")
    object AcceptedTrips  : Screen("accepted_trips")
    object TripHistory    : Screen("trip_history")
    object Dashboard      : Screen("dashboard")
    object Vehicles       : Screen("vehicles")

    object Account : Screen("account")

    object VerifyEmail : Screen("verify_email/{email}") {
        val arguments = listOf(navArgument("email") { type = NavType.StringType })
        fun createRoute(email: String) = "verify_email/$email"
    }

    object EditAccount : Screen("edit_account")

    object TripMap : Screen("trip_map/{tripId}") {
        val arguments = listOf(navArgument("tripId") { type = NavType.IntType })
        fun createRoute(tripId: Int) = "trip_map/$tripId"
    }

    object ChangePassword : Screen("change_password")

    object TripDetail : Screen("trip_detail/{tripId}") {
        val arguments = listOf(navArgument("tripId") { type = NavType.IntType })
        fun createRoute(tripId: Int) = "trip_detail/$tripId"

    }

    object DriverTripDetail : Screen("driver_trip_detail/{tripId}") {
        val arguments = listOf(navArgument("tripId") { type = NavType.IntType })
        fun createRoute(tripId: Int) = "driver_trip_detail/$tripId"
    }

    object TripProposals : Screen("trip_proposals/{tripId}") {
        val arguments = listOf(navArgument("tripId") { type = NavType.IntType })
        fun createRoute(tripId: Int) = "trip_proposals/$tripId"
    }

    object ActiveTrip : Screen("active_trip/{tripId}/{isDriver}") {
        val arguments = listOf(
            navArgument("tripId") { type = NavType.IntType },
            navArgument("isDriver") { type = NavType.BoolType }
        )
        fun createRoute(tripId: Int, isDriver: Boolean) = "active_trip/$tripId/$isDriver"
    }

}