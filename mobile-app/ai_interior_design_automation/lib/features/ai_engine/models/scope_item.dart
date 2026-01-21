class ScopeItem {
  final String id;
  final String title;
  final String category; // e.g. "Civil", "Electrical", "Furniture"
  final double quantity;
  final String unit; // "sq ft", "nos", "rft"
  final String description;

  ScopeItem({
    required this.id,
    required this.title,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.description,
  });
}
