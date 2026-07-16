/// La API devuelve "" en vez de null en campos de imagen; normaliza a null
/// para que los checks `!= null` de la UI sean suficientes.
String? _nonEmpty(dynamic v) {
  final s = v?.toString().trim();
  return (s == null || s.isEmpty) ? null : s;
}

class LoginRequest {
  final String email;
  final String password;
  LoginRequest({required this.email, required this.password});
  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class LoginResponse {
  final String message;
  final int userId;
  final int userType;
  LoginResponse(
      {required this.message, required this.userId, required this.userType});
  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        message: json['message'] ?? '',
        userId: json['data']?['iduser'] ?? 0,
        userType: json['data']?['usertype'] ?? 1,
      );
}

class UserResponse {
  final int iduser;
  final String name;
  final String lastname;
  final String email;
  final String numberPhone;
  final String birthdate;
  final int userType;
  final String? imageUrl;
  final double? rating;
  final int? totalTrips;

  UserResponse({
    required this.iduser,
    required this.name,
    required this.lastname,
    required this.email,
    required this.numberPhone,
    required this.birthdate,
    required this.userType,
    this.imageUrl,
    this.rating,
    this.totalTrips,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    final d = json['data'] ?? json;
    return UserResponse(
      iduser: d['iduser'] ?? 0,
      name: d['name'] ?? '',
      lastname: d['lastname'] ?? '',
      email: d['email'] ?? '',
      numberPhone: d['number_phone'] ?? d['numberphone'] ?? '',
      birthdate: d['birthdate'] ?? '',
      userType: d['user_type'] ?? 1,
      imageUrl: _nonEmpty(d['image_url']),
      rating: (d['rating'] as num?)?.toDouble(),
      totalTrips: (d['total_trips'] as num?)?.toInt(),
    );
  }
}

class Trip {
  final int id;
  final String origin;
  final String destination;
  final String city;
  final double originLat;
  final double originLng;
  final double destinationLat;
  final double destinationLng;
  final String date;
  final String hour;
  final double approxWeight;
  final String? description;
  final int status;
  final int clientId;
  final int? driverId;
  final double? distanceKm;
  final String? createdAt;
  final int? paymentMethod;
  final int? paymentStatus;

  Trip({
    required this.id,
    required this.origin,
    required this.destination,
    required this.city,
    required this.originLat,
    required this.originLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.date,
    required this.hour,
    required this.approxWeight,
    this.description,
    required this.status,
    required this.clientId,
    this.driverId,
    this.distanceKm,
    this.createdAt,
    this.paymentMethod,
    this.paymentStatus,
  });

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] ?? 0,
        origin: (json['origin_address'] as String?)?.isNotEmpty == true
            ? json['origin_address']
            : (json['origin'] as String?)?.isNotEmpty == true
                ? json['origin']
                : json['origin_city'] ?? '',
        destination:
            (json['destination_address'] as String?)?.isNotEmpty == true
                ? json['destination_address']
                : json['destination'] ?? '',
        city: json['origin_city'] ?? '',
        originLat: (json['origin_lat'] as num?)?.toDouble() ?? 0.0,
        originLng: (json['origin_lng'] as num?)?.toDouble() ?? 0.0,
        destinationLat: (json['destination_lat'] as num?)?.toDouble() ?? 0.0,
        destinationLng: (json['destination_lng'] as num?)?.toDouble() ?? 0.0,
        date: json['date'] ?? '',
        hour: json['hour'] ?? '',
        approxWeight: (json['approx_weight'] as num?)?.toDouble() ?? 0.0,
        description: json['description'],
        status: json['idstatus'] ?? json['status'] ?? 0,
        clientId: json['id_client'] ?? 0,
        driverId: json['id_driver'],
        distanceKm: (json['distance_km'] as num?)?.toDouble(),
        createdAt: json['created_at'],
        paymentMethod: (json['payment_method'] as num?)?.toInt(),
        paymentStatus: (json['payment_status'] as num?)?.toInt(),
      );
}

