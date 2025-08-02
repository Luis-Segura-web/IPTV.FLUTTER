import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/profile_service.dart';

class ProfileProvider with ChangeNotifier {
  final ProfileService _profileService = ProfileService();
  
  List<Profile> _profiles = [];
  Profile? _activeProfile;
  bool _isLoading = false;
  String? _error;

  List<Profile> get profiles => _profiles;
  Profile? get activeProfile => _activeProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfiles => _profiles.isNotEmpty;

  Future<void> loadProfiles() async {
    _setLoading(true);
    try {
      _profiles = await _profileService.getProfiles();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadActiveProfile() async {
    try {
      _activeProfile = await _profileService.getActiveProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> saveProfile(Profile profile) async {
    _setLoading(true);
    try {
      await _profileService.saveProfile(profile);
      await loadProfiles();
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProfile(String profileId) async {
    _setLoading(true);
    try {
      await _profileService.deleteProfile(profileId);
      
      // If deleted profile was active, clear active profile
      if (_activeProfile?.id == profileId) {
        _activeProfile = null;
      }
      
      await loadProfiles();
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> setActiveProfile(Profile profile) async {
    _setLoading(true);
    try {
      await _profileService.setActiveProfile(profile);
      _activeProfile = profile;
      await loadProfiles(); // Refresh to update isActive status
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> testConnection(Profile profile) async {
    _setLoading(true);
    try {
      final isValid = await _profileService.validateProfileConnection(profile);
      _error = isValid ? null : 'Connection test failed';
      return isValid;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearAllProfiles() async {
    _setLoading(true);
    try {
      await _profileService.clearAllProfiles();
      _profiles.clear();
      _activeProfile = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  Profile? getProfileById(String id) {
    try {
      return _profiles.firstWhere((profile) => profile.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateProfileLastUsed(String profileId) {
    _profileService.updateProfileLastUsed(profileId);
    loadProfiles(); // Refresh profiles
  }
}