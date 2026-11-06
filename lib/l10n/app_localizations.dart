import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('tr'),
  ];

  /// Heading of the sign-in screen. Ev is the app's name.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Ev'**
  String get signInTitle;

  /// Line under the sign-in heading.
  ///
  /// In en, this message translates to:
  /// **'Sign in to share lists, tasks and news with the people you live with.'**
  String get signInSubtitle;

  /// Button that signs in with a Google account.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get signInWithGoogle;

  /// Separator between Google sign-in and email sign-in.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get signInOr;

  /// Label of the email address field on the sign-in screen.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Shown under the email field when the address is not valid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get emailInvalid;

  /// Button that emails a one-time sign-in code.
  ///
  /// In en, this message translates to:
  /// **'Email me a code'**
  String get sendCodeButton;

  /// Shown after the sign-in code was emailed.
  ///
  /// In en, this message translates to:
  /// **'We sent a 6-digit code to {email}.'**
  String codeSentTo(String email);

  /// Label of the field for the emailed sign-in code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get codeLabel;

  /// Shown when the entered sign-in code is not accepted.
  ///
  /// In en, this message translates to:
  /// **'That code is wrong or has expired.'**
  String get codeInvalid;

  /// Button that signs in with the entered code.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get verifyCodeButton;

  /// Button that emails another sign-in code.
  ///
  /// In en, this message translates to:
  /// **'Send a new code'**
  String get resendCodeButton;

  /// Confirmation after another sign-in code was emailed.
  ///
  /// In en, this message translates to:
  /// **'We sent a new code.'**
  String get codeResent;

  /// Button that goes back to entering the email address.
  ///
  /// In en, this message translates to:
  /// **'Use a different email'**
  String get useDifferentEmailButton;

  /// Shown when Google sign-in fails for a reason other than the person cancelling.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign in with Google. Try again.'**
  String get googleSignInFailed;

  /// Shown when an action fails for an unexpected reason.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Check your connection and try again.'**
  String get genericError;

  /// Heading of the screen asking a new person for their name.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get displayNameTitle;

  /// Explains where the display name is shown.
  ///
  /// In en, this message translates to:
  /// **'The people you live with see this name, in every Household you join.'**
  String get displayNameExplanation;

  /// Label of the display name field.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get displayNameLabel;

  /// Shown when the display name field is left empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your name.'**
  String get displayNameEmpty;

  /// Button that saves what was entered on a step and moves on.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Shown when the signed-in person's profile cannot be loaded.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load your account.'**
  String get loadingFailed;

  /// Button that retries a failed load.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retryButton;

  /// Greeting on the main page.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}!'**
  String homeGreeting(String name);

  /// Button that signs the person out.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOutButton;

  /// Heading of the settings screen, and the tooltip of the button that opens it.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// Heading above the choice of app language on the settings screen.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageHeading;

  /// Heading of the screen that creates a Household, and the switcher entry that opens it.
  ///
  /// In en, this message translates to:
  /// **'Create a Household'**
  String get createHouseholdTitle;

  /// Line under the heading of the create-Household screen.
  ///
  /// In en, this message translates to:
  /// **'Give it a name everyone who lives there will recognise.'**
  String get createHouseholdExplanation;

  /// Label of the Household name field.
  ///
  /// In en, this message translates to:
  /// **'Household name'**
  String get householdNameLabel;

  /// Shown when the Household name field is left empty.
  ///
  /// In en, this message translates to:
  /// **'Enter a name for the Household.'**
  String get householdNameEmpty;

  /// Heading of the step after naming a new Household, where its Modules are switched on or off.
  ///
  /// In en, this message translates to:
  /// **'Choose your Modules'**
  String get moduleSetupTitle;

  /// Explains the Module setup step of a new Household.
  ///
  /// In en, this message translates to:
  /// **'Everything is on. Switch off what your Household won\'t use. Admins can change this later.'**
  String get moduleSetupExplanation;

  /// Shown in the Module setup step of a new Household when every Module is switched off.
  ///
  /// In en, this message translates to:
  /// **'Switch on at least one Module.'**
  String get moduleSetupNoneSelected;

  /// Name of the Shopping List Module.
  ///
  /// In en, this message translates to:
  /// **'Shopping List'**
  String get moduleShoppingList;

  /// What the Shopping List Module is for, under its name in the Module setup step.
  ///
  /// In en, this message translates to:
  /// **'Things the Household needs to buy'**
  String get moduleShoppingListDescription;

  /// Name of the Presence Module.
  ///
  /// In en, this message translates to:
  /// **'Presence'**
  String get modulePresence;

  /// What the Presence Module is for, under its name in the Module setup step.
  ///
  /// In en, this message translates to:
  /// **'Who is at home and who is out'**
  String get modulePresenceDescription;

  /// Name of the Announcements Module.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get moduleAnnouncements;

  /// What the Announcements Module is for, under its name in the Module setup step.
  ///
  /// In en, this message translates to:
  /// **'Messages and Hangouts for everyone'**
  String get moduleAnnouncementsDescription;

  /// Name of the Tasks Module.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get moduleTasks;

  /// What the Tasks Module is for, under its name in the Module setup step.
  ///
  /// In en, this message translates to:
  /// **'Household jobs, one-off or recurring'**
  String get moduleTasksDescription;

  /// Name of the House Info Module.
  ///
  /// In en, this message translates to:
  /// **'House Info'**
  String get moduleHouseInfo;

  /// What the House Info Module is for, under its name in the Module setup step.
  ///
  /// In en, this message translates to:
  /// **'Wifi password, bin day and other facts'**
  String get moduleHouseInfoDescription;

  /// Name of the Meals Module.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get moduleMeals;

  /// What the Meals Module is for, under its name in the Module setup step.
  ///
  /// In en, this message translates to:
  /// **'Who eats at home for upcoming meals'**
  String get moduleMealsDescription;

  /// Tooltip of the Household name at the top of the screen, which opens the list of the person's Households.
  ///
  /// In en, this message translates to:
  /// **'Switch Household'**
  String get switchHouseholdTooltip;

  /// Heading of the list of the person's Households in the switcher.
  ///
  /// In en, this message translates to:
  /// **'Your Households'**
  String get yourHouseholdsTitle;

  /// Tooltip of the filled star next to the person's Default Household in the switcher.
  ///
  /// In en, this message translates to:
  /// **'Default Household: the app opens here'**
  String get defaultHouseholdTooltip;

  /// Tooltip of the empty star that makes a Household the person's Default Household.
  ///
  /// In en, this message translates to:
  /// **'Make this your Default Household'**
  String get makeDefaultHouseholdTooltip;

  /// Confirmation after picking a Default Household.
  ///
  /// In en, this message translates to:
  /// **'{name} opens next time you start the app.'**
  String defaultHouseholdSaved(String name);
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
