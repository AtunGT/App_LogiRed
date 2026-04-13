package com.arthur.gloria.logired.features.navigation

import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.arthur.gloria.logired.features.login.forgotpassword.presentation.screen.ForgotPasswordScreen
import com.arthur.gloria.logired.features.login.presentation.screen.LoginScreen
import com.arthur.gloria.logired.features.login.registerclient.presentation.screen.RegisterClientScreen
import com.arthur.gloria.logired.features.login.registerdriver.presentation.screen.RegisterDriverScreen
import com.arthur.gloria.logired.features.login.verifyemail.presentation.screen.VerifyEmailScreen
import com.arthur.gloria.logired.features.roleselection.presentation.screen.RoleSelectionScreen
import com.arthur.gloria.logired.features.main.ClientMainScreen
import com.arthur.gloria.logired.features.main.DriverMainScreen

@Composable
fun NavGraph(startDestination: String = Screen.RoleSelection.route) {
    val navController = rememberNavController()

    NavHost(
        navController    = navController,
        startDestination = startDestination,
        modifier         = Modifier.fillMaxSize()
    ) {
        composable(Screen.RoleSelection.route) {
            RoleSelectionScreen(
                onClientSelected = { navController.navigate(Screen.RegisterClient.route) },
                onDriverSelected = { navController.navigate(Screen.RegisterDriver.route) },
                onLoginSelected  = { navController.navigate(Screen.Login.route) }
            )
        }

        composable(Screen.Login.route) {
            LoginScreen(
                onLoginSuccess = { userType ->
                    val dest = if (userType == 1) Screen.ClientMain.route else Screen.DriverMain.route
                    navController.navigate(dest) {
                        popUpTo(Screen.RoleSelection.route) { inclusive = true }
                    }
                },
                onBack           = { navController.popBackStack() },
                onForgotPassword = { navController.navigate(Screen.ForgotPassword.route) }
            )
        }

        composable(Screen.ForgotPassword.route) {
            ForgotPasswordScreen(onBack = { navController.popBackStack() })
        }

        composable(Screen.RegisterClient.route) {
            RegisterClientScreen(
                onRegisterSuccess = {
                    navController.navigate(Screen.Login.route) {
                        popUpTo(Screen.RegisterClient.route) { inclusive = true }
                    }
                },
                onVerifyEmail = { email ->
                    navController.navigate(Screen.VerifyEmail.createRoute(email)) {
                        popUpTo(Screen.RegisterClient.route) { inclusive = true }
                    }
                },
                onBack = { navController.popBackStack() }
            )
        }

        composable(Screen.RegisterDriver.route) {
            RegisterDriverScreen(
                onRegisterSuccess = {
                    navController.navigate(Screen.Login.route) {
                        popUpTo(Screen.RegisterDriver.route) { inclusive = true }
                    }
                },
                onVerifyEmail = { email ->
                    navController.navigate(Screen.VerifyEmail.createRoute(email)) {
                        popUpTo(Screen.RegisterDriver.route) { inclusive = true }
                    }
                },
                onBack = { navController.popBackStack() }
            )
        }

        composable(
            route     = Screen.VerifyEmail.route,
            arguments = Screen.VerifyEmail.arguments
        ) { backStack ->
            val email = backStack.arguments?.getString("email") ?: ""
            VerifyEmailScreen(
                email       = email,
                onGoToLogin = {
                    navController.navigate(Screen.Login.route) {
                        popUpTo(0) { inclusive = true }
                    }
                }
            )
        }

        composable(Screen.ClientMain.route) {
            ClientMainScreen(
                onLogout = {
                    navController.navigate(Screen.RoleSelection.route) {
                        popUpTo(0) { inclusive = true }
                    }
                }
            )
        }

        composable(Screen.DriverMain.route) {
            DriverMainScreen(
                onLogout = {
                    navController.navigate(Screen.RoleSelection.route) {
                        popUpTo(0) { inclusive = true }
                    }
                }
            )
        }
    }
}