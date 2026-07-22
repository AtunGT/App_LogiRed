import 'package:flutter/material.dart';
import '../../features/login/presentation/login_screen.dart';
import '../../features/login/forgotpassword/presentation/forgot_password_screen.dart';
import '../../features/login/registerclient/presentation/refiter_client_screen.dart';
import '../../features/login/registerdriver/presentation/register_driver_screen.dart';
import '../../features/login/verifyemail/presentation/verify_email_screen.dart';
import '../../features/roleselection/presentation/role_selection_screen.dart';
import '../../features/main/client_main_screen.dart';
import '../../features/driverstatus/presentation/driver_gate.dart';
import '../../features/driverstatus/presentation/driver_reapply_screen.dart';
import '../../features/trip/detail/presentation/trip_detail_screen.dart';
import '../../features/trip/driverdetail/presentation/driver_trip_detail_screen.dart';
import '../../features/trip/active/presentation/active_trip_screen.dart';
import '../../features/trip/map/presentation/trip_map_provider.dart';
import '../../features/trip/proposals/presentation/trip_proposals_screen.dart';
import '../../features/account/presentation/change_password_screen.dart';
import '../../features/trip/payment/presentation/payment_screen.dart';
import '../../features/account/presentation/personal_data_screen.dart';
import '../../features/account/presentation/contact_screen.dart';
import '../../features/account/presentation/terms_screen.dart';
import '../../features/account/presentation/privacy_policy_screen.dart';
import '../../features/account/presentation/support_screen.dart';
import '../../features/trip/history/presentation/trip_history_screen.dart';
import '../../features/trip/rating/presentation/rate_driver_screen.dart';
import '../../features/vehicles/presentation/car_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';

class AppRoutes {
  static const roleSelection = '/role-selection';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const registerClient = '/register-client';
  static const registerDriver = '/register-driver';
  static const verifyEmail = '/verify-email';
  static const clientMain = '/client-main';
  static const driverMain = '/driver-main';
  static const driverReapply = '/driver-reapply';
  static const tripDetail = '/trip-detail';
  static const driverTripDetail = '/driver-trip-detail';
  static const activeTrip = '/active-trip';
  static const tripMap = '/trip-map';
  static const tripProposals = '/trip-proposals';
  static const changePassword = '/change-password';
  static const payment = '/payment';
  static const personalData = '/profile/personal';
  static const contact = '/profile/contact';
  static const terms = '/terms';
  static const privacyPolicy = '/privacy-policy';
  static const support = '/support';
  static const rateDriver = '/rate-driver';
  static const cars = '/cars';
  static const wallet = '/wallet';
  static const tripHistory = '/trip-history';

  static Map<String, WidgetBuilder> get routes => {
        roleSelection: (_) => const RoleSelectionScreen(),
        login: (_) => const LoginScreen(),
        forgotPassword: (_) => const ForgotPasswordScreen(),
        registerClient: (_) => const RegisterClientScreen(),
        registerDriver: (_) => const RegisterDriverScreen(),
        clientMain: (_) => const ClientMainScreen(),
        // El conductor entra siempre por el gate: es quien decide si ve el mapa
        // o una pantalla de estado. Nadie debe apuntar a DriverMainScreen.
        driverMain: (_) => const DriverGate(),
        driverReapply: (_) => const DriverReapplyScreen(),
        changePassword: (_) => const ChangePasswordScreen(),
        personalData: (_) => const PersonalDataScreen(),
        contact: (_) => const ContactScreen(),
        terms: (_) => const TermsScreen(),
        privacyPolicy: (_) => const PrivacyPolicyScreen(),
        support: (_) => const SupportScreen(),
        cars: (_) => const CarScreen(),
        wallet: (_) => const WalletScreen(),
        tripHistory: (_) => const TripHistoryScreen(showBackButton: true),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case verifyEmail:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(
            builder: (_) => VerifyEmailScreen(email: email));
      case tripDetail:
        final id = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => TripDetailScreen(tripId: id));
      case driverTripDetail:
        final id = settings.arguments as int;
        return MaterialPageRoute(
            builder: (_) => DriverTripDetailScreen(tripId: id));
      case tripMap:
        final id = settings.arguments as int;
        return MaterialPageRoute(builder: (_) => TripMapScreen(tripId: id));
      case tripProposals:
        final id = settings.arguments as int;
        return MaterialPageRoute(
            builder: (_) => TripProposalsScreen(tripId: id));
      case activeTrip:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ActiveTripScreen(
            tripId: args['tripId'] as int,
            isDriver: args['isDriver'] as bool,
            proposalPrice: (args['proposalPrice'] as num).toDouble(),
          ),
        );
      case payment:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(
            tripId: args['tripId'] as int,
            proposalPrice: (args['proposalPrice'] as num).toDouble(),
            paymentMethod: args['paymentMethod'] as int? ?? 1,
            origin: args['origin'] as String? ?? '',
            destination: args['destination'] as String? ?? '',
            duration: args['duration'] as String? ?? '',
          ),
        );
      case rateDriver:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RateDriverScreen(
            tripId: args['tripId'] as int,
            driverId: args['driverId'] as int,
            driverName: args['driverName'] as String? ?? '',
            origin: args['origin'] as String? ?? '',
            destination: args['destination'] as String? ?? '',
            date: args['date'] as String? ?? '',
            duration: args['duration'] as String? ?? '',
          ),
        );
      default:
        return null;
    }
  }
}
