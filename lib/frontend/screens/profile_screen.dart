import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../backend/auth_service.dart';
import '../../backend/firebase_manager.dart';
import '../../backend/payment_backend_service.dart';
import '../../managers/cart_manager.dart';
import '../../managers/favorites_manager.dart';
import '../../managers/haptic_manager.dart';
import '../../managers/order_history_manager.dart';
import '../../managers/theme_manager.dart';
import '../../managers/toast_manager.dart';
import '../../managers/user_manager.dart';
import '../admin/admin_kitchen_dashboard.dart';
import '../modals/address_modal.dart';
import 'edit_screen.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';
import 'order_tracking_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onBackTap;

  const ProfileScreen({
    super.key,
    required this.onBackTap,
  });

  Future<void> _openEditProfile(BuildContext context, UserData userData) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: userData.name,
          currentPhone: userData.phone,
          currentAddressLine1: userData.addressLine1,
          currentAddressLine2: userData.addressLine2,
          avatarImagePath: userData.profileImagePath,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, Color cardBg, Color textColor, Color subtextColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to log out of Havelin?',
          style: GoogleFonts.poppins(color: subtextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins(color: subtextColor)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.instance.signOut();
              UserManager.instance.logout();
              CartManager.instance.clearCart();
              FavoritesManager.instance.clearFavorites();
              if (context.mounted) {
                ToastManager.instance.show(
                  context,
                  'Logged out successfully',
                  icon: Icons.logout_rounded,
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarImage(String path, Color textColor) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => CircleAvatar(
          backgroundColor: Colors.white12,
          child: Icon(Icons.person, color: textColor, size: 36),
        ),
      );
    }
    if (path.startsWith('/') || path.contains('/data/')) {
      final file = File(path);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => CircleAvatar(
        backgroundColor: Colors.white12,
        child: Icon(Icons.person, color: textColor, size: 36),
      ),
    );
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
        final hairline = ThemeManager.instance.hairlineColor(context);
        final accent = ThemeManager.instance.accentColor(context);

        final String themeText = (themeMode == ThemeMode.light)
            ? 'Light Mode'
            : (themeMode == ThemeMode.system ? 'System Default' : 'Dark Mode');

        return Scaffold(
          backgroundColor: bg,
          body: ValueListenableBuilder<UserData>(
            valueListenable: UserManager.instance,
            builder: (context, userData, child) {
              return SafeArea(
                child: Column(
                  children: [
                    // Header Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: onBackTap,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: hairline,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                color: textColor,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 5,
                            height: 26,
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Profile',
                            style: GoogleFonts.baloo2(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Profile Card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: hairline),
                                boxShadow: [
                                  if (!ThemeManager.instance.isDarkMode(context))
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                    ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(30),
                                    child: SizedBox(
                                      width: 60,
                                      height: 60,
                                      child: _buildAvatarImage(userData.profileImagePath, textColor),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          userData.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          userData.phone,
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: subtextColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => _openEditProfile(context, userData),
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: accent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit_outlined, size: 15, color: Colors.black),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Edit',
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Account Information
                            Text(
                              'Account Information',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: hairline),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoTile(
                                    icon: Icons.person_outline,
                                    title: 'Full Name',
                                    subtitle: userData.name,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    accent: accent,
                                  ),
                                  Divider(color: hairline, height: 1),
                                  _buildInfoTile(
                                    icon: Icons.phone_outlined,
                                    title: 'Phone Number',
                                    subtitle: userData.phone,
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    accent: accent,
                                  ),
                                  Divider(color: hairline, height: 1),
                                   GestureDetector(
                                     onTap: () => showAddressModalSheet(context),
                                     behavior: HitTestBehavior.opaque,
                                     child: _buildInfoTile(
                                       icon: Icons.location_on_outlined,
                                       title: 'Delivery Address (${userData.addressTag})',
                                       subtitle: '${userData.addressLine1}, ${userData.addressLine2}',
                                       textColor: textColor,
                                       subtextColor: subtextColor,
                                       accent: accent,
                                     ),
                                   ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Orders & Receipts Section Title
                            Text(
                              'Orders & Receipts',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),

                            Container(
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: hairline),
                              ),
                              child: Column(
                                children: [
                                  _buildMenuItem(
                                    icon: Icons.receipt_long_outlined,
                                    title: 'My Orders & Digital Receipts',
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    accent: accent,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => OrderHistoryScreen(onBackTap: () => Navigator.pop(context)),
                                        ),
                                      );
                                    },
                                  ),
                                  Divider(color: hairline, height: 1),
                                  _buildMenuItem(
                                    icon: Icons.delivery_dining_outlined,
                                    title: 'Track Active Order',
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    accent: accent,
                                    onTap: () {
                                      final active = OrderHistoryManager.instance.activeOrder;
                                      if (active != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OrderTrackingScreen(order: active),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('No active order right now! Place a new order in Cart.')),
                                        );
                                      }
                                    },
                                  ),
                                  Divider(color: hairline, height: 1),
                                  _buildMenuItem(
                                    icon: Icons.account_balance_wallet_outlined,
                                    title: 'Payment Verification & Ledger 💳',
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    accent: accent,
                                    onTap: () {
                                      _showTransactionLedgerModal(context, userData, cardBg, textColor, subtextColor, accent, ThemeManager.instance.isDarkMode(context));
                                    },
                                  ),
                                  Divider(color: hairline, height: 1),
                                  _buildMenuItem(
                                    icon: Icons.soup_kitchen_outlined,
                                    title: 'Kitchen Admin Control Panel 👨‍🍳',
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    accent: const Color(0xFF00A884),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const AdminKitchenDashboard(),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),

                            // Support & Settings
                            Text(
                              'Support & Settings',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: hairline),
                              ),
                              child: Column(
                                children: [
                                  _buildMenuItem(
                                    icon: Icons.palette_outlined,
                                    title: 'App Theme: $themeText',
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    accent: accent,
                                    onTap: () => _showThemeSelectionSheet(context, cardBg, textColor, subtextColor, accent),
                                  ),
                                  Divider(color: hairline, height: 1),
                                  _buildMenuItem(
                                    icon: Icons.vibration_rounded,
                                    title: 'Tactile Haptics: ${HapticManager.instance.isHapticsEnabled ? "Enabled" : "Disabled"}',
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    accent: accent,
                                    onTap: () {
                                      HapticManager.instance.isHapticsEnabled = !HapticManager.instance.isHapticsEnabled;
                                      HapticManager.instance.mediumImpact();
                                      ToastManager.instance.show(
                                        context,
                                        HapticManager.instance.isHapticsEnabled
                                            ? 'Haptic Feedback Enabled ⚡'
                                            : 'Haptic Feedback Muted 🔇',
                                        icon: Icons.vibration_rounded,
                                      );
                                    },
                                  ),
                                  Divider(color: hairline, height: 1),
                                  _buildMenuItem(
                                    icon: Icons.cloud_upload_outlined,
                                    title: 'Cloud Database Sync & Seed ☁️',
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    accent: accent,
                                    onTap: () async {
                                      HapticManager.instance.mediumImpact();
                                      await FirebaseManager.instance.syncUserProfile(UserManager.instance.value);
                                      await FirebaseManager.instance.seedMenuDishes(sampleDishes);
                                      if (context.mounted) {
                                        ToastManager.instance.show(
                                          context,
                                          'Cloud Database Synced & Seeded! Check Firebase Console 🚀',
                                          icon: Icons.cloud_done_rounded,
                                        );
                                      }
                                    },
                                  ),
                                  Divider(color: hairline, height: 1),
                                  _buildMenuItem(
                                    icon: Icons.help_outline,
                                    title: 'Help Center',
                                    textColor: textColor,
                                    subtextColor: subtextColor,
                                    accent: accent,
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Help Center tapped!')),
                                      );
                                    },
                                  ),
                                  Divider(color: hairline, height: 1),
                                  _buildMenuItem(
                                    icon: Icons.logout,
                                    title: 'Logout',
                                    textColor: Colors.redAccent,
                                    subtextColor: subtextColor,
                                    accent: Colors.redAccent,
                                    onTap: () => _showLogoutDialog(context, cardBg, textColor, subtextColor),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subtextColor,
    required Color accent,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: subtextColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color textColor,
    required Color subtextColor,
    required Color accent,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: accent, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: subtextColor,
          size: 20,
        ),
      ),
    );
  }

  void _showThemeSelectionSheet(
    BuildContext context,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color accent,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeManager.instance,
          builder: (context, currentMode, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(color: accent.withValues(alpha: 0.4)),
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
                  Text(
                    'Choose App Theme',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildThemeOptionTile(
                    context,
                    title: 'Dark Mode (Recommended)',
                    subtitle: 'Luxury Emerald & Pitch Black theme',
                    mode: ThemeMode.dark,
                    isSelected: currentMode == ThemeMode.dark,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    accent: accent,
                  ),
                  _buildThemeOptionTile(
                    context,
                    title: 'Light Mode',
                    subtitle: 'Clean Mint & Crisp Light Gray theme',
                    mode: ThemeMode.light,
                    isSelected: currentMode == ThemeMode.light,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    accent: accent,
                  ),
                  _buildThemeOptionTile(
                    context,
                    title: 'System Default',
                    subtitle: 'Matches your phone system theme settings',
                    mode: ThemeMode.system,
                    isSelected: currentMode == ThemeMode.system,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    accent: accent,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildThemeOptionTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required ThemeMode mode,
    required bool isSelected,
    required Color textColor,
    required Color subtextColor,
    required Color accent,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: () {
          ThemeManager.instance.setThemeMode(mode);
          Navigator.pop(context);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        leading: Icon(
          isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: isSelected ? accent : subtextColor,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: isSelected ? accent : textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14.5,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(color: subtextColor, fontSize: 12),
        ),
      ),
    );
  }

  void _showTransactionLedgerModal(
    BuildContext context,
    UserData userData,
    Color cardBg,
    Color textColor,
    Color subtextColor,
    Color accent,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: accent.withValues(alpha: 0.3)),
        ),
        child: Column(
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.account_balance_wallet_rounded, color: accent, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Ledger 💳',
                          style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        Text(
                          'Real-Time Cloud Firestore Verified Ledger',
                          style: GoogleFonts.poppins(fontSize: 11, color: subtextColor),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: StreamBuilder<List<TransactionModel>>(
                stream: PaymentBackendService.instance.streamUserTransactions(
                  userData.phone.isNotEmpty ? userData.phone : 'USER_GUEST',
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF00A884)));
                  }
                  final transactions = snapshot.data ?? [];
                  if (transactions.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48, color: subtextColor.withValues(alpha: 0.5)),
                          const SizedBox(height: 10),
                          Text(
                            'No Payment Records Found',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Place a new order in Cart to verify transactions!',
                            style: GoogleFonts.poppins(fontSize: 12, color: subtextColor),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final txn = transactions[index];
                      final isSuccess = txn.status == TransactionStatus.success;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSuccess ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: (isSuccess ? Colors.green : Colors.red).withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isSuccess ? Icons.check_circle_rounded : Icons.cancel_rounded,
                                color: isSuccess ? Colors.green : Colors.red,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    txn.transactionId,
                                    style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                                  ),
                                  Text(
                                    '${txn.paymentMethod} • Ref: ${txn.gatewayRef}',
                                    style: GoogleFonts.poppins(fontSize: 11, color: subtextColor),
                                  ),
                                  Text(
                                    '${txn.timestamp.day}/${txn.timestamp.month}/${txn.timestamp.year} at ${txn.timestamp.hour}:${txn.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.poppins(fontSize: 10.5, color: subtextColor),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${txn.amount.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: accent),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (isSuccess ? Colors.green : Colors.red).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    isSuccess ? 'VERIFIED' : 'FAILED',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: isSuccess ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
