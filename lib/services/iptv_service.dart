import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/channel.dart';
import '../models/category.dart';
import '../models/profile.dart';
import 'cache_service.dart';

class IPTVService {
  final CacheService _cacheService = CacheService();
  static const Duration _defaultCacheDuration = Duration(hours: 6);

  Future<List<Category>> getCategories(Profile profile) async {
    final cacheKey = 'categories_${profile.id}';
    
    // Try to get from cache first
    final cached = await _cacheService.getProfileCache<List<Category>>(
      profile.id,
      cacheKey,
      (data) => (data as List).map((item) => Category.fromJson(item)).toList(),
    );
    
    if (cached != null) return cached;

    try {
      final url = _buildXtreamUrl(profile, 'get_live_categories');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final categories = data.map((json) => Category.fromJson(json)).toList();
        
        // Cache the result
        await _cacheService.setProfileCache(
          profile.id,
          cacheKey,
          categories.map((c) => c.toJson()).toList(),
          duration: _defaultCacheDuration,
        );
        
        return categories;
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  Future<List<Channel>> getChannels(Profile profile, {String? categoryId}) async {
    final cacheKey = 'channels_${profile.id}_${categoryId ?? 'all'}';
    
    // Try to get from cache first
    final cached = await _cacheService.getProfileCache<List<Channel>>(
      profile.id,
      cacheKey,
      (data) => (data as List).map((item) => Channel.fromJson(item)).toList(),
    );
    
    if (cached != null) return cached;

    try {
      String url = _buildXtreamUrl(profile, 'get_live_streams');
      if (categoryId != null) {
        url += '&category_id=$categoryId';
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final channels = data.map((json) {
          // Build the stream URL for each channel
          final streamUrl = _buildStreamUrl(profile, json['stream_id']?.toString() ?? '');
          final channelJson = Map<String, dynamic>.from(json);
          channelJson['stream_url'] = streamUrl;
          return Channel.fromJson(channelJson);
        }).toList();
        
        // Cache the result
        await _cacheService.setProfileCache(
          profile.id,
          cacheKey,
          channels.map((c) => c.toJson()).toList(),
          duration: _defaultCacheDuration,
        );
        
        return channels;
      } else {
        throw Exception('Failed to load channels: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching channels: $e');
    }
  }

  Future<Map<String, dynamic>> getServerInfo(Profile profile) async {
    final cacheKey = 'server_info_${profile.id}';
    
    // Try to get from cache first
    final cached = await _cacheService.getProfileCache<Map<String, dynamic>>(
      profile.id,
      cacheKey,
      (data) => data as Map<String, dynamic>,
    );
    
    if (cached != null) return cached;

    try {
      final url = _buildXtreamUrl(profile, 'get_server_info');
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        // Cache the result
        await _cacheService.setProfileCache(
          profile.id,
          cacheKey,
          data,
          duration: const Duration(hours: 24), // Server info changes less frequently
        );
        
        return data;
      } else {
        throw Exception('Failed to get server info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching server info: $e');
    }
  }

  Future<bool> testConnection(Profile profile) async {
    try {
      final serverInfo = await getServerInfo(profile);
      return serverInfo.containsKey('user_info') || serverInfo.containsKey('server_info');
    } catch (e) {
      return false;
    }
  }

  String _buildXtreamUrl(Profile profile, String action) {
    final uri = Uri.parse(profile.serverUrl);
    final baseUrl = '${uri.scheme}://${uri.host}:${uri.port}/player_api.php';
    return '$baseUrl?username=${profile.username}&password=${profile.password}&action=$action';
  }

  String _buildStreamUrl(Profile profile, String streamId) {
    final uri = Uri.parse(profile.serverUrl);
    return '${uri.scheme}://${uri.host}:${uri.port}/live/${profile.username}/${profile.password}/$streamId.m3u8';
  }

  Future<List<Channel>> searchChannels(Profile profile, String query) async {
    final allChannels = await getChannels(profile);
    final searchQuery = query.toLowerCase();
    
    return allChannels.where((channel) {
      return channel.name.toLowerCase().contains(searchQuery) ||
             (channel.description?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  Future<void> clearCache(String profileId) async {
    await _cacheService.clearProfileCache(profileId);
  }

  Future<void> refreshData(Profile profile) async {
    await clearCache(profile.id);
    
    // Pre-load essential data
    await Future.wait([
      getCategories(profile),
      getChannels(profile),
      getServerInfo(profile),
    ]);
  }
}