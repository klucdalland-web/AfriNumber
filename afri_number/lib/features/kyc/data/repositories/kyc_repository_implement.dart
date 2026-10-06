import '../../domain/models/kyc_document_type.dart';
import '../../domain/models/kyc_profile.dart';
import '../../domain/models/kyc_verification.dart';
import '../../domain/repositories/kyc_repository.dart';
import '../datasources/kyc_remote_datasource.dart';

/// Implémentation réelle du [KycRepository] (Laravel + Express).
class KycRepositoryImpl implements KycRepository {
  /// Crée le repository.
  const KycRepositoryImpl(this._remote);

  final KycRemoteDataSource _remote;

  @override
  Future<List<KycDocumentType>> getDocumentTypes() async =>
      KycDocumentType.supported;

  @override
  Future<KycProfile> initVerification() async {
    final KycProfile profile = await _remote.initVerification();
    if (profile.isAuthorized ||
        profile.isAlreadyPending ||
        profile.isAlreadyApproved) {
      return profile;
    }
    throw KycException(
      message: profile.message.isEmpty ? null : profile.message,
    );
  }

  @override
  Future<void> uploadDocuments({
    required String profileId,
    required String selfiePath,
    required String frontPath,
    String? backPath,
  }) =>
      _remote.uploadDocuments(
        profileId: profileId,
        selfiePath: selfiePath,
        frontPath: frontPath,
        backPath: backPath,
      );

  @override
  Future<KycVerification> getCurrentVerificationStatus() =>
      _remote.fetchCurrentStatus();

  @override
  Future<KycVerification> getVerificationStatus({
    required String profileId,
  }) =>
      _remote.fetchStatus(profileId: profileId);
}