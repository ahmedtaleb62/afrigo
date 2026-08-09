import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../state/client_flow_controller.dart';
import '../state/client_screen.dart';
import '../widgets/client_bottom_nav.dart';
import '../widgets/simple_prompt_dialog.dart';
import '../core/context_ext.dart';

/// Screen 41 — Profile.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientFlowControllerProvider.notifier).loadProfile());
  }

  Future<void> _pickAvatar() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: const Text('📷'), title: const Text('التقاط صورة', style: TextStyle(fontFamily: 'Tajawal')), onTap: () => Navigator.pop(ctx, ImageSource.camera)),
            ListTile(leading: const Text('🖼️'), title: const Text('اختيار من المعرض', style: TextStyle(fontFamily: 'Tajawal')), onTap: () => Navigator.pop(ctx, ImageSource.gallery)),
          ],
        ),
      ),
    );
    if (source != null && mounted) await ref.read(clientFlowControllerProvider.notifier).pickAndUploadAvatar(source);
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(clientFlowControllerProvider.notifier);
    final s = ref.watch(clientFlowControllerProvider);

    Widget menuRow(String label, {VoidCallback? onTap, bool divider = true}) => InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: divider ? const Border(bottom: BorderSide(color: Color(0xFFF5F5F4))) : null),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w600, fontSize: 13)),
                const Text('›', style: TextStyle(color: Color(0xFFA8A29E))),
              ],
            ),
          ),
        );

    return Container(
      color: const Color(0xFFFAFAF9),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20, context.topGap(30), 20, 20),
              children: [
                Column(
                  children: [
                    InkWell(
                      onTap: s.profileAvatarUploading ? null : _pickAvatar,
                      customBorder: const CircleBorder(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            alignment: Alignment.center,
                            clipBehavior: Clip.antiAlias,
                            decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                            child: s.profileAvatarUploading
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                                : (s.profileAvatarUrl != null
                                    ? Image.network(s.profileAvatarUrl!, fit: BoxFit.cover, width: 76, height: 76, errorBuilder: (context, error, stack) => const Text('👩', style: TextStyle(fontSize: 30)))
                                    : const Text('👩', style: TextStyle(fontSize: 30))),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(color: Color(0xFF16A34A), shape: BoxShape.circle, border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))),
                              child: const Text('📷', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      s.profileLoading ? '...' : (s.profileFullName ?? 'مستخدم Afrigo'),
                      style: const TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.w800, fontSize: 17),
                    ),
                    Text(
                      s.profileEmail ?? s.profilePhone ?? '',
                      style: const TextStyle(fontFamily: 'Tajawal', fontSize: 12, color: Color(0xFF78716C)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  clipBehavior: Clip.antiAlias,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Column(children: [
                    menuRow(
                      'تعديل البيانات الشخصية',
                      onTap: () async {
                        final name = await SimplePromptDialog.showTextPrompt(
                          context,
                          title: 'الاسم الكامل',
                          initialValue: s.profileFullName,
                          hint: 'اسمك الكامل',
                        );
                        if (name != null && name.trim().isNotEmpty) await controller.updateFullName(name);
                      },
                    ),
                    menuRow(
                      'تغيير كلمة المرور',
                      divider: false,
                      onTap: () async {
                        final pass = await SimplePromptDialog.showTextPrompt(
                          context,
                          title: 'كلمة المرور الجديدة',
                          hint: '••••••••',
                          obscureText: true,
                          confirmLabel: 'تغيير',
                        );
                        if (pass == null || pass.isEmpty || !context.mounted) return;
                        final ok = await controller.changePassword(pass);
                        if (!context.mounted) return;
                        SimplePromptDialog.showInfo(
                          context,
                          title: ok ? 'تم' : 'تعذّر',
                          body: ok ? 'تم تغيير كلمة المرور بنجاح' : 'تعذّر تغيير كلمة المرور، حاول مجددًا',
                        );
                      },
                    ),
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: menuRow('⚙️ الإعدادات', onTap: () => controller.goTo(ClientScreen.settings), divider: false),
                ),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                  child: menuRow('🆘 الدعم والمساعدة', onTap: () => controller.goToInfo(ClientScreen.support), divider: false),
                ),
              ],
            ),
          ),
          const ClientBottomNav(current: ClientScreen.profile),
        ],
      ),
    );
  }
}
