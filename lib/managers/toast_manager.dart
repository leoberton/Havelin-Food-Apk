import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToastManager {
  static final ToastManager instance = ToastManager._internal();
  ToastManager._internal();

  OverlayEntry? _overlayEntry;

  void show(BuildContext context, String message, {IconData icon = Icons.shopping_cart_rounded}) {
    _overlayEntry?.remove();
    _overlayEntry = null;

    final overlayState = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => _SlideToastWidget(
        message: message,
        icon: icon,
        onDismiss: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    overlayState.insert(_overlayEntry!);
  }
}

class _SlideToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final VoidCallback onDismiss;

  const _SlideToastWidget({
    required this.message,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_SlideToastWidget> createState() => _SlideToastWidgetState();
}

class _SlideToastWidgetState extends State<_SlideToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
    );

    // Smooth Spring Bottom-to-Top Slide Animation
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    // Auto-dismiss after 2 seconds
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 85,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF3DEBB0), // Bright Mint Background
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3DEBB0).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: const Color(0xFF3DEBB0),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black, // Pure Bold Black Text
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
