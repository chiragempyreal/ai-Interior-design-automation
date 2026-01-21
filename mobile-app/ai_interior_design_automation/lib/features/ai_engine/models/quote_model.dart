import 'scope_item.dart';

class QuoteModel {
  final double totalAmount;
  final double materialCost;
  final double laborCost;
  final double designFee;
  final List<QuoteLineItem> lineItems;

  QuoteModel({
    required this.totalAmount,
    required this.materialCost,
    required this.laborCost,
    required this.designFee,
    required this.lineItems,
  });
}

class QuoteLineItem {
  final ScopeItem scopeItem;
  final double unitRate;
  final double amount;

  QuoteLineItem({
    required this.scopeItem,
    required this.unitRate,
    required this.amount,
  });
}
