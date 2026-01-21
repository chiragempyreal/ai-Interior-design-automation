import 'package:equatable/equatable.dart';

class CostConfigModel extends Equatable {
  final String id;
  final Map<String, MaterialCost> materialCosts;
  final Map<String, LaborRate> laborRates;
  final DesignFeeConfig designFees;
  final double taxPercentage;
  final double markupPercentage;
  final DateTime updatedAt;

  const CostConfigModel({
    required this.id,
    required this.materialCosts,
    required this.laborRates,
    required this.designFees,
    this.taxPercentage = 18.0, // GST in India
    this.markupPercentage = 15.0,
    required this.updatedAt,
  });

  CostConfigModel copyWith({
    String? id,
    Map<String, MaterialCost>? materialCosts,
    Map<String, LaborRate>? laborRates,
    DesignFeeConfig? designFees,
    double? taxPercentage,
    double? markupPercentage,
    DateTime? updatedAt,
  }) {
    return CostConfigModel(
      id: id ?? this.id,
      materialCosts: materialCosts ?? this.materialCosts,
      laborRates: laborRates ?? this.laborRates,
      designFees: designFees ?? this.designFees,
      taxPercentage: taxPercentage ?? this.taxPercentage,
      markupPercentage: markupPercentage ?? this.markupPercentage,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'materialCosts': materialCosts.map((key, value) => MapEntry(key, value.toJson())),
      'laborRates': laborRates.map((key, value) => MapEntry(key, value.toJson())),
      'designFees': designFees.toJson(),
      'taxPercentage': taxPercentage,
      'markupPercentage': markupPercentage,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CostConfigModel.fromJson(Map<String, dynamic> json) {
    return CostConfigModel(
      id: json['id'],
      materialCosts: (json['materialCosts'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, MaterialCost.fromJson(value)),
      ),
      laborRates: (json['laborRates'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, LaborRate.fromJson(value)),
      ),
      designFees: DesignFeeConfig.fromJson(json['designFees']),
      taxPercentage: json['taxPercentage']?.toDouble() ?? 18.0,
      markupPercentage: json['markupPercentage']?.toDouble() ?? 15.0,
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  List<Object?> get props => [id, materialCosts, laborRates, designFees, updatedAt];
}

class MaterialCost extends Equatable {
  final String category;
  final String item;
  final String unit;
  final double pricePerUnit;
  final String? brand;
  final String? quality; // Standard, Premium, Luxury

  const MaterialCost({
    required this.category,
    required this.item,
    required this.unit,
    required this.pricePerUnit,
    this.brand,
    this.quality,
  });

  MaterialCost copyWith({
    String? category,
    String? item,
    String? unit,
    double? pricePerUnit,
    String? brand,
    String? quality,
  }) {
    return MaterialCost(
      category: category ?? this.category,
      item: item ?? this.item,
      unit: unit ?? this.unit,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      brand: brand ?? this.brand,
      quality: quality ?? this.quality,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'item': item,
      'unit': unit,
      'pricePerUnit': pricePerUnit,
      'brand': brand,
      'quality': quality,
    };
  }

  factory MaterialCost.fromJson(Map<String, dynamic> json) {
    return MaterialCost(
      category: json['category'],
      item: json['item'],
      unit: json['unit'],
      pricePerUnit: json['pricePerUnit'].toDouble(),
      brand: json['brand'],
      quality: json['quality'],
    );
  }

  @override
  List<Object?> get props => [category, item, unit, pricePerUnit];
}

enum RateType { perDay, perSqFt, perItem, fixed }

class LaborRate extends Equatable {
  final String skillLevel; // Helper, Skilled, Expert
  final RateType rateType;
  final double amount;
  final String? description;

  const LaborRate({
    required this.skillLevel,
    required this.rateType,
    required this.amount,
    this.description,
  });

  LaborRate copyWith({
    String? skillLevel,
    RateType? rateType,
    double? amount,
    String? description,
  }) {
    return LaborRate(
      skillLevel: skillLevel ?? this.skillLevel,
      rateType: rateType ?? this.rateType,
      amount: amount ?? this.amount,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'skillLevel': skillLevel,
      'rateType': rateType.name,
      'amount': amount,
      'description': description,
    };
  }

  factory LaborRate.fromJson(Map<String, dynamic> json) {
    return LaborRate(
      skillLevel: json['skillLevel'],
      rateType: RateType.values.firstWhere(
        (e) => e.name == json['rateType'],
        orElse: () => RateType.perDay,
      ),
      amount: json['amount'].toDouble(),
      description: json['description'],
    );
  }

  @override
  List<Object?> get props => [skillLevel, rateType, amount];
}

class DesignFeeConfig extends Equatable {
  final double percentageOfTotal; // e.g., 10% of project cost
  final double minFlatAmount; // Minimum fee
  final double perSqFtRate; // Alternative pricing

  const DesignFeeConfig({
    this.percentageOfTotal = 10.0,
    this.minFlatAmount = 50000.0,
    this.perSqFtRate = 150.0,
  });

  DesignFeeConfig copyWith({
    double? percentageOfTotal,
    double? minFlatAmount,
    double? perSqFtRate,
  }) {
    return DesignFeeConfig(
      percentageOfTotal: percentageOfTotal ?? this.percentageOfTotal,
      minFlatAmount: minFlatAmount ?? this.minFlatAmount,
      perSqFtRate: perSqFtRate ?? this.perSqFtRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentageOfTotal': percentageOfTotal,
      'minFlatAmount': minFlatAmount,
      'perSqFtRate': perSqFtRate,
    };
  }

  factory DesignFeeConfig.fromJson(Map<String, dynamic> json) {
    return DesignFeeConfig(
      percentageOfTotal: json['percentageOfTotal']?.toDouble() ?? 10.0,
      minFlatAmount: json['minFlatAmount']?.toDouble() ?? 50000.0,
      perSqFtRate: json['perSqFtRate']?.toDouble() ?? 150.0,
    );
  }

  @override
  List<Object?> get props => [percentageOfTotal, minFlatAmount, perSqFtRate];
}
