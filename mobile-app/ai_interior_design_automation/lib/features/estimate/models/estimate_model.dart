import 'package:equatable/equatable.dart';

enum EstimateStatus {
  draft,
  pending,
  approved,
  rejected,
  revised,
}

class EstimateModel extends Equatable {
  final String id;
  final String projectId;
  final String projectName;
  final int version;
  final List<EstimateItem> items;
  final double subtotal;
  final double tax;
  final double total;
  final EstimateStatus status;
  final String? explanation;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final String? rejectionReason;
  final String? designImageUrl;

  const EstimateModel({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.version,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.total,
    this.status = EstimateStatus.draft,
    this.explanation,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    this.rejectionReason,
    this.designImageUrl,
  });

  EstimateModel copyWith({
    String? id,
    String? projectId,
    String? projectName,
    int? version,
    List<EstimateItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    EstimateStatus? status,
    String? explanation,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
    String? rejectionReason,
    String? designImageUrl,
  }) {
    return EstimateModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      version: version ?? this.version,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      explanation: explanation ?? this.explanation,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      designImageUrl: designImageUrl ?? this.designImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'projectName': projectName,
      'version': version,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': status.name,
      'explanation': explanation,
      'createdAt': createdAt.toIso8601String(),
      'approvedAt': approvedAt?.toIso8601String(),
      'approvedBy': approvedBy,
      'rejectionReason': rejectionReason,
      'designImageUrl': designImageUrl,
    };
  }

  factory EstimateModel.fromJson(Map<String, dynamic> json) {
    return EstimateModel(
      id: json['id'],
      projectId: json['projectId'],
      projectName: json['projectName'],
      version: json['version'],
      items: (json['items'] as List)
          .map((item) => EstimateItem.fromJson(item))
          .toList(),
      subtotal: json['subtotal'].toDouble(),
      tax: json['tax'].toDouble(),
      total: json['total'].toDouble(),
      status: EstimateStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EstimateStatus.draft,
      ),
      explanation: json['explanation'],
      createdAt: DateTime.parse(json['createdAt']),
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
      approvedBy: json['approvedBy'],
      rejectionReason: json['rejectionReason'],
      designImageUrl: json['designImageUrl'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        version,
        items,
        subtotal,
        tax,
        total,
        status,
        createdAt,
      ];
}

enum EstimateCategory {
  design,
  materials,
  labor,
  furniture,
  lighting,
  accessories,
  other,
}

class EstimateItem extends Equatable {
  final String id;
  final EstimateCategory category;
  final String description;
  final double quantity;
  final String unit;
  final double rate;
  final double amount;
  final String? notes;

  const EstimateItem({
    required this.id,
    required this.category,
    required this.description,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.amount,
    this.notes,
  });

  EstimateItem copyWith({
    String? id,
    EstimateCategory? category,
    String? description,
    double? quantity,
    String? unit,
    double? rate,
    double? amount,
    String? notes,
  }) {
    return EstimateItem(
      id: id ?? this.id,
      category: category ?? this.category,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'amount': amount,
      'notes': notes,
    };
  }

  factory EstimateItem.fromJson(Map<String, dynamic> json) {
    return EstimateItem(
      id: json['id'],
      category: EstimateCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => EstimateCategory.other,
      ),
      description: json['description'],
      quantity: json['quantity'].toDouble(),
      unit: json['unit'],
      rate: json['rate'].toDouble(),
      amount: json['amount'].toDouble(),
      notes: json['notes'],
    );
  }

  @override
  List<Object?> get props => [
        id,
        category,
        description,
        quantity,
        unit,
        rate,
        amount,
      ];
}
