import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_language_app/widgets/feature_card.dart';

void main() {
  testWidgets('FeatureCard renders correctly and handles tap', (WidgetTester tester) async {
    bool wasTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: FeatureCard(
            title: 'Test Title',
            subtitle: 'Test Subtitle',
            icon: Icons.star,
            badgeText: 'TEST BADGE',
            gradientColors: const [Colors.red, Colors.blue],
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    // Assert that the title and subtitle exist
    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Subtitle'), findsOneWidget);
    expect(find.text('TEST BADGE'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsOneWidget);

    // Tap the card
    await tester.tap(find.byType(FeatureCard));
    await tester.pump();

    // Verify tap was registered
    expect(wasTapped, true);
  });
}
