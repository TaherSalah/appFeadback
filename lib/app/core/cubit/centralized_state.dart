part of 'centralized_cubit.dart';

abstract class CentralizedState {}

class CentralizedInitial extends CentralizedState {}

class LocalizationState extends CentralizedState {}

class ThemeState extends CentralizedState {}

class ChangeLanguageState extends CentralizedState {}

class OnChangetextState extends CentralizedState {}

enum ConnectivityStatus { connected, disconnected }

class ConnectivityState extends CentralizedState {
  final ConnectivityStatus? status;

  ConnectivityState({this.status});
}

// جديد:
class AzkarFontChangedState extends CentralizedState {}