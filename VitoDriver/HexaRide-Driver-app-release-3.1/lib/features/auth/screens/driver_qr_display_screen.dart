import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/util/app_constants.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';

class DriverQrDisplayScreen extends StatefulWidget {
  const DriverQrDisplayScreen({super.key});

  @override
  State<DriverQrDisplayScreen> createState() => _DriverQrDisplayScreenState();
}

class _DriverQrDisplayScreenState extends State<DriverQrDisplayScreen> {
  String? _qrData;
  DateTime? _expiresAt;
  bool _isLoading = false;
  Timer? _countdownTimer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _generateToken();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _generateToken() async {
    setState(() => _isLoading = true);
    try {
      final response = await Get.find<ApiClient>().postData(
        AppConstants.qrTokenGenerate,
        {'role': 'customer'},
      );
      if (response.statusCode == 200) {
        final token = response.body['data']['token'] as String;
        final expiresAt = DateTime.parse(response.body['data']['expires_at']);
        setState(() {
          _qrData = token;
          _expiresAt = expiresAt;
          _secondsRemaining = expiresAt.difference(DateTime.now()).inSeconds;
        });
        _startCountdown();
      }
    } catch (_) {
      // handled by empty state
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _secondsRemaining = _expiresAt != null
            ? _expiresAt!.difference(DateTime.now()).inSeconds.clamp(0, 9999)
            : 0;
      });
      if (_secondsRemaining <= 0) timer.cancel();
    });
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('share_qr_code'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _generateToken,
          ),
        ],
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: Theme.of(context).primaryColor)
            : _qrData == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('failed_to_generate_qr'.tr),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _generateToken,
                        child: Text('retry'.tr),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'invite_customer'.tr,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12)],
                          ),
                          padding: const EdgeInsets.all(16),
                          child: QrImageView(
                            data: _qrData!,
                            version: QrVersions.auto,
                            size: 240,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.timer_outlined, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '${'valid_for'.tr}: ${_formatDuration(_secondsRemaining)}',
                              style: TextStyle(
                                fontSize: 16,
                                color: _secondsRemaining < 60 ? Colors.red : null,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}
