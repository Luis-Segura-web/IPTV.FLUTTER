class Channel {
  final String id;
  final String name;
  final String streamUrl;
  final String? iconUrl;
  final String? categoryId;
  final String? epgChannelId;
  final bool isLive;
  final String? description;
  final Map<String, dynamic>? metadata;

  Channel({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.iconUrl,
    this.categoryId,
    this.epgChannelId,
    this.isLive = true,
    this.description,
    this.metadata,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    return Channel(
      id: json['stream_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      streamUrl: json['stream_url'] ?? json['url'] ?? '',
      iconUrl: json['stream_icon'] ?? json['icon'] ?? json['logo'],
      categoryId: json['category_id']?.toString(),
      epgChannelId: json['epg_channel_id']?.toString(),
      isLive: json['stream_type'] == 'live' || json['is_live'] == true,
      description: json['description'] ?? json['plot'],
      metadata: Map<String, dynamic>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'stream_url': streamUrl,
      'icon': iconUrl,
      'category_id': categoryId,
      'epg_channel_id': epgChannelId,
      'is_live': isLive,
      'description': description,
      'metadata': metadata,
    };
  }

  Channel copyWith({
    String? id,
    String? name,
    String? streamUrl,
    String? iconUrl,
    String? categoryId,
    String? epgChannelId,
    bool? isLive,
    String? description,
    Map<String, dynamic>? metadata,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      streamUrl: streamUrl ?? this.streamUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      categoryId: categoryId ?? this.categoryId,
      epgChannelId: epgChannelId ?? this.epgChannelId,
      isLive: isLive ?? this.isLive,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Channel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Channel(id: $id, name: $name, isLive: $isLive)';
  }
}