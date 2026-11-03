import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeCubit extends Cubit<bool> {
  ThemeCubit({this._preferences, bool initialDark = false})
    : super(initialDark);

  static const _darkModeKey = 'dark_mode';

  final Box<bool>? _preferences;

  Future<void> toggle() async {
    final nextMode = !state;
    emit(nextMode);
    try {
      await _preferences?.put(_darkModeKey, nextMode);
    } catch (error) {
      emit(!nextMode);
      rethrow;
    }
  }
}
