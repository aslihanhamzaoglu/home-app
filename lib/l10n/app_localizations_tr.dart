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
}
