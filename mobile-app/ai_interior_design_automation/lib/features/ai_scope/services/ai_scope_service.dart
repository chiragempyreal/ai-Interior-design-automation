import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import '../../project/models/project_model.dart';
import '../models/scope_model.dart';

class AiScopeService {
  // Get API key from environment variable
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  final _uuid = const Uuid();

  /// Generate AI-powered scope for a project
  Future<ScopeModel> generateScope(ProjectModel project) async {
    try {
      // Build the prompt
      final prompt = _buildScopePrompt(project);

      // For demo/offline mode, return mock data
      if (_apiKey.isEmpty || _apiKey == "YOUR_GEMINI_API_KEY") {
        return _generateMockScope(project, prompt);
      }

      // Call Gemini API
      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Parse AI response into ScopeModel
        return _parseAiResponse(project.id, aiResponse, prompt);
      } else {
        throw Exception('Failed to generate scope: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data on error
      return _generateMockScope(project, _buildScopePrompt(project));
    }
  }

  String _buildScopePrompt(ProjectModel project) {
    final floors = project.designPreferences.materials.flooring.entries.map((e) => "${e.key}: ${e.value}").join(', ');
    final walls = project.designPreferences.materials.wallFinish.entries.map((e) => "${e.key}: ${e.value}").join(', ');
    final tech = project.technicalRequirements.smartHomeLevel;
    final lights = project.technicalRequirements.lightingTypes.join(', ');

    return '''
Generate a detailed interior design project scope for:

Project: ${project.name}
Type: ${project.propertyDetails.type.name.toUpperCase()}
Area: ${project.propertyDetails.carpetArea} ${project.propertyDetails.areaUnit}
Location: ${project.propertyDetails.city}
Budget: ₹${project.technicalRequirements.budget.totalBudget} (${project.technicalRequirements.budget.breakdownPreference})
Timeline: ${project.technicalRequirements.timeline.durationExpectation}
Current Status: ${project.propertyDetails.currentCondition}

DESIGN PREFERENCES:
Style: ${project.designPreferences.primaryStyle}
Vibe: ${project.designPreferences.moods.join(', ')}
Palette: ${project.designPreferences.palette.primaryColors.join(', ')}
Flooring: $floors
Walls: $walls
Furniture Style: ${project.designPreferences.materials.furnitureStyle}

TECHNICAL REQUIREMENTS:
Lighting: $lights
Smart Home: $tech
Amenities: ${project.technicalRequirements.amenities.join(', ')}
Special Notes: ${project.technicalRequirements.specialRequirements['notes'] ?? ''}

Please provide a phase-wise breakdown with:
1. Phase name and description
2. List of tasks for each phase
3. Duration estimate for each task
4. Required resources/materials
5. Estimated cost per task

Organize into these phases:
- Design & Planning
- Execution & Construction
- Finishing & Styling

Format the response as a structured breakdown.
''';
  }

  ScopeModel _parseAiResponse(String projectId, String aiResponse, String prompt) {
    // This is a simplified parser - in production, you'd use more sophisticated parsing
    // For now, return a structured mock based on AI response
    // We create a dummy project to pass to mock generator
    return _generateMockScope(
       ProjectModel(
        id: projectId,
        name: 'Parsed Project',
        clientDetails: ClientDetails(name: 'User'),
        propertyDetails: PropertyDetails(
          type: PropertyType.residential,
          carpetArea: 1000,
        ),
        designPreferences: DesignPreferences(materials: MaterialPreferences(), palette: ColorPalette()),
        technicalRequirements: TechnicalRequirements(
           budget: BudgetDetails(totalBudget: 800000), 
           timeline: TimelineDetails()
        ),
      ),
      prompt,
    );
  }

  ScopeModel _generateMockScope(ProjectModel project, String prompt) {
    final area = project.propertyDetails.carpetArea > 0 ? project.propertyDetails.carpetArea : 1000.0;
    final budget = project.technicalRequirements.budget.totalBudget > 0 
        ? project.technicalRequirements.budget.totalBudget 
        : 500000.0;

    return ScopeModel(
      id: _uuid.v4(),
      projectId: project.id,
      generatedAt: DateTime.now(),
      aiPrompt: prompt,
      aiResponse: "AI-generated scope (mock mode)",
      totalDuration: 60, // 60 days total
      phases: [
        // Phase 1: Design & Planning
        PhaseModel(
          id: _uuid.v4(),
          name: "Design & Planning",
          description: "Initial design concepts, 3D renders, and material selection",
          order: 1,
          duration: 15,
          tasks: [
            TaskModel(
              id: _uuid.v4(),
              name: "Site Survey & Measurement",
              description: "Detailed site survey and accurate measurements",
              duration: 2,
              resources: ["Measuring tools", "Survey equipment"],
              estimatedCost: 5000,
              priority: TaskPriority.high,
            ),
            TaskModel(
              id: _uuid.v4(),
              name: "Concept Design",
              description: "Initial design concepts and mood boards",
              duration: 5,
              resources: ["Design software", "Material samples"],
              estimatedCost: area * 50,
              priority: TaskPriority.high,
            ),
             TaskModel(
              id: _uuid.v4(),
              name: "3D Visualization",
              description: "Detailed 3D renders of all spaces",
              duration: 5,
              resources: ["3D software", "Rendering tools"],
              estimatedCost: area * 30,
              priority: TaskPriority.medium,
            ),
          ],
        ),

        // Phase 2: Execution & Construction
        PhaseModel(
          id: _uuid.v4(),
          name: "Execution & Construction",
          description: "Civil work, electrical, plumbing, and structural changes",
          order: 2,
          duration: 30,
          dependencies: [],
          tasks: [
            TaskModel(
              id: _uuid.v4(),
              name: "False Ceiling Work",
              description: "Gypsum false ceiling installation",
              duration: 10,
              resources: ["Gypsum boards", "Metal framework", "Labor"],
              estimatedCost: area * 120,
              priority: TaskPriority.high,
            ),
            TaskModel(
              id: _uuid.v4(),
              name: "Electrical Work",
              description: "Wiring, switches, and lighting points",
              duration: 8,
              resources: ["Wires", "Switches", "Electrician"],
              estimatedCost: area * 80,
              priority: TaskPriority.critical,
            ),
             TaskModel(
              id: _uuid.v4(),
              name: "Flooring",
              description: "Tile/wooden flooring installation",
              duration: 10,
              resources: ["Tiles/Wood", "Adhesive", "Labor"],
              estimatedCost: area * 150,
              priority: TaskPriority.high,
            ),
          ],
        ),

        // Phase 3: Finishing & Styling
        PhaseModel(
          id: _uuid.v4(),
          name: "Finishing & Styling",
          description: "Furniture, lighting, and final touches",
          order: 3,
          duration: 15,
          dependencies: [],
          tasks: [
            TaskModel(
              id: _uuid.v4(),
              name: "Modular Kitchen",
              description: "Complete modular kitchen installation",
              duration: 7,
              resources: ["Cabinets", "Countertop", "Hardware"],
              estimatedCost: budget * 0.15,
              priority: TaskPriority.high,
            ),
             TaskModel(
              id: _uuid.v4(),
              name: "Lighting Installation",
              description: "All light fixtures and decorative lighting",
              duration: 3,
              resources: ["Light fixtures", "LED strips", "Electrician"],
              estimatedCost: area * 100,
              priority: TaskPriority.medium,
            ),
          ],
        ),
      ],
    );
  }

  /// Get scope suggestions based on property type
  List<String> getScopeSuggestions(PropertyType type) {
    switch (type) {
      case PropertyType.residential:
        return [
          "Living room design",
          "Bedroom interiors",
          "Modular kitchen",
          "Bathroom renovation",
          "False ceiling",
        ];
      case PropertyType.office:
        return [
          "Workstation setup",
          "Conference room",
          "Reception area",
          "IT infrastructure",
        ];
      case PropertyType.commercial:
      case PropertyType.retail:
        return [
          "Display units",
          "Billing counter",
          "Signage & branding",
          "Customer seating",
        ];
      case PropertyType.hospitality:
         return [
           "Guest rooms",
           "Lobby design",
           "Kitchen setup",
         ];
      default:
        return ["Interior Design"];
    }
  }
  /// Generate furniture suggestions from image
  Future<List<Map<String, dynamic>>> generateFurnitureSuggestions(String imagePath) async {
    try {
      if (_apiKey.isEmpty || _apiKey == "YOUR_GEMINI_API_KEY") {
        return [
           {"name": "Modern Armchair", "price": 15000, "reason": "Fits the corner 50x50 area perfectly"},
           {"name": "Floor Lamp", "price": 5000, "reason": "Adds ambient lighting near the chair"},
           {"name": "Side Table", "price": 3500, "reason": "Functional addition for the seating area"},
        ];
      }

      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      final prompt = '''
      Analyze this room image. Identify empty spaces suitable for a 50x50 sq ft area.
      Suggest 3 furniture items to furnish this space.
      Return strictly a JSON list of objects with keys: "name", "price" (in INR, number only), "reason".
      Do not add markdown formatting like ```json ... ```.
      ''';

      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {
                    'mime_type': 'image/jpeg',
                    'data': base64Image
                  }
                }
              ]
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];
        // Cleanup markdown if present
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final List<dynamic> jsonList = jsonDecode(text);
        return List<Map<String, dynamic>>.from(jsonList);
      }
      throw Exception('Failed to generate furniture suggestions');
    } catch (e) {
      print("Vision API Error: $e");
      return [
         {"name": "Lounge Chair", "price": 12000, "reason": "Mock: Fits the space well"},
         {"name": "Rug", "price": 4000, "reason": "Mock: Adds texture"},
      ];
    }
  }
}
