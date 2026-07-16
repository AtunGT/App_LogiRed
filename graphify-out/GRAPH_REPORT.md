# Graph Report - .  (2026-07-12)

## Corpus Check
- 213 files · ~126,072 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 2358 nodes · 3127 edges · 136 communities (118 shown, 18 thin omitted)
- Extraction: 97% EXTRACTED · 3% INFERRED · 0% AMBIGUOUS · INFERRED: 89 edges (avg confidence: 0.88)
- Token cost: 96,141 input · 35,747 output

## Community Hubs (Navigation)
- Navegación del Conductor
- Modelos de Datos API
- Registro Conductor (Dominio)
- Tracking en Vivo del Cliente
- Runner Windows C++
- Rutas de la App
- Dependencias y Branding
- Pantalla Registro Conductor
- Cuenta y Contraseña
- Mis Viajes
- Cartera del Conductor
- Cliente HTTP ApiService
- Solicitar Viaje
- Detalle de Historial
- Shell de Navegación
- Registro Cliente (Dominio)
- Sprites y Utilidades de Mapa
- Pantalla Registro Cliente
- Home del Cliente
- trip (19)
- wallet (20)
- my_application.cc (21)
- account (22)
- trip (23)
- trip (24)
- trip (25)
- theme (26)
- services (27)
- main (28)
- phone_verification (29)
- Assets.xcassets (30)
- trip (31)
- trip (32)
- utils (33)
- trip (34)
- login (35)
- login (36)
- account (37)
- trip (38)
- trip (39)
- Assets.xcassets (40)
- trip (41)
- vehicles (42)
- trip (43)
- widgets (44)
- main.dart (45)
- security (46)
- trip (47)
- trip (48)
- vehicles (49)
- trip (50)
- trip (51)
- trip (52)
- account (53)
- websocket (54)
- GeneratedPluginRegistrant.swift (55)
- login (56)
- trip (57)
- account (58)
- trip (59)
- local (60)
- login (61)
- trip (62)
- trip (63)
- di (64)
- account (65)
- trip (66)
- utils.cpp (67)
- account (68)
- trip (69)
- roleselection (70)
- widgets (71)
- trip (72)
- login (73)
- manifest.json (74)
- utils (75)
- trip (76)
- None (77)
- login (78)
- login (79)
- login (80)
- trip (81)
- trip (82)
- None (83)
- trip (84)
- utils (85)
- login (86)
- firebase_options.dart (87)
- AppDelegate.swift (88)
- SceneDelegate.swift (89)
- account (90)
- account (91)
- login (92)
- phone_verification (93)
- roleselection (94)
- MainFlutterWindow.swift (95)
- trip (96)
- utils (97)
- main (98)
- trip (99)
- AppDelegate.swift (100)
- ephemeral (101)
- GeneratedPluginRegistrant.h (102)
- trip (103)
- src (104)
- gradlew (105)
- RunnerTests.swift (106)
- widgets (107)
- trip (108)
- GeneratedPluginRegistrant.swift (109)
- main.dart (110)
- login (111)
- main (112)
- src (113)
- ephemeral (114)
- None (115)
- flutter_export_environment.sh (116)
- login (117)
- trip (118)
- trip (119)
- trip (120)
- trip (121)
- trip (122)
- trip (123)
- trip (124)
- trip (125)
- wallet (126)
- wallet (127)
- ephemeral (128)
- None (132)
- None (135)

## God Nodes (most connected - your core abstractions)
1. `LogiRed Logistics App` - 32 edges
2. `Win32Window` - 22 edges
3. `iOS App Icon 1024x1024@1x (App Store) - LogiRed monogram: green 'LR' whose R's stroke forms a winding road with dashed lane markers vanishing to the horizon; dark teal-green on white, logistics/routing brand identity` - 15 edges
4. `Trip` - 12 edges
5. `MessageHandler` - 12 edges
6. `build` - 11 edges
7. `FlutterWindow` - 10 edges
8. `Create` - 10 edges
9. `WndProc` - 10 edges
10. `MessageHandler` - 9 edges

## Surprising Connections (you probably didn't know these)
- `LogiRed Logistics App` --references--> `LogiRed Brand Logo (LR road monogram)`  [INFERRED]
  pubspec.yaml → assets/images/logo.png
- `LogiRed Logistics App` --references--> `Car Marker Sprite (top-down green car)`  [INFERRED]
  pubspec.yaml → assets/images/car_marker.png
- `LogiRed Logistics App` --references--> `LogiRed Launcher Icon (LR monogram variant)`  [INFERRED]
  pubspec.yaml → assets/images/logo_icon.png
