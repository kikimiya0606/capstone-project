import '../models/dog_state.dart';

abstract interface class DogSaveService {
  Future<DogState?> load();
  Future<void> save(DogState state);
}

/// Keeps growth across room visits without adding a storage dependency.
/// This session ends when the app process restarts.
class SessionDogSaveService implements DogSaveService {
  static final instance = SessionDogSaveService();
  DogState? _stored;

  @override
  Future<DogState?> load() async => _stored;

  @override
  Future<void> save(DogState state) async {
    _stored = state;
  }
}
