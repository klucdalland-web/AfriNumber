import '../models/offer_item.dart';
import '../models/transaction_item.dart';

abstract class DashboardRepository {
  Future<List<TransactionItem>> fetchRecentTransactions();
  Future<List<OfferItem>> fetchRecommendedOffers();
}
