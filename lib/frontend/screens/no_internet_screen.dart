import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../managers/theme_manager.dart';
import '../../managers/toast_manager.dart';

class OnlineGuardWidget extends StatefulWidget {
  final Widget child;

  const OnlineGuardWidget({super.key, required this.child});

  @override
  State<OnlineGuardWidget> createState() => _OnlineGuardWidgetState();
}

class _OnlineGuardWidgetState extends State<OnlineGuardWidget> {
  bool _isOnline = true;
  bool _isChecking = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
    // Periodically check connectivity every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkInternetConnection();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(
        const Duration(seconds: 3),
      );
      final online = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      if (mounted && _isOnline != online) {
        setState(() => _isOnline = online);
      }
    } catch (_) {
      if (mounted && _isOnline != false) {
        setState(() => _isOnline = false);
      }
    }
  }

  Future<void> _retryConnection() async {
    setState(() => _isChecking = true);
    await _checkInternetConnection();
    if (mounted) {
      setState(() => _isChecking = false);
      if (_isOnline) {
        ToastManager.instance.show(
          context,
          'Connected! Synchronizing live updates... ⚡',
          icon: Icons.wifi_rounded,
        );
      } else {
        ToastManager.instance.show(
          context,
          'Still offline. Please enable Wi-Fi or Mobile Data!',
          icon: Icons.wifi_off_rounded,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnline) {
      final bg = ThemeManager.instance.bgColor(context);
      final textColor = ThemeManager.instance.textColor(context);
      final subtextColor = ThemeManager.instance.subtextColor(context);
      final accent = ThemeManager.instance.accentColor(context);

      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(),

                // Animated Wifi Off Icon Badge
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3), width: 2),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.redAccent,
                    size: 54,
                  ),
                ),

                const SizedBox(height: 28),

                Text(
                  'No Internet Connection 📡',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Havelin Food is a live e-commerce platform. Please turn on Mobile Data or Wi-Fi to load live prices, discounts, and place orders.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    color: subtextColor,
                    height: 1.45,
                  ),
                ),

                const Spacer(),

                // Retry Connection Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isChecking ? null : _retryConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 4,
                    ),
                    child: _isChecking
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                'Retry Connection',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    }

    return widget.child;
  }
}