- `Car Marker Sprite (top-down green car)` --conceptually_related_to--> `google_maps_flutter (map rendering)`  [INFERRED]
  assets/images/car_marker.png → pubspec.yaml
- `Car Marker Sprite (top-down green car)` --conceptually_related_to--> `Real-time Vehicle Tracking over WebSocket`  [INFERRED]
  assets/images/car_marker.png → pubspec.yaml

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Custom Navigation and Realtime Tracking Stack** — pubspec_google_maps_flutter, pubspec_geolocator, pubspec_flutter_compass, pubspec_flutter_tts, pubspec_web_socket_channel [INFERRED 0.85]
- **Authentication and Session Security Stack** — pubspec_firebase_core, pubspec_firebase_auth, pubspec_google_sign_in, pubspec_jwt_decoder, pubspec_flutter_secure_storage [INFERRED 0.75]
- **Flutter Desktop Embedding Build Pipeline** — linux_cmakelists_logired_binary, linux_flutter_cmakelists_flutter_assemble, windows_cmakelists_logired_binary, windows_flutter_cmakelists_flutter_assemble [INFERRED 0.75]
- **Android Adaptive Launcher Foreground Icon Set (LogiRed LR logo, all densities)** — android_app_src_main_res_drawable_mdpi_ic_launcher_foreground, android_app_src_main_res_drawable_hdpi_ic_launcher_foreground, android_app_src_main_res_drawable_xhdpi_ic_launcher_foreground, android_app_src_main_res_drawable_xxhdpi_ic_launcher_foreground, android_app_src_main_res_drawable_xxxhdpi_ic_launcher_foreground [EXTRACTED 1.00]
- **Android Launcher Icon Set (LogiRed LR logo, mipmap all densities)** — android_app_src_main_res_mipmap_mdpi_ic_launcher, android_app_src_main_res_mipmap_hdpi_ic_launcher, android_app_src_main_res_mipmap_xhdpi_ic_launcher, android_app_src_main_res_mipmap_xxhdpi_ic_launcher, android_app_src_main_res_mipmap_xxxhdpi_ic_launcher [EXTRACTED 1.00]
- **iOS AppIcon.appiconset (LogiRed LR logo, all sizes and scales)** — ios_runner_assets_xcassets_appicon_appiconset_icon_app_1024x1024_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_20x20_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_29x29_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_40x40_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_50x50_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_50x50_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_57x57_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_57x57_2x [EXTRACTED 1.00]
- **iOS App Icon Set (LogiRed LR road monogram, all scales)** — ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_60x60_3x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_72x72_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_72x72_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_1x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_76x76_2x, ios_runner_assets_xcassets_appicon_appiconset_icon_app_83_5x83_5_2x [EXTRACTED 1.00]
- **macOS App Icon Set (default Flutter logo, all scales)** — macos_runner_assets_xcassets_appicon_appiconset_app_icon_16, macos_runner_assets_xcassets_appicon_appiconset_app_icon_32, macos_runner_assets_xcassets_appicon_appiconset_app_icon_64, macos_runner_assets_xcassets_appicon_appiconset_app_icon_128, macos_runner_assets_xcassets_appicon_appiconset_app_icon_256, macos_runner_assets_xcassets_appicon_appiconset_app_icon_512, macos_runner_assets_xcassets_appicon_appiconset_app_icon_1024 [EXTRACTED 1.00]
- **Web PWA Icon Set (default Flutter logo, favicon + manifest icons)** — web_favicon, web_icons_icon_192, web_icons_icon_512, web_icons_icon_maskable_192, web_icons_icon_maskable_512 [INFERRED 0.85]

## Communities (136 total, 18 thin omitted)

### Community 0 - "Navegación del Conductor"
Cohesion: 0.02
Nodes (107): active_trip_provider.dart, ../../../../core/widgets/slide_to_confirm.dart, double? _lastLat,, FlutterTts, active, _animCount, _arrivedAtDestination, _arrivedAtOrigin (+99 more)

### Community 1 - "Modelos de Datos API"
Cohesion: 0.02
Nodes (95): amount, approxWeight, backViewImage, balance, birthdate, blocked, brand, card (+87 more)

### Community 2 - "Registro Conductor (Dominio)"
Cohesion: 0.03
Nodes (67): ../data/repository/register_driver_repository_impl.dart, ../domain/usecase/register_driver_usecase.dart, acceptedPrivacy, acceptedTerms, birthdate, brand, color, confirmPassword (+59 more)

