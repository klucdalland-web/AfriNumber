import '../../domain/models/kyc_document_type.dart';
import '../../domain/models/kyc_profile.dart';
import '../../domain/models/kyc_verification.dart';
import '../../domain/repositories/kyc_repository.dart';

/// Repository factice pour développer sans backend.
///
/// Le dossier passe de `pending` à `approved` 4 secondes après l'upload.
class MockKycRepository implements KycRepository {
  /// Crée le mock.
  MockKycRepository();

  static const String _profileId = 'mock-profile-001';
  static const Duration _approvalDelay = Duration(seconds: 4);

  DateTime? _uploadedAt;

  @override
  Future<List<KycDocumentType>> getDocumentTypes() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return KycDocumentType.supported;
  }

  @override
  Future<KycProfile> initVerification() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return const KycProfile(
      profileId: _profileId,
      status: 'autorise',
      message: 'Ticket de validation ouvert.',
    );
  }

  @override
  Future<void> uploadDocuments({
    required String profileId,
    required String selfiePath,
    required String frontPath,
    String? backPath,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    _uploadedAt = DateTime.now();
  }

  @override
  Future<KycVerification> getCurrentVerificationStatus() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (_uploadedAt == null) {
      return const KycVerification(status: 'none', reference: '');
    }
    return getVerificationStatus(profileId: _profileId);
  }

  @override
  Future<KycVerification> getVerificationStatus({
    required String profileId,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final DateTime? at = _uploadedAt;
    final bool approved =
        at != null && DateTime.now().difference(at) >= _approvalDelay;
    return KycVerification(
      status: approved ? 'approved' : 'pending',
      reference: profileId,
    );
  }
}