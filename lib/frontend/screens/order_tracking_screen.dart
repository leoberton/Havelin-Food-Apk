import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../backend/firebase_manager.dart';
import '../../backend/live_driver_gps_service.dart';
import '../../backend/notification_manager.dart';
import '../../managers/order_history_manager.dart';
import '../../managers/theme_manager.dart';
import '../../managers/toast_manager.dart';
import 'order_delivered_screen.dart';

class OrderTrackingScreen extends StatefulWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with TickerProviderStateMixin {
  late int _secondsRemaining;
  Timer? _timer;
  late AnimationController _pulseController;
  late AnimationController _driverMoveController;
  late OrderStatus _currentStatus;
  bool _isSatelliteMode = false;
  bool _useGoogleMapEngine = false;
  double _zoomLevel = 1.0;

  final List<String> _cancelReasons = const [
    'Ordered by mistake',
    'Delivery time taking too long',
    'Wrong delivery address',
    'Need to change food items',
    'Changed my mind',
  ];

  int _selectedReasonIndex = 0;
  StreamSubscription<String?>? _cloudStatusSubscription;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.order.status;
    _secondsRemaining = 18 * 60;
    _startTimer();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _driverMoveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Start Live Driver GPS Simulation to Cloud Firestore
    LiveDriverGpsService.instance.startDriverGpsSimulation(widget.order.orderId);

