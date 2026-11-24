import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/bank.dart';
import 'demo_seed.dart';

/// The player's own defaults, kept out of git so the public code holds only
/// generic ones: `assets/local/profile.json`, read once at start-up. The
/// file is optional; without it (a fresh clone, tests) the code's generic
/// defaults apply. Its shape is in `docs/local_profile.example.json`.
class LocalProfile {
  const LocalProfile({
    this.bank = const BankConfig(),
    this.heroName = kDemoHeroName,
    this.identity = kDemoIdentity,
  });

  factory LocalProfile.fromJson(Object? json) {
    if (json is! Map) return const LocalProfile();
    final demo = json['demo'];
    String text(Object? v, String fallback) =>
        v is String && v.trim().isNotEmpty ? v.trim() : fallback;
    return LocalProfile(
      bank: BankConfig.fromJson(json['bank']),
      heroName: text(demo is Map ? demo['name'] : null, kDemoHeroName),
      identity: text(demo is Map ? demo['identity'] : null, kDemoIdentity),
    );
  }

  static const asset = 'assets/local/profile.json';

  /// The profile in [bundle], or the generic one when there is none.
  static Future<LocalProfile> load(AssetBundle bundle) async {
    try {
      return LocalProfile.fromJson(jsonDecode(await bundle.loadString(asset)));
    } on Object {
      return const LocalProfile();
    }
  }

  /// Bank numbers before the player sets their own.
  final BankConfig bank;

  /// The demo adventurer ("載入示範資料").
  final String heroName;
  final String identity;
}

/// Overridden in `main` with the loaded profile.
final localProfileProvider = Provider<LocalProfile>(
  (ref) => const LocalProfile(),
);
