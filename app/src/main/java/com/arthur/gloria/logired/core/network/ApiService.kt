package com.arthur.gloria.logired.core.network

import com.arthur.gloria.logired.core.network.model.CarResponse
import com.arthur.gloria.logired.core.network.model.CarsResponse
import com.arthur.gloria.logired.core.network.model.DeviceTokenRequest
import com.arthur.gloria.logired.core.network.model.LoginRequest
import com.arthur.gloria.logired.core.network.model.LoginResponse
import com.arthur.gloria.logired.core.network.model.ProposalRequest
import com.arthur.gloria.logired.core.network.model.ProposalStatusRequest
import com.arthur.gloria.logired.core.network.model.ProposalsResponse
import com.arthur.gloria.logired.core.network.model.ResetPasswordRequest
import com.arthur.gloria.logired.core.network.model.RideResponse
import com.arthur.gloria.logired.core.network.model.RidesResponse
import com.arthur.gloria.logired.core.network.model.TripRequest
import com.arthur.gloria.logired.core.network.model.TripResponse
import com.arthur.gloria.logired.core.network.model.UpdatePasswordRequest
import com.arthur.gloria.logired.core.network.model.UpdateStatusRequest
import com.arthur.gloria.logired.core.network.model.UserResponse
import okhttp3.MultipartBody
import okhttp3.RequestBody
import retrofit2.Response
import retrofit2.http.*

interface ApiService {

    @Multipart
    @POST("users")
    suspend fun createUser(
        @Part("name") name: RequestBody,
        @Part("lastname") lastname: RequestBody,
        @Part("email") email: RequestBody,
        @Part("numberphone") numberphone: RequestBody,
        @Part("birthdate") birthdate: RequestBody,
        @Part("password") password: RequestBody,
        @Part("user_type") userType: RequestBody,
        @Part image: MultipartBody.Part?,
        @Part("citywork") citywork: RequestBody? = null
    ): Response<UserResponse>

    @POST("auth/login")
    suspend fun login(@Body request: LoginRequest): Response<LoginResponse>

    @POST("rides")
    suspend fun createTrip(@Body request: TripRequest): Response<TripResponse>

    @GET("rides/{id}")
    suspend fun getRideById(@Path("id") id: Int): Response<RideResponse>

    @GET("rides/city/{city}")
    suspend fun getTripsByCity(@Path("city") city: String): Response<RidesResponse>

    @GET("rides/driver/me")
    suspend fun getMyAcceptedTrips(): Response<RidesResponse>

    @GET("rides/client/me")
    suspend fun getMyRequestedTrips(): Response<RidesResponse>

    @PUT("rides/{id}/accept")
    suspend fun acceptTrip(@Path("id") tripId: Int): Response<Unit>

    @PUT("rides/{id}/status")
    suspend fun updateRideStatus(
        @Path("id") id: Int,
        @Body request: UpdateStatusRequest
    ): Response<Unit>

    @PUT("devices/token")
    suspend fun registerDeviceToken(@Body request: DeviceTokenRequest): Response<Unit>

    @GET("cars")
    suspend fun getMyCars(): Response<CarsResponse>

    @GET("cars/{id}")
    suspend fun getCarById(@Path("id") id: Int): Response<CarResponse>

    @Multipart
    @POST("cars")
    suspend fun createCar(
        @Part("car_registration") carRegistration: RequestBody,
        @Part("brand")            brand: RequestBody,
        @Part("model")            model: RequestBody,
        @Part("color")            color: RequestBody,
        @Part("max_capacity")     maxCapacity: RequestBody,
        @Part frontViewImage: MultipartBody.Part? = null,
        @Part backViewImage: MultipartBody.Part?  = null,
        @Part platesImage: MultipartBody.Part?    = null,
        @Part spacesImage: MultipartBody.Part?    = null
    ): Response<Unit>

    @Multipart
    @PUT("cars/{id}")
    suspend fun updateCar(
        @Path("id")               id: Int,
        @Part("car_registration") carRegistration: RequestBody,
        @Part("brand")            brand: RequestBody,
        @Part("model")            model: RequestBody,
        @Part("color")            color: RequestBody,
        @Part("max_capacity")     maxCapacity: RequestBody,
        @Part frontViewImage: MultipartBody.Part? = null,
        @Part backViewImage: MultipartBody.Part?  = null,
        @Part platesImage: MultipartBody.Part?    = null,
        @Part spacesImage: MultipartBody.Part?    = null
    ): Response<Unit>

    @DELETE("cars/{id}")
    suspend fun deleteCar(@Path("id") id: Int): Response<Unit>

    @PUT("users/password-reset")
    suspend fun resetPassword(@Body request: ResetPasswordRequest): Response<Unit>

    @GET("users/profile/{id}")
    suspend fun getUserProfile(@Path("id") id: Int): Response<UserResponse>

    @Multipart
    @PUT("users/{id}")
    suspend fun updateUser(
        @Path("id") id: Int,
        @Part("name") name: RequestBody,
        @Part("lastname") lastname: RequestBody,
        @Part("birthdate") birthdate: RequestBody,
        @Part("numberphone") numberphone: RequestBody,
        @Part("email") email: RequestBody,
        @Part image: MultipartBody.Part? = null,
        @Part("citywork") citywork: RequestBody? = null
    ): Response<Unit>

    @PUT("users/update-password")
    suspend fun updatePassword(@Body request: UpdatePasswordRequest): Response<Unit>

    @POST("proposals")
    suspend fun sendProposal(@Body request: ProposalRequest): Response<Unit>

    @GET("proposals/ride/{tripId}")
    suspend fun getProposalsByRide(@Path("tripId") tripId: Int): Response<ProposalsResponse>

    @PUT("proposals/{id}/accept")
    suspend fun updateProposalStatus(
        @Path("id") id: Int,
        @Body request: ProposalStatusRequest
    ): Response<Unit>

}