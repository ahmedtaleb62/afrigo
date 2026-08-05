import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AfrigoLocalizations
/// returned by `AfrigoLocalizations.of(context)`.
///
/// Applications need to include `AfrigoLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AfrigoLocalizations.localizationsDelegates,
///   supportedLocales: AfrigoLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AfrigoLocalizations.supportedLocales
/// property.
abstract class AfrigoLocalizations {
  AfrigoLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AfrigoLocalizations of(BuildContext context) {
    return Localizations.of<AfrigoLocalizations>(context, AfrigoLocalizations)!;
  }

  static const LocalizationsDelegate<AfrigoLocalizations> delegate =
      _AfrigoLocalizationsDelegate();

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
    Locale('ar'),
    Locale('fr'),
  ];

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'تراجع'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get commonConfirm;

  /// No description provided for @commonLoading.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ التحميل...'**
  String get commonLoading;

  /// No description provided for @commonChangesSaved.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ التغييرات بنجاح'**
  String get commonChangesSaved;

  /// No description provided for @commonErrorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ ما، حاول مرة أخرى'**
  String get commonErrorGeneric;

  /// No description provided for @emptyStateTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج بعد'**
  String get emptyStateTitle;

  /// No description provided for @emptyStateMessage.
  ///
  /// In ar, this message translates to:
  /// **'لم نجد أي عنصر مطابق حاليًا'**
  String get emptyStateMessage;

  /// No description provided for @confirmCancelOrderTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد إلغاء الرحلة'**
  String get confirmCancelOrderTitle;

  /// No description provided for @confirmCancelOrderMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد إلغاء هذه الرحلة؟ قد تُطبّق رسوم إلغاء.'**
  String get confirmCancelOrderMessage;

  /// No description provided for @confirmCancelOrderConfirm.
  ///
  /// In ar, this message translates to:
  /// **'نعم، إلغاء'**
  String get confirmCancelOrderConfirm;

  /// No description provided for @statusOnline.
  ///
  /// In ar, this message translates to:
  /// **'متصل'**
  String get statusOnline;

  /// No description provided for @statusOffline.
  ///
  /// In ar, this message translates to:
  /// **'غير متصل'**
  String get statusOffline;

  /// No description provided for @badgePending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get badgePending;

  /// No description provided for @badgeVerified.
  ///
  /// In ar, this message translates to:
  /// **'موثّق'**
  String get badgeVerified;

  /// No description provided for @badgeRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوض'**
  String get badgeRejected;

  /// No description provided for @badgeLowBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد منخفض'**
  String get badgeLowBalance;

  /// No description provided for @badgeStopped.
  ///
  /// In ar, this message translates to:
  /// **'متوقف'**
  String get badgeStopped;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navOrders.
  ///
  /// In ar, this message translates to:
  /// **'الطلبات'**
  String get navOrders;

  /// No description provided for @navWallet.
  ///
  /// In ar, this message translates to:
  /// **'المحفظة'**
  String get navWallet;

  /// No description provided for @navAccount.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get navAccount;
}

class _AfrigoLocalizationsDelegate
    extends LocalizationsDelegate<AfrigoLocalizations> {
  const _AfrigoLocalizationsDelegate();

  @override
  Future<AfrigoLocalizations> load(Locale locale) {
    return SynchronousFuture<AfrigoLocalizations>(
      lookupAfrigoLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AfrigoLocalizationsDelegate old) => false;
}

AfrigoLocalizations lookupAfrigoLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AfrigoLocalizationsAr();
    case 'fr':
      return AfrigoLocalizationsFr();
  }

  throw FlutterError(
    'AfrigoLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