### Community 3 - "Tracking en Vivo del Cliente"
Cohesion: 0.03
Nodes (61): BitmapDescriptor?, ../../../../core/utils/car_marker.dart, ../../../../core/websocket/websocket_manager.dart, dart:convert, DateTime?, LatLng?, LatLng get, _acceptedProposal (+53 more)

### Community 4 - "Runner Windows C++"
Cohesion: 0.06
Nodes (53): PluginRegistry, Point, RECT, Size, unique_ptr, RegisterPlugins(), DartProject, HWND (+45 more)

### Community 5 - "Rutas de la App"
Cohesion: 0.04
Nodes (52): ../../features/account/presentation/change_password_screen.dart, ../../features/account/presentation/contact_screen.dart, ../../features/account/presentation/personal_data_screen.dart, ../../features/account/presentation/privacy_policy_screen.dart, ../../features/account/presentation/support_screen.dart, ../../features/account/presentation/terms_screen.dart, ../../features/login/forgotpassword/presentation/forgot_password_screen.dart, ../../features/login/presentation/login_screen.dart (+44 more)

### Community 6 - "Dependencias y Branding"
Cohesion: 0.06
Nodes (51): Dart Analyzer Lint Configuration, Car Marker Sprite (top-down green car), LogiRed Launcher Icon (LR monogram variant), LogiRed Brand Logo (LR road monogram), Dart & Flutter DevTools Settings, iOS Launch Screen Assets Guide, GTK Application ID com.arthur.gloria.alhan.logired, APPLY_STANDARD_SETTINGS (Linux, C++14, -Wall -Werror) (+43 more)

### Community 7 - "Pantalla Registro Conductor"
Cohesion: 0.04
Nodes (50): _birthdateCtrl, _brandCtrl, _buildBottomButtons, _buildDriverDateField, _buildDriverPhotoField, _buildStep1, _buildStep2, _buildStep3 (+42 more)

### Community 8 - "Cuenta y Contraseña"
Cohesion: 0.04
Nodes (47): change_password_provider.dart, driver_trip_detail_provider.dart, build, ChangePasswordScreen, _ChangePasswordScreenState, colorScheme, _confirmCtrl, controller (+39 more)

### Community 9 - "Mis Viajes"
Cohesion: 0.04
Nodes (46): ../../inprogress/presentation/trip_in_progress_screen.dart, _avatarColor, _avatarColors, colorScheme, _confirmCancel, count, _countAssigned, _countInProgress (+38 more)

### Community 10 - "Cartera del Conductor"
Cohesion: 0.05
Nodes (39): driver_wallet_provider.dart, WalletMovement, _BalanceCard, _BalanceCell, _BlockedBanner, build, colorScheme, createState (+31 more)

### Community 11 - "Cliente HTTP ApiService"
Cohesion: 0.05
Nodes (38): Dio, acceptTrip, _baseUrl, createCar, createPaymentIntent, createReview, createTrip, createUser (+30 more)

### Community 12 - "Solicitar Viaje"
Cohesion: 0.05
Nodes (37): _apiKey, build, child, _clearFields, colorScheme, createState, _dateCtrl, _descCtrl (+29 more)

### Community 13 - "Detalle de Historial"
Cohesion: 0.05
Nodes (36): build, _Card, child, colorScheme, createState, date, _decodePolyline, dispose (+28 more)

### Community 14 - "Shell de Navegación"
Cohesion: 0.07
Nodes (33): ../account/presentation/account_screen.dart, client_home_screen.dart, ../../core/widgets/scrollable_nav_rail.dart, build, ClientMainScreen, _ClientMainScreenState, createState, _currentIndex (+25 more)

### Community 15 - "Registro Cliente (Dominio)"
Cohesion: 0.06
Nodes (33): ../data/repository/register_client_repository_impl.dart, ../domain/usecase/register_client_usecase.dart, acceptedPrivacy, acceptedTerms, birthdate, confirmPassword, email, error (+25 more)

### Community 16 - "Sprites y Utilidades de Mapa"
Cohesion: 0.07
Nodes (29): dart:ui, GoogleMapController?, buildCarMarker, bytes, canvas, codec, data, dstH (+21 more)

### Community 17 - "Pantalla Registro Cliente"
Cohesion: 0.07
Nodes (29): _birthdateCtrl, _buildDateField, _buildField, _buildLabel, _buildPhotoField, _CheckRow, colorScheme, _confirmCtrl (+21 more)

