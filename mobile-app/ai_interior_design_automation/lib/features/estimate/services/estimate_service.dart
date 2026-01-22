import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import '../../project/models/project_model.dart';
import '../../ai_scope/models/scope_model.dart';
import '../../cost_config/models/cost_config_model.dart';
import '../models/estimate_model.dart';

class EstimateService {
  // Get API key from environment variable
  static String get _apiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? 'AIzaSyCDNDZzkQhsc9fXavt_woHlv_RyFnWm_Ro';
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  final _uuid = const Uuid();

  /// Generate estimate from project and scope
  Future<EstimateModel> generateEstimate({
    required ProjectModel project,
    required ScopeModel scope,
    required CostConfigModel costConfig,
  }) async {
    // 1. Analyze the Input Image to get Structural Context
    String? structuralContext;

    // We prioritize using our local robust analysis over the external service to ensure
    // the image is actually "seen" by Gemini.
    if (project.photoPaths.isNotEmpty) {
      try {
        // Pass 'project' so we can access style/area for the meta-prompt
        structuralContext = await _analyzeImageStructure(
          project,
          project.photoPaths.first,
        );
      } catch (e) {
        print("Structure analysis failed: $e");
      }
    }

    final prompt = _buildEstimatePrompt(project, scope, costConfig);

    try {
      // For demo/offline mode, return calculated estimate
      if (_apiKey.isEmpty || _apiKey == "YOUR_GEMINI_API_KEY") {
        return _calculateEstimate(
          project,
          scope,
          costConfig,
          prompt,
          structuralContext,
        );
      }

      // Call Gemini API for Estimate Explanation (Text Only)
      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {'temperature': 0.5, 'maxOutputTokens': 2048},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];

        // Use AI response as explanation, but calculate costs ourselves
        final estimate = _calculateEstimate(
          project,
          scope,
          costConfig,
          prompt,
          structuralContext,
        );
        return estimate.copyWith(explanation: aiResponse);
      } else {
        throw Exception('Failed to generate estimate: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to calculated estimate
      return _calculateEstimate(
        project,
        scope,
        costConfig,
        prompt,
        structuralContext,
      );
    }
  }

  /// Regenerates only the AI design image (useful for "Try Again" functionality)
  Future<String> refreshDesignImage(ProjectModel project) async {
    String? structuralContext;
    if (project.photoPaths.isNotEmpty) {
      try {
        structuralContext = await _analyzeImageStructure(
          project,
          project.photoPaths.first,
        );
      } catch (e) {
        print("Refresh analysis failed: $e");
      }
    }
    return _generateDesignImageUrl(project, structuralContext);
  }

  String _buildEstimatePrompt(
    ProjectModel project,
    ScopeModel scope,
    CostConfigModel costConfig,
  ) {
    return '''
Generate a detailed budget estimate explanation for:

Project: ${project.name}
Property: ${project.propertyDetails.type.name} - ${project.propertyDetails.carpetArea} sq ft
Budget: ₹${project.technicalRequirements.budget.totalBudget}

Scope Summary:
${scope.phases.map((p) => '- ${p.name}: ${p.tasks.length} tasks, ${p.duration} days').join('\n')}

Please provide:
1. Explanation of cost breakdown
2. Justification for major expenses
3. Cost-saving suggestions
4. Alternative options if budget is tight
5. Timeline impact on costs

Keep it professional and client-friendly.
''';
  }

  EstimateModel _calculateEstimate(
    ProjectModel project,
    ScopeModel scope,
    CostConfigModel costConfig,
    String prompt,
    String? structuralContext,
  ) {
    final area = project.propertyDetails.carpetArea;
    final items = <EstimateItem>[];

    // 1. Design Fees
    final designFee = _calculateDesignFee(area, costConfig.designFees);
    items.add(
      EstimateItem(
        id: _uuid.v4(),
        category: EstimateCategory.design,
        description: "Complete Interior Design Services",
        quantity: area,
        unit: "sq ft",
        rate: costConfig.designFees.perSqFtRate,
        amount: designFee,
        notes: "Includes concept design, 3D renders, and supervision",
      ),
    );

    // 2. Calculate costs from scope tasks
    for (final phase in scope.phases) {
      for (final task in phase.tasks) {
        if (task.estimatedCost > 0) {
          items.add(
            EstimateItem(
              id: _uuid.v4(),
              category: _mapTaskToCategory(task.name),
              description: task.name,
              quantity: 1,
              unit: "item",
              rate: task.estimatedCost,
              amount: task.estimatedCost,
              notes: task.description,
            ),
          );
        }
      }
    }

    // 3. Add standard materials based on property type
    items.addAll(_getStandardMaterials(project, area, costConfig));

    // 4. Add labor costs
    items.addAll(_getLaborCosts(project, area, costConfig));

    // Calculate totals
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.amount);
    final tax = subtotal * (costConfig.taxPercentage / 100);
    final total = subtotal + tax;

