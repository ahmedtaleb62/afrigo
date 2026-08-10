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

  @override
  String get commonContinue => 'Continuer';

  @override
  String get commonSkip => 'Passer';

  @override
  String get commonNext => 'Suivant';

  @override
  String get commonStartNow => 'Commencer';

  @override
  String get commonPhoneLabel => 'Numéro de téléphone';

  @override
  String get commonPasswordLabel => 'Mot de passe';

  @override
  String get commonLogin => 'Connexion';

  @override
  String get commonCreateAccount => 'Créer un compte';

  @override
  String get commonOtpTitle => 'Confirmer le code';

  @override
  String get commonOtpDesc =>
      'Entrez le code à 6 chiffres envoyé à votre téléphone';

  @override
  String commonResendIn(int seconds) {
    return 'Renvoyer dans ${seconds}s';
  }

  @override
  String get commonResend => 'Renvoyer le code';

  @override
  String get commonVerify => 'Vérifier';

  @override
  String get commonNotNow => 'Plus tard';

  @override
  String get commonGreetingFallback => 'Bonjour';

  @override
  String get commonOk => 'D\'accord';

  @override
  String get clientPaymentMethodTitle => 'Mode de paiement';

  @override
  String get clientPaymentCash => 'Espèces';

  @override
  String get clientPaymentBankili => 'Bankily';

  @override
  String get clientPaymentBankTransfer => 'Virement bancaire';

  @override
  String get clientLoginTitle => 'Connexion';

  @override
  String get clientLoginSubtitle =>
      'Entrez vos informations pour continuer sur afrigo';

  @override
  String get clientForgotPassword => 'Mot de passe oublié ?';

  @override
  String get clientNoAccountPrompt => 'Vous n\'avez pas de compte ? ';

  @override
  String get clientHaveAccountPrompt => 'Vous avez déjà un compte ? ';

  @override
  String get clientFullNameLabel => 'Nom complet';

  @override
  String get clientFullNameHint => 'Exemple : Sara Ben Ali';

  @override
  String get clientConfirmPasswordLabel => 'Confirmer le mot de passe';

  @override
  String get clientOnboard1Title => 'Déplacez-vous en toute confiance';

  @override
  String get clientOnboard1Desc =>
      'Commandez un taxi en quelques secondes avec des chauffeurs vérifiés et des prix clairs avant le départ';

  @override
  String get clientOnboard2Title => 'Commandez votre plat préféré';

  @override
  String get clientOnboard2Desc =>
      'Parcourez des centaines de restaurants à proximité et commandez en un clic';

  @override
  String get clientOnboard3Title => 'Envoyez et recevez vos colis';

  @override
  String get clientOnboard3Desc =>
      'Livraison rapide et sécurisée pour tout colis dans votre ville';

  @override
  String get clientForgotTitle => 'Récupérer le mot de passe';

  @override
  String get clientForgotStep0Desc =>
      'Entrez votre numéro de téléphone, nous vous enverrons un code par SMS';

  @override
  String get clientSendCode => 'Envoyer le code';

  @override
  String get clientCodeSentDesc => 'Un code a été envoyé à votre téléphone';

  @override
  String get clientEnterCodeHint => 'Entrez le code';

  @override
  String get clientNewPasswordLabel => 'Nouveau mot de passe';

  @override
  String get clientSaveAndLogin => 'Enregistrer et se connecter';

  @override
  String get clientLocationPermTitle => 'Activer la localisation';

  @override
  String get clientLocationPermDesc =>
      'Nous avons besoin de votre position pour afficher les services à proximité et déterminer précisément votre point de départ';

  @override
  String get clientLocationPermAllow => 'Autoriser l\'accès à la position';

  @override
  String get clientLocationPermDeniedBanner =>
      'Impossible de déterminer votre position — appuyez pour autoriser l\'accès à la localisation';

  @override
  String get clientLocationPermanentlyDeniedBanner =>
      'Impossible de déterminer votre position — appuyez pour ouvrir les paramètres et activer la localisation';

  @override
  String get clientNotifPermTitle => 'Activer les notifications';

  @override
  String get clientNotifPermDesc =>
      'Restez informé de l\'état de vos commandes, des offres spéciales et des mises à jour importantes';

  @override
  String get clientNotifPermAllow => 'Activer les notifications';

  @override
  String get clientHomeTaxiTitle => 'Taxi';

  @override
  String get clientHomeTaxiDesc => 'Une course en quelques secondes';

  @override
  String get clientHomeFoodTitle => 'Nourriture';

  @override
  String get clientHomeFoodDesc => 'Vos plats préférés livrés rapidement';

  @override
  String get clientHomeDeliveryTitle => 'Livraison';

  @override
  String get clientHomeDeliveryDesc =>
      'Envoyez votre colis rapidement et en toute sécurité';

  @override
  String get clientVoiceOrderLabel => 'Commander à la voix';

  @override
  String get clientPromoTaxiTitle =>
      '20% de réduction sur votre première course';

  @override
  String get clientPromoTaxiSubtitle =>
      'Utilisez le code AFRIGO20 aujourd\'hui';

  @override
  String get clientPromoFoodTitle =>
      'Livraison gratuite pour votre première commande';

  @override
  String get clientPromoFoodSubtitle =>
      'Commandez maintenant chez vos restaurants préférés';

  @override
  String get clientPromoParcelTitle =>
      'Envoyez vos colis en toute sécurité et rapidité';

  @override
  String get clientPromoParcelSubtitle =>
      'Couverture complète de Nouakchott et ses environs';

  @override
  String get clientRideOriginTitle => 'Définissez le point de départ';

  @override
  String get clientRideLocatingAddress => 'Localisation en cours...';

  @override
  String get clientRideOriginDragHint =>
      'Faites glisser la carte pour ajuster précisément le point de départ';

  @override
  String get clientRideOriginConfirmBtn => 'Confirmer le point de départ';

  @override
  String get clientRideAddressNotFound =>
      'Impossible de trouver cette adresse, essayez une autre formulation';

  @override
  String get clientRideDestTitle => 'Où voulez-vous aller ?';

  @override
  String get clientRideDestSearchHint => 'Rechercher une destination...';

  @override
  String get clientRideSavedPlaces => 'Lieux enregistrés';

  @override
  String get clientRideHomeLabel => 'Domicile';

  @override
  String get clientRideHomeAddress => 'Tevragh-Zeina, Nouakchott';

  @override
  String get clientRideHomeDropoffLabel => 'Domicile — Tevragh-Zeina';

  @override
  String get clientRideWorkLabel => 'Travail';

  @override
  String get clientRideWorkAddress => 'Ksar, Nouakchott';

  @override
  String get clientRideWorkDropoffLabel => 'Travail — Ksar';

  @override
  String get clientRideRecentPlaces => 'Destinations récentes';

  @override
  String get clientRideAirportName =>
      'Aéroport international Nouakchott–Oumtounsy';

  @override
  String get clientRideAirportCity => 'Nouakchott';

  @override
  String get clientRideConfirmDestFallback => 'Votre destination sélectionnée';

  @override
  String get clientRideCalculatingLabel => 'Calcul en cours...';

  @override
  String clientRideDistanceDurationLabel(String km, String min) {
    return '$km km · environ $min min';
  }

  @override
  String clientRidePriceValue(String price) {
    return '$price MRU';
  }

  @override
  String get clientRideEstimatedPriceLabel => 'Prix estimé';

  @override
  String get clientRideVehicleTypeLabel => 'Type de véhicule';

  @override
  String get clientRideVehicleEconomy => 'Économique';

  @override
  String get clientRideVehicleComfort => 'Confort';

  @override
  String get clientRideDriverNoteHint => 'Note pour le chauffeur (facultatif)';

  @override
  String get clientRideOrderNowBtn => 'Commander maintenant';

  @override
  String get clientRideSearchingDriverTitle =>
      'Recherche d\'un chauffeur à proximité...';

  @override
  String get clientRideSearchingCourierTitle => 'Recherche d\'un livreur...';

  @override
  String get clientRideSearchingDriverDesc =>
      'Cela peut prendre quelques secondes';

  @override
  String get clientRideSearchingCourierDesc =>
      'Nous vous préviendrons dès qu\'une commande est acceptée';

  @override
  String get clientRideCancelBtn => 'Annuler';

  @override
  String get clientRideDriverNoun => 'chauffeur';

  @override
  String get clientRideCourierNoun => 'livreur';

  @override
  String clientRideNoProviderTitle(String providerNoun) {
    return 'Nous n\'avons pas pu trouver de $providerNoun disponible';
  }

  @override
  String get clientRideNoProviderDesc =>
      'La demande est peut-être élevée dans votre zone actuellement, réessayez dans un instant';

  @override
  String clientRideProviderFoundBanner(String providerNoun) {
    return '$providerNoun trouvé';
  }

  @override
  String get clientRideStatusDriverArriving =>
      'Le chauffeur est en route vers vous';

  @override
  String get clientRideStatusInProgress => 'Votre course est en cours';

  @override
  String get clientRideStatusPickedUp =>
      'Votre livreur a récupéré le colis, en route pour la livraison';

  @override
  String get clientRideEnRouteToYouDesc => 'En route vers vous';

  @override
  String get clientRideEnRoutePickupDesc => 'En route pour récupérer le colis';

  @override
  String get clientRideShareBtn => '🔗 Partager';

  @override
  String get clientRideStaleDriverWarning =>
      'Impossible de mettre à jour la position du chauffeur récemment — il est peut-être dans un tunnel ou une zone mal couverte';

  @override
  String get clientRideStaleCourierWarning =>
      'Impossible de mettre à jour la position du livreur récemment — il est peut-être dans une zone mal couverte';

  @override
  String get clientRideCancelOrderBtn => 'Annuler la commande';

  @override
  String get clientRideArrivedTitle => 'Arrivée effectuée avec succès';

  @override
  String get clientRideDistanceLabel => 'Distance';

  @override
  String get clientRideDurationLabel => 'Durée';

  @override
  String get clientRideTotalPriceLabel => 'Prix total';

  @override
  String clientRideDistanceKmValue(String km) {
    return '$km km';
  }

  @override
  String clientRideDurationMinValue(String min) {
    return '$min min';
  }

  @override
  String get clientRideCashPaidBtn => 'Paiement en espèces - Effectué';

  @override
  String clientRideRateProviderTitle(String name) {
    return 'Évaluez $name';
  }

  @override
  String get clientRideRateSubtitle =>
      'Comment s\'est passée votre expérience ?';

  @override
  String get clientRideTagClean => 'Propre 🧼';

  @override
  String get clientRideTagPolite => 'Poli 🙏';

  @override
  String get clientRideTagFast => 'Rapide ⚡';

  @override
  String get clientRideCommentHint => 'Ajouter un commentaire (facultatif)';

  @override
  String get clientRideSendBtn => 'Envoyer';

  @override
  String get clientParcelPickupTitle => 'Point de collecte';

  @override
  String get clientParcelConfirmPickupBtn => 'Confirmer le point de collecte';

  @override
  String get clientParcelDropoffTitle => 'Point de livraison';

  @override
  String get clientParcelDropoffSearchHint =>
      'Rechercher une adresse de livraison...';

  @override
  String get clientParcelRecipientDetailsLabel => 'Coordonnées du destinataire';

  @override
  String get clientParcelRecipientNameHint => 'Nom du destinataire';

  @override
  String get clientParcelRecipientPhoneHint => 'Téléphone du destinataire';

  @override
  String get clientParcelDetailsTitle => 'Description du colis';

  @override
  String get clientParcelTypeLabel => 'Type de colis';

  @override
  String get clientParcelTypeDocuments => 'Documents';

  @override
  String get clientParcelTypeFood => 'Nourriture';

  @override
  String get clientParcelTypeOther => 'Autre';

  @override
  String get clientParcelSizeLabel => 'Taille approximative';

  @override
  String get clientParcelSizeSmall => 'Petit';

  @override
  String get clientParcelSizeMedium => 'Moyen';

  @override
  String get clientParcelSizeLarge => 'Grand';

  @override
  String get clientParcelNotesHint => 'Notes supplémentaires';

  @override
  String get clientParcelPhotoAttached => 'Photo du colis ajoutée';

  @override
  String get clientParcelPhotoAddHint =>
      'Ajouter une photo du colis (facultatif)';

  @override
  String clientParcelTypeTitle(String parcelType) {
    return 'Colis $parcelType';
  }

  @override
  String get clientFoodFilterAll => 'Tous';

  @override
  String get clientFoodFilterTopRated => 'Les mieux notés';

  @override
  String get clientFoodFilterNearest => 'Les plus proches';

  @override
  String get clientFoodFilterPriceLow => 'Prix croissant';

  @override
  String get clientFoodFilterPriceHigh => 'Prix décroissant';

  @override
  String get clientFoodFilterOpenNow => 'Ouvert maintenant';

  @override
  String get clientFoodFilterClosedNow => 'Fermé actuellement';

  @override
  String get clientFoodListTitle => 'Restaurants à proximité';

  @override
  String get clientFoodSearchHint =>
      'Rechercher un restaurant ou un type de cuisine...';

  @override
  String get clientFoodEmptyNoRestaurants =>
      'Aucun restaurant disponible pour le moment';

  @override
  String get clientFoodEmptyNoMatches => 'Aucun résultat correspondant';

  @override
  String get clientFoodEmptyTryLater => 'Réessayez plus tard';

  @override
  String get clientFoodEmptyTryDifferentSearch =>
      'Essayez un autre mot-clé ou filtre';

  @override
  String get clientFoodOpenBadge => 'Ouvert';

  @override
  String get clientFoodClosedBadge => 'Fermé';

  @override
  String clientFoodRestaurantSubtitle(
    String cuisine,
    num minOrder,
    num deliveryFee,
  ) {
    return '$cuisine · Minimum $minOrder MRU · Livraison $deliveryFee MRU';
  }

  @override
  String clientFoodDistanceSuffix(String subtitle, String distance) {
    return '$subtitle · $distance km';
  }

  @override
  String clientFoodAmountMru(num amount) {
    return '$amount MRU';
  }

  @override
  String get clientFoodRestaurantClosedMessage =>
      'Ce restaurant est actuellement fermé et n\'accepte pas de nouvelles commandes';

  @override
  String get clientFoodNoDishesAvailable =>
      'Aucun plat disponible pour le moment';

  @override
  String clientFoodViewCartButton(int count) {
    return 'Voir le panier ($count)';
  }

  @override
  String get clientFoodQuantityLabel => 'Quantité';

  @override
  String clientFoodStockRemaining(int stock) {
    return 'Il ne reste que $stock en stock';
  }

  @override
  String clientFoodAddToCartButton(num total) {
    return 'Ajouter au panier · $total MRU';
  }

  @override
  String get clientFoodCartTitle => 'Mon panier';

  @override
  String get clientFoodOrderNoteHint => 'Note pour le restaurant (facultatif)';

  @override
  String get clientFoodSubtotalLabel => 'Sous-total';

  @override
  String get clientFoodDeliveryFeeLabel => 'Frais de livraison';

  @override
  String get clientFoodTotalLabel => 'Total';

  @override
  String clientFoodCartMinOrderWarning(String minOrder) {
    return 'Commande minimum pour ce restaurant : $minOrder MRU';
  }

  @override
  String get clientFoodContinueOrderButton => 'Continuer la commande';

  @override
  String get clientFoodCheckoutTitle => 'Confirmer la commande';

  @override
  String get clientFoodReceiveMethodLabel => 'Mode de récupération';

  @override
  String get clientFoodDeliveryOption => 'Livraison';

  @override
  String get clientFoodPickupOption => 'À emporter au restaurant';

  @override
  String get clientFoodDeliveryAddressLabel => 'Adresse de livraison';

  @override
  String get clientFoodChooseDeliveryAddress =>
      'Choisir l\'adresse de livraison';

  @override
  String get clientFoodEditLabel => 'Modifier';

  @override
  String get clientFoodPaymentMethodLabel => 'Mode de paiement';

  @override
  String get clientFoodFinalTotalLabel => 'Total final';

  @override
  String clientFoodCheckoutMinOrderWarning(String minOrder) {
    return 'Commande minimum pour ce restaurant : $minOrder MRU';
  }

  @override
  String get clientFoodSubmitOrderButton => 'Envoyer la commande';

  @override
  String get clientFoodWaitingTitle =>
      'En attente de l\'acceptation du restaurant';

  @override
  String get clientFoodWaitingSubtitle =>
      'Vous serez averti dès que le restaurant répondra';

  @override
  String get clientFoodCancelOrderButton => 'Annuler la commande';

  @override
  String get clientFoodOrderIncompleteTitle => 'Votre commande n\'a pas abouti';

  @override
  String get clientFoodOrderRejectedDefaultReason =>
      'Le restaurant est peut-être occupé actuellement. Aucun montant ne vous sera débité';

  @override
  String get clientFoodChooseAnotherRestaurantButton =>
      'Choisir un autre restaurant';

  @override
  String get clientFoodTrackingTitle => 'Suivi de la commande';

  @override
  String get clientFoodStepAccepted => 'Acceptée';

  @override
  String get clientFoodStepPreparing => 'En préparation';

  @override
  String get clientFoodStepReadyPickup => 'Prêt pour le retrait';

  @override
  String get clientFoodStepReady => 'Prêt';

  @override
  String get clientFoodStepOnWay => 'En route';

  @override
  String get clientFoodStatusWaiting =>
      'En attente de l\'acceptation du restaurant';

  @override
  String get clientFoodStatusPreparing =>
      'Le restaurant prépare votre commande';

  @override
  String get clientFoodStatusReadyPickup =>
      'Votre commande est prête, vous pouvez la récupérer au restaurant';

  @override
  String get clientFoodStatusSearchingCourier =>
      'Recherche d\'un livreur en cours';

  @override
  String get clientFoodStatusCourierOnWay =>
      'Le livreur est en route vers vous';

  @override
  String get clientFoodStatusPickedUp => 'Récupérée';

  @override
  String get clientFoodStatusDelivered => 'Livrée';

  @override
  String get clientFoodStatusFallback => 'En cours';

  @override
  String clientFoodCallButtonLabel(String name) {
    return '📞 Appeler $name';
  }

  @override
  String get clientFoodDefaultProviderName => 'le restaurant';

  @override
  String get clientFoodRatingTitle => 'Évaluez votre expérience';

  @override
  String get clientFoodRateRestaurantLabel => 'Note du restaurant';

  @override
  String get clientFoodRateDeliveryLabel => 'Note du livreur';

  @override
  String get clientFoodSubmitRatingButton => 'Envoyer l\'évaluation';

  @override
  String get clientFoodDeliveryAddressTitle => 'Adresse de livraison';

  @override
  String get clientFoodLocatingMessage => 'Localisation en cours...';

  @override
  String get clientFoodMapDragHint =>
      'Faites glisser la carte pour ajuster précisément l\'adresse de livraison';

  @override
  String get clientFoodConfirmDeliveryAddressButton =>
      'Confirmer l\'adresse de livraison';

  @override
  String get clientVoiceAnalyzingTitle =>
      'Analyse de votre demande en cours...';

  @override
  String get clientVoiceAnalyzingDesc => 'L\'IA comprend votre commande vocale';

  @override
  String get clientVoiceConfirmSampleTranscript =>
      'Commande-moi un taxi de ma position actuelle à l\'aéroport';

  @override
  String get clientVoiceConfirmTitle =>
      'Avons-nous bien compris votre demande ?';

  @override
  String get clientVoiceConfirmYes => 'Oui, c\'est exact, continuer';

  @override
  String get clientVoiceConfirmAirportName =>
      'Aéroport international de Nouakchott–Oumtounsy';

  @override
  String get clientVoiceConfirmManualEdit => 'Modifier manuellement';

  @override
  String get clientVoiceConfirmReRecord => 'Réenregistrer';

  @override
  String get clientVoiceFailTitle =>
      'Nous n\'avons pas bien compris votre demande';

  @override
  String get clientVoiceFailDesc =>
      'Essayez de parler plus clairement ou passez à la commande manuelle';

  @override
  String get clientVoiceFailManualContinue => 'Continuer manuellement';

  @override
  String get clientVoiceRecordListening => 'À l\'écoute... parlez maintenant';

  @override
  String get clientVoiceRecordTapToSpeak => 'Appuyez pour parler';

  @override
  String get clientVoiceRecordTapToStop =>
      'Appuyez à nouveau pour arrêter l\'enregistrement';

  @override
  String get clientVoiceRecordExampleHint =>
      'Exemple : « Commande-moi un taxi jusqu\'à l\'aéroport »';

  @override
  String clientNotifMinutesAgo(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String clientNotifHoursAgo(int hours) {
    return 'Il y a $hours h';
  }

  @override
  String clientNotifDaysAgo(int days) {
    return 'Il y a $days j';
  }

  @override
  String get clientNotifTitle => 'Notifications';

  @override
  String get clientNotifEmptyTitle => 'Aucune notification pour l\'instant';

  @override
  String get clientNotifEmptyMessage =>
      'Les dernières mises à jour de vos commandes apparaîtront ici';

  @override
  String get clientSupportTitle => 'Support et aide';

  @override
  String get clientSupportFaqLabel => 'Questions fréquentes';

  @override
  String get clientSupportFaq1 => 'Comment annuler une course ?';

  @override
  String get clientSupportFaq2 =>
      'Que faire si j\'ai oublié un objet dans la voiture ?';

  @override
  String get clientSupportFaq3 => 'Comment récupérer mon mot de passe ?';

  @override
  String get clientSupportWhatsapp => 'Contacter via WhatsApp';

  @override
  String get clientSupportCallUs => 'Appelez-nous';

  @override
  String get clientLegalNoContent => 'Aucun contenu pour le moment.';

  @override
  String get clientSettingsTitle => 'Paramètres';

  @override
  String get clientSettingsLanguage => 'Langue';

  @override
  String get clientSettingsNotifications => 'Notifications';

  @override
  String get clientSettingsSavedAddresses => 'Adresses enregistrées';

  @override
  String get clientSettingsAddressHome => 'Domicile';

  @override
  String get clientSettingsAddressWork => 'Travail';

  @override
  String get clientSettingsAddressOther => 'Adresse';

  @override
  String get clientSettingsNewAddressTitle => 'Nouvelle adresse';

  @override
  String get clientSettingsNewAddressHint =>
      'Exemple : Tevragh-Zeina, Nouakchott';

  @override
  String get clientSettingsAddConfirm => 'Ajouter';

  @override
  String get clientSettingsAddAddress => '+ Ajouter une nouvelle adresse';

  @override
  String get clientSettingsAbout => 'À propos de l\'application';

  @override
  String get clientSettingsTerms => 'Conditions générales';

  @override
  String get clientSettingsPrivacy => 'Politique de confidentialité';

  @override
  String get clientSettingsLogout => 'Déconnexion';

  @override
  String get clientSettingsDeleteAccountTitle => 'Supprimer le compte';

  @override
  String get clientSettingsDeleteAccountMessage =>
      'Votre compte et toutes vos données seront supprimés définitivement. Cette action est irréversible. Êtes-vous sûr(e) ?';

  @override
  String get clientSettingsDeleteAccountConfirm => 'Supprimer définitivement';

  @override
  String get clientSettingsDeleteFailedTitle => 'Échec de la suppression';

  @override
  String get clientSettingsDeleteAccountLink => 'Supprimer le compte';

  @override
  String get clientOrdersStatusCompleted => 'Terminée';

  @override
  String get clientOrdersStatusCancelled => 'Annulée';

  @override
  String get clientOrdersStatusRejected => 'Refusée';

  @override
  String get clientOrdersStatusNoDriver => 'Aucun chauffeur trouvé';

  @override
  String get clientOrdersStatusNoLivreur => 'Aucun livreur trouvé';

  @override
  String get clientOrdersStatusOngoing => 'En cours';

  @override
  String get clientOrdersTypeRide => 'Course en taxi';

  @override
  String get clientOrdersTypeDelivery => 'Livraison de colis';

  @override
  String clientOrdersTypeFoodFrom(String name) {
    return 'Commande de $name';
  }

  @override
  String get clientOrdersTypeFoodGeneric => 'Commande de repas';

  @override
  String get clientOrdersCurrencySuffix => 'MRU';

  @override
  String get clientOrdersTabActive => 'En cours';

  @override
  String get clientOrdersTabPast => 'Passées';

  @override
  String get clientOrdersTitle => 'Mes commandes';

  @override
  String get clientOrdersEmptyActiveTitle =>
      'Aucune commande en cours actuellement';

  @override
  String get clientOrdersEmptyPastTitle => 'Aucune commande passée';

  @override
  String get clientOrdersEmptyActiveMessage =>
      'Vos commandes en cours apparaîtront ici';

  @override
  String get clientOrdersEmptyPastMessage =>
      'Vos commandes terminées apparaîtront ici';

  @override
  String get clientOrdersReorder => 'Recommander ›';

  @override
  String get clientProfileTakePhoto => 'Prendre une photo';

  @override
  String get clientProfilePickFromGallery => 'Choisir depuis la galerie';

  @override
  String get clientProfileDefaultName => 'Utilisateur Afrigo';

  @override
  String get clientProfileEditPersonalInfo =>
      'Modifier les informations personnelles';

  @override
  String get clientProfileFullNameHint => 'Votre nom complet';

  @override
  String get clientProfileChangePassword => 'Changer le mot de passe';

  @override
  String get clientProfileNewPasswordTitle => 'Nouveau mot de passe';

  @override
  String get clientProfileChangeConfirm => 'Changer';

  @override
  String get clientProfileChangeSuccessTitle => 'Terminé';

  @override
  String get clientProfileChangeFailTitle => 'Échec';

  @override
  String get clientProfileChangeSuccessMsg =>
      'Le mot de passe a été changé avec succès';

  @override
  String get clientProfileChangeFailMsg =>
      'Impossible de changer le mot de passe, réessayez';

  @override
  String get clientProfileSettingsMenu => '⚙️ Paramètres';

  @override
  String get clientProfileSupportMenu => '🆘 Support et aide';
}
