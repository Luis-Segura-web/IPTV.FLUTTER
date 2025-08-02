import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../providers/profile_provider.dart';
import '../widgets/profile_card.dart';
import '../widgets/profile_form_dialog.dart';
import '../config/constants.dart';
import 'home_screen.dart';

class ProfileManagementScreen extends StatefulWidget {
  const ProfileManagementScreen({super.key});

  @override
  State<ProfileManagementScreen> createState() => _ProfileManagementScreenState();
}

class _ProfileManagementScreenState extends State<ProfileManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProfileProvider>(context, listen: false).loadProfiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IPTV Profiles'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (profileProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading profiles',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    profileProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      profileProvider.clearError();
                      profileProvider.loadProfiles();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: profileProvider.hasProfiles
                    ? _buildProfileList(profileProvider)
                    : _buildEmptyState(),
              ),
              _buildBottomActions(profileProvider),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProfileForm(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildProfileList(ProfileProvider profileProvider) {
    return RefreshIndicator(
      onRefresh: () => profileProvider.loadProfiles(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: profileProvider.profiles.length,
        itemBuilder: (context, index) {
          final profile = profileProvider.profiles[index];
          return ProfileCard(
            profile: profile,
            onTap: () => _selectProfile(profile),
            onEdit: () => _showProfileForm(context, profile: profile),
            onDelete: () => _deleteProfile(profile),
            onTest: () => _testConnection(profile),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.live_tv_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Profiles Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Create your first IPTV profile to get started streaming.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showProfileForm(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(ProfileProvider profileProvider) {
    if (!profileProvider.hasProfiles) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showClearAllDialog(profileProvider),
              child: const Text('Clear All'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: profileProvider.activeProfile != null
                  ? () => _navigateToHome()
                  : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileForm(BuildContext context, {Profile? profile}) {
    showDialog(
      context: context,
      builder: (context) => ProfileFormDialog(profile: profile),
    );
  }

  void _selectProfile(Profile profile) async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    final success = await profileProvider.setActiveProfile(profile);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile "${profile.name}" selected'),
          backgroundColor: Colors.green,
        ),
      );
      _navigateToHome();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(profileProvider.error ?? 'Failed to select profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteProfile(Profile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Are you sure you want to delete "${profile.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
              final success = await profileProvider.deleteProfile(profile.id);
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                        ? AppConstants.profileDeleted 
                        : profileProvider.error ?? 'Failed to delete profile'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _testConnection(Profile profile) async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    final success = await profileProvider.testConnection(profile);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
              ? AppConstants.connectionSuccessful 
              : profileProvider.error ?? 'Connection test failed'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showClearAllDialog(ProfileProvider profileProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Profiles'),
        content: const Text('Are you sure you want to delete all profiles? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await profileProvider.clearAllProfiles();
              
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All profiles cleared'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }
}