import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/common/app_viewport.dart';

void main() {
  for (final width in [1440.0, 480.0, 390.0]) {
    testWidgets('app viewport at $width pixels', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      const screenKey = Key('screen');
      const headerKey = Key('header');
      const menuKey = Key('menu');
      late BuildContext screenContext;
      late MediaQueryData mediaQuery;
      late double layoutWidth;

      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => AppViewport(child: child!),
          home: Builder(
            builder: (context) {
              screenContext = context;
              mediaQuery = MediaQuery.of(context);
              return LayoutBuilder(
                builder: (context, constraints) {
                  layoutWidth = constraints.maxWidth;
                  return Scaffold(
                    key: screenKey,
                    appBar: AppBar(key: headerKey, title: const Text('Header')),
                    body: const SizedBox.expand(),
                    bottomNavigationBar: const SizedBox(
                      key: menuKey,
                      height: 64,
                      child: Text('Menu'),
                    ),
                  );
                },
              );
            },
          ),
        ),
      );

      final expectedWidth = kIsWeb && width > AppViewport.maxWidth
          ? AppViewport.maxWidth
          : width;
      for (final key in [screenKey, headerKey, menuKey]) {
        expect(tester.getSize(find.byKey(key)).width, expectedWidth);
        expect(
          tester.getTopLeft(find.byKey(key)).dx,
          (width - expectedWidth) / 2,
        );
      }
      expect(layoutWidth, expectedWidth);
      expect(mediaQuery.size, Size(expectedWidth, 900));

      // The Navigator must stay inside the viewport on pushed routes as well.
      Navigator.of(screenContext).push(
        MaterialPageRoute<void>(
          builder: (context) => Scaffold(
            key: const Key('detail'),
            body: Text('${MediaQuery.sizeOf(context).width}'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byKey(const Key('detail'))).width,
        expectedWidth,
      );
      expect(find.text('$expectedWidth'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