### Community 18 - "Home del Cliente"
Cohesion: 0.07
Nodes (28): _actionable, badge, build, colorScheme, createState, date, destination, _DriverQuickCard (+20 more)

### Community 19 - "trip (19)"
Cohesion: 0.07
Nodes (28): build, child, colorScheme, createState, duration, _error, _fmt, _formatDate (+20 more)

### Community 20 - "wallet (20)"
Cohesion: 0.07
Nodes (27): DriverWallet, _dateKey, _describe, error, _fetchMovements, _fetchSummary, _fetchWallet, _guard (+19 more)

### Community 21 - "my_application.cc (21)"
Cohesion: 0.09
Nodes (22): FlPluginRegistry, FlView, GApplication, gboolean, gchar, GObject, GtkApplication, fl_register_plugins() (+14 more)

### Community 22 - "account (22)"
Cohesion: 0.08
Nodes (26): _birthdateCtrl, build, colorScheme, controller, createState, dispose, _FieldBlock, hint (+18 more)

### Community 23 - "trip (23)"
Cohesion: 0.07
Nodes (26): active, agreedPrice, amount, bold, _BreakdownCard, _BreakdownRow, build, _CashWarning (+18 more)

### Community 24 - "trip (24)"
Cohesion: 0.08
Nodes (26): _accept, _AcceptButton, _AcceptButtonState, build, _buildAiSummary, _Card, _CarPlaceholder, child (+18 more)

### Community 25 - "trip (25)"
Cohesion: 0.07
Nodes (26): approxWeight, date, description, destination, destinationLat, destinationLng, distanceKm, error (+18 more)

### Community 26 - "theme (26)"
Cohesion: 0.08
Nodes (25): Color seed,, color, colorContainer, ColorFamily, dark, darkHighContrast, darkHighContrastScheme, darkMediumContrast (+17 more)

### Community 27 - "services (27)"
Cohesion: 0.08
Nodes (25): ../di/service_locator.dart, _channelId, _channelName, _deviceName, _fcm, handleBackgroundMessage, init, _localNotif (+17 more)

### Community 28 - "main (28)"
Cohesion: 0.08
Nodes (25): _ActionCard, activos, badge, completados, createState, destination, icon, iconBg (+17 more)

### Community 29 - "phone_verification (29)"
Cohesion: 0.08
Nodes (23): bool get, isDark, _key, _load, _mode, toggle, _applyCredential, codeSent (+15 more)

### Community 30 - "Assets.xcassets (30)"
Cohesion: 0.09
Nodes (24): Android Launcher Foreground Icon (hdpi) - LogiRed green LR road logo, Android Launcher Foreground Icon (mdpi) - LogiRed green LR road logo, Android Launcher Foreground Icon (xhdpi) - LogiRed green LR road logo, Android Launcher Foreground Icon (xxhdpi) - LogiRed green LR road logo, Android Launcher Foreground Icon (xxxhdpi) - LogiRed monogram: stylized green 'LR' where the R's diagonal stroke is a winding road with dashed lane markers receding to the horizon; dark teal-green on transparent background, conveying a logistics/routing app identity, Android App Launcher Icon (hdpi) - LogiRed green LR road logo, Android App Launcher Icon (mdpi) - LogiRed green LR road logo, Android App Launcher Icon (xhdpi) - LogiRed green LR road logo (+16 more)

### Community 31 - "trip (31)"
Cohesion: 0.09
Nodes (23): ../../../core/utils/money.dart, history_trip_detail_screen.dart, cancelled, colorScheme, completed, _CountChip, createState, _formatDate (+15 more)

### Community 32 - "trip (32)"
Cohesion: 0.09
Nodes (22): accepted_trips_provider.dart, ../../../../core/utils/trip_schedule.dart, driver_proposal_detail_screen.dart, AcceptedTripsScreen, _actionButton, _btn, build, colorScheme (+14 more)

### Community 33 - "utils (33)"
Cohesion: 0.09
Nodes (21): _, _, card, cash, icon, isCard, label, PaymentMethodInfo (+13 more)

### Community 34 - "trip (34)"
Cohesion: 0.09
Nodes (20): ../data/repository/dashboard_repository_impl.dart, ../domain/dasboard_repository.dart, DashboardRepositoryImpl, getClientTrips, getDriverTrips, DashboardRepository, getClientTrips, getDriverTrips (+12 more)

### Community 35 - "login (35)"
Cohesion: 0.09
Nodes (21): ../data/repository/login_repository_impl.dart, ../domain/usecase/login_usecase.dart, LoginError, LoginResult, LoginSuccess, message, token, userType (+13 more)

