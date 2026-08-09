// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AfrigoLocalizationsAr extends AfrigoLocalizations {
  AfrigoLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonCancel => 'تراجع';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonLoading => 'جارٍ التحميل...';

  @override
  String get commonChangesSaved => 'تم حفظ التغييرات بنجاح';

  @override
  String get commonErrorGeneric => 'حدث خطأ ما، حاول مرة أخرى';

  @override
  String get emptyStateTitle => 'لا توجد نتائج بعد';

  @override
  String get emptyStateMessage => 'لم نجد أي عنصر مطابق حاليًا';

  @override
  String get confirmCancelOrderTitle => 'تأكيد إلغاء الرحلة';

  @override
  String get confirmCancelOrderMessage =>
      'هل أنت متأكد أنك تريد إلغاء هذه الرحلة؟ قد تُطبّق رسوم إلغاء.';

  @override
  String get confirmCancelOrderConfirm => 'نعم، إلغاء';

  @override
  String get statusOnline => 'متصل';

  @override
  String get statusOffline => 'غير متصل';

  @override
  String get badgePending => 'قيد المراجعة';

  @override
  String get badgeVerified => 'موثّق';

  @override
  String get badgeRejected => 'مرفوض';

  @override
  String get badgeLowBalance => 'رصيد منخفض';

  @override
  String get badgeStopped => 'متوقف';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navWallet => 'المحفظة';

  @override
  String get navAccount => 'الحساب';

  @override
  String get commonContinue => 'متابعة';

  @override
  String get commonSkip => 'تخطي';

  @override
  String get commonNext => 'التالي';

  @override
  String get commonStartNow => 'ابدأ الآن';

  @override
  String get commonPhoneLabel => 'رقم الهاتف';

  @override
  String get commonPasswordLabel => 'كلمة المرور';

  @override
  String get commonLogin => 'دخول';

  @override
  String get commonCreateAccount => 'إنشاء حساب';

  @override
  String get commonOtpTitle => 'تأكيد الرمز';

  @override
  String get commonOtpDesc =>
      'أدخل الرمز المكوّن من 6 أرقام المرسل إلى رقم هاتفك';

  @override
  String commonResendIn(int seconds) {
    return 'إعادة الإرسال خلال $seconds ثانية';
  }

  @override
  String get commonResend => 'إعادة الإرسال';

  @override
  String get commonVerify => 'تحقق';

  @override
  String get commonNotNow => 'ليس الآن';

  @override
  String get commonGreetingFallback => 'مرحبًا';

  @override
  String get clientLoginTitle => 'تسجيل الدخول';

  @override
  String get clientLoginSubtitle => 'أدخل بياناتك للاستمرار في afrigo';

  @override
  String get clientForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get clientNoAccountPrompt => 'ليس لديك حساب؟ ';

  @override
  String get clientHaveAccountPrompt => 'لديك حساب؟ ';

  @override
  String get clientFullNameLabel => 'الاسم الكامل';

  @override
  String get clientFullNameHint => 'مثال: سارة بن علي';

  @override
  String get clientConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get clientOnboard1Title => 'تنقّل بثقة';

  @override
  String get clientOnboard1Desc =>
      'اطلب تكسي في ثوانٍ مع سائقين موثّقين وأسعار واضحة قبل الانطلاق';

  @override
  String get clientOnboard2Title => 'اطلب طعامك المفضّل';

  @override
  String get clientOnboard2Desc =>
      'تصفّح مئات المطاعم القريبة واطلب وجبتك بضغطة زر';

  @override
  String get clientOnboard3Title => 'أرسل واستلم طرودك';

  @override
  String get clientOnboard3Desc => 'توصيل سريع وآمن لأي طرد داخل مدينتك';

  @override
  String get clientForgotTitle => 'استعادة كلمة المرور';

  @override
  String get clientForgotStep0Desc =>
      'أدخل رقم هاتفك وسنرسل رمز استعادة عبر رسالة نصية';

  @override
  String get clientSendCode => 'إرسال الرمز';

  @override
  String get clientCodeSentDesc => 'تم إرسال رمز إلى هاتفك';

  @override
  String get clientEnterCodeHint => 'أدخل الرمز';

  @override
  String get clientNewPasswordLabel => 'كلمة مرور جديدة';

  @override
  String get clientSaveAndLogin => 'حفظ وتسجيل الدخول';

  @override
  String get clientLocationPermTitle => 'تفعيل الموقع الجغرافي';

  @override
  String get clientLocationPermDesc =>
      'نحتاج موقعك لعرض الخدمات القريبة منك وتحديد نقطة انطلاقك بدقة';

  @override
  String get clientLocationPermAllow => 'السماح بالوصول للموقع';

  @override
  String get clientNotifPermTitle => 'تفعيل الإشعارات';

  @override
  String get clientNotifPermDesc =>
      'ابقَ على اطلاع بحالة طلباتك، عروض خاصة، وتحديثات مهمة';

  @override
  String get clientNotifPermAllow => 'تفعيل الإشعارات';

  @override
  String get clientHomeTaxiTitle => 'تكسي';

  @override
  String get clientHomeTaxiDesc => 'رحلة في ثوانٍ معدودة';

  @override
  String get clientHomeFoodTitle => 'طعام';

  @override
  String get clientHomeFoodDesc => 'أطباقك المفضلة تصلك بسرعة';

  @override
  String get clientHomeDeliveryTitle => 'توصيل';

  @override
  String get clientHomeDeliveryDesc => 'أرسل طردك بسرعة وأمان';

  @override
  String get clientVoiceOrderLabel => 'اطلب بصوتك';

  @override
  String get clientPromoTaxiTitle => 'خصم 20% على أول رحلة تكسي';

  @override
  String get clientPromoTaxiSubtitle => 'استخدم الكود AFRIGO20 اليوم';

  @override
  String get clientPromoFoodTitle => 'توصيل مجاني لأول طلب طعام';

  @override
  String get clientPromoFoodSubtitle => 'اطلب الآن من مطاعمك المفضلة';

  @override
  String get clientPromoParcelTitle => 'أرسل طرودك بأمان وسرعة';

  @override
  String get clientPromoParcelSubtitle => 'تغطية كاملة لنواكشوط وضواحيها';

  @override
  String get clientRideOriginTitle => 'حدّد نقطة الانطلاق';

  @override
  String get clientRideLocatingAddress => 'جارٍ تحديد الموقع...';

  @override
  String get clientRideOriginDragHint =>
      'اسحب الخريطة لتعديل نقطة الانطلاق بدقة';

  @override
  String get clientRideOriginConfirmBtn => 'تأكيد نقطة الانطلاق';

  @override
  String get clientRideAddressNotFound =>
      'تعذّر العثور على هذا العنوان، جرّب صياغة أخرى';

  @override
  String get clientRideDestTitle => 'إلى أين تريد الذهاب؟';

  @override
  String get clientRideDestSearchHint => 'ابحث عن وجهة...';

  @override
  String get clientRideSavedPlaces => 'أماكن محفوظة';

  @override
  String get clientRideHomeLabel => 'المنزل';

  @override
  String get clientRideHomeAddress => 'تفرغ زينة، نواكشوط';

  @override
  String get clientRideHomeDropoffLabel => 'المنزل — تفرغ زينة';

  @override
  String get clientRideWorkLabel => 'العمل';

  @override
  String get clientRideWorkAddress => 'لكصر، نواكشوط';

  @override
  String get clientRideWorkDropoffLabel => 'العمل — لكصر';

  @override
  String get clientRideRecentPlaces => 'آخر الوجهات';

  @override
  String get clientRideAirportName => 'مطار نواكشوط أم التونسي الدولي';

  @override
  String get clientRideAirportCity => 'نواكشوط';

  @override
  String get clientRideConfirmDestFallback => 'وجهتك المحددة';

  @override
  String get clientRideCalculatingLabel => '...جارٍ الحساب';

  @override
  String clientRideDistanceDurationLabel(String km, String min) {
    return '$km كم · $min دقيقة تقريبًا';
  }

  @override
  String clientRidePriceValue(String price) {
    return '$price أوقية';
  }

  @override
  String get clientRideEstimatedPriceLabel => 'سعر تقديري';

  @override
  String get clientRideVehicleTypeLabel => 'نوع المركبة';

  @override
  String get clientRideVehicleEconomy => 'اقتصادي';

  @override
  String get clientRideVehicleComfort => 'مريح';

  @override
  String get clientRideDriverNoteHint => 'ملاحظة للسائق (اختياري)';

  @override
  String get clientRideOrderNowBtn => 'اطلب الآن';

  @override
  String get clientRideSearchingDriverTitle => 'جارٍ البحث عن سائق قريب...';

  @override
  String get clientRideSearchingCourierTitle => 'جارٍ البحث عن عامل توصيل...';

  @override
  String get clientRideSearchingDriverDesc => 'قد يستغرق الأمر بضع ثوانٍ';

  @override
  String get clientRideSearchingCourierDesc => 'سنعلمك فور القبول';

  @override
  String get clientRideCancelBtn => 'إلغاء';

  @override
  String get clientRideDriverNoun => 'سائق';

  @override
  String get clientRideCourierNoun => 'عامل توصيل';

  @override
  String clientRideNoProviderTitle(String providerNoun) {
    return 'لم نتمكن من إيجاد $providerNoun متاح';
  }

  @override
  String get clientRideNoProviderDesc =>
      'قد تكون الكثافة مرتفعة حاليًا في منطقتك، حاول مجددًا خلال لحظات';

  @override
  String clientRideProviderFoundBanner(String providerNoun) {
    return 'تم العثور على $providerNoun';
  }

  @override
  String get clientRideStatusDriverArriving => 'السائق في طريقه إليك';

  @override
  String get clientRideStatusInProgress => 'رحلتك جارية الآن';

  @override
  String get clientRideStatusPickedUp => 'استلم مندوبك طردك، في الطريق للتسليم';

  @override
  String get clientRideEnRouteToYouDesc => 'في الطريق إليك';

  @override
  String get clientRideEnRoutePickupDesc => 'في الطريق لاستلام الطرد';

  @override
  String get clientRideShareBtn => '🔗 مشاركة';

  @override
  String get clientRideStaleDriverWarning =>
      'تعذّر تحديث موقع السائق مؤخرًا — قد يكون في نفق أو منطقة ضعيفة التغطية';

  @override
  String get clientRideStaleCourierWarning =>
      'تعذّر تحديث موقع المندوب مؤخرًا — قد يكون في منطقة ضعيفة التغطية';

  @override
  String get clientRideCancelOrderBtn => 'إلغاء الطلب';

  @override
  String get clientRideArrivedTitle => 'تم الوصول بنجاح';

  @override
  String get clientRideDistanceLabel => 'المسافة';

  @override
  String get clientRideDurationLabel => 'المدة';

  @override
  String get clientRideTotalPriceLabel => 'السعر الإجمالي';

  @override
  String clientRideDistanceKmValue(String km) {
    return '$km كم';
  }

  @override
  String clientRideDurationMinValue(String min) {
    return '$min دقيقة';
  }

  @override
  String get clientRideCashPaidBtn => 'الدفع نقدًا - تم';

  @override
  String clientRideRateProviderTitle(String name) {
    return 'قيّم $name';
  }

  @override
  String get clientRideRateSubtitle => 'كيف كانت تجربتك؟';

  @override
  String get clientRideTagClean => 'نظيف 🧼';

  @override
  String get clientRideTagPolite => 'مؤدب 🙏';

  @override
  String get clientRideTagFast => 'سريع ⚡';

  @override
  String get clientRideCommentHint => 'أضف تعليقًا (اختياري)';

  @override
  String get clientRideSendBtn => 'إرسال';

  @override
  String get clientParcelPickupTitle => 'نقطة الاستلام';

  @override
  String get clientParcelConfirmPickupBtn => 'تأكيد نقطة الاستلام';

  @override
  String get clientParcelDropoffTitle => 'نقطة التسليم';

  @override
  String get clientParcelDropoffSearchHint => 'ابحث عن عنوان التسليم...';

  @override
  String get clientParcelRecipientDetailsLabel => 'بيانات المستلم';

  @override
  String get clientParcelRecipientNameHint => 'اسم المستلم';

  @override
  String get clientParcelRecipientPhoneHint => 'رقم هاتف المستلم';

  @override
  String get clientParcelDetailsTitle => 'وصف الطرد';

  @override
  String get clientParcelTypeLabel => 'نوع الطرد';

  @override
  String get clientParcelTypeDocuments => 'وثائق';

  @override
  String get clientParcelTypeFood => 'طعام';

  @override
  String get clientParcelTypeOther => 'أخرى';

  @override
  String get clientParcelSizeLabel => 'الحجم التقريبي';

  @override
  String get clientParcelSizeSmall => 'صغير';

  @override
  String get clientParcelSizeMedium => 'متوسط';

  @override
  String get clientParcelSizeLarge => 'كبير';

  @override
  String get clientParcelNotesHint => 'ملاحظات إضافية';

  @override
  String get clientParcelPhotoAttached => 'تم إرفاق صورة الطرد';

  @override
  String get clientParcelPhotoAddHint => 'أضف صورة للطرد (اختياري)';

  @override
  String clientParcelTypeTitle(String parcelType) {
    return 'طرد $parcelType';
  }

  @override
  String get clientFoodFilterAll => 'الكل';

  @override
  String get clientFoodFilterTopRated => 'الأعلى تقييمًا';

  @override
  String get clientFoodFilterNearest => 'الأقرب';

  @override
  String get clientFoodFilterPriceLow => 'الأقل سعرًا';

  @override
  String get clientFoodFilterPriceHigh => 'الأعلى سعرًا';

  @override
  String get clientFoodFilterOpenNow => 'مفتوح الآن';

  @override
  String get clientFoodFilterClosedNow => 'مغلق حاليًا';

  @override
  String get clientFoodListTitle => 'المطاعم القريبة';

  @override
  String get clientFoodSearchHint => 'ابحث عن مطعم أو نوع مطبخ...';

  @override
  String get clientFoodEmptyNoRestaurants => 'لا توجد مطاعم متاحة الآن';

  @override
  String get clientFoodEmptyNoMatches => 'لا توجد نتائج مطابقة';

  @override
  String get clientFoodEmptyTryLater => 'جرّب العودة لاحقًا';

  @override
  String get clientFoodEmptyTryDifferentSearch =>
      'جرّب كلمة بحث أو فلترة مختلفة';

  @override
  String get clientFoodOpenBadge => 'مفتوح';

  @override
  String get clientFoodClosedBadge => 'مغلق';

  @override
  String clientFoodRestaurantSubtitle(
    String cuisine,
    num minOrder,
    num deliveryFee,
  ) {
    return '$cuisine · الحد الأدنى $minOrder أوقية · توصيل $deliveryFee أوقية';
  }

  @override
  String clientFoodDistanceSuffix(String subtitle, String distance) {
    return '$subtitle · $distance كم';
  }

  @override
  String clientFoodAmountMru(num amount) {
    return '$amount أوقية';
  }

  @override
  String get clientFoodRestaurantClosedMessage =>
      'المطعم مغلق حاليًا ولا يستقبل طلبات جديدة';

  @override
  String get clientFoodNoDishesAvailable => 'لا توجد أطباق متاحة حاليًا';

  @override
  String clientFoodViewCartButton(int count) {
    return 'عرض السلة ($count)';
  }

  @override
  String get clientFoodQuantityLabel => 'الكمية';

  @override
  String clientFoodStockRemaining(int stock) {
    return 'الكمية المتاحة: $stock فقط';
  }

  @override
  String clientFoodAddToCartButton(num total) {
    return 'أضف إلى السلة · $total أوقية';
  }

  @override
  String get clientFoodCartTitle => 'سلتك';

  @override
  String get clientFoodOrderNoteHint => 'ملاحظة للمطعم (اختياري)';

  @override
  String get clientFoodSubtotalLabel => 'المجموع الفرعي';

  @override
  String get clientFoodDeliveryFeeLabel => 'رسوم التوصيل';

  @override
  String get clientFoodTotalLabel => 'الإجمالي';

  @override
  String clientFoodCartMinOrderWarning(String minOrder) {
    return 'الحد الأدنى للطلب من هذا المطعم $minOrder أوقية';
  }

  @override
  String get clientFoodContinueOrderButton => 'متابعة الطلب';

  @override
  String get clientFoodCheckoutTitle => 'تأكيد الطلب';

  @override
  String get clientFoodReceiveMethodLabel => 'طريقة الاستلام';

  @override
  String get clientFoodDeliveryOption => 'توصيل';

  @override
  String get clientFoodPickupOption => 'استلام من المطعم';

  @override
  String get clientFoodDeliveryAddressLabel => 'عنوان التسليم';

  @override
  String get clientFoodChooseDeliveryAddress => 'اختر عنوان التوصيل';

  @override
  String get clientFoodEditLabel => 'تعديل';

  @override
  String get clientFoodPaymentMethodLabel => 'طريقة الدفع';

  @override
  String get clientFoodFinalTotalLabel => 'الإجمالي النهائي';

  @override
  String clientFoodCheckoutMinOrderWarning(String minOrder) {
    return 'الحد الأدنى للطلب في هذا المطعم $minOrder أوقية';
  }

  @override
  String get clientFoodSubmitOrderButton => 'أرسل الطلب';

  @override
  String get clientFoodWaitingTitle => 'بانتظار قبول المطعم للطلب';

  @override
  String get clientFoodWaitingSubtitle => 'سيتم إعلامك فور رد المطعم';

  @override
  String get clientFoodCancelOrderButton => 'إلغاء الطلب';

  @override
  String get clientFoodOrderIncompleteTitle => 'لم يكتمل طلبك';

  @override
  String get clientFoodOrderRejectedDefaultReason =>
      'قد يكون المطعم مشغولًا حاليًا. لن يتم خصم أي مبلغ منك';

  @override
  String get clientFoodChooseAnotherRestaurantButton => 'اختيار مطعم آخر';

  @override
  String get clientFoodTrackingTitle => 'تتبّع الطلب';

  @override
  String get clientFoodStepAccepted => 'تم القبول';

  @override
  String get clientFoodStepPreparing => 'قيد التحضير';

  @override
  String get clientFoodStepReadyPickup => 'جاهز للاستلام';

  @override
  String get clientFoodStepReady => 'جاهز';

  @override
  String get clientFoodStepOnWay => 'في الطريق';

  @override
  String get clientFoodStatusWaiting => 'بانتظار قبول المطعم';

  @override
  String get clientFoodStatusPreparing => 'المطعم يحضّر طلبك';

  @override
  String get clientFoodStatusReadyPickup =>
      'طلبك جاهز، تفضّل باستلامه من المطعم';

  @override
  String get clientFoodStatusSearchingCourier => 'جارٍ البحث عن مندوب توصيل';

  @override
  String get clientFoodStatusCourierOnWay => 'مندوب التوصيل في الطريق إليك';

  @override
  String get clientFoodStatusPickedUp => 'تم الاستلام';

  @override
  String get clientFoodStatusDelivered => 'تم التسليم';

  @override
  String get clientFoodStatusFallback => 'متابعة';

  @override
  String clientFoodCallButtonLabel(String name) {
    return '📞 اتصال بـ $name';
  }

  @override
  String get clientFoodDefaultProviderName => 'المطعم';

  @override
  String get clientFoodRatingTitle => 'قيّم تجربتك';

  @override
  String get clientFoodRateRestaurantLabel => 'تقييم المطعم';

  @override
  String get clientFoodRateDeliveryLabel => 'تقييم عامل التوصيل';

  @override
  String get clientFoodSubmitRatingButton => 'إرسال التقييم';

  @override
  String get clientFoodDeliveryAddressTitle => 'عنوان التوصيل';

  @override
  String get clientFoodLocatingMessage => 'جارٍ تحديد الموقع...';

  @override
  String get clientFoodMapDragHint => 'اسحب الخريطة لتعديل عنوان التوصيل بدقة';

  @override
  String get clientFoodConfirmDeliveryAddressButton => 'تأكيد عنوان التوصيل';

  @override
  String get clientVoiceAnalyzingTitle => 'جارٍ تحليل طلبك...';

  @override
  String get clientVoiceAnalyzingDesc => 'يفهم الذكاء الاصطناعي طلبك الصوتي';

  @override
  String get clientVoiceConfirmSampleTranscript =>
      'اطلب لي تكسي من موقعي الحالي إلى المطار';

  @override
  String get clientVoiceConfirmTitle => 'هل فهمنا طلبك بشكل صحيح؟';

  @override
  String get clientVoiceConfirmYes => 'نعم صحيح، تابع';

  @override
  String get clientVoiceConfirmAirportName => 'مطار نواكشوط أم التونسي الدولي';

  @override
  String get clientVoiceConfirmManualEdit => 'تعديل يدوي';

  @override
  String get clientVoiceConfirmReRecord => 'أعد التسجيل';

  @override
  String get clientVoiceFailTitle => 'لم نفهم طلبك جيدًا';

  @override
  String get clientVoiceFailDesc =>
      'حاول التحدث بوضوح أكبر أو انتقل للطلب اليدوي';

  @override
  String get clientVoiceFailManualContinue => 'تابع يدويًا';

  @override
  String get clientVoiceRecordListening => 'استمع... تحدّث الآن';

  @override
  String get clientVoiceRecordTapToSpeak => 'اضغط للتحدث';

  @override
  String get clientVoiceRecordTapToStop => 'اضغط مجددًا لإيقاف التسجيل';

  @override
  String get clientVoiceRecordExampleHint =>
      'مثال: \"اطلب لي تكسي إلى المطار\"';

  @override
  String clientNotifMinutesAgo(int minutes) {
    return 'قبل $minutes دقيقة';
  }

  @override
  String clientNotifHoursAgo(int hours) {
    return 'قبل $hours ساعة';
  }

  @override
  String clientNotifDaysAgo(int days) {
    return 'قبل $days يوم';
  }

  @override
  String get clientNotifTitle => 'الإشعارات';

  @override
  String get clientNotifEmptyTitle => 'لا توجد إشعارات بعد';

  @override
  String get clientNotifEmptyMessage => 'ستظهر هنا آخر التحديثات على طلباتك';

  @override
  String get clientSupportTitle => 'الدعم والمساعدة';

  @override
  String get clientSupportFaqLabel => 'الأسئلة الشائعة';

  @override
  String get clientSupportFaq1 => 'كيف ألغي رحلة؟';

  @override
  String get clientSupportFaq2 => 'ماذا لو نسيت غرضًا في السيارة؟';

  @override
  String get clientSupportFaq3 => 'كيف أستعيد كلمة المرور؟';

  @override
  String get clientSupportWhatsapp => 'تواصل عبر واتساب';

  @override
  String get clientSupportCallUs => 'اتصل بنا';

  @override
  String get clientLegalNoContent => 'لا يوجد محتوى بعد.';

  @override
  String get clientSettingsTitle => 'الإعدادات';

  @override
  String get clientSettingsLanguage => 'اللغة';

  @override
  String get clientSettingsNotifications => 'الإشعارات';

  @override
  String get clientSettingsSavedAddresses => 'العناوين المحفوظة';

  @override
  String get clientSettingsAddressHome => 'المنزل';

  @override
  String get clientSettingsAddressWork => 'العمل';

  @override
  String get clientSettingsAddressOther => 'عنوان';

  @override
  String get clientSettingsNewAddressTitle => 'عنوان جديد';

  @override
  String get clientSettingsNewAddressHint => 'مثال: تفرغ زينة، نواكشوط';

  @override
  String get clientSettingsAddConfirm => 'إضافة';

  @override
  String get clientSettingsAddAddress => '+ إضافة عنوان جديد';

  @override
  String get clientSettingsAbout => 'عن التطبيق';

  @override
  String get clientSettingsTerms => 'الشروط والأحكام';

  @override
  String get clientSettingsPrivacy => 'سياسة الخصوصية';

  @override
  String get clientSettingsLogout => 'تسجيل الخروج';

  @override
  String get clientSettingsDeleteAccountTitle => 'حذف الحساب';

  @override
  String get clientSettingsDeleteAccountMessage =>
      'سيتم حذف حسابك وكل بياناتك نهائيًا. لا يمكن التراجع عن هذا الإجراء. هل أنت متأكد؟';

  @override
  String get clientSettingsDeleteAccountConfirm => 'حذف نهائيًا';

  @override
  String get clientSettingsDeleteFailedTitle => 'تعذّر الحذف';

  @override
  String get clientSettingsDeleteAccountLink => 'حذف الحساب';

  @override
  String get clientOrdersStatusCompleted => 'مكتملة';

  @override
  String get clientOrdersStatusCancelled => 'ملغاة';

  @override
  String get clientOrdersStatusRejected => 'مرفوضة';

  @override
  String get clientOrdersStatusNoDriver => 'لم يُعثر على سائق';

  @override
  String get clientOrdersStatusNoLivreur => 'لم يُعثر على مندوب';

  @override
  String get clientOrdersStatusOngoing => 'جارية';

  @override
  String get clientOrdersTypeRide => 'رحلة تكسي';

  @override
  String get clientOrdersTypeDelivery => 'توصيل طرد';

  @override
  String clientOrdersTypeFoodFrom(String name) {
    return 'طلب من $name';
  }

  @override
  String get clientOrdersTypeFoodGeneric => 'طلب طعام';

  @override
  String get clientOrdersCurrencySuffix => 'أوقية';

  @override
  String get clientOrdersTabActive => 'نشطة';

  @override
  String get clientOrdersTabPast => 'سابقة';

  @override
  String get clientOrdersTitle => 'طلباتي';

  @override
  String get clientOrdersEmptyActiveTitle => 'لا توجد طلبات نشطة حاليًا';

  @override
  String get clientOrdersEmptyPastTitle => 'لا توجد طلبات سابقة';

  @override
  String get clientOrdersEmptyActiveMessage => 'ستظهر طلباتك الجارية هنا';

  @override
  String get clientOrdersEmptyPastMessage => 'ستظهر طلباتك المكتملة هنا';

  @override
  String get clientOrdersReorder => 'إعادة الطلب ›';

  @override
  String get clientProfileTakePhoto => 'التقاط صورة';

  @override
  String get clientProfilePickFromGallery => 'اختيار من المعرض';

  @override
  String get clientProfileDefaultName => 'مستخدم Afrigo';

  @override
  String get clientProfileEditPersonalInfo => 'تعديل البيانات الشخصية';

  @override
  String get clientProfileFullNameHint => 'اسمك الكامل';

  @override
  String get clientProfileChangePassword => 'تغيير كلمة المرور';

  @override
  String get clientProfileNewPasswordTitle => 'كلمة المرور الجديدة';

  @override
  String get clientProfileChangeConfirm => 'تغيير';

  @override
  String get clientProfileChangeSuccessTitle => 'تم';

  @override
  String get clientProfileChangeFailTitle => 'تعذّر';

  @override
  String get clientProfileChangeSuccessMsg => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get clientProfileChangeFailMsg =>
      'تعذّر تغيير كلمة المرور، حاول مجددًا';

  @override
  String get clientProfileSettingsMenu => '⚙️ الإعدادات';

  @override
  String get clientProfileSupportMenu => '🆘 الدعم والمساعدة';
}
