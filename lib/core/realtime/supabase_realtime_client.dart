import 'package:family_guard/core/realtime/supabase_realtime_config.dart';
import 'package:family_guard/features/login/data/datasources/auth_local_data_source.dart';
import 'package:supabase/supabase.dart';

class RealtimeWatchSubscription {
  const RealtimeWatchSubscription({
    required SupabaseClient client,
    required RealtimeChannel channel,
  }) : _client = client,
       _channel = channel;

  final SupabaseClient _client;
  final RealtimeChannel _channel;

  Future<void> cancel() async {
    await _client.removeChannel(_channel);
  }
}

class SupabaseRealtimeClient {
  SupabaseRealtimeClient({required AuthLocalDataSource authLocalDataSource})
    : _authLocalDataSource = authLocalDataSource,
      _client = SupabaseClient(
        SupabaseRealtimeConfig.url,
        SupabaseRealtimeConfig.anonKey,
        accessToken: authLocalDataSource.getAccessToken,
        authOptions: const AuthClientOptions(autoRefreshToken: false),
      );

  final AuthLocalDataSource _authLocalDataSource;
  final SupabaseClient _client;

  Future<RealtimeWatchSubscription?> watchNotifications(
    void Function() onEvent,
  ) {
    return _watchTable(
      table: 'notification',
      channelPrefix: 'family-guard-notification',
      onEvent: onEvent,
    );
  }

  Future<RealtimeWatchSubscription?> watchRelationships(
    void Function() onEvent,
  ) {
    return _watchTable(
      table: 'relationship',
      channelPrefix: 'family-guard-relationship',
      onEvent: onEvent,
    );
  }

  Future<RealtimeWatchSubscription?> _watchTable({
    required String table,
    required String channelPrefix,
    required void Function() onEvent,
  }) async {
    final session = await _authLocalDataSource.getSavedSession();
    final uid = session?.userId.trim() ?? '';
    final accessToken = session?.accessToken.trim() ?? '';
    if (uid.isEmpty || accessToken.isEmpty) {
      return null;
    }

    await _client.realtime.setAuth(accessToken);

    final channel = _client.channel(
      '$channelPrefix-$uid-${DateTime.now().microsecondsSinceEpoch}',
    );

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: SupabaseRealtimeConfig.schema,
          table: table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'uid',
            value: uid,
          ),
          callback: (_) => onEvent(),
        )
        .subscribe();

    return RealtimeWatchSubscription(client: _client, channel: channel);
  }

  Future<void> dispose() {
    return _client.dispose();
  }
}