### Community 36 - "login (36)"
Cohesion: 0.09
Nodes (22): birthdate, brand, color, docAddressProof, docIdBack, docIdFront, docLicense, DriverData (+14 more)

### Community 37 - "account (37)"
Cohesion: 0.10
Nodes (21): account_provider.dart, AccountScreen, _AccountScreenState, colorScheme, createState, didUpdateWidget, dispose, icon (+13 more)

### Community 38 - "trip (38)"
Cohesion: 0.10
Nodes (19): ../data/repository/available_trips_repository_impl.dart, ../domain/available_trips_repository.dart, acceptTrip, AvailableTripsRepositoryImpl, getAvailableTrips, acceptTrip, AvailableTripsRepository, getAvailableTrips (+11 more)

### Community 39 - "trip (39)"
Cohesion: 0.10
Nodes (19): ../data/repository/trip_repository_impl.dart, ../domain/trip_history_repository.dart, int?, _fetchHistory, getClientTrips, getDriverTrips, TripHistoryRepositoryImpl, getClientTrips (+11 more)

### Community 40 - "Assets.xcassets (40)"
Cohesion: 0.09
Nodes (22): iOS App Icon 60x60@2x - LogiRed teal LR road monogram, iOS App Icon 60x60@3x - LogiRed teal LR road monogram, iOS App Icon 72x72@1x - LogiRed teal LR road monogram, iOS App Icon 72x72@2x - LogiRed teal LR road monogram, iOS App Icon 76x76@1x - LogiRed teal LR road monogram, iOS App Icon 76x76@2x - LogiRed teal LR road monogram, iOS App Icon 83.5x83.5@2x - LogiRed teal LR road monogram, iOS Launch Image @1x - blank white Flutter placeholder (+14 more)

### Community 41 - "trip (41)"
Cohesion: 0.09
Nodes (21): build, colorScheme, _CommentCard, _commentCtrl, _CompletedBanner, createState, ctrl, date (+13 more)

### Community 42 - "vehicles (42)"
Cohesion: 0.09
Nodes (21): backImagePath, brandCtrl, carRegistrationCtrl, cars, _clearForm, colorCtrl, deleteCar, dispose (+13 more)

### Community 43 - "trip (43)"
Cohesion: 0.11
Nodes (17): ../../../core/network/model/models.dart, ../data/repository/my_trips_repository_impl.dart, ../domain/my_trips_repository.dart, getAcceptedTrips, cancelTrip, getMyTrips, MyTripsRepositoryImpl, cancelTrip (+9 more)

### Community 44 - "widgets (44)"
Cohesion: 0.10
Nodes (20): background, build, _confirm, createState, _done, _dragging, _dragX, enabled (+12 more)

### Community 45 - "main.dart (45)"
Cohesion: 0.11
Nodes (19): core/routes/app_routes.dart, core/security/mock_location_guard.dart, core/theme/material_theme.dart, core/theme/theme_provider.dart, firebase_options.dart, AppStartup, _AppStartupState, _checkAuth (+11 more)

### Community 46 - "security (46)"
Cohesion: 0.11
Nodes (19): dart:io, build, _checkVpn, child, createState, dispose, _gpsSub, initState (+11 more)

### Community 47 - "trip (47)"
Cohesion: 0.11
Nodes (18): _all, countAccepted, countInProgress, countPending, error, filter, _isAccepted, _isInProgress (+10 more)

### Community 48 - "trip (48)"
Cohesion: 0.11
Nodes (17): available_trips_provider.dart, AvailableTripsScreen, build, _buildBody, colorScheme, _formatDate, _formatHour, icon (+9 more)

### Community 49 - "vehicles (49)"
Cohesion: 0.12
Nodes (17): car_provider.dart, Car, build, car, _CarCard, CarScreen, _CarScreenState, colorScheme (+9 more)

### Community 50 - "trip (50)"
Cohesion: 0.15
Nodes (17): LoginScreen, _LoginScreenState, _MyTripsBody, _MyTripsBodyState, _ProposalBadge, _ProposalBadgeState, _ProposalsSection, _ProposalsSectionState (+9 more)

### Community 51 - "trip (51)"
Cohesion: 0.12
Nodes (16): badge, build, colorScheme, createState, DashboardScreen, _DashboardScreenState, icon, iconBg (+8 more)

### Community 52 - "trip (52)"
Cohesion: 0.12
Nodes (16): clientImageUrl, clientInitial, clientName, comment, DriverTripDetailProvider, error, isLoading, isSending (+8 more)

