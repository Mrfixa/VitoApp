# VitoApp — Codebase Reference

## Overview

VitoApp is a **ride-sharing and delivery platform** (similar to Uber/Grab) composed of four sub-projects:

| Directory | Technology | Purpose |
|-----------|-----------|---------|
| `vito/` | Laravel 12, PHP 8.2+ | Backend API (modular monolith) |
| `VitoRider/` | Flutter 3.3.4, GetX | Customer/rider mobile app |
| `VitoDriver/` | Flutter 3.3.4, GetX | Driver mobile app |
| `landing/` | HTML5 + JS | QR invitation token validation page |

---

## vito/ — Laravel Backend

### Tech Stack
- **Framework**: Laravel 12, PHP 8.2+
- **Modules**: nwidart/laravel-modules v12 (16 active modules)
- **Auth**: Laravel Passport (OAuth2) + Sanctum (API tokens)
- **Real-time**: Laravel Reverb (WebSocket) + Pusher fallback
- **Queue**: Database driver
- **Cache/Session**: File (configurable to Redis)
- **DB**: MySQL primary; SQLite/PostgreSQL/SQL Server supported

### Payment Gateways (14)
Stripe, Razorpay, PayPal, Mercado Pago, Paytabs, Flutterwave, Paystack, BKash, SSL Commerz, Paytm, Iyzico, Xendit, LiqPay, SenangPay

### External Services
- Firebase (kreait/firebase-php) — push notifications & auth
- AWS S3 — file storage (optional)
- OpenAI — AiModule
- Twilio — SMS
- Google Maps
- PDF: MPDF, DomPDF
- QR code generation

### Active Modules (all 16 enabled in `modules_statuses.json`)
```
AdminModule, UserManagement, FareManagement, ZoneManagement,
VehicleManagement, PromotionManagement, BusinessManagement,
AuthManagement, ParcelManagement, TripManagement, ChattingManagement,
ReviewModule, Gateways, TransactionManagement, BlogManagement, AiModule
```

### Routes
- `routes/web.php` — Landing page, blog, newsletter, parcel tracking, payment callbacks, WebSocket test
- `routes/api.php` — Entry points (minimal; most delegated to module routes)
- `routes/install.php` / `routes/update.php` — Setup/upgrade flows

### Key Models by Module

**TripManagement (21)**: `TripRequest`, `TripRequestCoordinate`, `TripStatus`, `TripRoute`, `TripNavigation`, `TripRequestTime`, `TripRequestFee`, `FareBidding`, `FareBiddingLog`, `SafetyAlert`, `RejectedDriverRequest`, `RecentAddress`, `MartOrder`, `MartOrderItem`, `MartProduct`, `MartPromoCode`, `ParcelRefund`, `ParcelRefundProof`, `StripeEvent`, `LateReturnPenaltyNotification`, `TempTripNotification`

**UserManagement (24)**: `User`, `DriverDetail`, `DriverIdentityVerification`, `DriverTimeLog`, `UserAccount`, `UserAddress`, `UserLastLocation`, `UserLevel`, `UserLevelHistory`, `Role`, `RoleUser`, `ModuleAccess`, `LevelAccess`, `OtpVerification`, `AppNotification`, `TimeLog`, `TimeTrack`, `ReferralCustomer`, `ReferralDriver`, `LoyaltyPointsHistory`, `WithdrawMethod`, `WithdrawRequest`, `UserWithdrawMethodInfo`, `WalletBonus`

**FareManagement (8)**: `TripFare`, `ParcelFare`, `ParcelFareWeight`, `SurgePricing`, `SurgePricingZone`, `SurgePricingServiceCategory`, `SurgePricingTimeSlot`, `ZoneWiseDefaultTripFare`

**Other key models**: `BusinessSetting`, `Zone`, `Vehicle`, `VehicleBrand`, `VehicleModel`, `VehicleCategory`, `Blog`, `BlogCategory`, `ParcelCategory`, `ParcelInformation`, `ParcelWeight`, `Review`, `Transaction`, `ActivityLog`, `QrToken`

### Notable Backend Features
- Surge pricing with time-slot management
- Parcel delivery system (separate from ride trips)
- Mart/marketplace ordering integration
- Driver/customer leveling + loyalty points
- Referral system
- Real-time trip tracking via WebSockets
- AI module (OpenAI integration)
- Activity logging & audit trails

---

## VitoRider/ — Flutter Rider App

**Path**: `VitoRider/HexaRide-User-app-release-3.1/`

### Dependencies
- State: GetX 4.7.3
- Maps: google_maps_flutter 2.14.2
- Location: geolocator 14.0.2, flutter_animarker 3.2.0
- Real-time: dart_pusher_channels 1.2.3
- Notifications: firebase_messaging, flutter_local_notifications
- Media: image_picker, cached_network_image, video_player, chewie, flutter_svg
- Input: pin_code_fields, country_code_picker, flutter_typeahead
- Other: qr_code_scanner, lottie, speech_to_text, share_plus, url_launcher

### Feature Modules (27)
```
splash, auth, onboard, home, dashboard, address, location,
ride, parcel, payment, wallet, coupon, promotion, mart,
my_offer, my_level, message, notification, profile,
settings, trip, refund_request, safety_setup, refer_and_earn,
support, realtime_location_tracking, map
```

### Architecture
- `lib/data/` — API client, error handling, network management
- `lib/features/` — Feature-based modules (controller + screen per feature)
- `lib/common_widgets/` — Reusable UI components
- `lib/theme/` — Light/dark themes
- `lib/localization/` — Multi-language support
- `lib/helper/` — DI container, utilities
- `lib/util/` — Constants, dimensions, image paths

---

## VitoDriver/ — Flutter Driver App

**Path**: `VitoDriver/HexaRide-Driver-app-release-3.1/`

### Additional Dependencies (vs Rider)
- camera 0.11.3+1
- google_mlkit_face_detection 0.13.2 — KYC face verification
- flutter_image_compress 2.4.0
- flutter_downloader 1.12.0

### Feature Modules (26, driver-specific)
```
splash, auth, home, dashboard, location, map, ride, trip,
profile, setting, wallet, notification, chat, mart,
refer_and_earn, realtime_location_tracking, leaderboard,
face_verification, safety_setup, review, help_and_support,
out_of_zone, maintainance_mode, html
```

### Key Differences from Rider App
- Face verification (ML Kit) for KYC
- Leaderboard / driver rankings
- Out-of-zone alerts
- Direct customer chat
- Download manager for offline content

---

## landing/ — Invitation Page

Single-page HTML5 app for QR invitation token validation.

- Validates 64-char alphanumeric tokens via `/api/qr/validate/{token}`
- Deep-links to app (`vito://invite?token=`)
- Platform detection: iOS → App Store, Android → Play Store, Desktop → instructions
- Configured for domain: `dacatlon.store`

---

## Development Branch
Active feature branch: `claude/repo-analysis-14pzg`
