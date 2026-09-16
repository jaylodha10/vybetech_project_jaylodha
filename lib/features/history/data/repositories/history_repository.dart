import '../../../booking/data/dummy/mock_data.dart';
import '../models/ride_history_item.dart';

class HistoryRepository {
  static const int pageSize = 3;

  List<RideHistoryItem> getPage(int page) {
    final all = MockData.dummyRideHistory;
    final start = page * pageSize;
    if (start >= all.length) return [];
    return all.skip(start).take(pageSize).toList();
  }

  bool hasMore(int currentCount) {
    return currentCount < MockData.dummyRideHistory.length;
  }
}
