import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../core/utils/auth_navigation.dart';
import '../../domain/models/kyc_document_type.dart';
import '../../domain/models/kyc_profile.dart';
import '../../domain/models/kyc_progress_status.dart';
import '../../domain/models/kyc_verification.dart';
import '../../domain/repositories/kyc_repository.dart';

/// Étapes du parcours KYC.
enum KycStep {
  /// Choix de la pièce.
  choose,

  /// Capture du recto.
  front,

  /// Capture du verso.
  back,

  /// Scan du visage.
  face,

  /// Vérification en cours côté serveur.
  verifying,

  /// Identité vérifiée.
  verified,

  /// Dossier refusé — proposer de renvoyer les pièces.
  rejected,
}

/// Contrôleur du parcours KYC.
class KycController extends GetxController {
  /// Crée le contrôleur avec son [KycRepository] et son [KycCameraService].
  KycController(this._repository);

  static const Duration _pollInterval = Duration(seconds: 2);

  final KycRepository _repository;

  Timer? _pollTimer;
  bool _isPolling = false;

  /// Ticket Laravel déjà ouvert (réutilisé si l'upload doit être retenté).
  String? _profileId;

  /// Chargement de la liste des pièces.
  final RxBool isLoading = false.obs;

  /// Action de capture / envoi en cours.
  final RxBool isBusy = false.obs;

  /// Dernier message d'erreur.
  final RxnString errorMessage = RxnString();

  /// Pièces disponibles.
  final RxList<KycDocumentType> documentTypes = <KycDocumentType>[].obs;

  /// Pièce sélectionnée.
  final Rxn<KycDocumentType> selectedType = Rxn<KycDocumentType>();

  /// Étape courante.
  final Rx<KycStep> step = KycStep.choose.obs;

  /// Résultat du contrôle qualité de chaque capture (recto, verso, selfie).
  final RxMap<KycStep, KycProgressStatus> _photoQuality =
      <KycStep, KycProgressStatus>{}.obs;

  /// Chemin de la photo du recto.
  final RxnString frontPath = RxnString();

  /// Chemin de la photo du verso.
  final RxnString backPath = RxnString();

  /// Chemin du selfie.
  final RxnString facePath = RxnString();

  /// Dernier statut du dossier soumis.
  final Rxn<KycVerification> verification = Rxn<KycVerification>();

  /// `true` tant que le compte n'est pas validé : sortie vers Main interdite.
  bool get isBlockedUntilValidated => !AuthNavigation.isUserValidated();

  /// Bouton retour visible uniquement pour naviguer entre étapes (ou quitter si déjà validé).
  bool get canShowBackButton {
    if (!isBlockedUntilValidated) return true;
    return step.value == KycStep.front ||
        step.value == KycStep.back ||
        step.value == KycStep.face;
  }

