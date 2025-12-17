import 'package:flutter/material.dart';
import 'package:grammar_up/models/user_model.dart';
import 'package:grammar_up/screens/profile/edit_profile_screen.dart';
import 'package:grammar_up/core/services/profile_platform_service.dart';
import 'package:grammar_up/core/services/supabase_service.dart';

/// Example: Simple Profile Screen that integrates the Edit Profile feature
/// 
/// This demonstrates how to:
/// 1. Fetch user profile data
/// 2. Display profile information
/// 3. Navigate to edit profile screen
/// 4. Refresh data after editing
class ExampleProfileScreen extends StatefulWidget {
  const ExampleProfileScreen({super.key});

  @override
  State<ExampleProfileScreen> createState() => _ExampleProfileScreenState();
}

class _ExampleProfileScreenState extends State<ExampleProfileScreen> {
  final _profileService = ProfilePlatformService.instance;
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final profile = await _profileService.getProfile(userId);
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          initialProfile: _profile,
        ),
      ),
    );

    // If profile was updated, reload it
    if (result == true) {
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (_profile != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _navigateToEditProfile,
              tooltip: 'Edit Profile',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_profile == null) {
      return const Center(
        child: Text('No profile data'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey[300],
            backgroundImage: _profile!.avatarUrl != null
                ? NetworkImage(_profile!.avatarUrl!)
                : null,
            child: _profile!.avatarUrl == null
                ? const Icon(Icons.person, size: 60, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 24),

          // Full Name
          Text(
            _profile!.fullName ?? 'No name set',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),

          // Email
          Text(
            _profile!.email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),

          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Streak',
                  '${_profile!.learningStreak ?? 0}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Points',
                  '${_profile!.totalPoints ?? 0}',
                  Icons.stars,
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Info Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Information',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Divider(),
                  _buildInfoRow('Level', _profile!.level ?? 'Beginner'),
                  _buildInfoRow('Native Language',
                      _profile!.nativeLanguage ?? 'Vietnamese'),
                  if (_profile!.createdAt != null)
                    _buildInfoRow(
                      'Member Since',
                      _formatDate(_profile!.createdAt!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Edit Profile Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _navigateToEditProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[600]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Example: Using the profile service directly in any widget
class DirectServiceExample {
  final _profileService = ProfilePlatformService.instance;

  // Example 1: Get profile
  Future<UserProfile?> getProfile() async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return null;

      return await _profileService.getProfile(userId);
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Example 2: Update name and email
  Future<bool> updateBasicInfo(String name, String email) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;

      return await _profileService.updateProfile(
        userId: userId,
        fullName: name,
        email: email,
      );
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  // Example 3: Upload profile picture
  Future<String?> uploadProfilePicture(String imagePath) async {
    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) return null;

      return await _profileService.updateProfilePicture(
        userId: userId,
        filePath: imagePath,
      );
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
