import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../data/models/history_entry.dart';
import '../../data/models/history_filter.dart';
import '../../data/repositories/history_repository.dart';

class HistoryController extends GetxController {
  HistoryController(this._repository);

  final HistoryRepository _repository;

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final filter = HistoryFilter.all.obs;
  final entries = <HistoryEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      entries.assignAll(await _repository.fetchHistory());
    } catch (_) {
      errorMessage.value = "Impossible de charger l'historique. Réessayez.";
    } finally {
      isLoading.value = false;
    }
  }

  void selectFilter(HistoryFilter value) => filter.value = value;

  /// Entrées filtrées, triées de la plus récente à la plus ancienne et
  /// regroupées par jour. Lit des `Rx` : à consommer dans un `Obx`.
  List<HistoryGroup> get groups {
    final visible = entries.where(filter.value.matches).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final groups = <HistoryGroup>[];
    for (final entry in visible) {
      final label = Formatters.dayLabel(entry.date);
      if (groups.isNotEmpty && groups.last.label == label) {
        groups.last.entries.add(entry);
      } else {
        groups.add(HistoryGroup(label: label, entries: [entry]));
      }
    }
    return groups;
  }
}