### Community 53 - "account (53)"
Cohesion: 0.13
Nodes (15): ColorScheme, a, build, colorScheme, createState, _expanded, _Faq, _faqs (+7 more)

### Community 54 - "websocket (54)"
Cohesion: 0.12
Nodes (15): dart:async, _channel, _closed, connect, disconnect, _open, _retryDelay, _retryTimer (+7 more)

### Community 55 - "GeneratedPluginRegistrant.swift (55)"
Cohesion: 0.12
Nodes (15): device_info_plus, file_selector_macos, firebase_auth, firebase_core, firebase_messaging, flutter_local_notifications, flutter_secure_storage_macos, flutter_tts (+7 more)

### Community 56 - "login (56)"
Cohesion: 0.13
Nodes (14): ../domain/model/client_data.dart, ../domain/model/driver_data.dart, ../../domain/repository/register_client_repository.dart, ../../domain/repository/register_driver_repository.dart, _extractMessage, register, _translateApiError, _translateFirebaseError (+6 more)

### Community 57 - "trip (57)"
Cohesion: 0.12
Nodes (15): int get, _comment, _error, _isSending, _labels, onCommentChange, _selectedTags, send (+7 more)

### Community 58 - "account (58)"
Cohesion: 0.13
Nodes (15): build, colorScheme, _ContactRow, ContactScreen, _ContactScreenState, createState, _editField, icon (+7 more)

### Community 59 - "trip (59)"
Cohesion: 0.13
Nodes (14): ../../../../core/utils/ride_status.dart, ../data/repository/home_repository_impl.dart, acceptedTrips, cancelledTrips, completedTrips, error, isLoading, lastTripDate (+6 more)

### Community 60 - "local (60)"
Cohesion: 0.13
Nodes (14): _cityKey, clearData, getCityWork, getToken, getUserId, getUserType, isPhoneVerified, _phoneVerifiedKey (+6 more)

### Community 61 - "login (61)"
Cohesion: 0.13
Nodes (14): build, colorScheme, createState, dispose, _emailCtrl, _LoginForm, _obscure, onToggleObscure (+6 more)

### Community 62 - "trip (62)"
Cohesion: 0.13
Nodes (15): _NavButton, _RouteRow, _Speedometer, _StatusChip, _TurnBanner, _CarPhoto, _InfoTag, _RouteRow (+7 more)

### Community 63 - "trip (63)"
Cohesion: 0.14
Nodes (13): double?, ActiveTripProvider, error, isDriver, isLoading, load, personImageUrl, personInitial (+5 more)

### Community 64 - "di (64)"
Cohesion: 0.14
Nodes (13): apiService, init, _instance, ServiceLocator, sl, tokenManager, webSocketManager, ApiService (+5 more)

### Community 65 - "account (65)"
Cohesion: 0.15
Nodes (12): UserResponse, displayName, email, error, _fetch, initial, isLoading, loadUser (+4 more)

### Community 66 - "trip (66)"
Cohesion: 0.17
Nodes (11): Color?, IconData, _DetailSection, _formatHour, icon, iconColor, title, TripDetailScreen (+3 more)

### Community 67 - "utils.cpp (67)"
Cohesion: 0.24
Nodes (9): _In_, _In_opt_, vector, wWinMain(), string, wchar_t, CreateAndAttachConsole(), GetCommandLineArguments() (+1 more)

### Community 68 - "account (68)"
Cohesion: 0.17
Nodes (11): ChangePasswordProvider, confirmPassword, error, isLoading, newPassword, oldPassword, onConfirmChange, onNewChange (+3 more)

### Community 69 - "trip (69)"
Cohesion: 0.18
Nodes (11): ChangeNotifier, AccountProvider, RegisterClientProvider, RegisterDriverProvider, AcceptedTripsProvider, AvailableTripsProvider, DashboardProvider, RateDriverProvider (+3 more)

### Community 70 - "roleselection (70)"
Cohesion: 0.18
Nodes (10): ../../../../core/utils/responsive.dart, dart:math, avatarLetter, build, onTap, _RoleCard, RoleSelectionScreen, subtitle (+2 more)

### Community 71 - "widgets (71)"
Cohesion: 0.18
Nodes (10): EdgeInsetsGeometry?, AdaptiveScrollView, AdaptiveWrapper, build, child, children, innerPadding, padding (+2 more)

### Community 72 - "trip (72)"
Cohesion: 0.18
Nodes (10): Proposal, build, isAccepting, onAccept, proposal, _ProposalCard, tripId, TripProposalsScreen (+2 more)

