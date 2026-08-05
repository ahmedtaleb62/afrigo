// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AfrigoLocalizationsFr extends AfrigoLocalizations {
  AfrigoLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get commonConfirm => 'Confirmer';

  @override
  String get commonLoading => 'Chargement...';

  @override
  String get commonChangesSaved => 'Modifications enregistrées';

  @override
  String get commonErrorGeneric =>
      'Une erreur est survenue, veuillez réessayer';

  @override
  String get emptyStateTitle => 'Aucun résultat pour l\'instant';

  @override
  String get emptyStateMessage =>
      'Nous n\'avons trouvé aucun élément correspondant';

  @override
  String get confirmCancelOrderTitle => 'Confirmer l\'annulation';

  @override
  String get confirmCancelOrderMessage =>
      'Voulez-vous vraiment annuler cette course ? Des frais d\'annulation peuvent s\'appliquer.';

  @override
  String get confirmCancelOrderConfirm => 'Oui, annuler';

  @override
  String get statusOnline => 'En ligne';

  @override
  String get statusOffline => 'Hors ligne';

  @override
  String get badgePending => 'En cours de vérification';

  @override
  String get badgeVerified => 'Vérifié';

  @override
  String get badgeRejected => 'Rejeté';

  @override
  String get badgeLowBalance => 'Solde faible';

  @override
  String get badgeStopped => 'Arrêté';

  @override
  String get navHome => 'Accueil';

  @override
  String get navOrders => 'Commandes';

  @override
  String get navWallet => 'Portefeuille';

  @override
  String get navAccount => 'Compte';
}
