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
    List<String>? inspirationPaths,
  }) {
    return ProjectModel(
      id: id,
      name: name ?? this.name,
      clientDetails: clientDetails,
      propertyDetails: propertyDetails ?? this.propertyDetails,
      designPreferences: designPreferences ?? this.designPreferences,
      technicalRequirements: technicalRequirements ?? this.technicalRequirements,
      photoPaths: photoPaths ?? this.photoPaths,
      inspirationPaths: inspirationPaths ?? this.inspirationPaths,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }
}

class ClientDetails {
  final String name;
  final String email;
  final String phone;
  final Map<String, String> contactPreferences;

  ClientDetails({
    required this.name,
    this.email = '',
    this.phone = '',
    this.contactPreferences = const {},
  });
}

class PropertyDetails {
  final PropertyType type;
  final List<String> categories; 
  final List<String> spaceTypes; 
  final String city;
  final String locality;
  final double carpetArea;
  final String areaUnit; 
  final double ceilingHeight;
  final String ceilingHeightUnit;
  final String lightAvailability;
  final String ventilation;
  final String currentCondition;
  final int numberOfRooms;
  final Map<String, RoomDimensions> roomMeasurements; 

  PropertyDetails({
    required this.type,
    this.categories = const [],
    this.spaceTypes = const [],
    this.city = '',
    this.locality = '',
    this.carpetArea = 0,
    this.areaUnit = 'sqft',
    this.ceilingHeight = 0,
    this.ceilingHeightUnit = 'feet',
    this.lightAvailability = '',
    this.ventilation = '',
    this.currentCondition = '',
    this.numberOfRooms = 1,
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
  final Map<String, String> flooring; // RoomName -> Material
  final Map<String, String> wallFinish; // RoomName -> Finish
  final Map<String, String> ceilingType; // RoomName -> Type
  final String furnitureStyle;
  final Map<String, String> materialDetails; // Extra details

  MaterialPreferences({
    this.flooring = const {},
    this.wallFinish = const {},
    this.ceilingType = const {},
    this.furnitureStyle = '',
    this.materialDetails = const {},
  });
}

class ColorPalette {
  final List<String> primaryColors;
  final List<String> accentColors;
  final double intensity; 
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
  final List<String> lightingFixtures;
  final String smartHomeLevel; 
  final List<String> smartIntegrations;
  final Map<String, int> electricalPoints;
  final String homeTheater;
  final Map<String, String> storageNeeds; 
  final Map<String, String> windowTreatments;
  final List<String> amenities;
  final BudgetDetails budget;
  final TimelineDetails timeline;
  final Map<String, String> specialRequirements;

  TechnicalRequirements({
    this.lightingTypes = const [],
    this.lightingFixtures = const [],
    this.smartHomeLevel = '',
    this.smartIntegrations = const [],
    this.electricalPoints = const {},
    this.homeTheater = '',
    this.storageNeeds = const {},
    this.windowTreatments = const {},
    this.amenities = const [],
    required this.budget,
    required this.timeline,
    this.specialRequirements = const {},
  });
}

class BudgetDetails {
  final double totalBudget;
  final String breakdownPreference; 
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
