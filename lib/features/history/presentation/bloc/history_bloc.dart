import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/ride_history_item.dart';
import '../../data/repositories/history_repository.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository historyRepository;
  int _currentPage = 0;

  HistoryBloc({required this.historyRepository}) : super(HistoryInitial()) {
    on<HistoryLoadRequested>(_onLoadRequested);
    on<HistoryLoadMoreRequested>(_onLoadMoreRequested);
  }

  Future<void> _onLoadRequested(
    HistoryLoadRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    _currentPage = 0;
    final rides = historyRepository.getPage(0);
    _currentPage = 1;
    emit(
      HistoryLoaded(
        rides: rides,
        hasMore: historyRepository.hasMore(rides.length),
      ),
    );
  }

  Future<void> _onLoadMoreRequested(
    HistoryLoadMoreRequested event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is! HistoryLoaded) return;
    final current = state as HistoryLoaded;
    if (!current.hasMore || current.isLoadingMore) return;

    emit(
      HistoryLoaded(
        rides: current.rides,
        hasMore: current.hasMore,
        isLoadingMore: true,
      ),
    );
    await Future.delayed(const Duration(milliseconds: 800));

    final newRides = historyRepository.getPage(_currentPage);
    _currentPage++;
    final allRides = [...current.rides, ...newRides];
    emit(
      HistoryLoaded(
        rides: allRides,
        hasMore: historyRepository.hasMore(allRides.length),
      ),
    );
  }
}
