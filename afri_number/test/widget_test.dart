import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';

import 'package:afri_number/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await GetStorage.init();
  });

  testWidgets('Welcome page loads with navigation buttons', (tester) async {
    await tester.pumpWidget(const AfriNumberApp());
    await tester.pumpAndSettle();

    expect(find.text('Accueil'), findsOneWidget);
    expect(find.text('Suivant — Connexion'), findsOneWidget);
    expect(find.text('Créer un compte'), findsOneWidget);
  });
}
