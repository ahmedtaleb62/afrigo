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

  /// No description provided for @commonContinue.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get commonContinue;

  /// No description provided for @commonSkip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get commonSkip;

  /// No description provided for @commonNext.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get commonNext;

  /// No description provided for @commonStartNow.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ الآن'**
  String get commonStartNow;

  /// No description provided for @commonPhoneLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get commonPhoneLabel;

  /// No description provided for @commonPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get commonPasswordLabel;

  /// No description provided for @commonLogin.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get commonLogin;

  /// No description provided for @commonCreateAccount.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get commonCreateAccount;

  /// No description provided for @commonOtpTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الرمز'**
  String get commonOtpTitle;

  /// No description provided for @commonOtpDesc.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز المكوّن من 6 أرقام المرسل إلى رقم هاتفك'**
  String get commonOtpDesc;

  /// No description provided for @commonResendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال خلال {seconds} ثانية'**
  String commonResendIn(int seconds);

  /// No description provided for @commonResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get commonResend;

  /// No description provided for @commonVerify.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get commonVerify;

  /// No description provided for @commonNotNow.
  ///
  /// In ar, this message translates to:
  /// **'ليس الآن'**
  String get commonNotNow;

  /// No description provided for @commonGreetingFallback.
  ///
  /// In ar, this message translates to:
  /// **'مرحبًا'**
  String get commonGreetingFallback;

  /// No description provided for @clientLoginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get clientLoginTitle;

  /// No description provided for @clientLoginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بياناتك للاستمرار في afrigo'**
  String get clientLoginSubtitle;

  /// No description provided for @clientForgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get clientForgotPassword;

  /// No description provided for @clientNoAccountPrompt.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟ '**
  String get clientNoAccountPrompt;

  /// No description provided for @clientHaveAccountPrompt.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب؟ '**
  String get clientHaveAccountPrompt;

  /// No description provided for @clientFullNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get clientFullNameLabel;

  /// No description provided for @clientFullNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: سارة بن علي'**
  String get clientFullNameHint;

  /// No description provided for @clientConfirmPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get clientConfirmPasswordLabel;

  /// No description provided for @clientOnboard1Title.
  ///
  /// In ar, this message translates to:
  /// **'تنقّل بثقة'**
  String get clientOnboard1Title;

  /// No description provided for @clientOnboard1Desc.
  ///
  /// In ar, this message translates to:
  /// **'اطلب تكسي في ثوانٍ مع سائقين موثّقين وأسعار واضحة قبل الانطلاق'**
  String get clientOnboard1Desc;

  /// No description provided for @clientOnboard2Title.
  ///
  /// In ar, this message translates to:
  /// **'اطلب طعامك المفضّل'**
  String get clientOnboard2Title;

  /// No description provided for @clientOnboard2Desc.
  ///
  /// In ar, this message translates to:
  /// **'تصفّح مئات المطاعم القريبة واطلب وجبتك بضغطة زر'**
  String get clientOnboard2Desc;

  /// No description provided for @clientOnboard3Title.
  ///
  /// In ar, this message translates to:
  /// **'أرسل واستلم طرودك'**
  String get clientOnboard3Title;

  /// No description provided for @clientOnboard3Desc.
  ///
  /// In ar, this message translates to:
  /// **'توصيل سريع وآمن لأي طرد داخل مدينتك'**
  String get clientOnboard3Desc;

  /// No description provided for @clientForgotTitle.
  ///
  /// In ar, this message translates to:
  /// **'استعادة كلمة المرور'**
  String get clientForgotTitle;

  /// No description provided for @clientForgotStep0Desc.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رقم هاتفك وسنرسل رمز استعادة عبر رسالة نصية'**
  String get clientForgotStep0Desc;

  /// No description provided for @clientSendCode.
  ///
  /// In ar, this message translates to:
  /// **'إرسال الرمز'**
  String get clientSendCode;

  /// No description provided for @clientCodeSentDesc.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رمز إلى هاتفك'**
  String get clientCodeSentDesc;

  /// No description provided for @clientEnterCodeHint.
  ///
  /// In ar, this message translates to:
  /// **'أدخل الرمز'**
  String get clientEnterCodeHint;

  /// No description provided for @clientNewPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة مرور جديدة'**
  String get clientNewPasswordLabel;

  /// No description provided for @clientSaveAndLogin.
  ///
  /// In ar, this message translates to:
  /// **'حفظ وتسجيل الدخول'**
  String get clientSaveAndLogin;

  /// No description provided for @clientLocationPermTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الموقع الجغرافي'**
  String get clientLocationPermTitle;

  /// No description provided for @clientLocationPermDesc.
  ///
  /// In ar, this message translates to:
  /// **'نحتاج موقعك لعرض الخدمات القريبة منك وتحديد نقطة انطلاقك بدقة'**
  String get clientLocationPermDesc;

  /// No description provided for @clientLocationPermAllow.
  ///
  /// In ar, this message translates to:
  /// **'السماح بالوصول للموقع'**
  String get clientLocationPermAllow;

  /// No description provided for @clientNotifPermTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get clientNotifPermTitle;

  /// No description provided for @clientNotifPermDesc.
  ///
  /// In ar, this message translates to:
  /// **'ابقَ على اطلاع بحالة طلباتك، عروض خاصة، وتحديثات مهمة'**
  String get clientNotifPermDesc;

  /// No description provided for @clientNotifPermAllow.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الإشعارات'**
  String get clientNotifPermAllow;

  /// No description provided for @clientHomeTaxiTitle.
  ///
  /// In ar, this message translates to:
  /// **'تكسي'**
  String get clientHomeTaxiTitle;

  /// No description provided for @clientHomeTaxiDesc.
  ///
  /// In ar, this message translates to:
  /// **'رحلة في ثوانٍ معدودة'**
  String get clientHomeTaxiDesc;

  /// No description provided for @clientHomeFoodTitle.
  ///
  /// In ar, this message translates to:
  /// **'طعام'**
  String get clientHomeFoodTitle;

  /// No description provided for @clientHomeFoodDesc.
  ///
  /// In ar, this message translates to:
  /// **'أطباقك المفضلة تصلك بسرعة'**
  String get clientHomeFoodDesc;

  /// No description provided for @clientHomeDeliveryTitle.
  ///
  /// In ar, this message translates to:
  /// **'توصيل'**
  String get clientHomeDeliveryTitle;

  /// No description provided for @clientHomeDeliveryDesc.
  ///
  /// In ar, this message translates to:
  /// **'أرسل طردك بسرعة وأمان'**
  String get clientHomeDeliveryDesc;

  /// No description provided for @clientVoiceOrderLabel.
  ///
  /// In ar, this message translates to:
  /// **'اطلب بصوتك'**
  String get clientVoiceOrderLabel;

  /// No description provided for @clientPromoTaxiTitle.
  ///
  /// In ar, this message translates to:
  /// **'خصم 20% على أول رحلة تكسي'**
  String get clientPromoTaxiTitle;

  /// No description provided for @clientPromoTaxiSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استخدم الكود AFRIGO20 اليوم'**
  String get clientPromoTaxiSubtitle;

  /// No description provided for @clientPromoFoodTitle.
  ///
  /// In ar, this message translates to:
  /// **'توصيل مجاني لأول طلب طعام'**
  String get clientPromoFoodTitle;

  /// No description provided for @clientPromoFoodSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'اطلب الآن من مطاعمك المفضلة'**
  String get clientPromoFoodSubtitle;

  /// No description provided for @clientPromoParcelTitle.
  ///
  /// In ar, this message translates to:
  /// **'أرسل طرودك بأمان وسرعة'**
  String get clientPromoParcelTitle;

  /// No description provided for @clientPromoParcelSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تغطية كاملة لنواكشوط وضواحيها'**
  String get clientPromoParcelSubtitle;

  /// No description provided for @clientRideOriginTitle.
  ///
  /// In ar, this message translates to:
  /// **'حدّد نقطة الانطلاق'**
  String get clientRideOriginTitle;

  /// No description provided for @clientRideLocatingAddress.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحديد الموقع...'**
  String get clientRideLocatingAddress;

  /// No description provided for @clientRideOriginDragHint.
  ///
  /// In ar, this message translates to:
  /// **'اسحب الخريطة لتعديل نقطة الانطلاق بدقة'**
  String get clientRideOriginDragHint;

  /// No description provided for @clientRideOriginConfirmBtn.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد نقطة الانطلاق'**
  String get clientRideOriginConfirmBtn;

  /// No description provided for @clientRideAddressNotFound.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر العثور على هذا العنوان، جرّب صياغة أخرى'**
  String get clientRideAddressNotFound;

  /// No description provided for @clientRideDestTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلى أين تريد الذهاب؟'**
  String get clientRideDestTitle;

  /// No description provided for @clientRideDestSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن وجهة...'**
  String get clientRideDestSearchHint;

  /// No description provided for @clientRideSavedPlaces.
  ///
  /// In ar, this message translates to:
  /// **'أماكن محفوظة'**
  String get clientRideSavedPlaces;

  /// No description provided for @clientRideHomeLabel.
  ///
  /// In ar, this message translates to:
  /// **'المنزل'**
  String get clientRideHomeLabel;

  /// No description provided for @clientRideHomeAddress.
  ///
  /// In ar, this message translates to:
  /// **'تفرغ زينة، نواكشوط'**
  String get clientRideHomeAddress;

  /// No description provided for @clientRideHomeDropoffLabel.
  ///
  /// In ar, this message translates to:
  /// **'المنزل — تفرغ زينة'**
  String get clientRideHomeDropoffLabel;

  /// No description provided for @clientRideWorkLabel.
  ///
  /// In ar, this message translates to:
  /// **'العمل'**
  String get clientRideWorkLabel;

  /// No description provided for @clientRideWorkAddress.
  ///
  /// In ar, this message translates to:
  /// **'لكصر، نواكشوط'**
  String get clientRideWorkAddress;

  /// No description provided for @clientRideWorkDropoffLabel.
  ///
  /// In ar, this message translates to:
  /// **'العمل — لكصر'**
  String get clientRideWorkDropoffLabel;

  /// No description provided for @clientRideRecentPlaces.
  ///
  /// In ar, this message translates to:
  /// **'آخر الوجهات'**
  String get clientRideRecentPlaces;

  /// No description provided for @clientRideAirportName.
  ///
  /// In ar, this message translates to:
  /// **'مطار نواكشوط أم التونسي الدولي'**
  String get clientRideAirportName;

  /// No description provided for @clientRideAirportCity.
  ///
  /// In ar, this message translates to:
  /// **'نواكشوط'**
  String get clientRideAirportCity;

  /// No description provided for @clientRideConfirmDestFallback.
  ///
  /// In ar, this message translates to:
  /// **'وجهتك المحددة'**
  String get clientRideConfirmDestFallback;

  /// No description provided for @clientRideCalculatingLabel.
  ///
  /// In ar, this message translates to:
  /// **'...جارٍ الحساب'**
  String get clientRideCalculatingLabel;

  /// No description provided for @clientRideDistanceDurationLabel.
  ///
  /// In ar, this message translates to:
  /// **'{km} كم · {min} دقيقة تقريبًا'**
  String clientRideDistanceDurationLabel(String km, String min);

  /// No description provided for @clientRidePriceValue.
  ///
  /// In ar, this message translates to:
  /// **'{price} أوقية'**
  String clientRidePriceValue(String price);

  /// No description provided for @clientRideEstimatedPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'سعر تقديري'**
  String get clientRideEstimatedPriceLabel;

  /// No description provided for @clientRideVehicleTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع المركبة'**
  String get clientRideVehicleTypeLabel;

  /// No description provided for @clientRideVehicleEconomy.
  ///
  /// In ar, this message translates to:
  /// **'اقتصادي'**
  String get clientRideVehicleEconomy;

  /// No description provided for @clientRideVehicleComfort.
  ///
  /// In ar, this message translates to:
  /// **'مريح'**
  String get clientRideVehicleComfort;

  /// No description provided for @clientRideDriverNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة للسائق (اختياري)'**
  String get clientRideDriverNoteHint;

  /// No description provided for @clientRideOrderNowBtn.
  ///
  /// In ar, this message translates to:
  /// **'اطلب الآن'**
  String get clientRideOrderNowBtn;

  /// No description provided for @clientRideSearchingDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ البحث عن سائق قريب...'**
  String get clientRideSearchingDriverTitle;

  /// No description provided for @clientRideSearchingCourierTitle.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ البحث عن عامل توصيل...'**
  String get clientRideSearchingCourierTitle;

  /// No description provided for @clientRideSearchingDriverDesc.
  ///
  /// In ar, this message translates to:
  /// **'قد يستغرق الأمر بضع ثوانٍ'**
  String get clientRideSearchingDriverDesc;

  /// No description provided for @clientRideSearchingCourierDesc.
  ///
  /// In ar, this message translates to:
  /// **'سنعلمك فور القبول'**
  String get clientRideSearchingCourierDesc;

  /// No description provided for @clientRideCancelBtn.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get clientRideCancelBtn;

  /// No description provided for @clientRideDriverNoun.
  ///
  /// In ar, this message translates to:
  /// **'سائق'**
  String get clientRideDriverNoun;

  /// No description provided for @clientRideCourierNoun.
  ///
  /// In ar, this message translates to:
  /// **'عامل توصيل'**
  String get clientRideCourierNoun;

  /// No description provided for @clientRideNoProviderTitle.
  ///
  /// In ar, this message translates to:
  /// **'لم نتمكن من إيجاد {providerNoun} متاح'**
  String clientRideNoProviderTitle(String providerNoun);

  /// No description provided for @clientRideNoProviderDesc.
  ///
  /// In ar, this message translates to:
  /// **'قد تكون الكثافة مرتفعة حاليًا في منطقتك، حاول مجددًا خلال لحظات'**
  String get clientRideNoProviderDesc;

  /// No description provided for @clientRideProviderFoundBanner.
  ///
  /// In ar, this message translates to:
  /// **'تم العثور على {providerNoun}'**
  String clientRideProviderFoundBanner(String providerNoun);

  /// No description provided for @clientRideStatusDriverArriving.
  ///
  /// In ar, this message translates to:
  /// **'السائق في طريقه إليك'**
  String get clientRideStatusDriverArriving;

  /// No description provided for @clientRideStatusInProgress.
  ///
  /// In ar, this message translates to:
  /// **'رحلتك جارية الآن'**
  String get clientRideStatusInProgress;

  /// No description provided for @clientRideStatusPickedUp.
  ///
  /// In ar, this message translates to:
  /// **'استلم مندوبك طردك، في الطريق للتسليم'**
  String get clientRideStatusPickedUp;

  /// No description provided for @clientRideEnRouteToYouDesc.
  ///
  /// In ar, this message translates to:
  /// **'في الطريق إليك'**
  String get clientRideEnRouteToYouDesc;

  /// No description provided for @clientRideEnRoutePickupDesc.
  ///
  /// In ar, this message translates to:
  /// **'في الطريق لاستلام الطرد'**
  String get clientRideEnRoutePickupDesc;

  /// No description provided for @clientRideShareBtn.
  ///
  /// In ar, this message translates to:
  /// **'🔗 مشاركة'**
  String get clientRideShareBtn;

  /// No description provided for @clientRideStaleDriverWarning.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديث موقع السائق مؤخرًا — قد يكون في نفق أو منطقة ضعيفة التغطية'**
  String get clientRideStaleDriverWarning;

  /// No description provided for @clientRideStaleCourierWarning.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تحديث موقع المندوب مؤخرًا — قد يكون في منطقة ضعيفة التغطية'**
  String get clientRideStaleCourierWarning;

  /// No description provided for @clientRideCancelOrderBtn.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get clientRideCancelOrderBtn;

  /// No description provided for @clientRideArrivedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم الوصول بنجاح'**
  String get clientRideArrivedTitle;

  /// No description provided for @clientRideDistanceLabel.
  ///
  /// In ar, this message translates to:
  /// **'المسافة'**
  String get clientRideDistanceLabel;

  /// No description provided for @clientRideDurationLabel.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get clientRideDurationLabel;

  /// No description provided for @clientRideTotalPriceLabel.
  ///
  /// In ar, this message translates to:
  /// **'السعر الإجمالي'**
  String get clientRideTotalPriceLabel;

  /// No description provided for @clientRideDistanceKmValue.
  ///
  /// In ar, this message translates to:
  /// **'{km} كم'**
  String clientRideDistanceKmValue(String km);

  /// No description provided for @clientRideDurationMinValue.
  ///
  /// In ar, this message translates to:
  /// **'{min} دقيقة'**
  String clientRideDurationMinValue(String min);

  /// No description provided for @clientRideCashPaidBtn.
  ///
  /// In ar, this message translates to:
  /// **'الدفع نقدًا - تم'**
  String get clientRideCashPaidBtn;

  /// No description provided for @clientRideRateProviderTitle.
  ///
  /// In ar, this message translates to:
  /// **'قيّم {name}'**
  String clientRideRateProviderTitle(String name);

  /// No description provided for @clientRideRateSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'كيف كانت تجربتك؟'**
  String get clientRideRateSubtitle;

  /// No description provided for @clientRideTagClean.
  ///
  /// In ar, this message translates to:
  /// **'نظيف 🧼'**
  String get clientRideTagClean;

  /// No description provided for @clientRideTagPolite.
  ///
  /// In ar, this message translates to:
  /// **'مؤدب 🙏'**
  String get clientRideTagPolite;

  /// No description provided for @clientRideTagFast.
  ///
  /// In ar, this message translates to:
  /// **'سريع ⚡'**
  String get clientRideTagFast;

  /// No description provided for @clientRideCommentHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف تعليقًا (اختياري)'**
  String get clientRideCommentHint;

  /// No description provided for @clientRideSendBtn.
  ///
  /// In ar, this message translates to:
  /// **'إرسال'**
  String get clientRideSendBtn;

  /// No description provided for @clientParcelPickupTitle.
  ///
  /// In ar, this message translates to:
  /// **'نقطة الاستلام'**
  String get clientParcelPickupTitle;

  /// No description provided for @clientParcelConfirmPickupBtn.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد نقطة الاستلام'**
  String get clientParcelConfirmPickupBtn;

  /// No description provided for @clientParcelDropoffTitle.
  ///
  /// In ar, this message translates to:
  /// **'نقطة التسليم'**
  String get clientParcelDropoffTitle;

  /// No description provided for @clientParcelDropoffSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن عنوان التسليم...'**
  String get clientParcelDropoffSearchHint;

  /// No description provided for @clientParcelRecipientDetailsLabel.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المستلم'**
  String get clientParcelRecipientDetailsLabel;

  /// No description provided for @clientParcelRecipientNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستلم'**
  String get clientParcelRecipientNameHint;

  /// No description provided for @clientParcelRecipientPhoneHint.
  ///
  /// In ar, this message translates to:
  /// **'رقم هاتف المستلم'**
  String get clientParcelRecipientPhoneHint;

  /// No description provided for @clientParcelDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصف الطرد'**
  String get clientParcelDetailsTitle;

  /// No description provided for @clientParcelTypeLabel.
  ///
  /// In ar, this message translates to:
  /// **'نوع الطرد'**
  String get clientParcelTypeLabel;

  /// No description provided for @clientParcelTypeDocuments.
  ///
  /// In ar, this message translates to:
  /// **'وثائق'**
  String get clientParcelTypeDocuments;

  /// No description provided for @clientParcelTypeFood.
  ///
  /// In ar, this message translates to:
  /// **'طعام'**
  String get clientParcelTypeFood;

  /// No description provided for @clientParcelTypeOther.
  ///
  /// In ar, this message translates to:
  /// **'أخرى'**
  String get clientParcelTypeOther;

  /// No description provided for @clientParcelSizeLabel.
  ///
  /// In ar, this message translates to:
  /// **'الحجم التقريبي'**
  String get clientParcelSizeLabel;

  /// No description provided for @clientParcelSizeSmall.
  ///
  /// In ar, this message translates to:
  /// **'صغير'**
  String get clientParcelSizeSmall;

  /// No description provided for @clientParcelSizeMedium.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get clientParcelSizeMedium;

  /// No description provided for @clientParcelSizeLarge.
  ///
  /// In ar, this message translates to:
  /// **'كبير'**
  String get clientParcelSizeLarge;

  /// No description provided for @clientParcelNotesHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات إضافية'**
  String get clientParcelNotesHint;

  /// No description provided for @clientParcelPhotoAttached.
  ///
  /// In ar, this message translates to:
  /// **'تم إرفاق صورة الطرد'**
  String get clientParcelPhotoAttached;

  /// No description provided for @clientParcelPhotoAddHint.
  ///
  /// In ar, this message translates to:
  /// **'أضف صورة للطرد (اختياري)'**
  String get clientParcelPhotoAddHint;

  /// No description provided for @clientParcelTypeTitle.
  ///
  /// In ar, this message translates to:
  /// **'طرد {parcelType}'**
  String clientParcelTypeTitle(String parcelType);

  /// No description provided for @clientFoodFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get clientFoodFilterAll;

  /// No description provided for @clientFoodFilterTopRated.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى تقييمًا'**
  String get clientFoodFilterTopRated;

  /// No description provided for @clientFoodFilterNearest.
  ///
  /// In ar, this message translates to:
  /// **'الأقرب'**
  String get clientFoodFilterNearest;

  /// No description provided for @clientFoodFilterPriceLow.
  ///
  /// In ar, this message translates to:
  /// **'الأقل سعرًا'**
  String get clientFoodFilterPriceLow;

  /// No description provided for @clientFoodFilterPriceHigh.
  ///
  /// In ar, this message translates to:
  /// **'الأعلى سعرًا'**
  String get clientFoodFilterPriceHigh;

  /// No description provided for @clientFoodFilterOpenNow.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح الآن'**
  String get clientFoodFilterOpenNow;

  /// No description provided for @clientFoodFilterClosedNow.
  ///
  /// In ar, this message translates to:
  /// **'مغلق حاليًا'**
  String get clientFoodFilterClosedNow;

  /// No description provided for @clientFoodListTitle.
  ///
  /// In ar, this message translates to:
  /// **'المطاعم القريبة'**
  String get clientFoodListTitle;

  /// No description provided for @clientFoodSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مطعم أو نوع مطبخ...'**
  String get clientFoodSearchHint;

  /// No description provided for @clientFoodEmptyNoRestaurants.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد مطاعم متاحة الآن'**
  String get clientFoodEmptyNoRestaurants;

  /// No description provided for @clientFoodEmptyNoMatches.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج مطابقة'**
  String get clientFoodEmptyNoMatches;

  /// No description provided for @clientFoodEmptyTryLater.
  ///
  /// In ar, this message translates to:
  /// **'جرّب العودة لاحقًا'**
  String get clientFoodEmptyTryLater;

  /// No description provided for @clientFoodEmptyTryDifferentSearch.
  ///
  /// In ar, this message translates to:
  /// **'جرّب كلمة بحث أو فلترة مختلفة'**
  String get clientFoodEmptyTryDifferentSearch;

  /// No description provided for @clientFoodOpenBadge.
  ///
  /// In ar, this message translates to:
  /// **'مفتوح'**
  String get clientFoodOpenBadge;

  /// No description provided for @clientFoodClosedBadge.
  ///
  /// In ar, this message translates to:
  /// **'مغلق'**
  String get clientFoodClosedBadge;

  /// No description provided for @clientFoodRestaurantSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'{cuisine} · الحد الأدنى {minOrder} أوقية · توصيل {deliveryFee} أوقية'**
  String clientFoodRestaurantSubtitle(
    String cuisine,
    num minOrder,
    num deliveryFee,
  );

  /// No description provided for @clientFoodDistanceSuffix.
  ///
  /// In ar, this message translates to:
  /// **'{subtitle} · {distance} كم'**
  String clientFoodDistanceSuffix(String subtitle, String distance);

  /// No description provided for @clientFoodAmountMru.
  ///
  /// In ar, this message translates to:
  /// **'{amount} أوقية'**
  String clientFoodAmountMru(num amount);

  /// No description provided for @clientFoodRestaurantClosedMessage.
  ///
  /// In ar, this message translates to:
  /// **'المطعم مغلق حاليًا ولا يستقبل طلبات جديدة'**
  String get clientFoodRestaurantClosedMessage;

  /// No description provided for @clientFoodNoDishesAvailable.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد أطباق متاحة حاليًا'**
  String get clientFoodNoDishesAvailable;

  /// No description provided for @clientFoodViewCartButton.
  ///
  /// In ar, this message translates to:
  /// **'عرض السلة ({count})'**
  String clientFoodViewCartButton(int count);

  /// No description provided for @clientFoodQuantityLabel.
  ///
  /// In ar, this message translates to:
  /// **'الكمية'**
  String get clientFoodQuantityLabel;

  /// No description provided for @clientFoodStockRemaining.
  ///
  /// In ar, this message translates to:
  /// **'الكمية المتاحة: {stock} فقط'**
  String clientFoodStockRemaining(int stock);

  /// No description provided for @clientFoodAddToCartButton.
  ///
  /// In ar, this message translates to:
  /// **'أضف إلى السلة · {total} أوقية'**
  String clientFoodAddToCartButton(num total);

  /// No description provided for @clientFoodCartTitle.
  ///
  /// In ar, this message translates to:
  /// **'سلتك'**
  String get clientFoodCartTitle;

  /// No description provided for @clientFoodOrderNoteHint.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة للمطعم (اختياري)'**
  String get clientFoodOrderNoteHint;

  /// No description provided for @clientFoodSubtotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'المجموع الفرعي'**
  String get clientFoodSubtotalLabel;

  /// No description provided for @clientFoodDeliveryFeeLabel.
  ///
  /// In ar, this message translates to:
  /// **'رسوم التوصيل'**
  String get clientFoodDeliveryFeeLabel;

  /// No description provided for @clientFoodTotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي'**
  String get clientFoodTotalLabel;

  /// No description provided for @clientFoodCartMinOrderWarning.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للطلب من هذا المطعم {minOrder} أوقية'**
  String clientFoodCartMinOrderWarning(String minOrder);

  /// No description provided for @clientFoodContinueOrderButton.
  ///
  /// In ar, this message translates to:
  /// **'متابعة الطلب'**
  String get clientFoodContinueOrderButton;

  /// No description provided for @clientFoodCheckoutTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الطلب'**
  String get clientFoodCheckoutTitle;

  /// No description provided for @clientFoodReceiveMethodLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الاستلام'**
  String get clientFoodReceiveMethodLabel;

  /// No description provided for @clientFoodDeliveryOption.
  ///
  /// In ar, this message translates to:
  /// **'توصيل'**
  String get clientFoodDeliveryOption;

  /// No description provided for @clientFoodPickupOption.
  ///
  /// In ar, this message translates to:
  /// **'استلام من المطعم'**
  String get clientFoodPickupOption;

  /// No description provided for @clientFoodDeliveryAddressLabel.
  ///
  /// In ar, this message translates to:
  /// **'عنوان التسليم'**
  String get clientFoodDeliveryAddressLabel;

  /// No description provided for @clientFoodChooseDeliveryAddress.
  ///
  /// In ar, this message translates to:
  /// **'اختر عنوان التوصيل'**
  String get clientFoodChooseDeliveryAddress;

  /// No description provided for @clientFoodEditLabel.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get clientFoodEditLabel;

  /// No description provided for @clientFoodPaymentMethodLabel.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الدفع'**
  String get clientFoodPaymentMethodLabel;

  /// No description provided for @clientFoodFinalTotalLabel.
  ///
  /// In ar, this message translates to:
  /// **'الإجمالي النهائي'**
  String get clientFoodFinalTotalLabel;

  /// No description provided for @clientFoodCheckoutMinOrderWarning.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للطلب في هذا المطعم {minOrder} أوقية'**
  String clientFoodCheckoutMinOrderWarning(String minOrder);

  /// No description provided for @clientFoodSubmitOrderButton.
  ///
  /// In ar, this message translates to:
  /// **'أرسل الطلب'**
  String get clientFoodSubmitOrderButton;

  /// No description provided for @clientFoodWaitingTitle.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار قبول المطعم للطلب'**
  String get clientFoodWaitingTitle;

  /// No description provided for @clientFoodWaitingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سيتم إعلامك فور رد المطعم'**
  String get clientFoodWaitingSubtitle;

  /// No description provided for @clientFoodCancelOrderButton.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الطلب'**
  String get clientFoodCancelOrderButton;

  /// No description provided for @clientFoodOrderIncompleteTitle.
  ///
  /// In ar, this message translates to:
  /// **'لم يكتمل طلبك'**
  String get clientFoodOrderIncompleteTitle;

  /// No description provided for @clientFoodOrderRejectedDefaultReason.
  ///
  /// In ar, this message translates to:
  /// **'قد يكون المطعم مشغولًا حاليًا. لن يتم خصم أي مبلغ منك'**
  String get clientFoodOrderRejectedDefaultReason;

  /// No description provided for @clientFoodChooseAnotherRestaurantButton.
  ///
  /// In ar, this message translates to:
  /// **'اختيار مطعم آخر'**
  String get clientFoodChooseAnotherRestaurantButton;

  /// No description provided for @clientFoodTrackingTitle.
  ///
  /// In ar, this message translates to:
  /// **'تتبّع الطلب'**
  String get clientFoodTrackingTitle;

  /// No description provided for @clientFoodStepAccepted.
  ///
  /// In ar, this message translates to:
  /// **'تم القبول'**
  String get clientFoodStepAccepted;

  /// No description provided for @clientFoodStepPreparing.
  ///
  /// In ar, this message translates to:
  /// **'قيد التحضير'**
  String get clientFoodStepPreparing;

  /// No description provided for @clientFoodStepReadyPickup.
  ///
  /// In ar, this message translates to:
  /// **'جاهز للاستلام'**
  String get clientFoodStepReadyPickup;

  /// No description provided for @clientFoodStepReady.
  ///
  /// In ar, this message translates to:
  /// **'جاهز'**
  String get clientFoodStepReady;

  /// No description provided for @clientFoodStepOnWay.
  ///
  /// In ar, this message translates to:
  /// **'في الطريق'**
  String get clientFoodStepOnWay;

  /// No description provided for @clientFoodStatusWaiting.
  ///
  /// In ar, this message translates to:
  /// **'بانتظار قبول المطعم'**
  String get clientFoodStatusWaiting;

  /// No description provided for @clientFoodStatusPreparing.
  ///
  /// In ar, this message translates to:
  /// **'المطعم يحضّر طلبك'**
  String get clientFoodStatusPreparing;

  /// No description provided for @clientFoodStatusReadyPickup.
  ///
  /// In ar, this message translates to:
  /// **'طلبك جاهز، تفضّل باستلامه من المطعم'**
  String get clientFoodStatusReadyPickup;

  /// No description provided for @clientFoodStatusSearchingCourier.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ البحث عن مندوب توصيل'**
  String get clientFoodStatusSearchingCourier;

  /// No description provided for @clientFoodStatusCourierOnWay.
  ///
  /// In ar, this message translates to:
  /// **'مندوب التوصيل في الطريق إليك'**
  String get clientFoodStatusCourierOnWay;

  /// No description provided for @clientFoodStatusPickedUp.
  ///
  /// In ar, this message translates to:
  /// **'تم الاستلام'**
  String get clientFoodStatusPickedUp;

  /// No description provided for @clientFoodStatusDelivered.
  ///
  /// In ar, this message translates to:
  /// **'تم التسليم'**
  String get clientFoodStatusDelivered;

  /// No description provided for @clientFoodStatusFallback.
  ///
  /// In ar, this message translates to:
  /// **'متابعة'**
  String get clientFoodStatusFallback;

  /// No description provided for @clientFoodCallButtonLabel.
  ///
  /// In ar, this message translates to:
  /// **'📞 اتصال بـ {name}'**
  String clientFoodCallButtonLabel(String name);

  /// No description provided for @clientFoodDefaultProviderName.
  ///
  /// In ar, this message translates to:
  /// **'المطعم'**
  String get clientFoodDefaultProviderName;

  /// No description provided for @clientFoodRatingTitle.
  ///
  /// In ar, this message translates to:
  /// **'قيّم تجربتك'**
  String get clientFoodRatingTitle;

  /// No description provided for @clientFoodRateRestaurantLabel.
  ///
  /// In ar, this message translates to:
  /// **'تقييم المطعم'**
  String get clientFoodRateRestaurantLabel;

  /// No description provided for @clientFoodRateDeliveryLabel.
  ///
  /// In ar, this message translates to:
  /// **'تقييم عامل التوصيل'**
  String get clientFoodRateDeliveryLabel;

  /// No description provided for @clientFoodSubmitRatingButton.
  ///
  /// In ar, this message translates to:
  /// **'إرسال التقييم'**
  String get clientFoodSubmitRatingButton;

  /// No description provided for @clientFoodDeliveryAddressTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان التوصيل'**
  String get clientFoodDeliveryAddressTitle;

  /// No description provided for @clientFoodLocatingMessage.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحديد الموقع...'**
  String get clientFoodLocatingMessage;

  /// No description provided for @clientFoodMapDragHint.
  ///
  /// In ar, this message translates to:
  /// **'اسحب الخريطة لتعديل عنوان التوصيل بدقة'**
  String get clientFoodMapDragHint;

  /// No description provided for @clientFoodConfirmDeliveryAddressButton.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد عنوان التوصيل'**
  String get clientFoodConfirmDeliveryAddressButton;

  /// No description provided for @clientVoiceAnalyzingTitle.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ تحليل طلبك...'**
  String get clientVoiceAnalyzingTitle;

  /// No description provided for @clientVoiceAnalyzingDesc.
  ///
  /// In ar, this message translates to:
  /// **'يفهم الذكاء الاصطناعي طلبك الصوتي'**
  String get clientVoiceAnalyzingDesc;

  /// No description provided for @clientVoiceConfirmSampleTranscript.
  ///
  /// In ar, this message translates to:
  /// **'اطلب لي تكسي من موقعي الحالي إلى المطار'**
  String get clientVoiceConfirmSampleTranscript;

  /// No description provided for @clientVoiceConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'هل فهمنا طلبك بشكل صحيح؟'**
  String get clientVoiceConfirmTitle;

  /// No description provided for @clientVoiceConfirmYes.
  ///
  /// In ar, this message translates to:
  /// **'نعم صحيح، تابع'**
  String get clientVoiceConfirmYes;

  /// No description provided for @clientVoiceConfirmAirportName.
  ///
  /// In ar, this message translates to:
  /// **'مطار نواكشوط أم التونسي الدولي'**
  String get clientVoiceConfirmAirportName;

  /// No description provided for @clientVoiceConfirmManualEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل يدوي'**
  String get clientVoiceConfirmManualEdit;

  /// No description provided for @clientVoiceConfirmReRecord.
  ///
  /// In ar, this message translates to:
  /// **'أعد التسجيل'**
  String get clientVoiceConfirmReRecord;

  /// No description provided for @clientVoiceFailTitle.
  ///
  /// In ar, this message translates to:
  /// **'لم نفهم طلبك جيدًا'**
  String get clientVoiceFailTitle;

  /// No description provided for @clientVoiceFailDesc.
  ///
  /// In ar, this message translates to:
  /// **'حاول التحدث بوضوح أكبر أو انتقل للطلب اليدوي'**
  String get clientVoiceFailDesc;

  /// No description provided for @clientVoiceFailManualContinue.
  ///
  /// In ar, this message translates to:
  /// **'تابع يدويًا'**
  String get clientVoiceFailManualContinue;

  /// No description provided for @clientVoiceRecordListening.
  ///
  /// In ar, this message translates to:
  /// **'استمع... تحدّث الآن'**
  String get clientVoiceRecordListening;

  /// No description provided for @clientVoiceRecordTapToSpeak.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للتحدث'**
  String get clientVoiceRecordTapToSpeak;

  /// No description provided for @clientVoiceRecordTapToStop.
  ///
  /// In ar, this message translates to:
  /// **'اضغط مجددًا لإيقاف التسجيل'**
  String get clientVoiceRecordTapToStop;

  /// No description provided for @clientVoiceRecordExampleHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: \"اطلب لي تكسي إلى المطار\"'**
  String get clientVoiceRecordExampleHint;

  /// No description provided for @clientNotifMinutesAgo.
  ///
  /// In ar, this message translates to:
  /// **'قبل {minutes} دقيقة'**
  String clientNotifMinutesAgo(int minutes);

  /// No description provided for @clientNotifHoursAgo.
  ///
  /// In ar, this message translates to:
  /// **'قبل {hours} ساعة'**
  String clientNotifHoursAgo(int hours);

  /// No description provided for @clientNotifDaysAgo.
  ///
  /// In ar, this message translates to:
  /// **'قبل {days} يوم'**
  String clientNotifDaysAgo(int days);

  /// No description provided for @clientNotifTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get clientNotifTitle;

  /// No description provided for @clientNotifEmptyTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد إشعارات بعد'**
  String get clientNotifEmptyTitle;

  /// No description provided for @clientNotifEmptyMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر هنا آخر التحديثات على طلباتك'**
  String get clientNotifEmptyMessage;

  /// No description provided for @clientSupportTitle.
  ///
  /// In ar, this message translates to:
  /// **'الدعم والمساعدة'**
  String get clientSupportTitle;

  /// No description provided for @clientSupportFaqLabel.
  ///
  /// In ar, this message translates to:
  /// **'الأسئلة الشائعة'**
  String get clientSupportFaqLabel;

  /// No description provided for @clientSupportFaq1.
  ///
  /// In ar, this message translates to:
  /// **'كيف ألغي رحلة؟'**
  String get clientSupportFaq1;

  /// No description provided for @clientSupportFaq2.
  ///
  /// In ar, this message translates to:
  /// **'ماذا لو نسيت غرضًا في السيارة؟'**
  String get clientSupportFaq2;

  /// No description provided for @clientSupportFaq3.
  ///
  /// In ar, this message translates to:
  /// **'كيف أستعيد كلمة المرور؟'**
  String get clientSupportFaq3;

  /// No description provided for @clientSupportWhatsapp.
  ///
  /// In ar, this message translates to:
  /// **'تواصل عبر واتساب'**
  String get clientSupportWhatsapp;

  /// No description provided for @clientSupportCallUs.
  ///
  /// In ar, this message translates to:
  /// **'اتصل بنا'**
  String get clientSupportCallUs;

  /// No description provided for @clientLegalNoContent.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد محتوى بعد.'**
  String get clientLegalNoContent;

  /// No description provided for @clientSettingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get clientSettingsTitle;

  /// No description provided for @clientSettingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get clientSettingsLanguage;

  /// No description provided for @clientSettingsNotifications.
  ///
  /// In ar, this message translates to:
  /// **'الإشعارات'**
  String get clientSettingsNotifications;

  /// No description provided for @clientSettingsSavedAddresses.
  ///
  /// In ar, this message translates to:
  /// **'العناوين المحفوظة'**
  String get clientSettingsSavedAddresses;

  /// No description provided for @clientSettingsAddressHome.
  ///
  /// In ar, this message translates to:
  /// **'المنزل'**
  String get clientSettingsAddressHome;

  /// No description provided for @clientSettingsAddressWork.
  ///
  /// In ar, this message translates to:
  /// **'العمل'**
  String get clientSettingsAddressWork;

  /// No description provided for @clientSettingsAddressOther.
  ///
  /// In ar, this message translates to:
  /// **'عنوان'**
  String get clientSettingsAddressOther;

  /// No description provided for @clientSettingsNewAddressTitle.
  ///
  /// In ar, this message translates to:
  /// **'عنوان جديد'**
  String get clientSettingsNewAddressTitle;

  /// No description provided for @clientSettingsNewAddressHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: تفرغ زينة، نواكشوط'**
  String get clientSettingsNewAddressHint;

  /// No description provided for @clientSettingsAddConfirm.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get clientSettingsAddConfirm;

  /// No description provided for @clientSettingsAddAddress.
  ///
  /// In ar, this message translates to:
  /// **'+ إضافة عنوان جديد'**
  String get clientSettingsAddAddress;

  /// No description provided for @clientSettingsAbout.
  ///
  /// In ar, this message translates to:
  /// **'عن التطبيق'**
  String get clientSettingsAbout;

  /// No description provided for @clientSettingsTerms.
  ///
  /// In ar, this message translates to:
  /// **'الشروط والأحكام'**
  String get clientSettingsTerms;

  /// No description provided for @clientSettingsPrivacy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get clientSettingsPrivacy;

  /// No description provided for @clientSettingsLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get clientSettingsLogout;

  /// No description provided for @clientSettingsDeleteAccountTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get clientSettingsDeleteAccountTitle;

  /// No description provided for @clientSettingsDeleteAccountMessage.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف حسابك وكل بياناتك نهائيًا. لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟'**
  String get clientSettingsDeleteAccountMessage;

  /// No description provided for @clientSettingsDeleteAccountConfirm.
  ///
  /// In ar, this message translates to:
  /// **'حذف نهائيًا'**
  String get clientSettingsDeleteAccountConfirm;

  /// No description provided for @clientSettingsDeleteFailedTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر الحذف'**
  String get clientSettingsDeleteFailedTitle;

  /// No description provided for @clientSettingsDeleteAccountLink.
  ///
  /// In ar, this message translates to:
  /// **'حذف الحساب'**
  String get clientSettingsDeleteAccountLink;

  /// No description provided for @clientOrdersStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتملة'**
  String get clientOrdersStatusCompleted;

  /// No description provided for @clientOrdersStatusCancelled.
  ///
  /// In ar, this message translates to:
  /// **'ملغاة'**
  String get clientOrdersStatusCancelled;

  /// No description provided for @clientOrdersStatusRejected.
  ///
  /// In ar, this message translates to:
  /// **'مرفوضة'**
  String get clientOrdersStatusRejected;

  /// No description provided for @clientOrdersStatusNoDriver.
  ///
  /// In ar, this message translates to:
  /// **'لم يُعثر على سائق'**
  String get clientOrdersStatusNoDriver;

  /// No description provided for @clientOrdersStatusNoLivreur.
  ///
  /// In ar, this message translates to:
  /// **'لم يُعثر على مندوب'**
  String get clientOrdersStatusNoLivreur;

  /// No description provided for @clientOrdersStatusOngoing.
  ///
  /// In ar, this message translates to:
  /// **'جارية'**
  String get clientOrdersStatusOngoing;

  /// No description provided for @clientOrdersTypeRide.
  ///
  /// In ar, this message translates to:
  /// **'رحلة تكسي'**
  String get clientOrdersTypeRide;

  /// No description provided for @clientOrdersTypeDelivery.
  ///
  /// In ar, this message translates to:
  /// **'توصيل طرد'**
  String get clientOrdersTypeDelivery;

  /// No description provided for @clientOrdersTypeFoodFrom.
  ///
  /// In ar, this message translates to:
  /// **'طلب من {name}'**
  String clientOrdersTypeFoodFrom(String name);

  /// No description provided for @clientOrdersTypeFoodGeneric.
  ///
  /// In ar, this message translates to:
  /// **'طلب طعام'**
  String get clientOrdersTypeFoodGeneric;

  /// No description provided for @clientOrdersCurrencySuffix.
  ///
  /// In ar, this message translates to:
  /// **'أوقية'**
  String get clientOrdersCurrencySuffix;

  /// No description provided for @clientOrdersTabActive.
  ///
  /// In ar, this message translates to:
  /// **'نشطة'**
  String get clientOrdersTabActive;

  /// No description provided for @clientOrdersTabPast.
  ///
  /// In ar, this message translates to:
  /// **'سابقة'**
  String get clientOrdersTabPast;

  /// No description provided for @clientOrdersTitle.
  ///
  /// In ar, this message translates to:
  /// **'طلباتي'**
  String get clientOrdersTitle;

  /// No description provided for @clientOrdersEmptyActiveTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات نشطة حاليًا'**
  String get clientOrdersEmptyActiveTitle;

  /// No description provided for @clientOrdersEmptyPastTitle.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد طلبات سابقة'**
  String get clientOrdersEmptyPastTitle;

  /// No description provided for @clientOrdersEmptyActiveMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر طلباتك الجارية هنا'**
  String get clientOrdersEmptyActiveMessage;

  /// No description provided for @clientOrdersEmptyPastMessage.
  ///
  /// In ar, this message translates to:
  /// **'ستظهر طلباتك المكتملة هنا'**
  String get clientOrdersEmptyPastMessage;

  /// No description provided for @clientOrdersReorder.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الطلب ›'**
  String get clientOrdersReorder;

  /// No description provided for @clientProfileTakePhoto.
  ///
  /// In ar, this message translates to:
  /// **'التقاط صورة'**
  String get clientProfileTakePhoto;

  /// No description provided for @clientProfilePickFromGallery.
  ///
  /// In ar, this message translates to:
  /// **'اختيار من المعرض'**
  String get clientProfilePickFromGallery;

  /// No description provided for @clientProfileDefaultName.
  ///
  /// In ar, this message translates to:
  /// **'مستخدم Afrigo'**
  String get clientProfileDefaultName;

  /// No description provided for @clientProfileEditPersonalInfo.
  ///
  /// In ar, this message translates to:
  /// **'تعديل البيانات الشخصية'**
  String get clientProfileEditPersonalInfo;

  /// No description provided for @clientProfileFullNameHint.
  ///
  /// In ar, this message translates to:
  /// **'اسمك الكامل'**
  String get clientProfileFullNameHint;

  /// No description provided for @clientProfileChangePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get clientProfileChangePassword;

  /// No description provided for @clientProfileNewPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get clientProfileNewPasswordTitle;

  /// No description provided for @clientProfileChangeConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get clientProfileChangeConfirm;

  /// No description provided for @clientProfileChangeSuccessTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get clientProfileChangeSuccessTitle;

  /// No description provided for @clientProfileChangeFailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر'**
  String get clientProfileChangeFailTitle;

  /// No description provided for @clientProfileChangeSuccessMsg.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح'**
  String get clientProfileChangeSuccessMsg;

  /// No description provided for @clientProfileChangeFailMsg.
  ///
  /// In ar, this message translates to:
  /// **'تعذّر تغيير كلمة المرور، حاول مجددًا'**
  String get clientProfileChangeFailMsg;

  /// No description provided for @clientProfileSettingsMenu.
  ///
  /// In ar, this message translates to:
  /// **'⚙️ الإعدادات'**
  String get clientProfileSettingsMenu;

  /// No description provided for @clientProfileSupportMenu.
  ///
  /// In ar, this message translates to:
  /// **'🆘 الدعم والمساعدة'**
  String get clientProfileSupportMenu;
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