class TripRequest {
  final String origin;
  final double originLat;
  final double originLng;
  final String destination;
  final double destinationLat;
  final double destinationLng;
  final double distanceKm;
  final String date;
  final String hour;
  final double approxWeight;
  final String? description;
  final int paymentMethod;

  TripRequest({
    required this.origin,
    required this.originLat,
    required this.originLng,
    required this.destination,
    required this.destinationLat,
    required this.destinationLng,
    required this.distanceKm,
    required this.date,
    required this.hour,
    required this.approxWeight,
    this.description,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'origin_address': origin,
        'origin_lat': originLat,
        'origin_lng': originLng,
        'destination_address': destination,
        'destination_lat': destinationLat,
        'destination_lng': destinationLng,
        'distance_km': distanceKm,
        'date': date,
        'hour': hour,
        'approx_weight': approxWeight,
        'payment_method': paymentMethod,
        if (description != null) 'description': description,
      };
}

class Car {
  final int id;
  final int iduser;
  final String carRegistration;
  final String brand;
  final String model;
  final String color;
  final int maxCapacity;
  final String? frontViewImage;
  final String? backViewImage;
  final String? platesImage;
  final String? spacesImage;

  Car({
    required this.id,
    required this.iduser,
    required this.carRegistration,
    required this.brand,
    required this.model,
    required this.color,
    required this.maxCapacity,
    this.frontViewImage,
    this.backViewImage,
    this.platesImage,
    this.spacesImage,
  });

  factory Car.fromJson(Map<String, dynamic> json) => Car(
        id: json['idcar'] ?? json['id'] ?? 0,
        iduser: json['iduser'] ?? 0,
        carRegistration: json['car_registration'] ?? '',
        brand: json['brand'] ?? '',
        model: json['model'] ?? '',
        color: json['color'] ?? '',
        maxCapacity: json['max_capacity'] ?? 0,
        frontViewImage: _nonEmpty(json['front_view_image']) ??
            _nonEmpty(json['frontview_image']),
        backViewImage: _nonEmpty(json['back_view_image']) ??
            _nonEmpty(json['backview_image']),
        platesImage: _nonEmpty(json['plates_image']),
        spacesImage:
            _nonEmpty(json['space_image']) ?? _nonEmpty(json['spaces_image']),
      );

  String get displayName => '$brand $model ($color)';
}

class ProposalRequest {
  final double price;
  final int idRide;
  final int idcar;
  final String? comment;

  ProposalRequest(
      {required this.price,
      required this.idRide,
      required this.idcar,
      this.comment});

  Map<String, dynamic> toJson() => {
        'price': price,
        'id_ride': idRide,
        'idcar': idcar,
        if (comment != null) 'comment': comment,
      };
}

class Proposal {
  final int id;
  final double price;
  final int idRide;
  final int idcar;
  final int? idDriver;
  final String? comment;
  final String? estimatedTime;
  final int status;
  final Car? car;
  final UserResponse? driver;

  Proposal({
    required this.id,
    required this.price,
    required this.idRide,
    required this.idcar,
    this.idDriver,
    this.comment,
    this.estimatedTime,
    required this.status,
    this.car,
    this.driver,
  });

