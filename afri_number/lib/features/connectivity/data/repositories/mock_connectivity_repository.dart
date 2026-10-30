import '../models/connectivity_overview.dart';
import '../models/connectivity_service.dart';
import '../models/data_plan.dart';
import 'connectivity_repository.dart';

/// Données de démonstration alignées sur la maquette Figma.
class MockConnectivityRepository implements ConnectivityRepository {
  bool _zeroData = true;

  @override
  Future<ConnectivityOverview> fetchOverview() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return ConnectivityOverview(
      zeroDataEnabled: _zeroData,
      services: const [
        ConnectivityService(
          id: 'esim',
          type: ConnectivityServiceType.esim,
          name: 'eSIM virtuelle',
          isActive: true,
        ),
        ConnectivityService(
          id: 'call-forwarding',
          type: ConnectivityServiceType.callForwarding,
          name: "Renvoi d'appel",
          isActive: true,
        ),
        ConnectivityService(
          id: 'sms-notification',
          type: ConnectivityServiceType.smsNotification,
          name: 'Notification SMS',
          isActive: false,
        ),
      ],
      plans: const [
        DataPlan(
          id: 'plan-1',
          name: '1 Go / Mois',
          description: 'Idéal pour les communications quotidiennes',
          price: 5000,
        ),
        DataPlan(
          id: 'plan-5',
          name: '5 Go / Mois',
          description: 'Pour les entrepreneurs actifs',
          price: 15000,
        ),
        DataPlan(
          id: 'plan-20',
          name: '20 Go / Mois',
          description: 'Pour les usages intensifs',
          price: 40000,
        ),
      ],
    );
  }

  @override
  Future<void> setZeroData(bool enabled) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _zeroData = enabled;
  }
}
