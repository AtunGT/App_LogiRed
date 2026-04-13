package com.arthur.gloria.logired.features.vehicle.presentation.viewmodel

import android.net.Uri
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.arthur.gloria.logired.core.network.model.Car
import com.arthur.gloria.logired.features.vehicle.domain.model.CarData
import com.arthur.gloria.logired.features.vehicle.domain.usecase.CreateCarUseCase
import com.arthur.gloria.logired.features.vehicle.domain.usecase.DeleteCarUseCase
import com.arthur.gloria.logired.features.vehicle.domain.usecase.GetMyCarsUseCase
import com.arthur.gloria.logired.features.vehicle.domain.usecase.UpdateCarUseCase
import com.arthur.gloria.logired.features.vehicle.presentation.ui.CarUiState
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class CarViewModel @Inject constructor(
    private val getMyCarsUseCase: GetMyCarsUseCase,
    private val createCarUseCase: CreateCarUseCase,
    private val updateCarUseCase: UpdateCarUseCase,
    private val deleteCarUseCase: DeleteCarUseCase,
    private val savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val _uiState = MutableStateFlow(
        CarUiState(
            showForm        = savedStateHandle.get<Boolean>("showForm") ?: false,
            editingCarId    = savedStateHandle.get<Int>("editingCarId"),
            carRegistration = savedStateHandle.get<String>("carRegistration") ?: "",
            brand           = savedStateHandle.get<String>("brand") ?: "",
            model           = savedStateHandle.get<String>("model") ?: "",
            year            = savedStateHandle.get<String>("year") ?: "",
            color           = savedStateHandle.get<String>("color") ?: "",
            maxCapacity     = savedStateHandle.get<String>("maxCapacity") ?: "",
            frontViewUri    = savedStateHandle.get<String>("frontViewUri")?.let { Uri.parse(it) },
            backViewUri     = savedStateHandle.get<String>("backViewUri")?.let { Uri.parse(it) },
            platesUri       = savedStateHandle.get<String>("platesUri")?.let { Uri.parse(it) },
            spacesUri       = savedStateHandle.get<String>("spacesUri")?.let { Uri.parse(it) }
        )
    )
    val uiState: StateFlow<CarUiState> = _uiState.asStateFlow()

    init { loadCars() }

    fun loadCars() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            getMyCarsUseCase()
                .onSuccess { cars -> _uiState.update { it.copy(isLoading = false, cars = cars) } }
                .onFailure { e -> _uiState.update { it.copy(isLoading = false, error = e.message) } }
        }
    }

    fun onCarRegistrationChange(v: String) {
        savedStateHandle["carRegistration"] = v
        _uiState.update { it.copy(carRegistration = v) }
    }

    fun onBrandChange(v: String) {
        savedStateHandle["brand"] = v
        _uiState.update { it.copy(brand = v) }
    }

    fun onModelChange(v: String) {
        savedStateHandle["model"] = v
        _uiState.update { it.copy(model = v) }
    }

    fun onYearChange(v: String) {
        savedStateHandle["year"] = v
        _uiState.update { it.copy(year = v) }
    }

    fun onColorChange(v: String) {
        savedStateHandle["color"] = v
        _uiState.update { it.copy(color = v) }
    }

    fun onMaxCapacityChange(v: String) {
        savedStateHandle["maxCapacity"] = v
        _uiState.update { it.copy(maxCapacity = v) }
    }

    fun onFrontViewSelected(uri: Uri) {
        savedStateHandle["frontViewUri"] = uri.toString()
        _uiState.update { it.copy(frontViewUri = uri) }
    }

    fun onBackViewSelected(uri: Uri) {
        savedStateHandle["backViewUri"] = uri.toString()
        _uiState.update { it.copy(backViewUri = uri) }
    }

    fun onPlatesSelected(uri: Uri) {
        savedStateHandle["platesUri"] = uri.toString()
        _uiState.update { it.copy(platesUri = uri) }
    }

    fun onSpacesSelected(uri: Uri) {
        savedStateHandle["spacesUri"] = uri.toString()
        _uiState.update { it.copy(spacesUri = uri) }
    }

    fun setPendingFrontUri(uri: Uri)  { savedStateHandle["pendingFrontUri"]  = uri.toString() }
    fun setPendingBackUri(uri: Uri)   { savedStateHandle["pendingBackUri"]   = uri.toString() }
    fun setPendingPlatesUri(uri: Uri) { savedStateHandle["pendingPlatesUri"] = uri.toString() }
    fun setPendingSpacesUri(uri: Uri) { savedStateHandle["pendingSpacesUri"] = uri.toString() }

    fun getPendingFrontUri()  = savedStateHandle.get<String>("pendingFrontUri")?.let  { Uri.parse(it) }
    fun getPendingBackUri()   = savedStateHandle.get<String>("pendingBackUri")?.let   { Uri.parse(it) }
    fun getPendingPlatesUri() = savedStateHandle.get<String>("pendingPlatesUri")?.let { Uri.parse(it) }
    fun getPendingSpacesUri() = savedStateHandle.get<String>("pendingSpacesUri")?.let { Uri.parse(it) }

    fun showCreateForm() {
        savedStateHandle["showForm"]        = true
        savedStateHandle["editingCarId"]    = null
        savedStateHandle["carRegistration"] = ""
        savedStateHandle["brand"]           = ""
        savedStateHandle["model"]           = ""
        savedStateHandle["year"]            = ""
        savedStateHandle["color"]           = ""
        savedStateHandle["maxCapacity"]     = ""
        savedStateHandle["frontViewUri"]    = null
        savedStateHandle["backViewUri"]     = null
        savedStateHandle["platesUri"]       = null
        savedStateHandle["spacesUri"]       = null
        savedStateHandle["pendingFrontUri"] = null
        savedStateHandle["pendingBackUri"]  = null
        savedStateHandle["pendingPlatesUri"]= null
        savedStateHandle["pendingSpacesUri"]= null
        _uiState.update {
            it.copy(
                showForm        = true,
                editingCarId    = null,
                carRegistration = "",
                brand           = "",
                model           = "",
                year            = "",
                color           = "",
                maxCapacity     = "",
                frontViewUri    = null,
                backViewUri     = null,
                platesUri       = null,
                spacesUri       = null,
                error           = null,
                successMessage  = null
            )
        }
    }

    fun showEditForm(car: Car) {
        savedStateHandle["showForm"]        = true
        savedStateHandle["editingCarId"]    = car.id
        savedStateHandle["carRegistration"] = car.carRegistration
        savedStateHandle["brand"]           = car.brand
        savedStateHandle["model"]           = car.model
        savedStateHandle["year"]            = ""
        savedStateHandle["color"]           = car.color
        savedStateHandle["maxCapacity"]     = car.maxCapacity.toString()
        savedStateHandle["frontViewUri"]    = null
        savedStateHandle["backViewUri"]     = null
        savedStateHandle["platesUri"]       = null
        savedStateHandle["spacesUri"]       = null
        savedStateHandle["pendingFrontUri"] = null
        savedStateHandle["pendingBackUri"]  = null
        savedStateHandle["pendingPlatesUri"]= null
        savedStateHandle["pendingSpacesUri"]= null
        _uiState.update {
            it.copy(
                showForm        = true,
                editingCarId    = car.id,
                carRegistration = car.carRegistration,
                brand           = car.brand,
                model           = car.model,
                year            = "",
                color           = car.color,
                maxCapacity     = car.maxCapacity.toString(),
                frontViewUri    = null,
                backViewUri     = null,
                platesUri       = null,
                spacesUri       = null,
                error           = null,
                successMessage  = null
            )
        }
    }

    fun hideForm() {
        savedStateHandle["showForm"] = false
        _uiState.update { it.copy(showForm = false, error = null) }
    }

    fun onSave() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            val s = _uiState.value
            val carData = CarData(
                carRegistration = s.carRegistration,
                brand           = s.brand,
                model           = s.model,
                color           = s.color,
                maxCapacity     = s.maxCapacity.toIntOrNull() ?: 0,
                frontViewUri    = s.frontViewUri,
                backViewUri     = s.backViewUri,
                platesUri       = s.platesUri,
                spacesUri       = s.spacesUri
            )
            val result = if (s.editingCarId == null) {
                createCarUseCase(carData)
            } else {
                updateCarUseCase(s.editingCarId, carData)
            }
            result
                .onSuccess {
                    savedStateHandle["showForm"]     = false
                    savedStateHandle["frontViewUri"] = null
                    savedStateHandle["backViewUri"]  = null
                    savedStateHandle["platesUri"]    = null
                    savedStateHandle["spacesUri"]    = null
                    _uiState.update {
                        it.copy(
                            isLoading      = false,
                            showForm       = false,
                            successMessage = if (s.editingCarId == null) "Vehículo registrado" else "Vehículo actualizado"
                        )
                    }
                    loadCars()
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoading = false, error = e.message) }
                }
        }
    }

    fun showDeleteDialog(carId: Int) = _uiState.update { it.copy(showDeleteDialog = carId) }
    fun hideDeleteDialog()           = _uiState.update { it.copy(showDeleteDialog = null) }

    fun onDelete(carId: Int) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, showDeleteDialog = null) }
            deleteCarUseCase(carId)
                .onSuccess {
                    _uiState.update { it.copy(isLoading = false, successMessage = "Vehículo eliminado") }
                    loadCars()
                }
                .onFailure { e ->
                    _uiState.update { it.copy(isLoading = false, error = e.message) }
                }
        }
    }

    fun clearMessages() = _uiState.update { it.copy(successMessage = null, error = null) }
}