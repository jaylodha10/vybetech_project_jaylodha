part of 'history_bloc.dart';

abstract class HistoryEvent {}

class HistoryLoadRequested extends HistoryEvent {}

class HistoryLoadMoreRequested extends HistoryEvent {}
