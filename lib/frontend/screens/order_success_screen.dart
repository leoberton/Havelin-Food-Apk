import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../managers/order_history_manager.dart';
import '../../managers/theme_manager.dart';
import 'order_tracking_screen.dart';

class OrderSuccessScreen extends StatefulWidget {
  final OrderModel order;

  const OrderSuccessScreen({super.key, required this.order});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _checkController;
  late final Animation<double> _checkScale;
  late final AnimationController _pulseController;
  Timer? _navigationTimer;
  int _secondsLeft = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _checkController.forward();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _secondsLeft > 1) {
        setState(() => _secondsLeft--);
      } else {
        timer.cancel();
      }
    });

    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _goToTracking();
      }
    });
  }

  void _goToTracking() {
    _navigationTimer?.cancel();
    _countdownTimer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OrderTrackingScreen(order: widget.order),
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _countdownTimer?.cancel();
    _checkController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.instance,
      builder: (context, themeMode, child) {
        final bg = ThemeManager.instance.bgColor(context);
        final cardBg = ThemeManager.instance.cardColor(context);
        final textColor = ThemeManager.instance.textColor(context);
        final subtextColor = ThemeManager.instance.subtextColor(context);
        final accent = ThemeManager.instance.accentColor(context);

        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _ConfettiPainter(pulseValue: _pulseController.value, accent: accent),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final glowSize = 150.0 + (_pulseController.value * 24.0);
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: glowSize,
                                height: glowSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: accent.withValues(alpha: 0.15),
                                ),
                              ),
                              ScaleTransition(
                                scale: _checkScale,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accent,
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withValues(alpha: 0.5),
                                        blurRadius: 30,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.black,
                                    size: 75,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 36),
                      Text(
                        'Order Placed Successfully',
                        style: GoogleFonts.baloo2(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order #${widget.order.orderId}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: accent,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your meal is being prepared by our kitchen team for express delivery.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: subtextColor,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: accent.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Estimated Time', style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
                                const SizedBox(height: 4),
                                Text(
                                  '20-25 Mins',
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                                ),
                              ],
                            ),
                            Container(width: 1, height: 30, color: subtextColor.withValues(alpha: 0.2)),
                            Column(
                              children: [
                                Text('Total Paid', style: GoogleFonts.poppins(fontSize: 11, color: subtextColor)),
                                const SizedBox(height: 4),
                                Text(
                                  '₹${widget.order.total.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: accent),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Redirecting to live tracking in $_secondsLeft sec...',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          color: subtextColor,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _goToTracking,
                          icon: const Icon(Icons.location_searching_rounded, color: Colors.black),
                          label: Text(
                            'Track Live Order',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double pulseValue;
  final Color accent;

  _ConfettiPainter({required this.pulseValue, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final colors = [accent, Colors.amber, Colors.pinkAccent, Colors.cyanAccent, Colors.orangeAccent];

    for (int i = 0; i < 35; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final y = (baseY + pulseValue * 15) % size.height;
      final particleSize = 3.0 + rng.nextDouble() * 5.0;
      final color = colors[i % colors.length];

      final paint = Paint()..color = color.withValues(alpha: 0.7);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}