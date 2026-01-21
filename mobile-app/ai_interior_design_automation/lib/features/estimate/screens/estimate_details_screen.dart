import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../project/models/project_model.dart';
import '../models/estimate_model.dart';
import '../providers/estimate_provider.dart';

class EstimateDetailsScreen extends StatelessWidget {
  final EstimateModel estimate;
  final ProjectModel project;

  const EstimateDetailsScreen({
    super.key,
    required this.estimate,
    required this.project,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estimate Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareEstimate(context),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPdf(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.secondary,
                  AppColors.secondary.withOpacity(0.8),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            project.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Estimate #${estimate.id.substring(0, 8).toUpperCase()}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(estimate.status),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildHeaderInfo(
                      "Version",
                      "v${estimate.version}",
                    ),
                    const SizedBox(width: 24),
                    _buildHeaderInfo(
                      "Date",
                      DateFormat('dd MMM yyyy').format(estimate.createdAt),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // AI Design Proposal Section
          if (estimate.designImageUrl != null)
             Container(
               margin: const EdgeInsets.fromLTRB(16, 24, 16, 8),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     children: [
                       const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                       const SizedBox(width: 8),
                       const Text("AI Design Proposal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                     ],
                   ),
                   const SizedBox(height: 16),
                   Row(
                     children: [
                       // Original
                       if (project.photoPaths.isNotEmpty)
                         Expanded(
                           child: Column(
                             children: [
                               const Text("Original Site", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                               const SizedBox(height: 8),
                               ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(project.photoPaths.first), height: 150, width: double.infinity, fit: BoxFit.cover)),
                             ],
                           ),
                         ),
                       if (project.photoPaths.isNotEmpty) const SizedBox(width: 16),
                       // Generated
                       Expanded(
                         child: Column(
                           children: [
                             const Text("AI Redesigned", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                             const SizedBox(height: 8),
                             GestureDetector(
                               onTap: () {
                                  showDialog(context: context, builder: (context) => Dialog.fullscreen(
                                    child: Stack(children: [
                                       InteractiveViewer(minScale: 0.5, maxScale: 4.0, child: Center(child: Image.network(estimate.designImageUrl!))),
                                       Positioned(top: 20, right: 20, child: FloatingActionButton(mini: true, backgroundColor: Colors.white, onPressed: () => Navigator.pop(context), child: const Icon(Icons.close, color: Colors.black))),
                                    ]),
                                  ));
                               },
                               child: ClipRRect(
                                 borderRadius: BorderRadius.circular(12),
                                 child: Stack(
                                   children: [
                                     Image.network(estimate.designImageUrl!, height: 150, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(height: 150, color: Colors.grey[200], child: const Center(child: Icon(Icons.broken_image, color: Colors.grey)))),
                                     Positioned(bottom: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(4)), child: const Text("TAP TO VIEW", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))))
                                   ],
                                 ),
                               ),
                             ),
                           ],
                         ),
                       ),
                     ],
                   ),
                 ],
               ),
             ),

          // Items List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Items by Category
                ..._buildItemsByCategory(currencyFormat),

                const SizedBox(height: 24),

                // Cost Summary
                _buildCostSummary(currencyFormat),

                const SizedBox(height: 24),

                // Explanation
                if (estimate.explanation != null)
                  _buildExplanation(estimate.explanation!),

                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),

          // Bottom Action Bar
          _buildBottomActionBar(context),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(EstimateStatus status) {
    Color color;
    String text;

    switch (status) {
      case EstimateStatus.draft:
        color = Colors.grey;
        text = "DRAFT";
        break;
      case EstimateStatus.pending:
        color = Colors.orange;
        text = "PENDING";
        break;
      case EstimateStatus.approved:
        color = Colors.green;
        text = "APPROVED";
        break;
      case EstimateStatus.rejected:
        color = Colors.red;
        text = "REJECTED";
        break;
      case EstimateStatus.revised:
        color = Colors.blue;
        text = "REVISED";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildItemsByCategory(NumberFormat currencyFormat) {
    final itemsByCategory = <EstimateCategory, List<EstimateItem>>{};

    for (final item in estimate.items) {
      if (!itemsByCategory.containsKey(item.category)) {
        itemsByCategory[item.category] = [];
      }
      itemsByCategory[item.category]!.add(item);
    }

    final widgets = <Widget>[];

    itemsByCategory.forEach((category, items) {
      widgets.add(_buildCategorySection(category, items, currencyFormat));
      widgets.add(const SizedBox(height: 16));
    });

    return widgets;
  }

  Widget _buildCategorySection(
    EstimateCategory category,
    List<EstimateItem> items,
    NumberFormat currencyFormat,
  ) {
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getCategoryIcon(category),
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getCategoryName(category),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  currencyFormat.format(total),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...items.map((item) => _buildItemRow(item, currencyFormat)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(EstimateItem item, NumberFormat currencyFormat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.quantity.toStringAsFixed(0)} ${item.unit} × ${currencyFormat.format(item.rate)}",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(item.amount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (item.notes != null) ...[
            const SizedBox(height: 4),
            Text(
              item.notes!,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostSummary(NumberFormat currencyFormat) {
    return Card(
      elevation: 4,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSummaryRow(
              "Subtotal",
              currencyFormat.format(estimate.subtotal),
              false,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              "Tax (18% GST)",
              currencyFormat.format(estimate.tax),
              false,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              "TOTAL ESTIMATE",
              currencyFormat.format(estimate.total),
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 20 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? AppColors.secondary : null,
          ),
        ),
      ],
    );
  }

  Widget _buildExplanation(String explanation) {
    return Card(
      elevation: 2,
      color: AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                SizedBox(width: 8),
                Text(
                  "Estimate Explanation",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              explanation,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _exportPdf(context),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text("Export PDF"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _approveEstimate(context),
                icon: const Icon(Icons.check_circle),
                label: const Text("Approve"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(EstimateCategory category) {
    switch (category) {
      case EstimateCategory.design:
        return Icons.design_services;
      case EstimateCategory.materials:
        return Icons.construction;
      case EstimateCategory.labor:
        return Icons.engineering;
      case EstimateCategory.furniture:
        return Icons.chair;
      case EstimateCategory.lighting:
        return Icons.lightbulb;
      case EstimateCategory.accessories:
        return Icons.shopping_bag;
      case EstimateCategory.other:
        return Icons.more_horiz;
    }
  }

  String _getCategoryName(EstimateCategory category) {
    switch (category) {
      case EstimateCategory.design:
        return "Design Services";
      case EstimateCategory.materials:
        return "Materials";
      case EstimateCategory.labor:
        return "Labor";
      case EstimateCategory.furniture:
        return "Furniture";
      case EstimateCategory.lighting:
        return "Lighting";
      case EstimateCategory.accessories:
        return "Accessories";
      case EstimateCategory.other:
        return "Other";
    }
  }

  Future<void> _exportPdf(BuildContext context) async {
    try {
      final estimateProvider = context.read<EstimateProvider>();
      await estimateProvider.printPdf(estimate);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✓ PDF generated successfully!"),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareEstimate(BuildContext context) async {
    try {
      final text = '''
Budget Estimate - ${project.name}

Total: ₹${estimate.total.toStringAsFixed(0)}
Version: ${estimate.version}
Status: ${estimate.status.name.toUpperCase()}

Generated by AI Interior Design Automation
      ''';

      await Share.share(text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error sharing: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _approveEstimate(BuildContext context) {
    final estimateProvider = context.read<EstimateProvider>();
    estimateProvider.approveEstimate(
      project.id,
      estimate.id,
      project.clientDetails.name,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✓ Estimate approved!"),
        backgroundColor: AppColors.secondary,
      ),
    );
  }
}
