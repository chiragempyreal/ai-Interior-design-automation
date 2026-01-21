import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import '../../project/models/project_model.dart';
import '../../ai_scope/models/scope_model.dart';
import '../../cost_config/models/cost_config_model.dart';
import '../models/estimate_model.dart';

class EstimateService {
  // Get API key from environment variable
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

  final _uuid = const Uuid();

  /// Generate estimate from project and scope
  Future<EstimateModel> generateEstimate({
    required ProjectModel project,
    required ScopeModel scope,
    required CostConfigModel costConfig,
  }) async {
    try {
      final prompt = _buildEstimatePrompt(project, scope, costConfig);

      // For demo/offline mode, return calculated estimate
      if (_apiKey.isEmpty || _apiKey == "YOUR_GEMINI_API_KEY") {
        return _calculateEstimate(project, scope, costConfig, prompt);
      }

      // Call Gemini API for AI-powered estimate
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
            'temperature': 0.5,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['candidates'][0]['content']['parts'][0]['text'];
        
        // Use AI response as explanation, but calculate costs ourselves
        final estimate = _calculateEstimate(project, scope, costConfig, prompt);
        return estimate.copyWith(explanation: aiResponse);
      } else {
        throw Exception('Failed to generate estimate: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to calculated estimate
      return _calculateEstimate(project, scope, costConfig, _buildEstimatePrompt(project, scope, costConfig));
    }
  }

  String _buildEstimatePrompt(ProjectModel project, ScopeModel scope, CostConfigModel costConfig) {
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
  ) {
    final area = project.propertyDetails.carpetArea;
    final items = <EstimateItem>[];

    // 1. Design Fees
    final designFee = _calculateDesignFee(area, costConfig.designFees);
    items.add(EstimateItem(
      id: _uuid.v4(),
      category: EstimateCategory.design,
      description: "Complete Interior Design Services",
      quantity: area,
      unit: "sq ft",
      rate: costConfig.designFees.perSqFtRate,
      amount: designFee,
      notes: "Includes concept design, 3D renders, and supervision",
    ));

    // 2. Calculate costs from scope tasks
    for (final phase in scope.phases) {
      for (final task in phase.tasks) {
        if (task.estimatedCost > 0) {
          items.add(EstimateItem(
            id: _uuid.v4(),
            category: _mapTaskToCategory(task.name),
            description: task.name,
            quantity: 1,
            unit: "item",
            rate: task.estimatedCost,
            amount: task.estimatedCost,
            notes: task.description,
          ));
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
      designImageUrl: _getDesignImageForStyle(project.designPreferences.primaryStyle),
    );
  }

  double _calculateDesignFee(double area, DesignFeeConfig config) {
    final perSqFtFee = area * config.perSqFtRate;
    return perSqFtFee > config.minFlatAmount ? perSqFtFee : config.minFlatAmount;
  }

  EstimateCategory _mapTaskToCategory(String taskName) {
    final lower = taskName.toLowerCase();
    if (lower.contains('design') || lower.contains('concept')) {
      return EstimateCategory.design;
    } else if (lower.contains('furniture') || lower.contains('wardrobe') || lower.contains('kitchen')) {
      return EstimateCategory.furniture;
    } else if (lower.contains('light')) {
      return EstimateCategory.lighting;
    } else if (lower.contains('floor') || lower.contains('wall') || lower.contains('ceiling')) {
      return EstimateCategory.materials;
    } else if (lower.contains('decor') || lower.contains('accessory')) {
      return EstimateCategory.accessories;
    } else {
      return EstimateCategory.labor;
    }
  }

  List<EstimateItem> _getStandardMaterials(ProjectModel project, double area, CostConfigModel costConfig) {
    final items = <EstimateItem>[];

    // Flooring
    items.add(EstimateItem(
      id: _uuid.v4(),
      category: EstimateCategory.materials,
      description: "Vitrified Tiles - Premium Quality",
      quantity: area,
      unit: "sq ft",
      rate: 80,
      amount: area * 80,
      notes: "800x800mm tiles with installation",
    ));

    // Paint
    items.add(EstimateItem(
      id: _uuid.v4(),
      category: EstimateCategory.materials,
      description: "Premium Emulsion Paint",
      quantity: area * 2.5, // Wall area approximation
      unit: "sq ft",
      rate: 35,
      amount: area * 2.5 * 35,
      notes: "Asian Paints Royale or equivalent",
    ));

    // Electrical
    items.add(EstimateItem(
      id: _uuid.v4(),
      category: EstimateCategory.materials,
      description: "Electrical Fittings & Wiring",
      quantity: area,
      unit: "sq ft",
      rate: 60,
      amount: area * 60,
      notes: "Switches, sockets, wiring, MCB",
    ));

    return items;
  }

  List<EstimateItem> _getLaborCosts(ProjectModel project, double area, CostConfigModel costConfig) {
    final items = <EstimateItem>[];

    items.add(EstimateItem(
      id: _uuid.v4(),
      category: EstimateCategory.labor,
      description: "Civil & Construction Labor",
      quantity: area,
      unit: "sq ft",
      rate: 100,
      amount: area * 100,
      notes: "Skilled and helper labor for 60 days",
    ));

    items.add(EstimateItem(
      id: _uuid.v4(),
      category: EstimateCategory.labor,
      description: "Carpenter & Finishing Work",
      quantity: area,
      unit: "sq ft",
      rate: 80,
      amount: area * 80,
      notes: "Furniture installation and finishing",
    ));

    return items;
  }

  String _generateExplanation(ProjectModel project, double subtotal, double total) {
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

    // Calculate reduction needed
    final reductionNeeded = estimate.total - targetBudget;
    final reductionPercentage = (reductionNeeded / estimate.total) * 100;

    // Reduce non-essential items
    final optimizedItems = estimate.items.map((item) {
      if (item.category == EstimateCategory.accessories || 
          item.category == EstimateCategory.lighting) {
        // Reduce by 20%
        final newAmount = item.amount * 0.8;
        return item.copyWith(
          amount: newAmount,
          notes: '${item.notes ?? ''} (Optimized)',
        );
      }
      return item;
    }).toList();

    final newSubtotal = optimizedItems.fold<double>(0, (sum, item) => sum + item.amount);
    final newTax = newSubtotal * 0.18;
    final newTotal = newSubtotal + newTax;

    return estimate.copyWith(
      items: optimizedItems,
      subtotal: newSubtotal,
      tax: newTax,
      total: newTotal,
      explanation: '${estimate.explanation}\n\nOptimized to fit budget: Reduced by ${reductionPercentage.toStringAsFixed(1)}%',
    );
  }

  String _getDesignImageForStyle(String style) {
    final prompt = "interior design $style room, photorealistic, 4k";
    final encoded = Uri.encodeComponent(prompt);
    // Simplified URL to ensure successful generation/decoding
    return "https://pollinations.ai/p/$encoded?width=800&height=600&nologo=true";
  }
}
