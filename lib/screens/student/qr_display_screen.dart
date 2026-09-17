import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_scaffold.dart';

enum TokenType { veg, nonVeg, eggs }

class QrDisplayScreen extends StatefulWidget {
  final String rollNumber;
  final TokenType tokenType;
  final int availableCount;

  const QrDisplayScreen({
    super.key,
    required this.rollNumber,
    required this.tokenType,
    required this.availableCount,
  });

  @override
  State<QrDisplayScreen> createState() => _QrDisplayScreenState();
}

class _QrDisplayScreenState extends State<QrDisplayScreen> {
  int _selectedCount = 1;
  bool _generated = false;

  @override
  void initState() {
    super.initState();
    // For single meal tokens, generate automatically
    if (widget.tokenType != TokenType.eggs) {
      _generated = true;
      _selectedCount = 1;
    } else {
      _selectedCount = 1;
      _generated = false;
    }
  }

  String get _typeName {
    return switch (widget.tokenType) {
      TokenType.veg => 'Veg',
      TokenType.nonVeg => 'Non-Veg',
      TokenType.eggs => 'Eggs',
    };
  }

  Color get _typeColor {
    return switch (widget.tokenType) {
      TokenType.veg => AppColors.vegGreen,
      TokenType.nonVeg => AppColors.nonVegRed,
      TokenType.eggs => AppColors.eggOrange,
    };
  }

  String get _qrPayload {
    return '${widget.rollNumber} $_typeName $_selectedCount';
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '$_typeName Token',
      showBackButton: true,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _typeColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.tokenType == TokenType.veg
                          ? Icons.eco_rounded
                          : widget.tokenType == TokenType.nonVeg
                              ? Icons.restaurant_rounded
                              : Icons.egg_rounded,
                      color: _typeColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.rollNumber} • $_typeName',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _typeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Present this QR at the mess counter',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Stepper for Eggs if applicable
              if (widget.tokenType == TokenType.eggs && !_generated) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Select Egg Quantity to Redeem',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _selectedCount > 1
                                ? () => setState(() => _selectedCount--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppColors.accent, size: 28),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Text(
                              '$_selectedCount',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _selectedCount < widget.availableCount
                                ? () => setState(() => _selectedCount++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline,
                                color: AppColors.accent, size: 28),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Available eggs: ${widget.availableCount}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AppPrimaryButton(
                        label: 'Generate QR',
                        icon: Icons.qr_code_rounded,
                        onPressed: () => setState(() => _generated = true),
                      ),
                    ],
                  ),
                ),
              ],

              // QR Code Card
              if (_generated) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: _typeColor.withValues(alpha: 0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      QrImageView(
                        data: _qrPayload,
                        version: QrVersions.auto,
                        size: 260,
                        backgroundColor: Colors.white,
                        gapless: false,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _qrPayload,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (widget.tokenType == TokenType.eggs) ...[
                  AppOutlineButton(
                    label: 'Change Quantity',
                    icon: Icons.refresh_rounded,
                    onPressed: () => setState(() => _generated = false),
                  ),
                  const SizedBox(height: 12),
                ],
              ],

              const SizedBox(height: 12),
              AppOutlineButton(
                label: 'Close',
                color: AppColors.textSecondary,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
