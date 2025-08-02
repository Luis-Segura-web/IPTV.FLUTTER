import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/iptv_provider.dart';
import '../widgets/category_list.dart';
import '../widgets/channel_grid.dart';
import '../widgets/search_bar_widget.dart';
import '../config/constants.dart';
import 'profile_management_screen.dart';
import 'video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final iptvProvider = Provider.of<IPTVProvider>(context, listen: false);
    
    if (profileProvider.activeProfile != null) {
      await iptvProvider.loadAllData(profileProvider.activeProfile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ProfileProvider>(
          builder: (context, profileProvider, child) {
            return Text(profileProvider.activeProfile?.name ?? AppConstants.appName);
          },
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showProfileMenu,
            icon: const Icon(Icons.account_circle),
          ),
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer2<ProfileProvider, IPTVProvider>(
        builder: (context, profileProvider, iptvProvider, child) {
          if (profileProvider.activeProfile == null) {
            return _buildNoProfileState();
          }

          if (iptvProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading channels...'),
                ],
              ),
            );
          }

          if (iptvProvider.error != null) {
            return _buildErrorState(iptvProvider);
          }

          return Column(
            children: [
              const SearchBarWidget(),
              if (iptvProvider.hasCategories)
                const CategoryList(),
              Expanded(
                child: iptvProvider.hasChannels
                    ? const ChannelGrid()
                    : _buildNoChannelsState(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNoProfileState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Please select or create a profile to start streaming.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToProfileManagement,
              icon: const Icon(Icons.add),
              label: const Text('Manage Profiles'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(IPTVProvider iptvProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Connection Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              iptvProvider.error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: _navigateToProfileManagement,
                  child: const Text('Change Profile'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    iptvProvider.clearError();
                    _loadData();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoChannelsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tv_off_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Channels Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Consumer<IPTVProvider>(
              builder: (context, iptvProvider, child) {
                if (iptvProvider.searchQuery.isNotEmpty) {
                  return Column(
                    children: [
                      Text(
                        'No channels match your search "${iptvProvider.searchQuery}".',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => iptvProvider.clearSearch(),
                        child: const Text('Clear Search'),
                      ),
                    ],
                  );
                } else if (iptvProvider.selectedCategory != null) {
                  return Column(
                    children: [
                      Text(
                        'No channels in "${iptvProvider.selectedCategory!.name}" category.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => iptvProvider.selectCategory(null),
                        child: const Text('Show All Categories'),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Text(
                        'No channels available for this profile.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _refreshData,
                        child: const Text('Refresh'),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                return Column(
                  children: [
                    if (profileProvider.activeProfile != null) ...[
                      ListTile(
                        leading: const Icon(Icons.account_circle),
                        title: Text(profileProvider.activeProfile!.name),
                        subtitle: const Text('Active Profile'),
                        trailing: const Icon(Icons.check_circle, color: Colors.green),
                      ),
                      const Divider(),
                    ],
                    ListTile(
                      leading: const Icon(Icons.manage_accounts),
                      title: const Text('Manage Profiles'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _navigateToProfileManagement();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.refresh),
                      title: const Text('Refresh Data'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _refreshData();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: Navigate to settings screen
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _refreshData() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final iptvProvider = Provider.of<IPTVProvider>(context, listen: false);
    
    if (profileProvider.activeProfile != null) {
      await iptvProvider.refreshData(profileProvider.activeProfile!);
      
      if (mounted && iptvProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(iptvProvider.error!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToProfileManagement() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ProfileManagementScreen()),
    );
  }
}