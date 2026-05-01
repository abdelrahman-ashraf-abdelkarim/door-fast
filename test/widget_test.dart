import 'dart:io';

import 'package:captain_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  late Directory storageDirectory;

  setUpAll(() async {
    storageDirectory = Directory.systemTemp.createTempSync(
      'captain_app_hydrated_test_',
    );
    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: HydratedStorageDirectory(storageDirectory.path),
    );
  });

  tearDownAll(() async {
    await HydratedBloc.storage.close();
    storageDirectory.deleteSync(recursive: true);
  });

  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CaptainApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
