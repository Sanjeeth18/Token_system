import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/error/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../repositories/firestore_repository.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;

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

    try {
      final updatedTokens =
          await FirestoreRepository.instance.redeemToken(rawValue.trim());
      if (!mounted) return;
      _showResultDialog(
        isSuccess: true,
        title: 'Token Redeemed!',
        message: 'Successfully redeemed:\n$rawValue\n\nRemaining: '
            'Veg: ${updatedTokens.veg}, Non-Veg: ${updatedTokens.nonVeg}, Eggs: ${updatedTokens.eggs}',
      );
    } on TokenException catch (e) {
      if (!mounted) return;
      _showResultDialog(
        isSuccess: false,
        title: 'Redemption Failed',
        message: e.message,
      );
    } on UserNotFoundException catch (e) {
      if (!mounted) return;
      _showResultDialog(
        isSuccess: false,
        title: 'Student Not Found',
        message: 'Roll number "${e.userId}" not found in database.',
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
        message: 'An unexpected error occurred: $e',
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
              // Reset processing to allow next scan
              Future.delayed(const Duration(milliseconds: 500), () {
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
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_rounded, color: Colors.white70),
            onPressed: () => _controller.switchCamera(),
            tooltip: 'Switch Camera',
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

          // Instruction Text
          Positioned(
            bottom: 48,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _isProcessing
                    ? 'Processing redemption...'
                    : 'Align student QR code within the frame to redeem',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _isProcessing ? AppColors.accentLight : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