  factory Proposal.fromJson(Map<String, dynamic> json) {
    final j = (json['proposal'] as Map<String, dynamic>?) ?? json;

    Car? car;
    if (j['car'] is Map<String, dynamic>) {
      car = Car.fromJson(j['car'] as Map<String, dynamic>);
    } else if (j['idcar'] != null || j['car_registration'] != null) {
      car = Car.fromJson(j);
    }

    UserResponse? driver;
    if (j['driver'] is Map<String, dynamic>) {
      driver = UserResponse.fromJson(j['driver'] as Map<String, dynamic>);
    } else if (j['rating'] != null || j['trip_count'] != null) {
      driver = UserResponse(
        iduser: j['iddriver'] ?? j['iduser'] ?? 0,
        name: '',
        lastname: '',
        email: '',
        numberPhone: '',
        birthdate: '',
        userType: 2,
        rating: (j['rating'] as num?)?.toDouble(),
        totalTrips: (j['trip_count'] as num?)?.toInt(),
      );
    }

    return Proposal(
      id: j['idproposal'] ?? j['id'] ?? 0,
      price: (j['price'] as num?)?.toDouble() ?? 0.0,
      idRide: j['idride'] ?? j['id_ride'] ?? 0,
      idcar: j['idcar'] ?? 0,
      idDriver:
          j['iddriver'] ?? j['iduser'] ?? j['id_driver'] ?? j['driver_id'],
      comment: j['comment'],
      estimatedTime: j['estimated_time'],
      status: j['idproposalstatus'] ?? j['idstatus'] ?? j['status'] ?? 0,
      car: car,
      driver: driver,
    );
  }

  Proposal copyWith({Car? car, UserResponse? driver, int? idDriver}) =>
      Proposal(
        id: id,
        price: price,
        idRide: idRide,
        idcar: idcar,
        idDriver: idDriver ?? this.idDriver,
        comment: comment,
        estimatedTime: estimatedTime,
        status: status,
        car: car ?? this.car,
        driver: driver ?? this.driver,
      );
}

class DriverProposalItem {
  final int id;
  final double price;
  final int idRide;
  final int status;
  final String? comment;
  final String origin;
  final String destination;
  final String date;
  final String hour;
  final double approxWeight;
  final String? description;
  final String clientName;
  final int? paymentMethod;
  final int rideStatus;

  /// false cuando no se pudieron obtener los datos del viaje (p. ej. la API
  /// negó el acceso o el viaje ya no existe); la UI no debe permitir iniciarlo.
  final bool rideLoaded;

  DriverProposalItem({
    required this.id,
    required this.price,
    required this.idRide,
    required this.status,
    this.comment,
    required this.origin,
    required this.destination,
    required this.date,
    required this.hour,
    required this.approxWeight,
    this.description,
    required this.clientName,
    this.paymentMethod,
    this.rideStatus = 0,
    this.rideLoaded = true,
  });

  factory DriverProposalItem.fromJson(Map<String, dynamic> json) {
    final ride = json['ride'] as Map<String, dynamic>? ?? {};
    final client = json['client'] as Map<String, dynamic>?;
    final clientName = client != null
        ? '${client['name'] ?? ''} ${client['lastname'] ?? ''}'.trim()
        : 'Cliente';
    return DriverProposalItem(
      id: json['id'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      idRide: json['id_ride'] ?? 0,
      status: json['status'] ?? 0,
      comment: json['comment'],
      origin: ride['origin'] ?? '',
      destination: ride['destination'] ?? '',
      date: ride['date'] ?? '',
      hour: ride['hour'] ?? '',
      approxWeight: (ride['approx_weight'] as num?)?.toDouble() ?? 0.0,
      description: ride['description'],
      clientName: clientName,
      paymentMethod: (ride['payment_method'] as num?)?.toInt(),
    );
  }
}

class DeviceTokenRequest {
  final String fcmToken;
  final String deviceName;
  DeviceTokenRequest({required this.fcmToken, required this.deviceName});
  Map<String, dynamic> toJson() =>
      {'fcm_token': fcmToken, 'device_name': deviceName};
}

class UpdateStatusRequest {
  final int status;
  UpdateStatusRequest({required this.status});
  Map<String, dynamic> toJson() => {'status': status};
}

class ResetPasswordRequest {
  final String email;
  final String newPassword;
  ResetPasswordRequest({required this.email, required this.newPassword});
  Map<String, dynamic> toJson() => {'email': email, 'newPassword': newPassword};
}

class UpdatePasswordRequest {
  final String oldPassword;
  final String newPassword;
  UpdatePasswordRequest({required this.oldPassword, required this.newPassword});
  Map<String, dynamic> toJson() =>
      {'oldPassword': oldPassword, 'newPassword': newPassword};
}

class ProposalStatusRequest {
  final int idstatus;
  ProposalStatusRequest({required this.idstatus});
  Map<String, dynamic> toJson() => {'idstatus': idstatus};
}

class PaymentRequest {
  final int rideId;
  final double amount;
  PaymentRequest({required this.rideId, required this.amount});
  Map<String, dynamic> toJson() => {'ride_id': rideId, 'amount': amount};
}

class PaymentIntentResponse {
  final String clientSecret;
  final String paymentIntentId;
  PaymentIntentResponse(
      {required this.clientSecret, required this.paymentIntentId});
  factory PaymentIntentResponse.fromJson(Map<String, dynamic> json) =>
      PaymentIntentResponse(
        clientSecret: json['client_secret'] ?? '',
        paymentIntentId: json['payment_intent_id'] ?? '',
      );
}

class DriverWallet {
  final double balance;
  final double pendingCommission;
  final double pendingEarnings;
  final double debtLimit;
  final bool blocked;

