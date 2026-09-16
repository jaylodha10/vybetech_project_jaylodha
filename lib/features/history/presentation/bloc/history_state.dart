part of 'history_bloc.dart';

abstract class HistoryState {}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<RideHistoryItem> rides;
  final bool hasMore;
  final bool isLoadingMore;

  HistoryLoaded({
    required this.rides,
    required this.hasMore,
    this.isLoadingMore = false,
  });
}

class HistoryError extends HistoryState {
  final String message;
  HistoryError(this.message);
}
