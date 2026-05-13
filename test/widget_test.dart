import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foyer_rural_ops/main.dart';

void main() {
  testWidgets('navigates across operational sections', (tester) async {
    await tester.pumpWidget(FoyerApp(store: AppStore.seeded(readOnly: true)));
    await tester.pumpAndSettle();

    expect(find.text('Operations'), findsOneWidget);
    expect(find.text('Open files'), findsOneWidget);

    await tester.tap(find.text('Assets'));
    await tester.pumpAndSettle();
    expect(find.text('Containers'), findsWidgets);
    expect(find.text('CTR-12 Supplies'), findsOneWidget);

    await tester.tap(find.text('Revenue'));
    await tester.pumpAndSettle();
    expect(find.text('Revenue analytics'), findsOneWidget);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('No APIs, no cloud sync, no analytics'), findsOneWidget);
  });

  testWidgets('creates a local record from the form', (tester) async {
    final store = AppStore.seeded(readOnly: true);
    await tester.pumpWidget(FoyerApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Records'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('new-record-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('record-name-field')),
      'Luc Moreau',
    );
    await tester.enterText(
      find.byKey(const Key('record-concern-field')),
      'Transport follow-up',
    );
    await tester.enterText(
      find.byKey(const Key('record-action-field')),
      'Call volunteer driver',
    );
    await tester.tap(find.byKey(const Key('save-record-button')));
    await tester.pumpAndSettle();

    expect(find.text('Luc Moreau'), findsOneWidget);
    expect(store.patientFiles.first.name, 'Luc Moreau');
  });
}
