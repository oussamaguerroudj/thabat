import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/connectivity/connectivity_provider.dart';
import 'core/providers/core_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_state_views.dart';

/// THABAT is Arabic-first and RTL throughout (project rule §13/§14) — this
/// is fixed here at the app root via `locale: Locale('ar')`, not left to
/// per-screen `Directionality` widgets, so RTL is the default every new
/// screen inherits rather than something each one has to opt into.
class ThabatApp extends ConsumerWidget {
  const ThabatApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ثبات — THABAT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: _OfflineAwareShell(child: child),
        );
      },
    );
  }
}

/// Wraps every screen with the app-wide offline banner (see
/// `core/connectivity/connectivity_provider.dart`) so offline state is
/// handled once at the shell level rather than duplicated per screen.
class _OfflineAwareShell extends ConsumerWidget {
  const _OfflineAwareShell({required this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityStatusProvider);
    final isOffline = connectivity.valueOrNull == false;

    return Column(
      children: [
        if (isOffline) const OfflineBanner(),
        Expanded(child: child ?? const SizedBox.shrink()),
      ],
    );
  }
}
