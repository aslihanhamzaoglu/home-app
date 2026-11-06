import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

var _channelCount = 0;

/// The rows [load] returns, loaded again whenever Realtime reports a change
/// to [table] (narrowed by [filter]).
///
/// Used instead of `.stream()`: right after a row is inserted, Realtime can
/// still deliver that INSERT once `.stream()` has loaded the row, and
/// `.stream()` then lists the row twice. Reloading on every change cannot go
/// out of step with the database.
Stream<List<Map<String, dynamic>>> liveRows(
  SupabaseClient client, {
  required String table,
  PostgresChangeFilter? filter,
  required Future<List<Map<String, dynamic>>> Function() load,
}) {
  late final StreamController<List<Map<String, dynamic>>> controller;
  RealtimeChannel? channel;
  var latestLoad = 0;

  Future<void> reload() async {
    final thisLoad = ++latestLoad;
    try {
      final rows = await load();
      // A later reload started meanwhile; its result is the fresher one.
      if (thisLoad == latestLoad && !controller.isClosed) controller.add(rows);
    } catch (error, stackTrace) {
      if (!controller.isClosed) controller.addError(error, stackTrace);
    }
  }

  controller = StreamController(
    onListen: () {
      unawaited(reload());
      channel = client
          .channel('live-$table-${_channelCount++}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            filter: filter,
            callback: (_) => unawaited(reload()),
          )
          .subscribe((status, [error]) {
            switch (status) {
              // Catches up on changes made before (re)connecting.
              case RealtimeSubscribeStatus.subscribed:
                unawaited(reload());
              case RealtimeSubscribeStatus.channelError:
              case RealtimeSubscribeStatus.timedOut:
                if (!controller.isClosed) {
                  controller.addError(
                    RealtimeSubscribeException(status, error),
                  );
                }
              case RealtimeSubscribeStatus.closed:
                break;
            }
          });
    },
    onCancel: () async {
      if (channel case final subscribed?) {
        await client.removeChannel(subscribed);
      }
      await controller.close();
    },
  );
  return controller.stream;
}
