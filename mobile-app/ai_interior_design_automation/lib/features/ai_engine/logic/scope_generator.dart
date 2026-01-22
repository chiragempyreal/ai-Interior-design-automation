import 'package:uuid/uuid.dart';
import '../models/scope_item.dart';
import '../../project/models/project_model.dart';

class ScopeGenerator {
  static List<ScopeItem> generateScope({
    required PropertyType propertyType,
    required double carpetArea,
    required String style,
    required List<String> roomTypes,
  }) {
    List<ScopeItem> items = [];
    final uuid = const Uuid();

    // 1. Civil Work
    items.add(
      ScopeItem(
        id: uuid.v4(),
        title: "Wall Preparation & Painting",
        category: "Civil",
        quantity: carpetArea * 2.5,
        unit: "sq ft",
        description: "Premium emulsion paint with 2 coat putty.",
      ),
    );

    // 2. Flooring
    items.add(
      ScopeItem(
        id: uuid.v4(),
        title: "Vitrified Tiling Work",
        category: "Civil",
        quantity: carpetArea,
        unit: "sq ft",
        description: "600x1200mm GVT Tiles installation.",
      ),
    );

    // 3. Room Specifics
    for (var room in roomTypes) {
      if (room == "Living Area") {
        items.add(
          ScopeItem(
            id: uuid.v4(),
            title: "False Ceiling (Living)",
            category: "POP/Ceiling",
            quantity: 150,
            unit: "sq ft",
            description:
                "Gypsum board false ceiling with cove lighting channel.",
          ),
        );
        items.add(
          ScopeItem(
            id: uuid.v4(),
            title: "TV Unit Console",
            category: "Furniture",
            quantity: 1,
            unit: "nos",
            description: "6ft x 5ft TV Unit with laminate finish.",
          ),
        );
      } else if (room == "Kitchen") {
        items.add(
          ScopeItem(
            id: uuid.v4(),
            title: "Modular Kitchen Cabinets",
            category: "Furniture",
            quantity: 60,
            unit: "sq ft",
            description: "BWP Grade Plywood with Acrylic shutters.",
          ),
        );
      } else if (room == "Master Bedroom") {
        items.add(
          ScopeItem(
            id: uuid.v4(),
            title: "Wardrobe (Sliding)",
            category: "Furniture",
            quantity: 45,
            unit: "sq ft",
            description: "Floor to ceiling sliding wardrobe.",
          ),
        );
      }
    }

    // 4. Electrical
    items.add(
      ScopeItem(
        id: uuid.v4(),
        title: "Electrical Point Wiring",
        category: "Electrical",
        quantity: (carpetArea / 50).ceil().toDouble() * 4,
        unit: "points",
        description: "New wiring for sockets and lights.",
      ),
    );

    return items;
  }
}
