import 'package:flutter_test/flutter_test.dart';
import 'package:iptv_flutter/models/profile.dart';

void main() {
  group('Profile Model Tests', () {
    test('Profile creation and JSON serialization', () {
      final profile = Profile(
        id: '1',
        name: 'Test Profile',
        serverUrl: 'http://test.com:8080',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(profile.id, '1');
      expect(profile.name, 'Test Profile');
      expect(profile.serverUrl, 'http://test.com:8080');
      expect(profile.username, 'testuser');
      expect(profile.password, 'testpass');
      expect(profile.isActive, false);
    });

    test('Profile JSON serialization and deserialization', () {
      final originalProfile = Profile(
        id: '1',
        name: 'Test Profile',
        serverUrl: 'http://test.com:8080',
        username: 'testuser',
        password: 'testpass',
        logoUrl: 'http://test.com/logo.png',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        lastUsed: DateTime(2024, 1, 2),
      );

      final json = originalProfile.toJson();
      final deserializedProfile = Profile.fromJson(json);

      expect(deserializedProfile.id, originalProfile.id);
      expect(deserializedProfile.name, originalProfile.name);
      expect(deserializedProfile.serverUrl, originalProfile.serverUrl);
      expect(deserializedProfile.username, originalProfile.username);
      expect(deserializedProfile.password, originalProfile.password);
      expect(deserializedProfile.logoUrl, originalProfile.logoUrl);
      expect(deserializedProfile.isActive, originalProfile.isActive);
      expect(deserializedProfile.createdAt, originalProfile.createdAt);
      expect(deserializedProfile.lastUsed, originalProfile.lastUsed);
    });

    test('Profile copyWith method', () {
      final originalProfile = Profile(
        id: '1',
        name: 'Test Profile',
        serverUrl: 'http://test.com:8080',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime(2024, 1, 1),
      );

      final updatedProfile = originalProfile.copyWith(
        name: 'Updated Profile',
        isActive: true,
      );

      expect(updatedProfile.id, originalProfile.id);
      expect(updatedProfile.name, 'Updated Profile');
      expect(updatedProfile.serverUrl, originalProfile.serverUrl);
      expect(updatedProfile.username, originalProfile.username);
      expect(updatedProfile.password, originalProfile.password);
      expect(updatedProfile.isActive, true);
      expect(updatedProfile.createdAt, originalProfile.createdAt);
    });

    test('Profile equality', () {
      final profile1 = Profile(
        id: '1',
        name: 'Test Profile',
        serverUrl: 'http://test.com:8080',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime(2024, 1, 1),
      );

      final profile2 = Profile(
        id: '1',
        name: 'Different Name',
        serverUrl: 'http://different.com:8080',
        username: 'differentuser',
        password: 'differentpass',
        createdAt: DateTime(2024, 1, 2),
      );

      final profile3 = Profile(
        id: '2',
        name: 'Test Profile',
        serverUrl: 'http://test.com:8080',
        username: 'testuser',
        password: 'testpass',
        createdAt: DateTime(2024, 1, 1),
      );

      expect(profile1, equals(profile2)); // Same ID
      expect(profile1, isNot(equals(profile3))); // Different ID
    });
  });
}