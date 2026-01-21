import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../project/models/project_model.dart';
import '../../ai_scope/models/scope_model.dart';
import '../../cost_config/providers/cost_config_provider.dart';
import '../providers/estimate_provider.dart';

class EstimateGeneratorScreen extends StatefulWidget {
  final ProjectModel project;
  final ScopeModel scope;

  const EstimateGeneratorScreen({
    super.key,
    required this.project,
    required this.scope,
  });

  @override
  State<EstimateGeneratorScreen> createState() => _EstimateGeneratorScreenState();
}

class _EstimateGeneratorScreenState extends State<EstimateGeneratorScreen> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    final estimateProvider = context.watch<EstimateProvider>();
    final existingEstimate = estimateProvider.getLatestEstimate(widget.project.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate Estimate"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              "Budget Estimate",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "AI will calculate detailed costs based on your project scope",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            const SizedBox(height: 32),

            // Project Summary Card
            _buildProjectSummary(),

            const SizedBox(height: 16),

            // Scope Summary Card
            _buildScopeSummary(),

            const SizedBox(height: 32),

            // What's Included
            Text(
              "What's Included in Estimate:",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildIncludedItem(Icons.design_services, "Design Services"),
            _buildIncludedItem(Icons.construction, "Materials & Labor"),
            _buildIncludedItem(Icons.lightbulb, "Lighting & Electrical"),
            _buildIncludedItem(Icons.chair, "Furniture & Fixtures"),
            _buildIncludedItem(Icons.receipt_long, "Tax & Documentation"),

            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateEstimate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
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
                          Text("Calculating Costs..."),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.calculate),
                          const SizedBox(width: 8),
                          Text(existingEstimate == null
                              ? "Generate Estimate"
                              : "Regenerate Estimate"),
                        ],
                      ),
              ),
            ),

            if (existingEstimate != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () => _viewEstimateDetails(existingEstimate),
                  child: const Text("View Latest Estimate"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSummary() {
    return Container(
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
              Expanded(
                child: _buildInfoItem(
                  "Budget",
                  "₹${(widget.project.technicalRequirements.budget.totalBudget / 100000).toStringAsFixed(1)}L",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScopeSummary() {
    final totalTasks = widget.scope.phases.fold<int>(
      0,
      (sum, phase) => sum + phase.tasks.length,
    );

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
          const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.secondary),
              SizedBox(width: 8),
              Text(
                "Scope Ready",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildScopeChip("${widget.scope.phases.length} Phases"),
              const SizedBox(width: 8),
              _buildScopeChip("$totalTasks Tasks"),
              const SizedBox(width: 8),
              _buildScopeChip("${widget.scope.totalDuration} Days"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildScopeChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildIncludedItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Future<void> _generateEstimate() async {
    setState(() => _isGenerating = true);

    final estimateProvider = context.read<EstimateProvider>();
    final costConfigProvider = context.read<CostConfigProvider>();

    final estimate = await estimateProvider.generateEstimate(
      project: widget.project,
      scope: widget.scope,
      costConfig: costConfigProvider.config,
    );

    setState(() => _isGenerating = false);

    if (estimate != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✓ Estimate generated successfully!"),
          backgroundColor: AppColors.secondary,
        ),
      );

      // Navigate to estimate details
      _viewEstimateDetails(estimate);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to generate estimate. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _viewEstimateDetails(estimate) {
    context.push('/estimate-details', extra: {
      'estimate': estimate,
      'project': widget.project,
    });
  }
}
