import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_pa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
    Locale('pa')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Rural Health Connect'**
  String get appTitle;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Title for language selection screen
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Hindi language name
  ///
  /// In en, this message translates to:
  /// **'हिंदी'**
  String get hindi;

  /// Marathi language name
  ///
  /// In en, this message translates to:
  /// **'मराठी'**
  String get marathi;

  /// Punjabi language name
  ///
  /// In en, this message translates to:
  /// **'ਪੰਜਾਬੀ'**
  String get punjabi;

  /// Personal information menu item
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// Doctor schedule menu item
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// Clinic location menu item
  ///
  /// In en, this message translates to:
  /// **'Clinic Location'**
  String get clinicLocation;

  /// Store location menu item
  ///
  /// In en, this message translates to:
  /// **'Store Location'**
  String get storeLocation;

  /// Health records menu item
  ///
  /// In en, this message translates to:
  /// **'Health Records'**
  String get healthRecords;

  /// Notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Dark mode menu item
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Help and support menu item
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Logout menu item
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Login screen welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// Login screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to Rural Health Connect'**
  String get signInToContinue;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register prompt text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Sign up link
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Register screen title
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Register screen header
  ///
  /// In en, this message translates to:
  /// **'Join Rural Health Connect'**
  String get joinRuralHealthConnect;

  /// Register screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started'**
  String get createAccountToGetStarted;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Location field label
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Home navigation tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Appointments navigation tab
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// Consult navigation tab
  ///
  /// In en, this message translates to:
  /// **'Consult'**
  String get consult;

  /// Medicines navigation tab
  ///
  /// In en, this message translates to:
  /// **'Medicines'**
  String get medicines;

  /// Profile navigation tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Video consult quick action
  ///
  /// In en, this message translates to:
  /// **'Video Consult'**
  String get videoConsult;

  /// Video consult description
  ///
  /// In en, this message translates to:
  /// **'Talk to a doctor now'**
  String get talkToDoctorNow;

  /// Symptom check quick action
  ///
  /// In en, this message translates to:
  /// **'Symptom Check'**
  String get symptomCheck;

  /// Symptom check description
  ///
  /// In en, this message translates to:
  /// **'AI-powered diagnosis'**
  String get aiPoweredDiagnosis;

  /// Find medicine quick action
  ///
  /// In en, this message translates to:
  /// **'Find Medicine'**
  String get findMedicine;

  /// Find medicine description
  ///
  /// In en, this message translates to:
  /// **'Check availability nearby'**
  String get checkAvailabilityNearby;

  /// Nearby pharmacy quick action
  ///
  /// In en, this message translates to:
  /// **'Nearby Pharmacy'**
  String get nearbyPharmacy;

  /// Nearby pharmacy description
  ///
  /// In en, this message translates to:
  /// **'Find pharmacies'**
  String get findPharmacies;

  /// Upcoming appointments section title
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get upcomingAppointments;

  /// No appointments message
  ///
  /// In en, this message translates to:
  /// **'No upcoming appointments'**
  String get noUpcomingAppointments;

  /// View all button
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Search bar placeholder
  ///
  /// In en, this message translates to:
  /// **'Search doctors, medicines...'**
  String get searchDoctors;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Book appointment button
  ///
  /// In en, this message translates to:
  /// **'Book'**
  String get book;

  /// Upcoming tab
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Completed tab
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Cancelled tab
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// Find doctor tab
  ///
  /// In en, this message translates to:
  /// **'Find Doctor'**
  String get findDoctor;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Find nearby pharmacy card title
  ///
  /// In en, this message translates to:
  /// **'Find Nearby Pharmacy'**
  String get findNearbyPharmacy;

  /// Find nearby pharmacy description
  ///
  /// In en, this message translates to:
  /// **'Locate pharmacies near you'**
  String get locatePharmaciesNearYou;

  /// Upload prescription card title
  ///
  /// In en, this message translates to:
  /// **'Upload Prescription'**
  String get uploadPrescription;

  /// Upload prescription description
  ///
  /// In en, this message translates to:
  /// **'Add a new prescription'**
  String get addNewPrescription;

  /// My prescriptions section title
  ///
  /// In en, this message translates to:
  /// **'My Prescriptions'**
  String get myPrescriptions;

  /// Orders button
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No prescriptions message
  ///
  /// In en, this message translates to:
  /// **'No prescriptions yet'**
  String get noPrescriptions;

  /// No prescriptions prompt
  ///
  /// In en, this message translates to:
  /// **'Upload your first prescription to get started'**
  String get uploadYourFirstPrescription;

  /// Symptom checker input placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter your symptoms'**
  String get enterYourSymptoms;

  /// Check symptoms button
  ///
  /// In en, this message translates to:
  /// **'Check Symptoms'**
  String get checkSymptoms;

  /// Select date button
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Title field label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Add health record screen title
  ///
  /// In en, this message translates to:
  /// **'Add Health Record'**
  String get addHealthRecord;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Attachment section title
  ///
  /// In en, this message translates to:
  /// **'Attachment (Optional)'**
  String get attachmentOptional;

  /// Attach file button
  ///
  /// In en, this message translates to:
  /// **'Attach File'**
  String get attachFile;

  /// Save health record button
  ///
  /// In en, this message translates to:
  /// **'Save Health Record'**
  String get saveHealthRecord;

  /// Store name field label
  ///
  /// In en, this message translates to:
  /// **'Store Name'**
  String get storeName;

  /// Store address field label
  ///
  /// In en, this message translates to:
  /// **'Store Address'**
  String get storeAddress;

  /// Store information section title
  ///
  /// In en, this message translates to:
  /// **'Store Information'**
  String get storeInformation;

  /// Use current location button
  ///
  /// In en, this message translates to:
  /// **'Use Current Location'**
  String get useCurrentLocation;

  /// Clinic address field label
  ///
  /// In en, this message translates to:
  /// **'Clinic Address'**
  String get clinicAddress;

  /// Clinic information section title
  ///
  /// In en, this message translates to:
  /// **'Clinic Information'**
  String get clinicInformation;

  /// Dashboard tab
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// My orders tab
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No appointments message
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get noAppointmentsFound;

  /// No doctors message
  ///
  /// In en, this message translates to:
  /// **'No doctors found'**
  String get noDoctorsFound;

  /// Search no results message
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get tryDifferentSearchTerm;

  /// Search empty state message
  ///
  /// In en, this message translates to:
  /// **'Start typing to search'**
  String get startTypingToSearch;

  /// Doctor search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search by name or specialty...'**
  String get searchByNameOrSpecialty;

  /// No doctors available message
  ///
  /// In en, this message translates to:
  /// **'No doctors available'**
  String get noDoctorsAvailable;

  /// Health tips section title
  ///
  /// In en, this message translates to:
  /// **'Health Tips'**
  String get healthTips;

  /// Health tip title
  ///
  /// In en, this message translates to:
  /// **'Stay Hydrated'**
  String get stayHydrated;

  /// Health tip description
  ///
  /// In en, this message translates to:
  /// **'Drink at least 8 glasses of water daily'**
  String get drinkAtLeast8Glasses;

  /// Health tip title
  ///
  /// In en, this message translates to:
  /// **'Regular Exercise'**
  String get regularExercise;

  /// Health tip description
  ///
  /// In en, this message translates to:
  /// **'30 minutes of physical activity each day'**
  String get thirtyMinutesPhysicalActivity;

  /// Health tip title
  ///
  /// In en, this message translates to:
  /// **'Balanced Diet'**
  String get balancedDiet;

  /// Health tip description
  ///
  /// In en, this message translates to:
  /// **'Include fruits and vegetables in every meal'**
  String get includeFruitsVegetables;

  /// Health tip title
  ///
  /// In en, this message translates to:
  /// **'Quality Sleep'**
  String get qualitySleep;

  /// Health tip description
  ///
  /// In en, this message translates to:
  /// **'Get 7-8 hours of sleep every night'**
  String get get7To8HoursSleep;

  /// Available doctors section title
  ///
  /// In en, this message translates to:
  /// **'Available Doctors'**
  String get availableDoctors;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'mr', 'pa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'pa':
      return AppLocalizationsPa();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
