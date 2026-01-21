import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/brand_colors.dart';
import '../../project/models/project_model.dart';
import '../models/scope_model.dart';

class ScopeDetailsScreen extends StatelessWidget {
  final ScopeModel scope;
  final ProjectModel project;

  const ScopeDetailsScreen({
    super.key,
    required this.scope,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.background,
      appBar: AppBar(
        title: Text(
          "Project Scope",
          style: BrandTypography.h5.copyWith(color: BrandColors.textDark),
        ),
        backgroundColor: BrandColors.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: BrandColors.textDark),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Implement Share
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Project Summary Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: BrandColors.surface,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: BrandColors.shadowLight,
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.name,
                  style: BrandTypography.h3,
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 8),
                Text(
                  "Scope Overview & Phase Breakdown",
                  style: BrandTypography.bodyRegular.copyWith(
                    color: BrandColors.textBody,
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 20),
                
                // Stats Row
                Row(
                  children: [
                    _buildSummaryChip(
                      "${scope.phases.length} Phases",
                      Icons.layers_outlined,
                      BrandColors.primary,
                      delay: 300,
                    ),
                    const SizedBox(width: 12),
                    _buildSummaryChip(
                      "${scope.totalDuration} Days",
                      Icons.calendar_today_outlined,
                      BrandColors.accent,
                      delay: 400,
                    ),
                    const SizedBox(width: 12),
                    _buildSummaryChip(
                      "${_getTotalTasks()} Tasks",
                      Icons.check_circle_outline,
                      BrandColors.info,
                      delay: 500,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Phases List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              physics: const BouncingScrollPhysics(),
              itemCount: scope.phases.length,
              itemBuilder: (context, index) {
                final phase = scope.phases[index];
                return _PhaseCard(
                  phase: phase,
                  phaseNumber: index + 1,
                  delay: 600 + (index * 100),
                );
              },
            ),
          ),
        ],
      ),
      
      // Fixed Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: BrandColors.surface,
          boxShadow: [
            BoxShadow(
              color: BrandColors.shadowMedium,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () => _generateEstimate(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: BrandColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(BrandRadius.xxl),
              ),
              elevation: 4,
              shadowColor: BrandColors.shadowMedium,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calculate_outlined),
                const SizedBox(width: 10),
                Text(
                  "Generate Cost Estimate",
                  style: BrandTypography.bodyLarge.copyWith(
                    fontWeight: BrandTypography.semiBold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().slideY(begin: 1.0, end: 0, delay: 800.ms),
    );
  }

  Widget _buildSummaryChip(String label, IconData icon, Color color, {required int delay}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(BrandRadius.full),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: BrandTypography.caption.copyWith(
              color: BrandColors.textDark,
              fontWeight: BrandTypography.semiBold,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).scale();
  }

  int _getTotalTasks() {
    return scope.phases.fold(0, (sum, phase) => sum + phase.tasks.length);
  }

  void _generateEstimate(BuildContext context) {
    context.push('/generate-estimate', extra: {
      'project': project,
      'scope': scope,
    });
  }
}

class _PhaseCard extends StatefulWidget {
  final PhaseModel phase;
  final int phaseNumber;
  final int delay;

  const _PhaseCard({
    required this.phase,
    required this.phaseNumber,
    required this.delay,
  });

  @override
  State<_PhaseCard> createState() => _PhaseCardState();
}

class _PhaseCardState extends State<_PhaseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Calculate total cost for visual indicator
    /*
    final totalCost = widget.phase.tasks.fold<double>(
      0,
      (sum, task) => sum + task.estimatedCost,
    );
    */ 
    // Note: Scope model might not have costs yet until estimated. Assuming estimatedCost is 0 or placeholder.

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: BrandColors.surface,
        borderRadius: BorderRadius.circular(BrandRadius.xl),
        boxShadow: _isExpanded 
          ? [BoxShadow(color: BrandColors.primary.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))]
          : [BoxShadow(color: BrandColors.shadowLight, blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(
          color: _isExpanded ? BrandColors.primary.withOpacity(0.3) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(BrandRadius.xl),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number Indicator
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: BrandColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: BrandColors.border),
                    ),
                    child: Center(
                      child: Text(
                        "${widget.phaseNumber}",
                        style: BrandTypography.h5.copyWith(color: BrandColors.primary),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded( // Added Expanded to Text to prevent overflow
                              child: Text(
                                widget.phase.name,
                                style: BrandTypography.h5,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              _isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: BrandColors.textLight,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.phase.description,
                          style: BrandTypography.bodySmall,
                          maxLines: _isExpanded ? null : 2,
                          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Mini stats
                        Row(
                          children: [
                            Icon(Icons.task_alt, size: 14, color: BrandColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.phase.tasks.length} tasks",
                              style: BrandTypography.caption,
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.schedule, size: 14, color: BrandColors.textLight),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.phase.duration} days",
                              style: BrandTypography.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Tasks List
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Divider(color: BrandColors.divider, height: 1),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(20),
                        itemCount: widget.phase.tasks.length,
                        itemBuilder: (context, index) {
                          return _TaskTile(task: widget.phase.tasks[index]);
                        },
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: widget.delay.ms).slideY(begin: 0.1, end: 0);
  }
}

class _TaskTile extends StatelessWidget {
  final TaskModel task;

  const _TaskTile({required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BrandColors.background,
        borderRadius: BorderRadius.circular(BrandRadius.lg),
        border: Border.all(
          color: _getPriorityColor(task.priority).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.priority.name.toUpperCase(),
                  style: BrandTypography.caption.copyWith(
                    fontWeight: BrandTypography.bold,
                    color: _getPriorityColor(task.priority),
                    fontSize: 10,
                  ),
                ),
              ),
              const Spacer(),
              // Cost if available
              if (task.estimatedCost > 0)
                Text(
                  "₹${task.estimatedCost.toStringAsFixed(0)}",
                  style: BrandTypography.bodySmall.copyWith(
                    fontWeight: BrandTypography.bold,
                    color: BrandColors.textDark,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.name,
            style: BrandTypography.bodyRegular.copyWith(
              fontWeight: BrandTypography.semiBold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            task.description,
            style: BrandTypography.bodySmall,
          ),
          const SizedBox(height: 8),
          
          // Resources / Duration
          Row(
            children: [
              Icon(Icons.schedule, size: 14, color: BrandColors.textLight),
              const SizedBox(width: 4),
              Text(
                "${task.duration} days",
                style: BrandTypography.caption,
              ),
              if (task.resources.isNotEmpty) ...[
                const SizedBox(width: 12),
                Icon(Icons.handyman_outlined, size: 14, color: BrandColors.textLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.resources.take(2).join(", "),
                    style: BrandTypography.caption,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.critical:
        return BrandColors.error;
      case TaskPriority.high:
        return BrandColors.warning;
      case TaskPriority.medium:
        return BrandColors.info;
      case TaskPriority.low:
        return BrandColors.success;
    }
  }
}