  DriverWallet({
    this.balance = 0,
    this.pendingCommission = 0,
    this.pendingEarnings = 0,
    this.debtLimit = 0,
    this.blocked = false,
  });

  factory DriverWallet.fromJson(Map<String, dynamic> json) {
    final w = (json['wallet'] as Map<String, dynamic>?) ?? json;
    return DriverWallet(
      balance: (w['balance'] as num?)?.toDouble() ?? 0,
      pendingCommission: (w['pending_commission'] as num?)?.toDouble() ?? 0,
      pendingEarnings: (w['pending_earnings'] as num?)?.toDouble() ?? 0,
      debtLimit: (w['debt_limit'] as num?)?.toDouble() ?? 0,
      blocked: w['blocked'] == true,
    );
  }
}

class WalletMovement {
  static const int typeCashTrip = 1;
  static const int typeCardTrip = 2;
  static const int typeDebtPayment = 3;
  static const int typePayout = 4;

  final int id;
  final int? idRide;
  final int type;
  final double? fare;
  final double? commission;
  final double amount;
  final int? paymentMethod;
  final String origin;
  final String destination;
  final String createdAt;

  WalletMovement({
    required this.id,
    this.idRide,
    required this.type,
    this.fare,
    this.commission,
    required this.amount,
    this.paymentMethod,
    this.origin = '',
    this.destination = '',
    this.createdAt = '',
  });

  factory WalletMovement.fromJson(Map<String, dynamic> json) => WalletMovement(
        id: json['id'] ?? 0,
        idRide: (json['id_ride'] as num?)?.toInt(),
        type: (json['type'] as num?)?.toInt() ?? 0,
        fare: (json['fare'] as num?)?.toDouble(),
        commission: (json['commission'] as num?)?.toDouble(),
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        paymentMethod: (json['payment_method'] as num?)?.toInt(),
        origin: json['origin'] ?? '',
        destination: json['destination'] ?? '',
        createdAt: json['created_at'] ?? '',
      );
}

class WalletSummaryEntry {
  final String period;
  final int trips;
  final double gross;
  final double commission;
  final double net;
  final double cash;
  final double card;

  WalletSummaryEntry({
    required this.period,
    this.trips = 0,
    this.gross = 0,
    this.commission = 0,
    this.net = 0,
    this.cash = 0,
    this.card = 0,
  });

  factory WalletSummaryEntry.fromJson(Map<String, dynamic> json) =>
      WalletSummaryEntry(
        period: json['period']?.toString() ?? '',
        trips: (json['trips'] as num?)?.toInt() ?? 0,
        gross: (json['gross'] as num?)?.toDouble() ?? 0,
        commission: (json['commission'] as num?)?.toDouble() ?? 0,
        net: (json['net'] as num?)?.toDouble() ?? 0,
        cash: (json['cash'] as num?)?.toDouble() ?? 0,
        card: (json['card'] as num?)?.toDouble() ?? 0,
      );
}