### Community 73 - "login (73)"
Cohesion: 0.20
Nodes (10): build, createState, dispose, _emailCtrl, error, ForgotPasswordScreen, _ForgotPasswordScreenState, isLoading (+2 more)

### Community 74 - "manifest.json (74)"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 75 - "utils (75)"
Cohesion: 0.20
Nodes (9): _, _cents, format, Money, mxn, signed, _whole, package:intl/intl.dart (+1 more)

### Community 76 - "trip (76)"
Cohesion: 0.20
Nodes (9): ../../../core/utils/payment_method.dart, DriverProposalItem, build, DriverProposalDetailScreen, _formatDate, _formatHour, _infoRow, item (+1 more)

### Community 77 - "None (77)"
Cohesion: 0.20
Nodes (10): build, Route /cars, Route /change-password, Route /privacy-policy, Route /profile/contact, Route /profile/personal, Route /support, Route /terms (+2 more)

### Community 78 - "login (78)"
Cohesion: 0.22
Nodes (8): LoginRepositoryImpl, login, LoginRepository, call, LoginUseCase, repository, ../model/login_result.dart, ../repository/login_repository.dart

### Community 79 - "login (79)"
Cohesion: 0.22
Nodes (8): RegisterClientRepositoryImpl, register, RegisterClientRepository, call, RegisterClientUseCase, repository, ../model/client_data.dart, ../repository/register_client_repository.dart

### Community 80 - "login (80)"
Cohesion: 0.22
Nodes (8): RegisterDriverRepositoryImpl, register, RegisterDriverRepository, call, RegisterDriverUseCase, repository, ../model/driver_data.dart, ../repository/register_driver_repository.dart

### Community 81 - "trip (81)"
Cohesion: 0.20
Nodes (9): accepting, acceptProposal, error, isLoading, loadProposals, proposals, TripProposalsProvider, List (+1 more)

### Community 82 - "trip (82)"
Cohesion: 0.20
Nodes (9): driverId, enrichProposal, fetchAcceptedProposal, list, res, result, userType, where (+1 more)

### Community 83 - "None (83)"
Cohesion: 0.22
Nodes (8): core/services/notification_service.dart, ../domain/model/login_result.dart, ../../domain/repository/login_repository.dart, login, loginWithGoogle, package:dio/dio.dart, package:google_sign_in/google_sign_in.dart, package:jwt_decoder/jwt_decoder.dart

### Community 84 - "trip (84)"
Cohesion: 0.22
Nodes (7): ../domain/home_repository.dart, getClientTrips, getDriverTrips, HomeRepositoryImpl, getClientTrips, getDriverTrips, HomeRepository

### Community 85 - "utils (85)"
Cohesion: 0.22
Nodes (8): gridColumns, horizontalPadding, isExpanded, isLandscape, isTablet, maxContentWidth, Responsive, useRail

### Community 86 - "login (86)"
Cohesion: 0.22
Nodes (8): birthdate, ClientData, email, imagePath, lastname, name, numberPhone, password

### Community 87 - "firebase_options.dart (87)"
Cohesion: 0.22
Nodes (8): android, DefaultFirebaseOptions, ios, macos, web, windows, package:firebase_core/firebase_core.dart, static const FirebaseOptions

### Community 88 - "AppDelegate.swift (88)"
Cohesion: 0.25
Nodes (6): Any, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, AppDelegate, Bool, UIApplication

### Community 89 - "SceneDelegate.swift (89)"
Cohesion: 0.32
Nodes (5): Flutter, FlutterSceneDelegate, SceneDelegate, UIKit, XCTest

### Community 90 - "account (90)"
Cohesion: 0.25
Nodes (7): body, build, number, PrivacyPolicyScreen, _Section, _sections, title

### Community 91 - "account (91)"
Cohesion: 0.25
Nodes (7): body, build, number, _Section, _sections, TermsScreen, title

### Community 92 - "login (92)"
Cohesion: 0.25
Nodes (6): build, email, VerifyEmailScreen, build, WalletScreen, package:flutter/material.dart

### Community 93 - "phone_verification (93)"
Cohesion: 0.32
Nodes (7): build, PhoneVerificationBanner, _showCodeDialog, _showConfirmDialog, PhoneVerificationProvider, package:provider/provider.dart, phone_verification_provider.dart

### Community 94 - "roleselection (94)"
Cohesion: 0.25
Nodes (7): goToLogin, RoleSelectionProvider, selectClient, selectDriver, Route /login, Route /register-client, Route /register-driver

