import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/error/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/token_model.dart';
import '../../repositories/firestore_repository.dart';
import '../../widgets/error_dialog.dart';

class ScannerScreen extends StatefulWidget {
  final String? studentRollNumber;

  const ScannerScreen({
    super.key,
    this.studentRollNumber,
  });

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  final Set<String> _scannedQrs = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    final code = rawValue.trim();

    // Check if QR code was already scanned in this active session
    if (_scannedQrs.contains(code)) {
      _showResultDialog(
        isSuccess: false,
        title: 'QR Code Already Used',
        message: 'QR code already used.',
      );
      return;
    }

    // Student scanning counter QR code to purchase token
    if (widget.studentRollNumber != null) {
      final roll = widget.studentRollNumber!;
      if (code == 'PURCHASE_VEG_TOKEN' || code == 'PURCHASE_NONVEG_TOKEN') {
        final isVeg = code == 'PURCHASE_VEG_TOKEN';
        final selection = TokenSelection(wantsVeg: isVeg, wantsNonVeg: !isVeg, eggCount: 0);

        try {
          await FirestoreRepository.instance.purchaseTokens(roll, selection);
          if (!mounted) return;
          _showResultDialog(
            isSuccess: true,
            title: 'Token Purchased!',
            message: 'Successfully purchased 1 ${isVeg ? "Veg" : "Non-Veg"} Meal Token via QR Scan.',
          );
        } catch (e) {
          if (!mounted) return;
          _showResultDialog(
            isSuccess: false,
            title: 'Purchase Failed',
            message: e.toString().replaceAll('AppException: ', '').replaceAll('Exception: ', ''),
          );
        }
        return;
      }
    }

    try {
      await FirestoreRepository.instance.redeemToken(code);
      _scannedQrs.add(code);
      if (!mounted) return;

      final parts = code.trim().split(' ');
      String redeemedSummary = 'Token';
      if (parts.length >= 3) {
        final rawType = parts[1].toLowerCase();
        final count = int.tryParse(parts[2]) ?? 1;
        String typeName = 'Meal';
        if (rawType == 'eggs' || rawType == 'egg') {
          typeName = 'Egg';
        } else if (rawType == 'veg') {
          typeName = 'Veg';
        } else if (rawType == 'nonveg' || rawType == 'non-veg') {
          typeName = 'Non-Veg';
        }
        redeemedSummary = '$count $typeName token${count > 1 ? 's' : ''}';
      }

      _showResultDialog(
        isSuccess: true,
        title: 'Token Redeemed!',
        message: '$redeemedSummary redeemed successfully.',
      );
    } on TokenException {
      _scannedQrs.add(code);
      if (!mounted) return;
      _showResultDialog(
        isSuccess: false,
        title: 'QR Code Already Used',
        message: 'QR code already used.',
      );
    } on UserNotFoundException catch (e) {
      if (!mounted) return;
      _showResultDialog(
        isSuccess: false,
        title: 'Student Not Found',
        message: 'Roll number "${e.userId}" not found in system.',
      );
    } on InvalidQrDataException {
      if (!mounted) return;
      _showResultDialog(
        isSuccess: false,
        title: 'Invalid QR Format',
        message: 'The scanned QR code is not a valid PSG Mess token format.',
      );
    } catch (e) {
      if (!mounted) return;
      _showResultDialog(
        isSuccess: false,
        title: 'Scan Error',
        message: AppFeedback.sanitizeErrorMessage(e),
      );
    }
  }

  void _showResultDialog({
    required bool isSuccess,
    required String title,
    required String message,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: isSuccess ? AppColors.success : AppColors.error,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              // Reset processing to allow next scan immediately
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() => _isProcessing = false);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isSuccess ? AppColors.accent : AppColors.surface,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Scan Next'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Scan Mess Token QR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: Colors.white70),
            onPressed: () => _controller.toggleTorch(),
            tooltip: 'Toggle Flashlight',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Mobile Scanner
          MobileScanner(
            controller: _controller,
            onDetect: _handleBarcode,
          ),

          // Scanner Overlay Frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _isProcessing ? AppColors.accent : Colors.white70,
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          // Standard Loading Indicator while processing redemption
          if (_isProcessing)
            Center(
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 38,
                  height: 38,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
              ),
            ),

          // Instruction Text
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: !_isProcessing
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text(
                      'Align student QR code within the frame to redeem',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
