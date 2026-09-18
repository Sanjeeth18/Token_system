import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/firestore_repository.dart';
import '../../services/cloudinary_service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loading_overlay.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserSession session;

  const EditProfileScreen({
    super.key,
    required this.session,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late String _selectedDepartment;

  File? _pickedImage;
  String? _uploadedPhotoUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.session.name);
    _uploadedPhotoUrl = widget.session.photoUrl;

    if (widget.session.role == UserRole.student &&
        AppConstants.courses.contains(widget.session.department)) {
      _selectedDepartment = widget.session.department!;
    } else {
      _selectedDepartment = AppConstants.courses.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 90,
      );

      if (image != null) {
        CroppedFile? croppedFile;
        try {
          croppedFile = await ImageCropper().cropImage(
            sourcePath: image.path,
            aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Circular Profile Picture',
                toolbarColor: AppColors.surfaceElevated,
                toolbarWidgetColor: Colors.white,
                statusBarLight: false,
                activeControlsWidgetColor: AppColors.accent,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true,
                cropStyle: CropStyle.circle,
              ),
              IOSUiSettings(
                title: 'Crop Circular Profile Picture',
                cropStyle: CropStyle.circle,
                aspectRatioLockEnabled: true,
              ),
              WebUiSettings(
                context: context,
                presentStyle: WebPresentStyle.dialog,
              ),
            ],
          );
        } catch (cropErr) {
          debugPrint('ImageCropper note: $cropErr');
        }

        final finalPath = croppedFile != null ? croppedFile.path : image.path;
        setState(() {
          _pickedImage = File(finalPath);
        });
      }
    } catch (e) {
      AppFeedback.showSnackBar(
        context,
        'Error picking image: $e',
        isError: true,
      );
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? photoUrl = _uploadedPhotoUrl;

      // Upload to Cloudinary if new image selected
      if (_pickedImage != null) {
        try {
          photoUrl = await CloudinaryService.instance.uploadProfileImage(_pickedImage!);
        } catch (cloudinaryErr) {
          debugPrint('Cloudinary upload note: $cloudinaryErr');
          // Graceful fallback if Cloudinary credentials are not configured yet
        }
      }

      final newName = _nameController.text.trim();
      final newDept = widget.session.role == UserRole.student
          ? _selectedDepartment
          : widget.session.department;

      // Update Firestore
      await FirestoreRepository.instance.updateUserProfile(
        userId: widget.session.id,
        role: widget.session.role,
        name: newName,
        department: newDept,
        photoUrl: photoUrl,
      );

      // Update Riverpod Auth State
      ref.read(authProvider.notifier).updateProfileSession(
            name: newName,
            department: newDept,
            photoUrl: photoUrl,
          );

      if (!mounted) return;
      AppFeedback.showSnackBar(
        context,
        'Profile updated successfully!',
        isError: false,
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        AppFeedback.showSnackBar(
          context,
          'Failed to update profile: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Updating profile & Cloudinary image...',
      child: AppScaffold(
        title: 'Edit Profile',
        showBackButton: true,
        userRole: widget.session.role,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Picker Preview Section
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.accent, width: 3),
                                color: AppColors.surfaceElevated,
                              ),
                              child: ClipOval(
                                child: _pickedImage != null
                                    ? Image.file(_pickedImage!, fit: BoxFit.cover)
                                    : _uploadedPhotoUrl != null && _uploadedPhotoUrl!.isNotEmpty
                                        ? Image.network(
                                            _uploadedPhotoUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                                          )
                                        : _buildAvatarFallback(),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Tap photo to update via Cloudinary',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Edit Fields Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      // Full Name
                      AppTextField(
                        label: 'Full Name',
                        hint: 'Enter your name',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Name cannot be empty';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Department for Student
                      if (widget.session.role == UserRole.student) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Department / Course',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedDepartment,
                              isExpanded: true,
                              dropdownColor: AppColors.surfaceElevated,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.school_outlined,
                                    size: 20, color: AppColors.textMuted),
                              ),
                              items: AppConstants.courses.map((course) {
                                return DropdownMenuItem(
                                  value: course,
                                  child: Text(
                                    course,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() => _selectedDepartment = val);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                AppPrimaryButton(
                  label: 'Save Changes',
                  icon: Icons.check_circle_rounded,
                  onPressed: _handleSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      color: AppColors.surfaceElevated,
      child: Center(
        child: Text(
          widget.session.name.isNotEmpty ? widget.session.name[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: AppColors.accent,
          ),
        ),
      ),
    );
  }
}
