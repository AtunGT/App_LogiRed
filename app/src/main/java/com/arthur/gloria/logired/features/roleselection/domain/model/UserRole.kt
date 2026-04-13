package com.arthur.gloria.logired.features.roleselection.domain.model

sealed class UserRole {
    object Client : UserRole()
    object Driver : UserRole()
}