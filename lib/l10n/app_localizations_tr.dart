// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get signInTitle => 'Ev\'e hoş geldin';

  @override
  String get signInSubtitle =>
      'Birlikte yaşadığın kişilerle listeleri, işleri ve haberleri paylaşmak için giriş yap.';

  @override
  String get signInWithGoogle => 'Google ile devam et';

  @override
  String get signInOr => 'veya';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get emailInvalid => 'Geçerli bir e-posta adresi gir.';

  @override
  String get sendCodeButton => 'Bana kod gönder';

  @override
  String codeSentTo(String email) {
    return '$email adresine 6 haneli bir kod gönderdik.';
  }

  @override
  String get codeLabel => 'Kod';

  @override
  String get codeInvalid => 'Bu kod yanlış ya da süresi dolmuş.';

  @override
  String get verifyCodeButton => 'Giriş yap';

  @override
  String get resendCodeButton => 'Yeni kod gönder';

  @override
  String get codeResent => 'Yeni bir kod gönderdik.';

  @override
  String get useDifferentEmailButton => 'Başka bir e-posta kullan';

  @override
  String get googleSignInFailed => 'Google ile giriş yapılamadı. Tekrar dene.';

  @override
  String get genericError =>
      'Bir şeyler ters gitti. Bağlantını kontrol edip tekrar dene.';

  @override
  String get displayNameTitle => 'Sana nasıl hitap edelim?';

  @override
  String get displayNameExplanation =>
      'Birlikte yaşadığın kişiler, katıldığın her evde bu adı görür.';

  @override
  String get displayNameLabel => 'Adın';

  @override
  String get displayNameEmpty => 'Adını gir.';

  @override
  String get continueButton => 'Devam et';

  @override
  String get loadingFailed => 'Hesabın yüklenemedi.';

  @override
  String get retryButton => 'Tekrar dene';

  @override
  String homeGreeting(String name) {
    return 'Merhaba, $name!';
  }

  @override
  String get signOutButton => 'Çıkış yap';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get languageHeading => 'Dil';

  @override
  String get createHouseholdTitle => 'Yeni ev oluştur';

  @override
  String get createHouseholdExplanation =>
      'Orada yaşayan herkesin tanıyacağı bir ad ver.';

  @override
  String get householdNameLabel => 'Evin adı';

  @override
  String get householdNameEmpty => 'Ev için bir ad gir.';

  @override
  String get moduleSetupTitle => 'Modülleri seç';

  @override
  String get moduleSetupExplanation =>
      'Hepsi açık. Evinde kullanmayacağın modülleri kapat. Yöneticiler bunu sonra değiştirebilir.';

  @override
  String get moduleSetupNoneSelected => 'En az bir modülü açık bırak.';

  @override
  String get moduleShoppingList => 'Alışveriş Listesi';

  @override
  String get moduleShoppingListDescription => 'Evin alması gerekenler';

  @override
  String get modulePresence => 'Evde / Dışarıda';

  @override
  String get modulePresenceDescription => 'Kim evde, kim dışarıda';

  @override
  String get moduleAnnouncements => 'Duyurular';

  @override
  String get moduleAnnouncementsDescription =>
      'Herkese mesajlar ve etkinlikler';

  @override
  String get moduleTasks => 'Ev İşleri';

  @override
  String get moduleTasksDescription => 'Tek seferlik ya da düzenli ev işleri';

  @override
  String get moduleHouseInfo => 'Ev Bilgileri';

  @override
  String get moduleHouseInfoDescription =>
      'Wifi şifresi, çöp günü ve diğer bilgiler';

  @override
  String get moduleMeals => 'Yemek';

  @override
  String get moduleMealsDescription => 'Kim evde yemek yiyecek';

  @override
  String get switchHouseholdTooltip => 'Evi değiştir';

  @override
  String get yourHouseholdsTitle => 'Evlerin';

  @override
  String get defaultHouseholdTooltip => 'Varsayılan ev: uygulama burada açılır';

  @override
  String get makeDefaultHouseholdTooltip => 'Varsayılan evin yap';

  @override
  String defaultHouseholdSaved(String name) {
    return 'Uygulamayı bir dahaki açışında $name açılacak.';
  }
}
