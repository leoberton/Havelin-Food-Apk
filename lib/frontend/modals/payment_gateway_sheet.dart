import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../backend/payment_backend_service.dart';
import '../../managers/haptic_manager.dart';
import '../../managers/user_manager.dart';

enum PaymentMethodType { upi, card, netBanking, cod }

class PaymentMethodOption {
  final PaymentMethodType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const PaymentMethodOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class PaymentGatewaySheet extends StatefulWidget {
  final double amount;
  final String? orderId;
  final Function(PaymentMethodOption selectedOption, String transactionId) onPaymentSuccess;

  const PaymentGatewaySheet({
    super.key,
    required this.amount,
    this.orderId,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentGatewaySheet> createState() => _PaymentGatewaySheetState();
}

class _PaymentGatewaySheetState extends State<PaymentGatewaySheet> {
  PaymentMethodType _selectedType = PaymentMethodType.upi;
  bool _isProcessing = false;

  // Controllers for Interactive Inputs (Option 2)
  final TextEditingController _upiIdController = TextEditingController(text: 'havelin@okaxis');
  final TextEditingController _cardNumberController = TextEditingController(text: '4532 8912 3456 7890');
  final TextEditingController _cardNameController = TextEditingController(text: 'John Doe');
  final TextEditingController _expiryController = TextEditingController(text: '12/28');
  final TextEditingController _cvvController = TextEditingController(text: '888');
  String _selectedBank = 'HDFC Bank';

  final List<PaymentMethodOption> _options = const [
    PaymentMethodOption(
      type: PaymentMethodType.upi,
      title: 'UPI Instant Pay',
      subtitle: 'Google Pay, PhonePe, Paytm, BHIM',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF00A884),
    ),
    PaymentMethodOption(
      type: PaymentMethodType.card,
      title: 'Credit / Debit Card',
      subtitle: 'Visa, Mastercard, RuPay, Amex',
      icon: Icons.credit_card_rounded,
      color: Color(0xFF3B82F6),
    ),
    PaymentMethodOption(
      type: PaymentMethodType.netBanking,
      title: 'Net Banking',
      subtitle: 'HDFC, ICICI, SBI, Axis, Kotak',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF8B5CF6),
    ),
    PaymentMethodOption(
      type: PaymentMethodType.cod,
      title: 'Cash on Delivery (COD)',
      subtitle: 'Pay cash or UPI at your doorstep',
      icon: Icons.payments_rounded,
      color: Color(0xFFF59E0B),
    ),
  ];

  @override
  void dispose() {
    _upiIdController.dispose();
    _cardNumberController.dispose();
    _cardNameController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  /// Option 1: Direct UPI Deep-Link URI Launch (Google Pay / PhonePe / Paytm)
  Future<void> _launchUpiApp(String appName) async {
    HapticManager.instance.mediumImpact();
    final upiUri = Uri.parse(
      'upi://pay?pa=havelinfood@okaxis&pn=Havelin%20Food&am=${widget.amount.toStringAsFixed(2)}&cu=INR',
    );
    try {
      if (await canLaunchUrl(upiUri)) {
        await launchUrl(upiUri, mode: LaunchMode.externalApplication);
      } else {
        _processPayment();
      }
    } catch (_) {
      _processPayment();
    }
  }

  void _processPayment() async {
    HapticManager.instance.mediumImpact();
    setState(() {
      _isProcessing = true;
    });

    final selectedOpt = _options.firstWhere((o) => o.type == _selectedType);
    final user = UserManager.instance.value;

    final transaction = await PaymentBackendService.instance.processPaymentVerification(
      orderId: widget.orderId ?? 'HV-INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}',
      userId: user.phone.isNotEmpty ? user.phone : 'USER_GUEST',
      userName: user.name.isNotEmpty ? user.name : 'Customer',
      userPhone: user.phone,
      amount: widget.amount,
      paymentMethod: selectedOpt.title,
    );

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
      Navigator.pop(context);
      widget.onPaymentSuccess(selectedOpt, transaction.transactionId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final inputBg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final subtextColor = isDark ? Colors.white60 : const Color(0xFF64748B);
    const accent = Color(0xFF00A884);

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Payment Gateway',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '100% Encrypted & Secure Checkout 🔒',
                      style: GoogleFonts.poppins(fontSize: 12, color: subtextColor),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    '₹${widget.amount.toStringAsFixed(0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Payment Options Selector
            ..._options.map((option) {
              final isSelected = _selectedType == option.type;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isSelected ? option.color.withValues(alpha: 0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? option.color : subtextColor.withValues(alpha: 0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticManager.instance.selectionClick();
                        setState(() => _selectedType = option.type);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: option.color.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(option.icon, color: option.color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  Text(
                                    option.subtitle,
                                    style: GoogleFonts.poppins(fontSize: 12, color: subtextColor),
                                  ),
                                ],
                              ),
                            ),
                            Radio<PaymentMethodType>(
                              value: option.type,
                              groupValue: _selectedType,
                              activeColor: option.color,
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedType = val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Option 2 & 1 Interactive Expanded Inputs
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: _buildExpandedInputs(option.type, inputBg, textColor, subtextColor, option.color),
                      ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 4,
                ),
                child: _isProcessing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5),
                      )
                    : Text(
                        'Pay ₹${widget.amount.toStringAsFixed(0)} Now 💳',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedInputs(
    PaymentMethodType type,
    Color inputBg,
    Color textColor,
    Color subtextColor,
    Color activeColor,
  ) {
    switch (type) {
      case PaymentMethodType.upi:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Launch Installed UPI App 📲',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: activeColor),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildUpiAppChip('GPay 🟢', activeColor, () => _launchUpiApp('Google Pay')),
                const SizedBox(width: 8),
                _buildUpiAppChip('PhonePe 💜', activeColor, () => _launchUpiApp('PhonePe')),
                const SizedBox(width: 8),
                _buildUpiAppChip('Paytm 💙', activeColor, () => _launchUpiApp('Paytm')),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'OR Enter Virtual Payment Address (VPA)',
              style: GoogleFonts.poppins(fontSize: 11, color: subtextColor),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _upiIdController,
              style: GoogleFonts.poppins(color: textColor, fontSize: 13.5),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputBg,
                hintText: 'e.g. yourname@okaxis',
                hintStyle: GoogleFonts.poppins(color: subtextColor, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: subtextColor.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ],
        );

      case PaymentMethodType.card:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Card Details 💳',
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: activeColor),
                ),
                Text('VISA / Mastercard', style: GoogleFonts.poppins(fontSize: 11, color: Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _cardNumberController,
              style: GoogleFonts.poppins(color: textColor, fontSize: 13.5, letterSpacing: 1),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: inputBg,
                hintText: '4532 •••• •••• 8910',
                prefixIcon: const Icon(Icons.credit_card_rounded, size: 20, color: Colors.blueAccent),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: subtextColor.withValues(alpha: 0.3)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expiryController,
                    style: GoogleFonts.poppins(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      hintText: 'MM/YY',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: subtextColor.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _cvvController,
                    obscureText: true,
                    style: GoogleFonts.poppins(color: textColor, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      hintText: 'CVV (3 digits)',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: subtextColor.withValues(alpha: 0.3)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

      case PaymentMethodType.netBanking:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Popular Bank 🏦',
              style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: activeColor),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedBank,
              dropdownColor: inputBg,
              style: GoogleFonts.poppins(color: textColor, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: inputBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: subtextColor.withValues(alpha: 0.3)),
                ),
              ),
              items: ['HDFC Bank', 'ICICI Bank', 'State Bank of India (SBI)', 'Axis Bank', 'Kotak Bank']
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedBank = val);
              },
            ),
          ],
        );

      case PaymentMethodType.cod:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Rider Rahul will deliver your hot food and collect ₹${widget.amount.toStringAsFixed(0)} via Cash or Doorstep QR Code.',
                  style: GoogleFonts.poppins(fontSize: 11.5, color: textColor),
                ),
              ),
            ],
          ),
        );
    }
  }

  Widget _buildUpiAppChip(String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color),
          ),
        ),
      ),
    );
  }
}
