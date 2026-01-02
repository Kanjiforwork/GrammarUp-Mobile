import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/providers/settings_provider.dart';
import '../../core/services/sound_service.dart';
import '../../models/user_model.dart';
import '../../core/services/profile_platform_service.dart';
import '../../core/services/supabase_service.dart';
import '../../widgets/common/buttons.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile? initialProfile;

  const EditProfileScreen({
    super.key,
    this.initialProfile,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _profileService = ProfilePlatformService.instance;
  final _imagePicker = ImagePicker();
  final _soundService = SoundService();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _avatarUrl;
  File? _selectedImage;
  UserProfile? _currentProfile;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _playSound() {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    _soundService.setSoundEnabled(settingsProvider.soundEffects);
    _soundService.playClick();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      UserProfile profile;
      if (widget.initialProfile != null) {
        profile = widget.initialProfile!;
      } else {
        try {
          profile = await _profileService.getProfile(userId);
        } catch (e) {
          debugPrint(
              'Platform service failed, fetching directly from Supabase: $e');
          final response = await SupabaseService.client
              .from('users')
              .select()
              .eq('id', userId)
              .single();
          profile = UserProfile.fromJson(response);
        }
      }

      setState(() {
        _currentProfile = profile;
        _fullNameController.text = profile.fullName ?? '';
        _emailController.text = profile.email;
        _avatarUrl = profile.avatarUrl;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load profile: ${e.toString()}';
      });
      _showError('Failed to load profile');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Failed to pick image');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError('Failed to take photo');
    }
  }

  void _showImageSourceDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    _playSound();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                color: isDark ? AppColors.darkBorder : AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Choose Image Source',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
              ),
            ),
            const SizedBox(height: 20),
            _buildImageSourceOption(
              icon: Icons.photo_library_rounded,
              title: 'Gallery',
              subtitle: 'Choose from your photos',
              color: primaryColor,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            const SizedBox(height: 12),
            _buildImageSourceOption(
              icon: Icons.camera_alt_rounded,
              title: 'Camera',
              subtitle: 'Take a new photo',
              color: AppColors.success,
              isDark: isDark,
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.gray900,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? AppColors.darkTextTertiary : AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _playSound();

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final userId = SupabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      String? newAvatarUrl = _avatarUrl;

      if (_selectedImage != null) {
        try {
          newAvatarUrl = await _profileService.uploadProfilePicture(
            userId: userId,
            filePath: _selectedImage!.path,
          );
        } catch (e) {
          debugPrint('Platform upload failed, using Supabase directly: $e');
          final fileName =
              '${userId}_${DateTime.now().millisecondsSinceEpoch}.${_selectedImage!.path.split('.').last}';
          final bytes = await _selectedImage!.readAsBytes();

          await SupabaseService.client.storage
              .from('user-avatars')
              .uploadBinary('avatars/$fileName', bytes);

          newAvatarUrl = SupabaseService.client.storage
              .from('user-avatars')
              .getPublicUrl('avatars/$fileName');
        }
      }

      bool success;
      try {
        success = await _profileService.updateProfile(
          userId: userId,
          fullName: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          avatarUrl: newAvatarUrl,
        );
      } catch (e) {
        debugPrint('Platform update failed, using Supabase directly: $e');
        await SupabaseService.client.from('users').update({
          'full_name': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'avatar_url': newAvatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        success = true;
      }

      if (success) {
        final settingsProvider =
            Provider.of<SettingsProvider>(context, listen: false);
        _soundService.setSoundEnabled(settingsProvider.soundEffects);
        _soundService.playSuccess();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Profile updated successfully!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Failed to update profile');
      }
    } on PlatformException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Platform error occurred';
      });
      _showError(e.message ?? 'Platform error occurred');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      _showError('Failed to save profile');
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.gray50,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.nunito(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
                strokeWidth: 3,
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Image
                    _buildProfileImage(context),
                    const SizedBox(height: 32),

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withAlpha(26),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.error.withAlpha(77)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.error),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: GoogleFonts.nunito(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Form fields
                    _buildTextField(
                      controller: _fullNameController,
                      label: 'Full Name',
                      icon: Icons.person_outline_rounded,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      isDark: isDark,
                      primaryColor: primaryColor,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Stats section
                    if (_currentProfile != null) ...[
                      Text(
                        'STATS',
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.gray500,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              isDark ? AppColors.darkSurface : AppColors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.gray200,
                          ),
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.local_fire_department_rounded,
                              label: 'Learning Streak',
                              value:
                                  '${_currentProfile!.learningStreak ?? 0} days',
                              color: AppColors.warning,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.star_rounded,
                              label: 'Total Points',
                              value: '${_currentProfile!.totalPoints ?? 0}',
                              color: primaryColor,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.school_rounded,
                              label: 'Level',
                              value: _currentProfile!.level ?? 'Beginner',
                              color: AppColors.success,
                              isDark: isDark,
                            ),
                            const SizedBox(height: 16),
                            _buildInfoRow(
                              icon: Icons.language_rounded,
                              label: 'Native Language',
                              value:
                                  _currentProfile!.nativeLanguage ?? 'Vietnamese',
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.gray600,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Buttons
                    PrimaryButton(
                      text: _isSaving ? 'Saving...' : 'Save Changes',
                      icon: Icons.check_rounded,
                      isLoading: _isSaving,
                      onPressed: _isSaving ? null : _saveProfile,
                    ),
                    const SizedBox(height: 12),
                    OutlinedPrimaryButton(
                      text: 'Cancel',
                      onPressed: _isSaving ? null : () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.darkTeal : AppColors.primary;

    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_avatarUrl!);
    }

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withAlpha(26),
              border: Border.all(
                color: primaryColor,
                width: 3,
              ),
              image: imageProvider != null
                  ? DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withAlpha(51),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: imageProvider == null
                ? Icon(
                    Icons.person_rounded,
                    size: 56,
                    color: primaryColor,
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImageSourceDialog,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? AppColors.darkBackground : AppColors.white,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withAlpha(128),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color primaryColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.gray200,
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.nunito(
          fontSize: 16,
          color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunito(
            color: isDark ? AppColors.darkTextSecondary : AppColors.gray600,
          ),
          prefixIcon: Icon(icon, color: primaryColor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: GoogleFonts.nunito(
            color: AppColors.error,
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(26),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color:
                      isDark ? AppColors.darkTextTertiary : AppColors.gray500,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
