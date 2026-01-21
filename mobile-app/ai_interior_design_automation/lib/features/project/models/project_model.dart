import 'package:uuid/uuid.dart';

enum ProjectStatus { draft, generated, revised, approved }
enum PropertyType { residential, commercial, hospitality, retail, office, other }

class ProjectModel {
  final String id;
  final String name;
  final ClientDetails clientDetails;
  final PropertyDetails propertyDetails;
  final DesignPreferences designPreferences;
  final TechnicalRequirements technicalRequirements;
  final List<String> photoPaths;
  final List<String> inspirationPaths;
  final DateTime createdAt;
  final ProjectStatus status;

  ProjectModel({
    String? id,
    required this.name,
    required this.clientDetails,
    required this.propertyDetails,
    required this.designPreferences,
    required this.technicalRequirements,
    this.photoPaths = const [],
    this.inspirationPaths = const [],
    DateTime? createdAt,
    this.status = ProjectStatus.draft,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  ProjectModel copyWith({
    String? name,
    ProjectStatus? status,
    PropertyDetails? propertyDetails,
    DesignPreferences? designPreferences,
    TechnicalRequirements? technicalRequirements,
    List<String>? photoPaths,
  }) {
    return ProjectModel(
      id: id,
      name: name ?? this.name,
      clientDetails: clientDetails,
      propertyDetails: propertyDetails ?? this.propertyDetails,
      designPreferences: designPreferences ?? this.designPreferences,
      technicalRequirements: technicalRequirements ?? this.technicalRequirements,
      photoPaths: photoPaths ?? this.photoPaths,
      inspirationPaths: inspirationPaths,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}

class ClientDetails {
  final String name;
  final String email;
  final String phone;

  ClientDetails({
    required this.name,
    this.email = '',
    this.phone = '',
  });
}

class PropertyDetails {
  final PropertyType type;
  final List<String> categories; // New Construction, Renovation, etc.
  final List<String> spaceTypes; // Living Room, Kitchen, etc.
  final String city;
  final String locality;
  final double carpetArea;
  final String areaUnit; // sqft, sqm, sq yards
  final double ceilingHeight;
  final String lightAvailability;
  final String ventilation;
  final String currentCondition;
  final Map<String, RoomDimensions> roomMeasurements; // Room Name -> Dimensions

  PropertyDetails({
    required this.type,
    this.categories = const [],
    this.spaceTypes = const [],
    this.city = '',
    this.locality = '',
    this.carpetArea = 0,
    this.areaUnit = 'sqft',
    this.ceilingHeight = 0,
    this.lightAvailability = '',
    this.ventilation = '',
    this.currentCondition = '',
    this.roomMeasurements = const {},
  });
}

class RoomDimensions {
  final double length;
  final double width;
  final double height;

  RoomDimensions({this.length = 0, this.width = 0, this.height = 0});
}

class DesignPreferences {
  final String primaryStyle;
  final List<String> accentStyles;
  final List<String> moods;
  final List<String> themes;
  final MaterialPreferences materials;
  final ColorPalette palette;

  DesignPreferences({
    this.primaryStyle = '',
    this.accentStyles = const [],
    this.moods = const [],
    this.themes = const [],
    required this.materials,
    required this.palette,
  });
}

class MaterialPreferences {
  final String flooring;
  final String wallFinish;
  final String ceilingType;
  final String furnitureStyle;

  MaterialPreferences({
    this.flooring = '',
    this.wallFinish = '',
    this.ceilingType = '',
    this.furnitureStyle = '',
  });
}

class ColorPalette {
  final List<String> primaryColors;
  final List<String> accentColors;
  final double intensity; // 0.0 to 1.0
  final String notes;

  ColorPalette({
    this.primaryColors = const [],
    this.accentColors = const [],
    this.intensity = 0.5,
    this.notes = '',
  });
}

class TechnicalRequirements {
  final List<String> lightingTypes;
  final String smartHomeLevel; // Fully Automated, Partially...
  final Map<String, String> storageNeeds; // Room -> Description
  final BudgetDetails budget;
  final TimelineDetails timeline;
  final Map<String, String> specialRequirements; // Accessibility, Sustainability..

  TechnicalRequirements({
    this.lightingTypes = const [],
    this.smartHomeLevel = '',
    this.storageNeeds = const {},
    required this.budget,
    required this.timeline,
    this.specialRequirements = const {},
  });
}

class BudgetDetails {
  final double totalBudget;
  final String breakdownPreference; // Flexible, Materials-focused...
  final List<String> priorities;

  BudgetDetails({
    this.totalBudget = 0,
    this.breakdownPreference = '',
    this.priorities = const [],
  });
}

class TimelineDetails {
  final String expectedStart;
  final String durationExpectation;
  final String occupancyStatus;

  TimelineDetails({
    this.expectedStart = '',
    this.durationExpectation = '',
    this.occupancyStatus = '',
  });
}
