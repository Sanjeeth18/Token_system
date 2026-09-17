import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/error/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_model.dart';
import '../../repositories/firestore_repository.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/error_dialog.dart';
import '../../widgets/loading_overlay.dart';

class CreateUserScreen extends StatefulWidget {
  final UserSession currentUser;

  const CreateUserScreen({
    super.key,
    required this.currentUser,
  });

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final _formKey = GlobalKey<FormState>();

  late UserRole _selectedRole;
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobController = TextEditingController();
  final _dojController = TextEditingController();

  String _selectedCourse = AppConstants.courses.first;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = UserRole.student;
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _dojController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1970),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              surface: AppColors.surfaceElevated,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    final id = _idController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final dob = _dobController.text.trim();
    final doj = _dojController.text.trim();

    // Validate prefix
    if (_selectedRole == UserRole.student && !id.startsWith(AppConstants.prefixStudent)) {
      AppFeedback.showSnackBar(context, 'Student roll number must start with 2', isError: true);
      return;
    }
    if (_selectedRole == UserRole.employee &&
        !id.toUpperCase().startsWith(AppConstants.prefixEmployee.toUpperCase())) {
      AppFeedback.showSnackBar(context, 'Staff ID must start with E', isError: true);
      return;
    }
    if (_selectedRole == UserRole.manager &&
        !id.toUpperCase().startsWith(AppConstants.prefixManager.toUpperCase())) {
      AppFeedback.showSnackBar(context, 'Manager ID must start with M', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = FirestoreRepository.instance;
      if (_selectedRole == UserRole.student) {
        await repo.createStudent(
          roll: id,
          name: name,
          course: _selectedCourse,
          dob: dob,
          doj: doj,
          password: password,
        );
      } else if (_selectedRole == UserRole.employee) {
        await repo.createEmployee(
          id: id,
          name: name,
          dob: dob,
          doj: doj,
          password: password,
        );
      } else if (_selectedRole == UserRole.manager) {
        await repo.createManager(
          id: id,
          name: name,
          password: password,
          currentUser: widget.currentUser,
        );
      }

      if (!mounted) return;
      AppFeedback.showSnackBar(
        context,
        '${_selectedRole.displayName} account created successfully!',
        isError: false,
      );
      Navigator.of(context).pop();
    } on UserAlreadyExistsException catch (e) {
      if (mounted) {
        AppFeedback.showSnackBar(context, 'Account with ID "${e.userId}" already exists.', isError: true);
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showSnackBar(context, 'Error creating account: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canCreateManager = widget.currentUser.role.isAdmin;

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Creating account...',
      child: AppScaffold(
        title: 'Create Account',
        showBackButton: true,
        userRole: widget.currentUser.role,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Role Selector Segmented Button
                const Text(
                  'Account Role',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRoleOption(UserRole.student, 'Student (2xxx)'),
                      const SizedBox(width: 8),
                      _buildRoleOption(UserRole.employee, 'Staff (Exxx)'),
                      if (canCreateManager) ...[
                        const SizedBox(width: 8),
                        _buildRoleOption(UserRole.manager, 'Manager (Mxxx)'),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Account Details Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      // ID / Roll No Field
                      AppTextField(
                        label: _selectedRole == UserRole.student
                            ? 'Student Roll Number'
                            : _selectedRole == UserRole.employee
                                ? 'Staff ID'
                                : 'Manager ID',
                        hint: _selectedRole == UserRole.student
                            ? 'e.g. 23XX01'
                            : _selectedRole == UserRole.employee
                                ? 'e.g. E101'
                                : 'e.g. M01',
                        controller: _idController,
                        prefixIcon: Icons.badge_outlined,
                        textCapitalization: TextCapitalization.characters,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'ID is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Full Name
                      AppTextField(
                        label: 'Full Name',
                        hint: 'Enter full name',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Name is required';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Course (Only for Student)
                      if (_selectedRole == UserRole.student) ...[
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
                              initialValue: _selectedCourse,
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
                                  child: Text(course),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedCourse = val);
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // DOB and DOJ (For Student and Employee)
                      if (_selectedRole != UserRole.manager) ...[
                        AppTextField(
                          label: 'Date of Birth (DOB)',
                          hint: 'DD-MM-YYYY',
                          controller: _dobController,
                          readOnly: true,
                          prefixIcon: Icons.cake_outlined,
                          suffixIcon: const Icon(Icons.calendar_today_rounded,
                              size: 18, color: AppColors.textMuted),
                          onTap: () => _pickDate(_dobController),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'DOB is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          label: 'Date of Joining (DOJ)',
                          hint: 'DD-MM-YYYY',
                          controller: _dojController,
                          readOnly: true,
                          prefixIcon: Icons.login_rounded,
                          suffixIcon: const Icon(Icons.calendar_today_rounded,
                              size: 18, color: AppColors.textMuted),
                          onTap: () => _pickDate(_dojController),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) return 'DOJ is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Password
                      AppTextField(
                        label: 'Temporary Password',
                        hint: 'Enter password',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: (val) {
                          if (val == null || val.trim().length < 4) {
                            return 'Password must be at least 4 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                AppPrimaryButton(
                  label: 'Create Account',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: _handleCreate,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption(UserRole role, String label) {
    final isSelected = _selectedRole == role;
    return InkWell(
      onTap: () => setState(() => _selectedRole = role),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
