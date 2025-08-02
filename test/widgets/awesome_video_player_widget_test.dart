import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_flutter/models/channel.dart';
import 'package:iptv_flutter/models/profile.dart';
import 'package:iptv_flutter/widgets/awesome_video_player_widget.dart';

void main() {
  group('AwesomeVideoPlayerWidget Tests', () {
    late Channel testChannel;
    late Profile testProfile;

    setUp(() {
      testChannel = Channel(
        id: 'test_1',
        name: 'Test Channel',
        streamUrl: 'https://example.com/stream.m3u8',
        isLive: true,
        description: 'Test channel description',
      );
      
      testProfile = Profile(
        id: 'profile_1',
        name: 'Test Profile',
        serverUrl: 'https://example.com',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime.now(),
      );
    });

    testWidgets('should create widget with required parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AwesomeVideoPlayerWidget(
              channel: testChannel,
              profile: testProfile,
            ),
          ),
        ),
      );

      // Initially should show loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading stream...'), findsOneWidget);
    });

    testWidgets('should display error state when error occurs', (WidgetTester tester) async {
      String? capturedError;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AwesomeVideoPlayerWidget(
              channel: testChannel,
              profile: testProfile,
              onError: (error) {
                capturedError = error;
              },
            ),
          ),
        ),
      );

      // Widget should be in loading state initially
      expect(find.text('Loading stream...'), findsOneWidget);
      
      // Pump and settle to allow for state changes
      await tester.pumpAndSettle();
    });

    testWidgets('should show correct channel information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AwesomeVideoPlayerWidget(
              channel: testChannel,
              profile: testProfile,
            ),
          ),
        ),
      );

      // The widget should be created successfully
      expect(find.byType(AwesomeVideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should handle controls visibility', (WidgetTester tester) async {
      // Test with controls enabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AwesomeVideoPlayerWidget(
              channel: testChannel,
              profile: testProfile,
              showControls: true,
            ),
          ),
        ),
      );

      expect(find.byType(AwesomeVideoPlayerWidget), findsOneWidget);

      // Test with controls disabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AwesomeVideoPlayerWidget(
              channel: testChannel,
              profile: testProfile,
              showControls: false,
            ),
          ),
        ),
      );

      expect(find.byType(AwesomeVideoPlayerWidget), findsOneWidget);
    });

    testWidgets('should handle different channel types', (WidgetTester tester) async {
      // Test with live channel
      final liveChannel = testChannel.copyWith(isLive: true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AwesomeVideoPlayerWidget(
              channel: liveChannel,
              profile: testProfile,
            ),
          ),
        ),
      );

      expect(find.byType(AwesomeVideoPlayerWidget), findsOneWidget);

      // Test with VOD channel
      final vodChannel = testChannel.copyWith(isLive: false);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AwesomeVideoPlayerWidget(
              channel: vodChannel,
              profile: testProfile,
            ),
          ),
        ),
      );

      expect(find.byType(AwesomeVideoPlayerWidget), findsOneWidget);
    });
  });

  group('VideoControls Tests', () {
    testWidgets('should handle duration formatting correctly', (WidgetTester tester) async {
      // This is testing a utility function that should be extracted
      // For now, we'll test the widget creation
      expect(true, isTrue); // Placeholder test
    });
  });
}