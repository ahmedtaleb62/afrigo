import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/client_bottom_nav.dart';
import '../widgets/promo_slider.dart';
import '../core/context_ext.dart';
import '../core/push_notifications.dart';

/// Screens 10/11 — Home.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final controller = ref.read(clientFlowControllerProvider.notifier);
      controller.loadProfile();
      // Covers the case where permission was already granted in a past
      // session — `requestLocationPermission()` only fetches a fix right
      // after the OS prompt, this catches every other app launch.
      controller.fetchCurrentLocation();
      // Covers a session that was already logged in when the app launched
      // (persisted Supabase session, `doLogin()` never ran this process) —
      // without this, push notifications would never register for it.
      PushNotifications.register();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);
    final firstName = (s.profileFullName ?? '').trim().split(RegExp(r'\s+')).first;

    return Container(
      // The new design has no distinct app-bar chrome anywhere — every
      // screen is one continuous flat surface from the status bar down to
      // the bottom nav, header row included. No shadow, no rounded corners,
      // no separate background for the header.
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, context.topGap(14), 20, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => controller.goTo(ClientScreen.profile),
                  borderRadius: BorderRadius.circular(20),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                        child: Text(
                          firstName.isEmpty ? '👤' : firstName.characters.first.toUpperCase(),
                          style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF166534)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(firstName.isEmpty ? context.l10n.commonGreetingFallback : firstName, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14)),
                    ],
                  ),
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () => controller.setSettingsLang(s.settingsLang == 'ar' ? 'fr' : 'ar'),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFF0FDF4), border: Border.all(color: const Color(0xFFDCFCE7)), borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          s.settingsLang == 'ar' ? 'FR' : 'AR',
                          style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w700, fontSize: 11, color: Color(0xFF16A34A)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () => controller.goTo(ClientScreen.notificationsList),
                      customBorder: const CircleBorder(),
                      child: Container(
                        width: 36,
                        height: 36,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Color(0xFFF5F5F4), shape: BoxShape.circle),
                        child: const Text('🔔', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const PromoSlider(),
                  _ServiceGrid(controller: controller),
                ],
              ),
            ),
          ),
          const ClientBottomNav(current: ClientScreen.home),
        ],
      ),
    );
  }
}

class _ServiceGrid extends StatelessWidget {
  const _ServiceGrid({required this.controller});
  final ClientFlowController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ServiceRow(
            icon: Icons.local_taxi_outlined,
            iconBg: const Color(0xFFF0FDF4),
            iconFg: const Color(0xFF16A34A),
            title: l10n.clientHomeTaxiTitle,
            subtitle: l10n.clientHomeTaxiDesc,
            onTap: () => controller.goTo(
              ClientScreen.rideOrigin,
              patch: (s) => s.copyWith(
                flowType: ClientFlowType.taxi,
                pickupLat: null,
                pickupLng: null,
                pickupAddress: null,
                pickupIsUserSet: false,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _ServiceRow(
            icon: Icons.restaurant_outlined,
            iconBg: const Color(0xFFFEFCE8),
            iconFg: const Color(0xFFCA8A04),
            title: l10n.clientHomeFoodTitle,
            subtitle: l10n.clientHomeFoodDesc,
            onTap: controller.goToFoodList,
          ),
          const SizedBox(height: 12),
          _ServiceRow(
            icon: Icons.inventory_2_outlined,
            iconBg: const Color(0xFFF5F5F4),
            iconFg: const Color(0xFF57534E),
            title: l10n.clientHomeDeliveryTitle,
            subtitle: l10n.clientHomeDeliveryDesc,
            onTap: () => controller.goTo(
              ClientScreen.parcelPickup,
              patch: (s) => s.copyWith(
                flowType: ClientFlowType.delivery,
                pickupLat: null,
                pickupLng: null,
                pickupAddress: null,
                pickupIsUserSet: false,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: InkWell(
              onTap: () => controller.goTo(ClientScreen.voiceRecord, patch: (s) => s.copyWith(voiceStage: VoiceStage.idle)),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: const BoxDecoration(color: Color(0xFF1C1917), borderRadius: BorderRadius.all(Radius.circular(30))),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(color: Color(0xFFFACC15), shape: BoxShape.circle),
                      child: const Text('🎤', style: TextStyle(fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Text(l10n.clientVoiceOrderLabel, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.icon,
    required this.iconBg,
    required this.iconFg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconFg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE7E5E4)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 3, offset: Offset(0, 1))],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, size: 24, color: iconFg),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w700, fontSize: 15, color: Color(0xFF1C1917))),
                  Text(subtitle, style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C))),
                ],
              ),
            ),
            const Text('‹', style: TextStyle(color: Color(0xFFA8A29E), fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
