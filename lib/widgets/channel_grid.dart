import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/iptv_provider.dart';
import '../providers/profile_provider.dart';
import '../models/channel.dart';
import '../config/constants.dart';
import '../screens/video_player_screen.dart';

class ChannelGrid extends StatelessWidget {
  const ChannelGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IPTVProvider>(
      builder: (context, iptvProvider, child) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppConstants.gridCrossAxisCount,
            crossAxisSpacing: AppConstants.gridSpacing,
            mainAxisSpacing: AppConstants.gridSpacing,
            childAspectRatio: AppConstants.gridAspectRatio,
          ),
          itemCount: iptvProvider.channels.length,
          itemBuilder: (context, index) {
            final channel = iptvProvider.channels[index];
            return ChannelCard(
              channel: channel,
              onTap: () => _playChannel(context, channel),
            );
          },
        );
      },
    );
  }

  void _playChannel(BuildContext context, Channel channel) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    if (profileProvider.activeProfile != null) {
      profileProvider.updateProfileLastUsed(profileProvider.activeProfile!.id);
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
            channel: channel,
            profile: profileProvider.activeProfile!,
          ),
        ),
      );
    }
  }
}

class ChannelCard extends StatelessWidget {
  final Channel channel;
  final VoidCallback onTap;

  const ChannelCard({
    super.key,
    required this.channel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppConstants.cardBorderRadius),
                ),
                child: _buildChannelImage(context),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (channel.description != null) ...[
                      Text(
                        channel.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Icon(
                            channel.isLive ? Icons.live_tv : Icons.movie,
                            size: 16,
                            color: channel.isLive ? Colors.red : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            channel.isLive ? 'Live TV' : 'On Demand',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelImage(BuildContext context) {
    if (channel.iconUrl != null && channel.iconUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: channel.iconUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Theme.of(context).colorScheme.surface,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(context),
      );
    }
    
    return _buildPlaceholder(context);
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            channel.isLive ? Icons.live_tv : Icons.movie,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            channel.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}