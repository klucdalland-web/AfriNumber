import 'connectivity_service.dart';
import 'data_plan.dart';

/// Instantané de l'écran Connectivité.
class ConnectivityOverview {
  const ConnectivityOverview({
    required this.zeroDataEnabled,
    required this.services,
    required this.plans,
  });

  final bool zeroDataEnabled;
  final List<ConnectivityService> services;
  final List<DataPlan> plans;
}
