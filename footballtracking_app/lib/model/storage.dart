import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import '../model/users.dart';
import '../model/training.dart';
import 'dart:convert';
import 'dart:io';


class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    final dir = await getApplicationDocumentsDirectory();
    final dbPath = join(dir.path, 'players.db');

    _db = await databaseFactoryIo.openDatabase(dbPath);
    return _db!;
  }
}



class PlayerRepository {
  final _store = intMapStoreFactory.store('players');

  Future<Database> get _db async => AppDatabase().database;

  /// Get all players from DB
  Future<List<Player>> getAll() async {
    final records = await _store.find(await _db);

    return records
        .map((r) => Player.fromJson(r.value))
        .toList();
  }

  Future<void> add(Player player) async {
    await _store.add(await _db, player.toJson());
  }

  Future<void> update(Player player) async {
  final finder = Finder(filter: Filter.equals('id', player.id));
  await _store.update(
    await _db,
    player.toJson(),
    finder: finder,
  );
}
}


class CoachRepository {
  final _store = stringMapStoreFactory.store('coaches');

  Future<Database> get _db async => AppDatabase().database;

  Future<List<Coach>> getAll() async {
    final records = await _store.find(await _db);

    return records
        .map((r) => Coach.fromJson(r.value))
        .toList();
  }

  Future<void> add(Coach coach) async {
    await _store.record(coach.id).put(
      await _db,
      coach.toJson(),
    );
  }

  Future<void> update(Coach coach) async {
    await _store.record(coach.id).put(
      await _db,
      coach.toJson(),
    );
  }

}


class TrainingRepository {
  final _store = intMapStoreFactory.store('training_sessions');

  Future<Database> get _db async => AppDatabase().database;

  Future<void> addSession(TrainingSession session) async {
    await _store.add(await _db, session.toJson());
  }

  Future<List<TrainingSession>> getSessionsByPlayer(String playerId) async {
    final records = await _store.find(
      await _db,
      finder: Finder(
        filter: Filter.equals('playerId', playerId),
      ),
    );

    return records
        .map((r) => TrainingSession.fromJson(r.value))
        .toList();
  }
}




class ExportService {
  /// Export all training S as JSON + Saved directly in Android Downloads folder
  static Future<File> exportPlayerSessions({
    required Player player,
    required List<TrainingSession> sessions,
  }) async {
    final jsonData = {
      'playerId': player.id,
      'playerName': player.name,
      'exportedAt': DateTime.now().toIso8601String(),
      'sessions': sessions.map((s) => s.toJson()).toList(),
    };

    final directory = Directory('/storage/emulated/0/Download'); //check
    if (!directory.existsSync()) {
      throw Exception('Download directory not found');
    }

    final file = File(
      '${directory.path}/player_${player.id}_sessions.json',
    );

    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

    return await file.writeAsString(jsonString);
  }
}


