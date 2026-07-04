import 'package:shared_preferences/shared_preferences.dart';

/// Persistence boundary for the single high-score value (SR-6).
///
/// Kept as an interface so the game logic ([HighscoreService]) can be unit
/// tested against a fake — including a store that *throws* — without pulling in
/// the platform channel that [SharedPreferences] needs.
abstract class HighscoreStore {
  /// Reads the persisted best score. Returns `0` when nothing was ever saved.
  /// May throw if the backing store is unavailable — callers decide how to
  /// degrade.
  Future<int> read();

  /// Persists [value] as the new best. Throws if the write did not succeed, so
  /// the caller can keep its in-memory value consistent with storage (AC4).
  Future<void> write(int value);
}

/// [HighscoreStore] backed by `shared_preferences` — a small local key/value
/// store that survives app restarts.
class SharedPrefsHighscoreStore implements HighscoreStore {
  const SharedPrefsHighscoreStore();

  static const String _key = 'asteroids.highscore';

  @override
  Future<int> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }

  @override
  Future<void> write(int value) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setInt(_key, value);
    if (!ok) {
      throw StateError('failed to persist high score ($value)');
    }
  }
}

/// Owns the current best score in memory and mediates every read/write to the
/// [HighscoreStore] (SR-6).
///
/// Two invariants back the negative scenarios:
///  * **AC4 (storage failure):** the in-memory [best] is only advanced *after*
///    a successful persist. A read/write that throws is swallowed, [best] keeps
///    its previous value, and no exception escapes — the game never crashes on
///    a storage fault and memory never disagrees with disk.
///  * **Load-before-compare:** [submit] internally awaits [load] before it
///    compares, so a submit that fires while the persisted best is still being
///    read never sees a stale `0` and can never clobber a real record with a
///    lower score. Concurrent submits are serialized through [_tail] so two
///    game-overs racing (e.g. a fast restart) can't both decide against the
///    same `_best` — the higher score always wins.
class HighscoreService {
  HighscoreService(this._store);

  final HighscoreStore _store;

  int _best = 0;

  /// Memoized load — read the store at most once; every [submit] awaits it.
  Future<void>? _loaded;

  /// Serializes submits: each new submit chains onto the previous one so their
  /// compare-then-write sequences never interleave.
  Future<void> _tail = Future<void>.value();

  /// The best score known this session — `0` until [load] resolves.
  int get best => _best;

  /// Loads the persisted best (once). A read failure is swallowed and leaves
  /// [best] at its current value (0 on a fresh start), so a broken store
  /// degrades to "no record yet" rather than a crash. Idempotent: repeated
  /// calls return the same in-flight/completed future.
  Future<void> load() => _loaded ??= _doLoad();

  Future<void> _doLoad() async {
    try {
      _best = await _store.read();
    } catch (_) {
      // Keep the current in-memory value; a missing/broken store is not fatal.
    }
  }

  /// Compares [score] against the best and, when higher, tries to persist it.
  ///
  /// Returns `true` only when [score] became the new best *and* the write
  /// succeeded. A non-record score returns `false` without touching the store;
  /// a failed write also returns `false` and leaves [best] unchanged (AC4).
  ///
  /// The comparison is deferred until [load] has completed and until any prior
  /// submit has finished, so it always runs against an up-to-date [best].
  Future<bool> submit(int score) {
    final result = _tail.then((_) => _submitLocked(score));
    // Keep the serialization chain alive regardless of this submit's outcome.
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }

  Future<bool> _submitLocked(int score) async {
    await load(); // never compare against an unloaded (stale-zero) best
    if (score <= _best) return false;
    try {
      await _store.write(score);
      _best = score; // committed to memory only after a durable write
      return true;
    } catch (_) {
      return false;
    }
  }
}