### Community 95 - "MainFlutterWindow.swift (95)"
Cohesion: 0.38
Nodes (4): Cocoa, FlutterMacOS, MainFlutterWindow, NSWindow

### Community 96 - "trip (96)"
Cohesion: 0.29
Nodes (6): Trip, error, isLoading, loadTrip, trip, TripDetailProvider

### Community 97 - "utils (97)"
Cohesion: 0.29
Nodes (6): canStart, label, _months, scheduledAt, TripSchedule, static const

### Community 98 - "main (98)"
Cohesion: 0.29
Nodes (6): build, DriverAppBar, preferredSize, showBack, PreferredSizeWidget, Size get

### Community 99 - "trip (99)"
Cohesion: 0.33
Nodes (5): core/di/service_locator.dart, ../../domain/accepted_trips_repository.dart, AcceptedTripsRepositoryImpl, getAcceptedTrips, AcceptedTripsRepository

### Community 100 - "AppDelegate.swift (100)"
Cohesion: 0.47
Nodes (4): FlutterAppDelegate, AppDelegate, Bool, NSApplication

### Community 101 - "ephemeral (101)"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 102 - "GeneratedPluginRegistrant.h (102)"
Cohesion: 0.40
Nodes (3): GeneratedPluginRegistrant, +registerWithRegistry, NSObject

### Community 103 - "trip (103)"
Cohesion: 0.33
Nodes (6): _openActive, build, _openActive, Route /active-trip, Route /trip-map, Route /trip-proposals

### Community 104 - "src (104)"
Cohesion: 0.60
Nodes (3): GeneratedPluginRegistrant, FlutterEngine, Keep

### Community 105 - "gradlew (105)"
Cohesion: 0.60
Nodes (3): gradlew script, die(), warn()

### Community 106 - "RunnerTests.swift (106)"
Cohesion: 0.40
Nodes (3): RunnerTests, RunnerTests, XCTestCase

### Community 107 - "widgets (107)"
Cohesion: 0.40
Nodes (4): build, rail, ScrollableNavigationRail, NavigationRail

### Community 108 - "trip (108)"
Cohesion: 0.40
Nodes (5): build, _buildBody, build, build, MaterialPageRoute

### Community 109 - "GeneratedPluginRegistrant.swift (109)"
Cohesion: 0.50
Nodes (3): FlutterPluginRegistry, FlutterViewController, RegisterGeneratedPlugins()

### Community 110 - "main.dart (110)"
Cohesion: 0.50
Nodes (4): ThemeProvider, _ThemeToggle, build, LogiRedApp

### Community 111 - "login (111)"
Cohesion: 0.67
Nodes (4): build, build, AppRoutes.privacyPolicy, AppRoutes.terms

### Community 112 - "main (112)"
Cohesion: 0.50
Nodes (4): ClientHomeScreen, _ClientHomeScreenState, initState, HomeProvider

## Knowledge Gaps
- **1548 isolated node(s):** `flutter_export_environment.sh script`, `+registerWithRegistry`, `ServiceLocator`, `_instance`, `tokenManager` (+1543 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **18 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Trip` connect `trip (96)` to `Modelos de Datos API`, `Tracking en Vivo del Cliente`, `Mis Viajes`, `Detalle de Historial`, `trip (31)`, `trip (48)`, `Sprites y Utilidades de Mapa`, `trip (19)`, `trip (52)`, `main (28)`, `trip (63)`?**
  _High betweenness centrality (0.023) - this node is a cross-community bridge._
- **Why does `Proposal` connect `trip (72)` to `Modelos de Datos API`, `Tracking en Vivo del Cliente`, `Mis Viajes`, `Detalle de Historial`, `trip (19)`, `trip (24)`, `trip (31)`?**
  _High betweenness centrality (0.016) - this node is a cross-community bridge._
- **What connects `flutter_export_environment.sh script`, `+registerWithRegistry`, `ServiceLocator` to the rest of the system?**
  _1548 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Navegación del Conductor` be split into smaller, more focused modules?**
  _Cohesion score 0.018518518518518517 - nodes in this community are weakly interconnected._
- **Should `Modelos de Datos API` be split into smaller, more focused modules?**
  _Cohesion score 0.020833333333333332 - nodes in this community are weakly interconnected._
- **Should `Registro Conductor (Dominio)` be split into smaller, more focused modules?**
  _Cohesion score 0.029411764705882353 - nodes in this community are weakly interconnected._
- **Should `Tracking en Vivo del Cliente` be split into smaller, more focused modules?**
  _Cohesion score 0.03225806451612903 - nodes in this community are weakly interconnected._