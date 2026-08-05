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
}
