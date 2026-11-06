// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get signInTitle => 'Welcome to Ev';

  @override
  String get signInSubtitle =>
      'Sign in to share lists, tasks and news with the people you live with.';

  @override
  String get signInWithGoogle => 'Continue with Google';

  @override
  String get signInOr => 'or';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailInvalid => 'Enter a valid email address.';

  @override
  String get sendCodeButton => 'Email me a code';

  @override
  String codeSentTo(String email) {
    return 'We sent a 6-digit code to $email.';
  }

  @override
  String get codeLabel => 'Code';

  @override
  String get codeInvalid => 'That code is wrong or has expired.';

  @override
  String get verifyCodeButton => 'Sign in';

  @override
  String get resendCodeButton => 'Send a new code';

  @override
  String get codeResent => 'We sent a new code.';

  @override
  String get useDifferentEmailButton => 'Use a different email';

  @override
  String get googleSignInFailed => 'Couldn\'t sign in with Google. Try again.';

  @override
  String get genericError =>
      'Something went wrong. Check your connection and try again.';

  @override
  String get displayNameTitle => 'What should we call you?';

  @override
  String get displayNameExplanation =>
      'The people you live with see this name, in every Household you join.';

  @override
  String get displayNameLabel => 'Your name';

  @override
  String get displayNameEmpty => 'Enter your name.';

  @override
  String get continueButton => 'Continue';

  @override
  String get loadingFailed => 'Couldn\'t load your account.';

  @override
  String get retryButton => 'Try again';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name!';
  }

  @override
  String get signOutButton => 'Sign out';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageHeading => 'Language';

  @override
  String get createHouseholdTitle => 'Create a Household';

  @override
  String get createHouseholdExplanation =>
      'Give it a name everyone who lives there will recognise.';

  @override
  String get householdNameLabel => 'Household name';

  @override
  String get householdNameEmpty => 'Enter a name for the Household.';

  @override
  String get moduleSetupTitle => 'Choose your Modules';

  @override
  String get moduleSetupExplanation =>
      'Everything is on. Switch off what your Household won\'t use. Admins can change this later.';

  @override
  String get moduleShoppingList => 'Shopping List';

  @override
  String get moduleShoppingListDescription =>
      'Things the Household needs to buy';

  @override
  String get modulePresence => 'Presence';

  @override
  String get modulePresenceDescription => 'Who is at home and who is out';

  @override
  String get moduleAnnouncements => 'Announcements';

  @override
  String get moduleAnnouncementsDescription =>
      'Messages and Hangouts for everyone';

  @override
  String get moduleTasks => 'Tasks';

  @override
  String get moduleTasksDescription => 'Household jobs, one-off or recurring';

  @override
  String get moduleHouseInfo => 'House Info';

  @override
  String get moduleHouseInfoDescription =>
      'Wifi password, bin day and other facts';

  @override
  String get moduleMeals => 'Meals';

  @override
  String get moduleMealsDescription => 'Who eats at home for upcoming meals';

  @override
  String get switchHouseholdTooltip => 'Switch Household';

  @override
  String get yourHouseholdsTitle => 'Your Households';

  @override
  String get defaultHouseholdTooltip => 'Default Household: the app opens here';

  @override
  String get makeDefaultHouseholdTooltip => 'Make this your Default Household';

  @override
  String defaultHouseholdSaved(String name) {
    return '$name opens next time you start the app.';
  }
}
