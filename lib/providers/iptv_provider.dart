import 'package:flutter/foundation.dart';
import '../models/channel.dart';
import '../models/category.dart';
import '../models/profile.dart';
import '../services/iptv_service.dart';

class IPTVProvider with ChangeNotifier {
  final IPTVService _iptvService = IPTVService();
  
  List<Category> _categories = [];
  List<Channel> _channels = [];
  List<Channel> _filteredChannels = [];
  Category? _selectedCategory;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<Category> get categories => _categories;
  List<Channel> get channels => _filteredChannels;
  Category? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get hasChannels => _filteredChannels.isNotEmpty;
  bool get hasCategories => _categories.isNotEmpty;

  Future<void> loadCategories(Profile profile) async {
    _setLoading(true);
    try {
      _categories = await _iptvService.getCategories(profile);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _categories = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadChannels(Profile profile, {String? categoryId}) async {
    _setLoading(true);
    try {
      _channels = await _iptvService.getChannels(profile, categoryId: categoryId);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = e.toString();
      _channels = [];
      _filteredChannels = [];
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllData(Profile profile) async {
    _setLoading(true);
    try {
      await Future.wait([
        loadCategories(profile),
        loadChannels(profile),
      ]);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void selectCategory(Category? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void searchChannels(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredChannels = _channels.where((channel) {
      // Apply category filter
      bool categoryMatch = _selectedCategory == null || 
                          channel.categoryId == _selectedCategory!.id;
      
      // Apply search filter
      bool searchMatch = _searchQuery.isEmpty ||
                        channel.name.toLowerCase().contains(_searchQuery) ||
                        (channel.description?.toLowerCase().contains(_searchQuery) ?? false);
      
      return categoryMatch && searchMatch;
    }).toList();
  }

  Future<bool> testConnection(Profile profile) async {
    _setLoading(true);
    try {
      final isConnected = await _iptvService.testConnection(profile);
      _error = isConnected ? null : 'Connection test failed';
      return isConnected;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshData(Profile profile) async {
    _setLoading(true);
    try {
      await _iptvService.refreshData(profile);
      await loadAllData(profile);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearCache(String profileId) async {
    try {
      await _iptvService.clearCache(profileId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
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

  Channel? getChannelById(String id) {
    try {
      return _channels.firstWhere((channel) => channel.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Channel> getChannelsByCategory(String categoryId) {
    return _channels.where((channel) => channel.categoryId == categoryId).toList();
  }

  void reset() {
    _categories = [];
    _channels = [];
    _filteredChannels = [];
    _selectedCategory = null;
    _searchQuery = '';
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}