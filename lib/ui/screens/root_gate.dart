import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../pixel/pixel.dart';
import 'onboarding/onboarding_flow.dart';
import 'shell/shell.dart';

/// Sends new players to onboarding and everyone else to the main tabs.
class RootGate extends ConsumerWidget {
  const RootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarded = ref.watch(onboardedProvider);
    return onboarded.when(
      loading: () => const Scaffold(body: PixelBackdrop(child: SizedBox())),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (done) => done ? const Shell() : const OnboardingFlow(),
    );
  }
}
