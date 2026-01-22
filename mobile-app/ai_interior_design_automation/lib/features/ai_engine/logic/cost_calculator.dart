import '../models/scope_item.dart';
import '../models/quote_model.dart';

class CostCalculator {
  // Configurable Rates (Mock Config)
  static const Map<String, double> _rates = {
    "Civil": 85.0,
    "POP/Ceiling": 120.0,
    "Furniture": 1800.0,
    "Electrical": 650.0,
  };

  static QuoteModel calculate(List<ScopeItem> items) {
    double totalMaterial = 0;
    double totalLabor = 0;
    List<QuoteLineItem> lineItems = [];

    for (var item in items) {
      double rate = _rates[item.category] ?? 100.0;

      if (item.title.contains("Wardrobe")) rate = 2200;
      if (item.title.contains("Kitchen")) rate = 2500;

      double amount = item.quantity * rate;
      double material = amount * 0.60;
      double labor = amount * 0.40;

      totalMaterial += material;
      totalLabor += labor;

      lineItems.add(
        QuoteLineItem(scopeItem: item, unitRate: rate, amount: amount),
      );
    }

    double executionTotal = totalMaterial + totalLabor;
    double designFee = executionTotal * 0.10;

    return QuoteModel(
      totalAmount: executionTotal + designFee,
      materialCost: totalMaterial,
      laborCost: totalLabor,
      designFee: designFee,
      lineItems: lineItems,
    );
  }
}
