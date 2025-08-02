import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_flutter/screens/video_player_screen.dart';
import 'package:iptv_flutter/models/channel.dart';
import 'package:iptv_flutter/models/profile.dart';

void main() {
  group('VideoPlayerScreen Lifecycle Tests', () {
    testWidgets('VideoPlayerScreen initializes safely with mounted checks', (WidgetTester tester) async {
      // Create test data
      final testChannel = Channel(
        id: 'test-channel',
        name: 'Test Channel',
        streamUrl: 'http://test-stream.m3u8',
        logoUrl: null,
        description: 'Test channel description',
        category: 'Test',
        isLive: true,
      );

      final testProfile = Profile(
        id: 'test-profile',
        name: 'Test Profile',
        serverUrl: 'http://test-server.com',
        username: 'test',
        password: 'test',
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: VideoPlayerScreen(
            channel: testChannel,
            profile: testProfile,
          ),
        ),
      );

      // Verify initial loading state
      expect(find.text('Loading stream...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify the app bar shows the channel name
      expect(find.text('Test Channel'), findsOneWidget);

      // Verify retry and fullscreen buttons are present
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.fullscreen), findsOneWidget);
    });

    testWidgets('VideoPlayerScreen handles dispose safely', (WidgetTester tester) async {
      final testChannel = Channel(
        id: 'test-channel',
        name: 'Test Channel',
        streamUrl: 'http://test-stream.m3u8',
        logoUrl: null,
        description: 'Test channel description',
        category: 'Test',
        isLive: true,
      );

      final testProfile = Profile(
        id: 'test-profile',
        name: 'Test Profile',
        serverUrl: 'http://test-server.com',
        username: 'test',
        password: 'test',
      );

      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: VideoPlayerScreen(
            channel: testChannel,
            profile: testProfile,
          ),
        ),
      );

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Different Screen'),
          ),
        ),
      );

      // This should not throw any lifecycle errors
      await tester.pumpAndSettle();

      expect(find.text('Different Screen'), findsOneWidget);
    });
  });
}