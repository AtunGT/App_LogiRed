package com.arthur.gloria.logired.features.account.presentation.screen

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Email
import androidx.compose.material.icons.filled.LocationCity
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import com.arthur.gloria.logired.features.account.presentation.viewmodel.EditAccountViewModel

@Composable
fun EditAccountScreen(
    onBack: () -> Unit,
    viewModel: EditAccountViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val green = Color(0xFF1E7A5E)
    val bgColor = Color(0xFFF0F7F4)

    val imagePicker = rememberLauncherForActivityResult(ActivityResultContracts.GetContent()) { uri ->
        uri?.let { viewModel.onImageSelected(it) }
    }

    LaunchedEffect(uiState.success) {
        if (uiState.success) onBack()
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(bgColor)
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 24.dp)
    ) {
        Spacer(modifier = Modifier.height(48.dp))

        IconButton(onClick = onBack) {
            Icon(Icons.Filled.ArrowBack, contentDescription = null, tint = green)
        }

        Spacer(modifier = Modifier.height(8.dp))

        Text("Editar cuenta", fontSize = 26.sp, fontWeight = FontWeight.Bold, color = Color(0xFF1A1A1A))

        Spacer(modifier = Modifier.height(24.dp))

        EditField(label = "Nombre",    value = uiState.name,      onValueChange = viewModel::onNameChange,     icon = Icons.Filled.Person,        green = green)
        Spacer(modifier = Modifier.height(12.dp))
        EditField(label = "Apellido",  value = uiState.lastname,  onValueChange = viewModel::onLastnameChange, icon = Icons.Filled.Person,        green = green)
        Spacer(modifier = Modifier.height(12.dp))
        EditField(label = "Correo",    value = uiState.email,     onValueChange = viewModel::onEmailChange,    icon = Icons.Filled.Email,         green = green, keyboardType = KeyboardType.Email)
        Spacer(modifier = Modifier.height(12.dp))
        EditField(label = "Teléfono",  value = uiState.phone,     onValueChange = viewModel::onPhoneChange,    icon = Icons.Filled.Phone,         green = green, keyboardType = KeyboardType.Phone)
        Spacer(modifier = Modifier.height(12.dp))
        EditField(label = "Fecha de nacimiento (YYYY-MM-DD)", value = uiState.birthdate, onValueChange = viewModel::onBirthdateChange, icon = Icons.Filled.CalendarMonth, green = green)

        if (uiState.userType == 2) {
            Spacer(modifier = Modifier.height(12.dp))
            EditField(label = "Ciudad de trabajo", value = uiState.citywork, onValueChange = viewModel::onCityworkChange, icon = Icons.Filled.LocationCity, green = green)
        }

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedButton(
            onClick  = { imagePicker.launch("image/*") },
            modifier = Modifier.fillMaxWidth(),
            shape    = RoundedCornerShape(14.dp),
            colors   = ButtonDefaults.outlinedButtonColors(contentColor = green),
            border   = androidx.compose.foundation.BorderStroke(1.dp, green)
        ) {
            Text(if (uiState.imageUri != null) "Imagen seleccionada ✓" else "Cambiar foto de perfil")
        }

        uiState.error?.let {
            Spacer(modifier = Modifier.height(8.dp))
            Text(it, color = Color.Red, fontSize = 13.sp)
        }

        Spacer(modifier = Modifier.height(24.dp))

        Button(
            onClick  = viewModel::onSaveClick,
            modifier = Modifier.fillMaxWidth().height(52.dp),
            shape    = RoundedCornerShape(14.dp),
            colors   = ButtonDefaults.buttonColors(containerColor = green),
            enabled  = !uiState.isLoading
        ) {
            if (uiState.isLoading) {
                CircularProgressIndicator(color = Color.White, modifier = Modifier.size(24.dp))
            } else {
                Text("Guardar cambios", fontSize = 16.sp, fontWeight = FontWeight.SemiBold)
            }
        }

        Spacer(modifier = Modifier.height(32.dp))
    }
}

@Composable
private fun EditField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    green: Color,
    keyboardType: KeyboardType = KeyboardType.Text
) {
    OutlinedTextField(
        value         = value,
        onValueChange = onValueChange,
        label         = { Text(label) },
        leadingIcon   = { Icon(icon, null, tint = green) },
        modifier      = Modifier.fillMaxWidth(),
        shape         = RoundedCornerShape(14.dp),
        keyboardOptions = KeyboardOptions(keyboardType = keyboardType),
        colors        = OutlinedTextFieldDefaults.colors(
            focusedBorderColor = green,
            focusedLabelColor  = green,
            cursorColor        = green
        )
    )
}