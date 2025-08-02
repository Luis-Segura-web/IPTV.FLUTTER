import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/profile.dart';

class ProfileService {
  static const _storage = FlutterSecureStorage();
  static const String _profilesKey = 'user_profiles';
  static const String _activeProfileKey = 'active_profile';

  Future<List<Profile>> getProfiles() async {
    try {
      final profilesJson = await _storage.read(key: _profilesKey);
      if (profilesJson == null) return [];

      final List<dynamic> profilesList = json.decode(profilesJson);
      return profilesList.map((json) => Profile.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Profile?> getActiveProfile() async {
    try {
      final activeProfileJson = await _storage.read(key: _activeProfileKey);
      if (activeProfileJson == null) return null;

      return Profile.fromJson(json.decode(activeProfileJson));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveProfile(Profile profile) async {
    final profiles = await getProfiles();
    final existingIndex = profiles.indexWhere((p) => p.id == profile.id);

    if (existingIndex >= 0) {
      profiles[existingIndex] = profile;
    } else {
      profiles.add(profile);
    }

    await _saveProfiles(profiles);
  }

  Future<void> deleteProfile(String profileId) async {
    final profiles = await getProfiles();
    profiles.removeWhere((profile) => profile.id == profileId);
    await _saveProfiles(profiles);

    // If the deleted profile was active, clear active profile
    final activeProfile = await getActiveProfile();
    if (activeProfile?.id == profileId) {
      await _storage.delete(key: _activeProfileKey);
    }
  }

  Future<void> setActiveProfile(Profile profile) async {
    // Update the profile's lastUsed timestamp
    final updatedProfile = profile.copyWith(
      lastUsed: DateTime.now(),
      isActive: true,
    );

    // Deactivate all other profiles
    final profiles = await getProfiles();
    final updatedProfiles = profiles.map((p) {
      if (p.id == profile.id) {
        return updatedProfile;
      } else {
        return p.copyWith(isActive: false);
      }
    }).toList();

    await _saveProfiles(updatedProfiles);
    await _storage.write(
      key: _activeProfileKey,
      value: json.encode(updatedProfile.toJson()),
    );
  }

  Future<void> _saveProfiles(List<Profile> profiles) async {
    final profilesJson = json.encode(profiles.map((p) => p.toJson()).toList());
    await _storage.write(key: _profilesKey, value: profilesJson);
  }

  Future<bool> validateProfileConnection(Profile profile) async {
    try {
      // This would normally make an HTTP request to test the connection
      // For now, we'll just validate the URL format
      final uri = Uri.tryParse(profile.serverUrl);
      return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<void> clearAllProfiles() async {
    await _storage.delete(key: _profilesKey);
    await _storage.delete(key: _activeProfileKey);
  }

  Future<Profile?> getProfileById(String id) async {
    final profiles = await getProfiles();
    try {
      return profiles.firstWhere((profile) => profile.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateProfileLastUsed(String profileId) async {
    final profile = await getProfileById(profileId);
    if (profile != null) {
      await saveProfile(profile.copyWith(lastUsed: DateTime.now()));
    }
  }
}