  /// Message affiché sur l'écran de refus (motif serveur ou texte générique).
  String get rejectionBody {
    final reason = verification.value?.reason?.trim();
    if (reason != null && reason.isNotEmpty) return reason;
    return 'kyc.rejected.body'.tr;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  /// Couleur logique de chaque segment : choix, scans requis, puis selfie.
  List<KycProgressStatus> get progressStatuses {
    final stages = <KycStep>[
      KycStep.choose,
      KycStep.front,
      if (selectedType.value?.requiresBack == true) KycStep.back,
      KycStep.face,
    ];
    return stages
        .map((stage) {
          if (stage == step.value) {
            return errorMessage.value != null
                ? KycProgressStatus.failed
                : KycProgressStatus.active;
          }
          if (stage == KycStep.choose) {
            return KycProgressStatus.passed;
          }
          return _photoQuality[stage] ?? KycProgressStatus.pending;
        })
        .toList(growable: false);
  }

  /// Indique si l'indicateur de progression doit être visible.
  bool get showProgress =>
      step.value != KycStep.verifying &&
      step.value != KycStep.verified &&
      step.value != KycStep.rejected;

  /// Charge les pièces et reprend l'écran d'attente / refus si besoin.
  Future<void> load() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final typesFuture = _repository.getDocumentTypes();
      await _resumeIfPending();
      documentTypes.assignAll(await typesFuture);
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'kyc.err'.tr;
    } finally {
      isLoading.value = false;
    }
  }

  /// Si `non_valide` et dossier déjà ouvert → attente, verified ou rejected.
  Future<void> _resumeIfPending() async {
    if (!isBlockedUntilValidated) return;
    try {
      final KycVerification current =
          await _repository.getCurrentVerificationStatus();
      verification.value = current;
      if (current.isApproved) {
        _profileId = current.reference.isEmpty ? null : current.reference;
        step.value = KycStep.verified;
        return;
      }
      if (current.isRejected) {
        _enterRejected(current);
        return;
      }
      if (current.isPending && current.reference.isNotEmpty) {
        _enterWaiting(current.reference);
      }
    } catch (_) {
      // Pas de statut : on laisse le parcours classique (choix de pièce).
    }
  }

  /// Affiche « Vérification en cours » et démarre le polling.
  void _enterWaiting(String profileId) {
    _profileId = profileId;
    verification.value = KycVerification(
      status: 'pending',
      reference: profileId,
    );
    step.value = KycStep.verifying;
    _startPolling();
  }

  /// Affiche l'écran de refus avec possibilité de renvoyer les pièces.
  void _enterRejected(KycVerification result) {
    _pollTimer?.cancel();
    _profileId = null;
    frontPath.value = null;
    backPath.value = null;
    facePath.value = null;
    _photoQuality.clear();
    selectedType.value = null;
    verification.value = result;
    step.value = KycStep.rejected;
    errorMessage.value = null;
  }

  /// Sélectionne une pièce (le verso déjà pris est oublié si la pièce change).
  void selectType(KycDocumentType type) {
    if (selectedType.value?.id != type.id) {
      frontPath.value = null;
      backPath.value = null;
      facePath.value = null;
      _photoQuality.clear();
    }
    selectedType.value = type;
  }

  /// Enregistre le résultat du contrôle qualité de l'étape caméra active.
  void onPhotoQualityResult(bool accepted, String? messageKey) {
    final currentStep = step.value;
    if (currentStep != KycStep.front &&
        currentStep != KycStep.back &&
        currentStep != KycStep.face) {
      return;
    }
    _photoQuality[currentStep] = accepted
        ? KycProgressStatus.passed
        : KycProgressStatus.failed;
    errorMessage.value = accepted ? null : messageKey?.tr ?? 'kyc.err'.tr;
  }

  /// Action du bouton principal selon l'étape courante.
  Future<void> onPrimaryPressed() async {
    final KycDocumentType? type = selectedType.value;
    if (type == null) return;
    switch (step.value) {
      case KycStep.choose:
        errorMessage.value = null;
        _photoQuality[KycStep.choose] = KycProgressStatus.passed;
        step.value = KycStep.front;
        return;
      case KycStep.front:
      case KycStep.back:
      case KycStep.face:
        // La capture est pilotée directement par l'aperçu caméra de la vue.
        return;
      case KycStep.verifying:
      case KycStep.verified:
      case KycStep.rejected:
        return;
    }
  }

  /// Repart du choix de pièce après un refus.
  void resubmitDocuments() {
    frontPath.value = null;
    backPath.value = null;
    facePath.value = null;
    _photoQuality.clear();
    verification.value = null;
    selectedType.value = null;
    _profileId = null;
    errorMessage.value = null;
    step.value = KycStep.choose;
  }

  /// Traite la photo prise depuis l'aperçu caméra intégré.
  Future<void> onPhotoCaptured(String path) async {
    final type = selectedType.value;
    if (type == null) return;

    switch (step.value) {
      case KycStep.front:
        frontPath.value = path;
        step.value = type.requiresBack ? KycStep.back : KycStep.face;
      case KycStep.back:
        backPath.value = path;
        step.value = KycStep.face;
      case KycStep.face:
        facePath.value = path;
        await _run(() => _submit(type));
      case KycStep.choose:
      case KycStep.verifying:
      case KycStep.verified:
      case KycStep.rejected:
        return;
    }
  }

  /// Revient à l'étape précédente. Ne quitte pas le KYC si le compte n'est pas validé.
  void goBack() {
    if (isBusy.value) return;
    errorMessage.value = null;
    switch (step.value) {
      case KycStep.choose:
      case KycStep.verifying:
      case KycStep.rejected:
        if (isBlockedUntilValidated) return;
        Get.back<void>();
      case KycStep.verified:
        if (isBlockedUntilValidated) {
          unawaited(enterAppAfterValidation());
          return;
        }
        Get.back<void>();
      case KycStep.front:
        step.value = KycStep.choose;
      case KycStep.back:
        step.value = KycStep.front;
      case KycStep.face:
        step.value = (selectedType.value?.requiresBack ?? false)
            ? KycStep.back
            : KycStep.front;
    }
  }

  /// Après validation KYC : met à jour le statut local et ouvre Main.
  Future<void> enterAppAfterValidation() =>
      AuthNavigation.completeKycAndEnterApp();

  /// Quitte le parcours pour revenir à l'accueil (interdit si non validé).
  void goHome() {
    if (isBlockedUntilValidated) return;
    AuthNavigation.goToHome();
  }

  /// CTA post-vérification : débloque l'app (statut local `valide`) puis Main.
  void onVerifiedContinue() {
    unawaited(enterAppAfterValidation());
  }

  /// Ouvre le ticket (une seule fois), envoie les 3 fichiers, lance le suivi.
  ///
  /// Si Laravel refuse (`demande déjà en cours`) → écran d'attente, pas d'erreur.
  Future<void> _submit(KycDocumentType type) async {
    final String? front = frontPath.value;
    final String? face = facePath.value;
    final String? back = type.requiresBack ? backPath.value : null;
    if (front == null || face == null || (type.requiresBack && back == null)) {
      // Une photo manque : on repart de la première étape de capture.
      step.value = KycStep.front;
      return;
    }

    String? profileId = _profileId;
    if (profileId == null) {
      final KycProfile profile = await _repository.initVerification();
      if (profile.isAlreadyApproved) {
        _profileId = profile.profileId;
        step.value = KycStep.verified;
        return;
      }
      if (profile.isAlreadyPending) {
        _enterWaiting(profile.profileId);
        return;
      }
      profileId = profile.profileId;
      _profileId = profileId;
    }

    await _repository.uploadDocuments(
      profileId: profileId,
      selfiePath: face,
      frontPath: front,
      backPath: back,
    );

    _enterWaiting(profileId);
  }

  /// Lance l'interrogation périodique du statut du dossier.
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    if (_isPolling) return;
    final String? profileId = _profileId;
    if (profileId == null) return;
    _isPolling = true;
    try {
      final KycVerification result = await _repository.getVerificationStatus(
        profileId: profileId,
      );
      verification.value = result;
      if (result.isApproved) {
        _pollTimer?.cancel();
        step.value = KycStep.verified;
      } else if (result.isRejected) {
        _enterRejected(result);
      }
    } catch (_) {
      // Erreur réseau ponctuelle : on réessaie au prochain tick.
    } finally {
      _isPolling = false;
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    if (isBusy.value) return;
    isBusy.value = true;
    errorMessage.value = null;
    try {
      await action();
    } on KycException catch (e) {
      errorMessage.value = e.message ?? e.messageKey?.tr ?? 'kyc.err'.tr;
    } on ApiException catch (e) {
      errorMessage.value = e.message;
    } catch (_) {
      errorMessage.value = 'kyc.err'.tr;
    } finally {
      isBusy.value = false;
    }
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    documentTypes.clear();
    super.onClose();
  }
}
