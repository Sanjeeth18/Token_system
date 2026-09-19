import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _emailController = TextEditingController();
  final _passwordController =
      TextEditingController(text: AppConstants.defaultPassword);
  final _dobController = TextEditingController();
  final _dojController = TextEditingController();

  String _selectedCourse = AppConstants.courses.first;
  bool _isLoading = false;
  bool _isGeneratingId = false;

  @override
  void initState() {
    super.initState();
    _selectedRole = UserRole.student;
    _idController.clear(); 
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    _dojController.dispose();
    super.dispose();
  }

  Future<void> _generateNextId() async {
    setState(() => _isGeneratingId = true);
    try {
      final generated =
          await FirestoreRepository.instance.generateNextUserId(_selectedRole);
      if (mounted) {
        setState(() {
          _idController.text = generated;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isGeneratingId = false);
    }
  }

  void _onRoleChanged(UserRole role) {
    if (_selectedRole == role) return;
    setState(() {
      _selectedRole = role;
    });
    if (role == UserRole.student) {
      _idController.clear();
    } else {
      _generateNextId();
    }
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
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim().isEmpty
        ? AppConstants.defaultPassword
        : _passwordController.text.trim();
    final dob = _dobController.text.trim();
    final doj = _dojController.text.trim();

    setState(() => _isLoading = true);

    try {
      final repo = FirestoreRepository.instance;
      if (_selectedRole == UserRole.student) {
        await repo.createStudent(
          roll: id,
          name: name,
          course: _selectedCourse,
          dob: dob.isNotEmpty ? dob : '01-01-2000',
          doj: doj.isNotEmpty
              ? doj
              : DateFormat('dd-MM-yyyy').format(DateTime.now()),
          customEmail: email.isNotEmpty ? email : null,
          password: password,
        );
      } else if (_selectedRole == UserRole.employee) {
        await repo.createEmployee(
          id: id,
          name: name,
          dob: dob.isNotEmpty ? dob : '01-01-1990',
          doj: doj.isNotEmpty
              ? doj
              : DateFormat('dd-MM-yyyy').format(DateTime.now()),
          customEmail: email.isNotEmpty ? email : null,
          password: password,
        );
      } else if (_selectedRole == UserRole.manager) {
        await repo.createManager(
          id: id,
          name: name,
          customEmail: email.isNotEmpty ? email : null,
          password: password,
          currentUser: widget.currentUser,
        );
      } else if (_selectedRole == UserRole.admin) {
        await repo.createAdmin(
          id: id,
          name: name,
          customEmail: email.isNotEmpty ? email : null,
          password: password,
          currentUser: widget.currentUser,
        );
      }

      if (!mounted) return;

      final usedEmail =
          email.isNotEmpty ? email : '${id.toLowerCase()}@psgtoken.com';
      await _showSuccessPopup(
        id: id,
        name: name,
        role: _selectedRole,
        email: usedEmail,
        password: password,
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } on UserAlreadyExistsException catch (e) {
      if (mounted) {
        AppFeedback.showSnackBar(
            context, 'Account with ID "${e.userId}" already exists.',
            isError: true);
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showSnackBar(context, 'Error creating account: $e',
            isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showSuccessPopup({
    required String id,
    required String name,
    required UserRole role,
    required String email,
    required String password,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.cardBorder),
          ),
          contentPadding: const EdgeInsets.all(24),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon Circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.vegGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppColors.vegGreen.withValues(alpha: 0.4),
                      width: 2),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.vegGreen,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Account Provisioned!',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Member details created successfully',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Credentials Receipt Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    _buildReceiptRow('Member Name', name, highlight: true),
                    const Divider(color: AppColors.cardBorder, height: 20),
                    _buildReceiptRow('Role', role.displayName),
                    const Divider(color: AppColors.cardBorder, height: 20),
                    _buildReceiptRow(role.idLabel, id, accent: true),
                    const Divider(color: AppColors.cardBorder, height: 20),
                    _buildReceiptRow('Email', email),
                    const Divider(color: AppColors.cardBorder, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Initial Password',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 12),
                        ),
                        SelectableText(
                          password,
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                            text:
                                'Email: $email\nPassword: $password\nID: $id'));
                        AppFeedback.showSnackBar(
                            context, 'Credentials copied to clipboard!',
                            isError: false);
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accentLight,
                        side: const BorderSide(color: AppColors.cardBorder),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Done',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReceiptRow(String label, String value,
      {bool highlight = false, bool accent = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: accent
                  ? AppColors.accentLight
                  : (highlight
                      ? AppColors.textPrimary
                      : AppColors.textSecondary),
              fontWeight:
                  highlight || accent ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCreateAdmin = widget.currentUser.role.isAdmin;

    return LoadingOverlay(
      isLoading: _isLoading,
      message: 'Creating account...',
      child: AppScaffold(
        title: 'Add Member',
        showBackButton: true,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Banner Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.surfaceElevated,
                        AppColors.accent.withValues(alpha: 0.15),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_add_alt_1_rounded,
                          color: AppColors.accentLight,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Member Provisioning',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Register new students, staff, manager, or admin accounts',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Role Selection Title & Cards
                const Text(
                  'SELECT ACCOUNT ROLE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: AppColors.accentLight,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildRoleCard(
                        role: UserRole.student,
                        title: 'Student',
                        icon: Icons.school_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildRoleCard(
                        role: UserRole.employee,
                        title: 'Staff',
                        icon: Icons.badge_rounded,
                      ),
                      if (canCreateAdmin) ...[
                        const SizedBox(width: 8),
                        _buildRoleCard(
                          role: UserRole.manager,
                          title: 'Manager',
                          icon: Icons.shield_rounded,
                        ),
                        const SizedBox(width: 8),
                        _buildRoleCard(
                          role: UserRole.admin,
                          title: 'Admin',
                          icon: Icons.admin_panel_settings_rounded,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Section 1: Account Identity
                _buildSectionHeader(
                    'ACCOUNT IDENTITY', Icons.fingerprint_rounded),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      if (_selectedRole == UserRole.student) ...[
                        AppTextField(
                          label: 'Roll Number / Student ID',
                          hint: 'e.g. 21T101',
                          controller: _idController,
                          readOnly: false,
                          prefixIcon: Icons.badge_outlined,
                          textCapitalization: TextCapitalization.characters,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Roll Number is required';
                            }
                            return null;
                          },
                        ),
                      ] else ...[
                        AppTextField(
                          label: 'User ID',
                          hint: 'Generating ID...',
                          controller: _idController,
                          readOnly: true,
                          prefixIcon: Icons.badge_outlined,
                          suffixIcon: _isGeneratingId
                              ? const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.accent),
                                  ),
                                )
                              : null,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'User ID is required';
                            }
                            return null;
                          },
                        ),
                      ],
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Full Name',
                        hint: 'Enter member name',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline_rounded,
                        textCapitalization: TextCapitalization.words,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        label: 'Email Address',
                        hint: 'e.g. user@domain.com',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textCapitalization: TextCapitalization.none,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form Section 2: Department & Schedule (For non-managers or students)
                if (_selectedRole == UserRole.student ||
                    _selectedRole == UserRole.employee) ...[
                  _buildSectionHeader(
                      'ACADEMICS & TIMELINE', Icons.domain_rounded),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_selectedRole == UserRole.student) ...[
                          const Text(
                            'Department / Course',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCourse,
                            isExpanded: true,
                            dropdownColor: AppColors.surfaceElevated,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surface,
                              prefixIcon: const Icon(Icons.school_outlined,
                                  size: 20, color: AppColors.accentLight),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.cardBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: AppColors.cardBorder),
                              ),
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
                                setState(() => _selectedCourse = val);
                              }
                            },
                          ),
                          const SizedBox(height: 14),
                        ],
                        AppTextField(
                          label: 'Date of Birth (DOB)',
                          hint: 'DD-MM-YYYY',
                          controller: _dobController,
                          readOnly: true,
                          prefixIcon: Icons.cake_outlined,
                          suffixIcon: const Icon(Icons.calendar_today_rounded,
                              size: 18, color: AppColors.accentLight),
                          onTap: () => _pickDate(_dobController),
                        ),
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Date of Joining (DOJ)',
                          hint: 'DD-MM-YYYY',
                          controller: _dojController,
                          readOnly: true,
                          prefixIcon: Icons.event_available_outlined,
                          suffixIcon: const Icon(Icons.calendar_today_rounded,
                              size: 18, color: AppColors.accentLight),
                          onTap: () => _pickDate(_dojController),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Form Section 3: Credentials Setup
                _buildSectionHeader(
                    'DEFAULT SECURITY CREDENTIALS', Icons.lock_clock_outlined),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: AppTextField(
                    label: 'Initial Default Password',
                    controller: _passwordController,
                    readOnly: true,
                    prefixIcon: Icons.key_rounded,
                    suffixIcon: const Icon(Icons.verified_user_outlined,
                        size: 18, color: AppColors.vegGreen),
                  ),
                ),

                const SizedBox(height: 28),
                AppPrimaryButton(
                  label: 'Create Account',
                  icon: Icons.person_add_alt_1_rounded,
                  onPressed: _handleCreate,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.accentLight),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: AppColors.accentLight,
          ),
        ),
      ],
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    String subtitle = '', 
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => _onRoleChanged(role),
      child: AnimatedContainer(
        width :80,
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.15)
              : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? AppColors.accentLight : AppColors.textMuted,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            // Only render the subtitle (and its spacing) when there is one
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color:
                      isSelected ? AppColors.accentLight : AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


}
