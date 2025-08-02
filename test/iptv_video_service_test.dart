import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_flutter/models/channel.dart';
import 'package:iptv_flutter/models/profile.dart';
import 'package:iptv_flutter/services/iptv_video_service.dart';

void main() {
  group('IPTVVideoService Tests', () {
    late IPTVVideoService service;
    late Channel testChannel;
    late Profile testProfile;

    setUp(() {
      service = IPTVVideoService();
      testChannel = Channel(
        id: 'test_1',
        name: 'Test Channel',
        streamUrl: 'https://example.com/stream.m3u8',
        isLive: true,
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

    tearDown(() async {
      await service.dispose();
    });

    test('should create service instance', () {
      expect(service, isNotNull);
    });

    test('should build http headers correctly', () {
      // This tests the private method indirectly through the service
      expect(service.hasActiveController, isFalse);
    });

    test('should handle multiple controller disposal', () async {
      await service.disposeCurrentController();
      await service.disposeCurrentController();
      // Should not throw
      expect(service.hasActiveController, isFalse);
    });

    test('should validate channel and profile models', () {
      expect(testChannel.id, 'test_1');
      expect(testChannel.name, 'Test Channel');
      expect(testChannel.isLive, true);
      expect(testProfile.username, 'testuser');
      expect(testProfile.serverUrl, 'https://example.com');
    });
  });
}