    // Stream live order status from Cloud Firestore
    _cloudStatusSubscription = FirebaseManager.instance
        .listenToOrderStatus(widget.order.orderId)
        .listen((statusStr) {
      if (statusStr != null && mounted) {
        final parsed = _parseStatusString(statusStr);
        if (parsed != null && parsed != _currentStatus) {
          setState(() {
            _currentStatus = parsed;
          });
          NotificationManager.instance.showNotification(
            title: 'Havelin Order Status Update 🔔',
            body: 'Order #${widget.order.orderId} is now ${statusStr.toUpperCase()}!',
          );
          ToastManager.instance.show(
            context,
            '⚡ Live Cloud Order Update: ${statusStr.toUpperCase()}!',
            icon: Icons.electric_bolt_rounded,
          );
        }
      }
    });
  }

  OrderStatus? _parseStatusString(String str) {
    switch (str.toLowerCase()) {
      case 'placed':
        return OrderStatus.placed;
      case 'cooking':
        return OrderStatus.cooking;
      case 'outfordelivery':
      case 'out_for_delivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return null;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0 && _currentStatus != OrderStatus.cancelled) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    LiveDriverGpsService.instance.stopSimulation(widget.order.orderId);
    _cloudStatusSubscription?.cancel();
    _timer?.cancel();
    _pulseController.dispose();
    _driverMoveController.dispose();
    super.dispose();
  }

  String get _formattedTime {
    final mins = _secondsRemaining ~/ 60;
    final secs = _secondsRemaining % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showCancelOrderModal(
      BuildContext context, Color cardBg, Color textColor, Color subtextColor, Color accent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: subtextColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cancel Order',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        'Please select a reason for cancellation',
                        style: GoogleFonts.poppins(fontSize: 12, color: subtextColor),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...List.generate(_cancelReasons.length, (index) {
                final reason = _cancelReasons[index];
                final isSelected = _selectedReasonIndex == index;
                return GestureDetector(
                  onTap: () {
                    setModalState(() => _selectedReasonIndex = index);
                    setState(() {});
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.redAccent.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.redAccent : subtextColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                          color: isSelected ? Colors.redAccent : subtextColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reason,
                            style: GoogleFonts.poppins(
                              fontSize: 13.5,
                              color: textColor,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text('Keep Order', style: GoogleFonts.poppins(color: textColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        OrderHistoryManager.instance.cancelOrder(widget.order.orderId);
                        FirebaseManager.instance.updateOrderStatusInCloud(widget.order.orderId, 'cancelled');
                        setState(() {
                          _currentStatus = OrderStatus.cancelled;
                        });
                        ToastManager.instance.show(
                          context,
                          'Order #${widget.order.orderId} cancelled',
                          icon: Icons.cancel_outlined,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: Text(
                        'Confirm Cancel',
                        style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCancelled = _currentStatus == OrderStatus.cancelled;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.instance,
      builder: (context, themeMode, child) {
        final bg = ThemeManager.instance.bgColor(context);
        final cardBg = ThemeManager.instance.cardColor(context);
        final textColor = ThemeManager.instance.textColor(context);
        final subtextColor = ThemeManager.instance.subtextColor(context);
        final hairline = ThemeManager.instance.hairlineColor(context);
        final accent = ThemeManager.instance.accentColor(context);
        final isDark = ThemeManager.instance.isDarkMode(context);

        return Scaffold(
          backgroundColor: bg,
          body: SafeArea(
            child: Column(
              children: [
                // Top Header Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: hairline,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.arrow_back_ios_new, color: textColor, size: 18),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 5,
                        height: 26,
                        decoration: BoxDecoration(
                          color: isCancelled ? Colors.redAccent : accent,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Track Order #${widget.order.orderId}',
                        style: GoogleFonts.baloo2(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Realistic Google Maps Live View Container
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: isCancelled
                            ? Colors.redAccent.withValues(alpha: 0.4)
                            : accent.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isCancelled ? Colors.redAccent : accent).withValues(alpha: 0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Stack(
                        children: [
                          // Map Rendering Engine (Google Maps SDK or 3D Vector Live Painter)
                          Positioned.fill(
                            child: _useGoogleMapEngine
                                ? StreamBuilder<DriverGpsModel?>(
                                    stream: LiveDriverGpsService.instance.streamDriverGps(widget.order.orderId),
                                    builder: (context, gpsSnapshot) {
                                      final gpsData = gpsSnapshot.data ?? DriverGpsModel(
                                        driverName: 'Rider Rahul 🛵',
                                        driverPhone: '+91 98765 43210',
                                        rating: 4.9,
                                        vehicleNumber: 'TS 09 EV 4821',
                                        latitude: 17.4385,
                                        longitude: 78.3972,
                                        progress: _driverMoveController.value,
                                        etaMinutes: 14,
                                        statusText: 'Out for delivery',
                                      );

                                      final LatLng kitchenPos = const LatLng(17.4325, 78.4072);
                                      final LatLng customerPos = const LatLng(17.4485, 78.3802);
                                      final LatLng driverPos = LatLng(gpsData.latitude, gpsData.longitude);

                                      final Set<Marker> markers = {
                                        Marker(
                                          markerId: const MarkerId('kitchen'),
                                          position: kitchenPos,
                                          infoWindow: const InfoWindow(title: 'Executive Kitchen 👨‍🍳'),
                                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                                        ),
                                        Marker(
                                          markerId: const MarkerId('rider'),
                                          position: driverPos,
                                          infoWindow: InfoWindow(title: gpsData.driverName, snippet: gpsData.statusText),
                                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                                        ),
                                        Marker(
                                          markerId: const MarkerId('customer'),
                                          position: customerPos,
                                          infoWindow: const InfoWindow(title: 'Delivery Address 📍'),
                                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                                        ),
                                      };

                                      final Set<Polyline> polylines = {
                                        Polyline(
                                          polylineId: const PolylineId('delivery_route'),
                                          points: [kitchenPos, driverPos, customerPos],
                                          color: isCancelled ? Colors.redAccent : accent,
                                          width: 4,
                                        ),
                                      };

                                      return GoogleMap(
                                        initialCameraPosition: CameraPosition(
                                          target: driverPos,
                                          zoom: 14.5 * _zoomLevel,
                                        ),
                                        mapType: _isSatelliteMode ? MapType.hybrid : MapType.normal,
                                        markers: markers,
                                        polylines: polylines,
                                        zoomControlsEnabled: false,
                                        myLocationButtonEnabled: false,
                                      );
                                    },
                                  )
                                : AnimatedBuilder(
                                    animation: _driverMoveController,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        painter: _GoogleMapPainter(
                                          pulseValue: _pulseController.value,
                                          driverProgress: _driverMoveController.value,
                                          isDark: isDark,
                                          accent: isCancelled ? Colors.redAccent : accent,
                                          isSatellite: _isSatelliteMode,
                                          zoomLevel: _zoomLevel,
                                        ),
                                      );
                                    },
                                  ),
                          ),

                          // Google Maps Top Floating Header Badge (Live Traffic + ETA)
                          Positioned(
                            top: 14,
                            left: 14,
                            right: 14,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // ETA Glassmorphic Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: (isDark ? const Color(0xFF181A20) : Colors.white)
                                        .withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(22),
                                    border: Border.all(
                                      color: (isCancelled ? Colors.redAccent : accent)
                                          .withValues(alpha: 0.5),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isCancelled ? Icons.cancel : Icons.timer,
                                        color: isCancelled ? Colors.redAccent : accent,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isCancelled ? 'Cancelled' : 'ETA: $_formattedTime',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: isCancelled ? Colors.redAccent : textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Live Traffic Status Indicator
                                if (!isCancelled)
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.75),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: const Color(0xFF4CAF50)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF4CAF50),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Fastest Route',
                                          style: GoogleFonts.poppins(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Google Maps Map Controls (Compass, Layer, Zoom, Re-center)
                          Positioned(
                            right: 14,
                            bottom: 20,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Compass Button
                                _buildMapControlButton(
                                  icon: Icons.explore,
                                  color: accent,
                                  onTap: () {
                                    ToastManager.instance.show(
                                      context,
                                      'Orienting North',
                                      icon: Icons.explore,
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),

                                // Google Maps SDK vs 3D Vector Map Engine Switcher
                                _buildMapControlButton(
                                  icon: _useGoogleMapEngine ? Icons.map_outlined : Icons.route_rounded,
                                  color: accent,
                                  onTap: () {
                                    setState(() => _useGoogleMapEngine = !_useGoogleMapEngine);
                                    ToastManager.instance.show(
                                      context,
                                      _useGoogleMapEngine ? 'Google Maps SDK Engine' : '3D Vector Live Map Engine',
                                      icon: Icons.map,
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),

                                // Satellite Layer Switcher
                                _buildMapControlButton(
                                  icon: _isSatelliteMode ? Icons.map : Icons.layers,
                                  color: textColor,
                                  onTap: () {
                                    setState(() => _isSatelliteMode = !_isSatelliteMode);
                                    ToastManager.instance.show(
                                      context,
                                      _isSatelliteMode ? 'Satellite View' : 'Standard Map',
                                      icon: Icons.layers,
                                    );
                                  },
                                ),
                                const SizedBox(height: 8),

                                // Zoom In
                                _buildMapControlButton(
                                  icon: Icons.add,
                                  color: textColor,
                                  onTap: () {
                                    setState(() {
                                      if (_zoomLevel < 1.4) _zoomLevel += 0.15;
                                    });
                                  },
                                ),
                                const SizedBox(height: 4),

                                // Zoom Out
                                _buildMapControlButton(
                                  icon: Icons.remove,
                                  color: textColor,
                                  onTap: () {
                                    setState(() {
                                      if (_zoomLevel > 0.7) _zoomLevel -= 0.15;
                                    });
                                  },
                                ),
                                const SizedBox(height: 8),

                                // Center Target
                                _buildMapControlButton(
                                  icon: Icons.my_location,
                                  color: accent,
                                  onTap: () {
                                    setState(() => _zoomLevel = 1.0);
                                    ToastManager.instance.show(
                                      context,
                                      'Centered on Live Delivery Driver',
                                      icon: Icons.my_location,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Driver & Order Status Card
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: hairline),
                    boxShadow: [
                      if (!isDark)
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor:
                                (isCancelled ? Colors.redAccent : accent).withValues(alpha: 0.2),
                            child: Icon(
                              isCancelled ? Icons.person_off : Icons.person,
                              color: isCancelled ? Colors.redAccent : Colors.black,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCancelled ? 'Order Cancelled' : 'Rahul Sharma',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isCancelled ? Colors.redAccent : textColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isCancelled
                                      ? 'Refund initiated to original payment'
                                      : 'Havelin Delivery Partner • 4.9 ★',
                                  style: GoogleFonts.poppins(fontSize: 12, color: subtextColor),
                                ),
                              ],
                            ),
                          ),
                          if (!isCancelled)
                            IconButton(
                              onPressed: () {
                                ToastManager.instance.show(
                                  context,
                                  'Calling Rahul (+91 98765 43210)...',
                                  icon: Icons.phone,
                                );
                              },
                              icon: Icon(Icons.phone_in_talk, color: accent),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),
                      Divider(color: hairline),
                      const SizedBox(height: 12),

                      if (!isCancelled) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusStep('Confirmed', true, accent, subtextColor),
                            _buildStatusStep('Preparing', true, accent, subtextColor),
                            _buildStatusStep('On the Way', true, accent, subtextColor),
                            _buildStatusStep('Delivered', false, accent, subtextColor),
                          ],
                        ),

                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showCancelOrderModal(
                                    context, cardBg, textColor, subtextColor, accent),
                                icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 16),
                                label: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OrderDeliveredScreen(order: widget.order),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.black, size: 18),
                                label: Text(
                                  'Delivered Screen',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'This order was cancelled. You can re-order anytime from the menu!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.redAccent,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 18),
      ),
    );
  }

  Widget _buildStatusStep(String label, bool isDone, Color accent, Color subtextColor) {
    return Column(
      children: [
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isDone ? accent : subtextColor,
          size: 18,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            color: isDone ? accent : subtextColor,
          ),
        ),
      ],
    );
  }
}

class _GoogleMapPainter extends CustomPainter {
  final double pulseValue;
  final double driverProgress;
  final bool isDark;
  final Color accent;
  final bool isSatellite;
  final double zoomLevel;

  _GoogleMapPainter({
    required this.pulseValue,
    required this.driverProgress,
    required this.isDark,
    required this.accent,
    required this.isSatellite,
    required this.zoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(zoomLevel, zoomLevel);

    final groundColor = isSatellite
        ? (isDark ? const Color(0xFF141F16) : const Color(0xFF2C3E2D))
        : (isDark ? const Color(0xFF181A20) : const Color(0xFFF4F3F0));

    final buildingBlockColor = isSatellite
        ? (isDark ? const Color(0xFF1A261D) : const Color(0xFF384D39))
        : (isDark ? const Color(0xFF22252E) : const Color(0xFFE5E3DD));

    final riverColor = isDark ? const Color(0xFF152A38) : const Color(0xFFAADAFF);
    final parkColor = isDark ? const Color(0xFF1C2D21) : const Color(0xFFC8E6C9);

    final primaryRoadColor = isDark ? const Color(0xFF2E323D) : const Color(0xFFFFFFFF);
    final highwayColor = isDark ? const Color(0xFF3A3F4D) : const Color(0xFFFFEB3B);

    // 1. Draw Map Ground
    final backgroundPaint = Paint()..color = groundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width / zoomLevel, size.height / zoomLevel), backgroundPaint);

    // 2. Draw Green Park Zone
    final parkPaint = Paint()..color = parkColor;
    final parkPath = Path()
      ..moveTo(20, 20)
      ..lineTo(140, 20)
      ..lineTo(120, 110)
      ..lineTo(10, 90)
      ..close();
    canvas.drawPath(parkPath, parkPaint);

    // 3. Draw Winding Blue River
    final riverPaint = Paint()
      ..color = riverColor
      ..strokeWidth = 32
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final riverPath = Path();
    riverPath.moveTo(0, size.height * 0.2);
    riverPath.cubicTo(
      size.width * 0.3,
      size.height * 0.1,
      size.width * 0.6,
      size.height * 0.45,
      size.width,
      size.height * 0.35,
    );
    canvas.drawPath(riverPath, riverPaint);

    // 4. Draw City Building Blocks
    final blockPaint = Paint()..color = buildingBlockColor;
    final blockBorder = Paint()
      ..color = isDark ? Colors.white10 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final blocks = [
      RRect.fromLTRBR(30, 130, 150, 230, const Radius.circular(8)),
      RRect.fromLTRBR(170, 40, 290, 140, const Radius.circular(8)),
      RRect.fromLTRBR(200, 170, 340, 280, const Radius.circular(8)),
      RRect.fromLTRBR(40, 260, 160, 390, const Radius.circular(8)),
      RRect.fromLTRBR(180, 310, 320, 440, const Radius.circular(8)),
    ];

    for (var b in blocks) {
      canvas.drawRRect(b, blockPaint);
      canvas.drawRRect(b, blockBorder);
    }

    // 5. Draw Road Grid System
    final minorRoadPaint = Paint()
      ..color = primaryRoadColor
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;

    final highwayPaint = Paint()
      ..color = highwayColor
      ..strokeWidth = 20
      ..style = PaintingStyle.stroke;

    final roadPath = Path();
    roadPath.moveTo(0, 120);
    roadPath.lineTo(size.width, 120);
    roadPath.moveTo(0, 240);
    roadPath.lineTo(size.width, 240);
    roadPath.moveTo(0, 300);
    roadPath.lineTo(size.width, 300);

    roadPath.moveTo(160, 0);
    roadPath.lineTo(160, size.height);
    roadPath.moveTo(330, 0);
    roadPath.lineTo(330, size.height);

    canvas.drawPath(roadPath, minorRoadPaint);

    final hwyPath = Path();
    hwyPath.moveTo(0, size.height * 0.85);
    hwyPath.lineTo(size.width, size.height * 0.15);
    canvas.drawPath(hwyPath, highwayPaint);

    // 6. Navigation Route Curve (Vibrant Blue Line)
    final startPoint = Offset(60, size.height * 0.72);
    final wayPoint1 = Offset(160, size.height * 0.48);
    final wayPoint2 = Offset(240, 240);
    final endPoint = Offset(size.width * 0.75, 85);

    final routePath = Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..lineTo(wayPoint1.dx, wayPoint1.dy)
      ..lineTo(wayPoint2.dx, wayPoint2.dy)
      ..lineTo(endPoint.dx, endPoint.dy);

    final routeGlow = Paint()
      ..color = const Color(0xFF4285F4).withValues(alpha: 0.3)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, routeGlow);

    final routeMain = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = 7
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(routePath, routeMain);

    // 7. Calculate Live Delivery Rider Position
    Offset currentRiderPos;
    double angle = 0;

    if (driverProgress < 0.35) {
      final p = driverProgress / 0.35;
      currentRiderPos = Offset.lerp(startPoint, wayPoint1, p)!;
      angle = math.atan2(wayPoint1.dy - startPoint.dy, wayPoint1.dx - startPoint.dx);
    } else if (driverProgress < 0.7) {
      final p = (driverProgress - 0.35) / 0.35;
      currentRiderPos = Offset.lerp(wayPoint1, wayPoint2, p)!;
      angle = math.atan2(wayPoint2.dy - wayPoint1.dy, wayPoint2.dx - wayPoint1.dx);
    } else {
      final p = (driverProgress - 0.7) / 0.3;
      currentRiderPos = Offset.lerp(wayPoint2, endPoint, p)!;
      angle = math.atan2(endPoint.dy - wayPoint2.dy, endPoint.dx - wayPoint2.dx);
    }

    // 8. Draw Pins
    _drawMarkerPin(
      canvas: canvas,
      center: startPoint,
      color: Colors.orangeAccent,
      iconText: '🏪',
      title: 'Havelin Kitchens',
    );

    _drawMarkerPin(
      canvas: canvas,
      center: endPoint,
      color: Colors.redAccent,
      iconText: '📍',
      title: 'Home Address',
      isPulse: true,
      pulseVal: pulseValue,
    );

    // 9. Draw Live Driver Pulse & Rider Icon
    final driverPulsePaint = Paint()
      ..color = accent.withValues(alpha: 0.4 - pulseValue * 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(currentRiderPos, 22 + pulseValue * 14, driverPulsePaint);

    canvas.save();
    canvas.translate(currentRiderPos.dx, currentRiderPos.dy);

    final riderBgPaint = Paint()..color = Colors.black;
    final riderRingPaint = Paint()..color = accent;
    canvas.drawCircle(Offset.zero, 18, riderBgPaint);
    canvas.drawCircle(Offset.zero, 16, riderRingPaint);

    canvas.rotate(angle);
    final arrowPath = Path()
      ..moveTo(8, 0)
      ..lineTo(-6, -6)
      ..lineTo(-3, 0)
      ..lineTo(-6, 6)
      ..close();
    canvas.drawPath(arrowPath, Paint()..color = Colors.black);
    canvas.restore();

    canvas.restore();
  }

  void _drawMarkerPin({
    required Canvas canvas,
    required Offset center,
    required Color color,
    required String iconText,
    required String title,
    bool isPulse = false,
    double pulseVal = 0,
  }) {
    if (isPulse) {
      final pulse = Paint()
        ..color = color.withValues(alpha: 0.35 - pulseVal * 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 18 + pulseVal * 12, pulse);
    }

    final pinPaint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 14, pinPaint);
    canvas.drawCircle(center, 14, borderPaint);

    final tp = TextPainter(
      text: TextSpan(
        text: iconText,
        style: const TextStyle(fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _GoogleMapPainter oldDelegate) => true;
}