import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://osnblefzulmsuthhuswl.supabase.co',
  );
  static const publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_IZdxqiGHY53pbkCsb9qXPQ_-aqyWsBh',
  );

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  static Future<void> initialize() async {
    if (url.isEmpty && publishableKey.isEmpty) return;
    if (!isConfigured) {
      throw StateError('Set both SUPABASE_URL and SUPABASE_PUBLISHABLE_KEY.');
    }

    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }
}