    return EstimateModel(
      id: _uuid.v4(),
      projectId: project.id,
      projectName: project.name,
      version: 1,
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: EstimateStatus.draft,
      createdAt: DateTime.now(),
      explanation: _generateExplanation(project, subtotal, total),
      // Pass the structural context
      designImageUrl: _generateDesignImageUrl(project, structuralContext),
    );
  }

  double _calculateDesignFee(double area, DesignFeeConfig config) {
    final perSqFtFee = area * config.perSqFtRate;
    return perSqFtFee > config.minFlatAmount
        ? perSqFtFee
        : config.minFlatAmount;
  }

  EstimateCategory _mapTaskToCategory(String taskName) {
    final lower = taskName.toLowerCase();
    if (lower.contains('design') || lower.contains('concept')) {
      return EstimateCategory.design;
    } else if (lower.contains('furniture') ||
        lower.contains('wardrobe') ||
        lower.contains('kitchen')) {
      return EstimateCategory.furniture;
    } else if (lower.contains('light')) {
      return EstimateCategory.lighting;
    } else if (lower.contains('floor') ||
        lower.contains('wall') ||
        lower.contains('ceiling')) {
      return EstimateCategory.materials;
    } else if (lower.contains('decor') || lower.contains('accessory')) {
      return EstimateCategory.accessories;
    } else {
      return EstimateCategory.labor;
    }
  }

  List<EstimateItem> _getStandardMaterials(
    ProjectModel project,
    double area,
    CostConfigModel costConfig,
  ) {
    final items = <EstimateItem>[];

    // Flooring
    items.add(
      EstimateItem(
        id: _uuid.v4(),
        category: EstimateCategory.materials,
        description: "Vitrified Tiles - Premium Quality",
        quantity: area,
        unit: "sq ft",
        rate: 80,
        amount: area * 80,
        notes: "800x800mm tiles with installation",
      ),
    );

    // Paint
    items.add(
      EstimateItem(
        id: _uuid.v4(),
        category: EstimateCategory.materials,
        description: "Premium Emulsion Paint",
        quantity: area * 2.5, // Wall area approximation
        unit: "sq ft",
        rate: 35,
        amount: area * 2.5 * 35,
        notes: "Asian Paints Royale or equivalent",
      ),
    );

    // Electrical
    items.add(
      EstimateItem(
        id: _uuid.v4(),
        category: EstimateCategory.materials,
        description: "Electrical Fittings & Wiring",
        quantity: area,
        unit: "sq ft",
        rate: 60,
        amount: area * 60,
        notes: "Switches, sockets, wiring, MCB",
      ),
    );

    return items;
  }

  List<EstimateItem> _getLaborCosts(
    ProjectModel project,
    double area,
    CostConfigModel costConfig,
  ) {
    final items = <EstimateItem>[];

    items.add(
      EstimateItem(
        id: _uuid.v4(),
        category: EstimateCategory.labor,
        description: "Civil & Construction Labor",
        quantity: area,
        unit: "sq ft",
        rate: 100,
        amount: area * 100,
        notes: "Skilled and helper labor for 60 days",
      ),
    );

    items.add(
      EstimateItem(
        id: _uuid.v4(),
        category: EstimateCategory.labor,
        description: "Carpenter & Finishing Work",
        quantity: area,
        unit: "sq ft",
        rate: 80,
        amount: area * 80,
        notes: "Furniture installation and finishing",
      ),
    );

    return items;
  }

  String _generateExplanation(
    ProjectModel project,
    double subtotal,
    double total,
  ) {
    return '''
Budget Estimate Breakdown:

This estimate is prepared for ${project.name} covering ${project.propertyDetails.carpetArea} sq ft ${project.propertyDetails.type.name}.

Cost Summary:
- Subtotal: ₹${subtotal.toStringAsFixed(2)}
- Tax (18% GST): ₹${(total - subtotal).toStringAsFixed(2)}
- Total Estimate: ₹${total.toStringAsFixed(2)}

The estimate includes:
✓ Complete design services with 3D visualization
✓ Premium quality materials
✓ Skilled labor and supervision
✓ All electrical and plumbing work
✓ Modular furniture and storage solutions
✓ Lighting and accessories

Budget Alignment:
Your budget: ₹${project.technicalRequirements.budget.totalBudget}
This estimate: ₹${total.toStringAsFixed(0)}

${total <= project.technicalRequirements.budget.totalBudget ? '✓ Within your budget' : '⚠ Slightly above budget - we can suggest cost optimizations'}

Timeline: Approximately 60 days from start to completion.

Note: Prices are indicative and may vary based on final material selection and market rates.
''';
  }

  /// Optimize estimate to fit budget
  EstimateModel optimizeForBudget(EstimateModel estimate, double targetBudget) {
    if (estimate.total <= targetBudget) {
      return estimate;
    }

    final reductionNeeded = estimate.total - targetBudget;
    final reductionPercentage = (reductionNeeded / estimate.total) * 100;

    final optimizedItems = estimate.items.map((item) {
      if (item.category == EstimateCategory.accessories ||
          item.category == EstimateCategory.lighting) {
        final newAmount = item.amount * 0.8;
        return item.copyWith(
          amount: newAmount,
          notes: '${item.notes ?? ''} (Optimized)',
        );
      }
      return item;
    }).toList();

    final newSubtotal = optimizedItems.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );
    final newTax = newSubtotal * 0.18;
    final newTotal = newSubtotal + newTax;

    return estimate.copyWith(
      items: optimizedItems,
      subtotal: newSubtotal,
      tax: newTax,
      total: newTotal,
      explanation:
          '${estimate.explanation}\n\nOptimized to fit budget: Reduced by ${reductionPercentage.toStringAsFixed(1)}%',
    );
  }

  String _generateDesignImageUrl(
    ProjectModel project,
    String? structuralContext,
  ) {
    final prefs = project.designPreferences;

    final StringBuffer promptBuilder = StringBuffer();

    // 1. Meta-Prompt Strategy (Pre-generated by Gemini)
    if (structuralContext != null && structuralContext.isNotEmpty) {
      // Gemini has already written a perfect prompt for us. Use it directly.
      promptBuilder.write(structuralContext);
    } else {
      // Fallback Construction
      promptBuilder.write(
        "A photorealistic interior design of a furnished ${project.propertyDetails.spaceTypes.join(', ')}. ",
      );
      promptBuilder.write("Style: ${prefs.primaryStyle}. ");
      if (prefs.materials.flooring.isNotEmpty)
        promptBuilder.write("${prefs.materials.flooring} floor. ");
      promptBuilder.write(
        "8k resolution, cinematic lighting, architectural digest.",
      );
    }

    final encoded = Uri.encodeComponent(promptBuilder.toString());

    // Generate a new unique seed on every call to ensure different furniture arrangements each time
    final seed = DateTime.now().millisecondsSinceEpoch;

    // Using Flux model handles complex, multi-part prompts like this best.
    return "https://image.pollinations.ai/prompt/$encoded?width=1024&height=768&nologo=true&seed=$seed&model=flux";
  }

  /// New Method: Sends the image file to Gemini to get a "Visual Blueprint"
  Future<String?> _analyzeImageStructure(
    ProjectModel project,
    String imagePath,
  ) async {
    if (_apiKey.isEmpty) return null;

    try {
      final file = File(imagePath);
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final style = project.designPreferences.primaryStyle;

      // CHANGED: This prompt now focuses on GEOMETRY and CAMERA ANGLE, not design.
      final structurePrompt =
          """
### ROLE
You are a 3D Spatial Scanner.

### TASK
Analyze the input image geometry. Do not describe the furniture. Describe the SCENE COMPOSITION for a 3D artist to recreate this exact camera angle.

### OUTPUT
Return a single JSON object with key "image_generation_prompt".
The value must be a prompt following this specific template:
"A [wide/narrow] angle architectural shot of a [room type]. The camera is positioned at [eye-level/high-angle/low-angle]. 
On the LEFT side of the frame is [describe wall/window/feature]. 
On the RIGHT side of the frame is [describe wall/window/feature]. 
The CENTER contains [floor space/wall]. 
The lighting comes from [source] on the [left/right].
The empty structural shell is preserved, but furnished with new $style furniture including [suggest 2-3 items].
High resolution, photorealistic, 8k, interior design photography."
""";

      final response = await http.post(
        Uri.parse("$_baseUrl?key=$_apiKey"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': structurePrompt},
                {
                  'inline_data': {
                    'mime_type':
                        'image/jpeg', // Ensure this matches your file type
                    'data': base64Image,
                  },
                },
              ],
            },
          ],
          'generationConfig': {
            'temperature':
                0.2, // Lower temperature for more precise/robotic descriptions
            'maxOutputTokens': 500,
            'response_mime_type': 'application/json',
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jsonText = data['candidates'][0]['content']['parts'][0]['text'];

        try {
          final parsed = jsonDecode(jsonText);
          return parsed['image_generation_prompt'];
        } catch (e) {
          // Fallback cleanup if JSON is messy
          return jsonText
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();
        }
      }
    } catch (e) {
      print("Error analyzing image structure: $e");
    }
    return null;
  }
}
