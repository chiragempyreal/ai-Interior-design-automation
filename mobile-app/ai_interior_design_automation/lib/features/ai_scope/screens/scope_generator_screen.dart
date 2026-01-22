import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../project/models/project_model.dart';
import '../providers/scope_provider.dart';
import '../models/scope_model.dart';
import '../../ai_scope/services/ai_scope_service.dart';

class ScopeGeneratorScreen extends StatefulWidget {
  final ProjectModel project;

  const ScopeGeneratorScreen({super.key, required this.project});

  @override
  State<ScopeGeneratorScreen> createState() => _ScopeGeneratorScreenState();
}

class _ScopeGeneratorScreenState extends State<ScopeGeneratorScreen> {
  bool _isGenerating = false;
  List<Map<String, dynamic>>? _furnitureSuggestions;

  @override
  Widget build(BuildContext context) {
    final scopeProvider = context.watch<ScopeProvider>();
    final existingScope = scopeProvider.getScopeByProjectId(widget.project.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Scope Generator"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Generate Project Scope",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "AI will analyze your project and create a detailed phase-wise breakdown",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            const SizedBox(height: 32),

            // Reference Image
            if (widget.project.photoPaths.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: FileImage(File(widget.project.photoPaths.first)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: const Text("Your Reference Space", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

            // Project Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.home_work, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.project.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "${widget.project.propertyDetails.type.name.toUpperCase()} • ${widget.project.propertyDetails.carpetArea.toInt()} sq ft",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        "Budget",
                        "₹${(widget.project.technicalRequirements.budget.totalBudget / 100000).toStringAsFixed(1)}L",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (_furnitureSuggestions != null) ...[
              Text("AI Virtual Staging Ideas", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              // Split View: Original vs Generated Concept
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text("Original", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 8),
                        ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(widget.project.photoPaths.first), height: 120, width: double.infinity, fit: BoxFit.cover)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Text("AI Concept (Preview)", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                         Container(
                           height: 120,
                           width: double.infinity,
                           decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.solid)),
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                               const Icon(Icons.auto_awesome, color: AppColors.primary, size: 30),
                               const SizedBox(height: 8),
                               Text("Visual Rendering\nAvailable in Pro", textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: AppColors.primary)),
                             ],
                           ),
                         ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              Text("Suggested Furniture (50x50 Layout)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              // List of items
              ..._furnitureSuggestions!.map((item) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: AppColors.textSecondary.withOpacity(0.1))),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: CircleAvatar(backgroundColor: AppColors.secondary.withOpacity(0.1), child: const Icon(Icons.chair_alt, color: AppColors.secondary, size: 20)),
                  title: Text(item['name'] ?? 'Item', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(item['reason'] ?? '', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  trailing: Text("₹${item['price']}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ),
              )).toList(),
              
              const SizedBox(height: 8),
              Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.1))),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                   const Text("Furniture Estimate", style: TextStyle(fontWeight: FontWeight.bold)),
                   Text("₹${_furnitureSuggestions!.fold<int>(0, (sum, item) => sum + (item['price'] as int? ?? 0))}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 18)),
                ]),
              ),
              const SizedBox(height: 32),
            ],

            const SizedBox(height: 32),

            // Suggestions
            if (existingScope == null) ...[
              Text(
                "What AI will generate:",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              ...scopeProvider
                  .getScopeSuggestions(widget.project.propertyDetails.type)
                  .map((suggestion) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: AppColors.secondary, size: 20),
                            const SizedBox(width: 12),
                            Text(suggestion),
                          ],
                        ),
                      )),
            ],

            if (existingScope != null) ...[
              _buildExistingScopePreview(existingScope),
            ],

            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateScope,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text("Generating Scope..."),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.auto_awesome),
                          const SizedBox(width: 8),
                          Text(existingScope == null
                              ? "Generate AI Scope"
                              : "Regenerate Scope"),
                        ],
                      ),
              ),
            ),

            if (existingScope != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _viewScopeDetails(existingScope),
                  child: const Text("View Full Scope"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingScopePreview(ScopeModel scope) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.secondary),
              const SizedBox(width: 8),
              const Text(
                "Scope Generated",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "${scope.phases.length} Phases • ${scope.totalDuration} Days",
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          ...scope.phases.take(3).map((phase) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text("• ${phase.name}"),
              )),
        ],
      ),
    );
  }

  Future<void> _generateScope() async {
    setState(() => _isGenerating = true);

    final scopeProvider = context.read<ScopeProvider>();
    final aiService = AiScopeService();
    
    // 1. Generate Scope
    Future<ScopeModel?> scopeFuture = scopeProvider.generateScope(widget.project);
    
    // 2. Generate Furniture (if image exists)
    Future<List<Map<String, dynamic>>>? furnitureFuture;
    if (widget.project.photoPaths.isNotEmpty) {
       furnitureFuture = aiService.generateFurnitureSuggestions(widget.project.photoPaths.first);
    }
    
    final results = await Future.wait([
        scopeFuture,
        if (furnitureFuture != null) furnitureFuture else Future.value([]),
    ]);
    
    final scope = results[0] as ScopeModel?;
    if (results.length > 1 && results[1] is List) {
       _furnitureSuggestions = results[1] as List<Map<String, dynamic>>?;
    }

    setState(() => _isGenerating = false);

    if (scope != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✓ AI Scope generated successfully!"),
          backgroundColor: AppColors.secondary,
        ),
      );

      // Navigate to scope details
      _viewScopeDetails(scope);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to generate scope. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewScopeDetails(ScopeModel scope) {
    context.push('/scope-details', extra: {
      'scope': scope,
      'project': widget.project,
    });
  }
}
