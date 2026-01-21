import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/brand_colors.dart';
import '../../project/models/project_model.dart';
import '../models/estimate_model.dart';
import '../providers/estimate_provider.dart';

class EstimateDetailsScreen extends StatefulWidget {
  final EstimateModel estimate;
  final ProjectModel project;

  const EstimateDetailsScreen({
    super.key,
    required this.estimate,
    required this.project,
  });

  @override
  State<EstimateDetailsScreen> createState() => _EstimateDetailsScreenState();
}

class _EstimateDetailsScreenState extends State<EstimateDetailsScreen> {
  bool _isExporting = false;
  bool _isSharing = false;

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
        centerTitle: true,
        actions: [
          IconButton(
            icon: _isSharing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: BrandColors.textDark,
                    ),
                  )
                : const Icon(Icons.share),
            onPressed: _isSharing ? null : () => _shareEstimate(context),
          ),
          IconButton(
            icon: _isExporting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: BrandColors.textDark,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf),
            onPressed: _isExporting ? null : () => _exportPdf(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: BrandColors.primaryGradient,
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
                            widget.project.name,
                            style: BrandTypography.h3.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Estimate #${widget.estimate.id.substring(0, 8).toUpperCase()}",
                            style: BrandTypography.bodySmall.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(widget.estimate.status),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildHeaderInfo("Version", "v${widget.estimate.version}"),
                    const SizedBox(width: 24),
                    _buildHeaderInfo(
                      "Date",
                      DateFormat(
                        'dd MMM yyyy',
                      ).format(widget.estimate.createdAt),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // AI Design Proposal Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget.estimate.designImageUrl != null) ...[
                  Container(
                    margin: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: BrandColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text("AI Design Proposal", style: BrandTypography.h5),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Original
                      if (widget.project.photoPaths.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Original Site",
                                style: BrandTypography.caption,
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  BrandRadius.lg,
                                ),
                                child: Image.file(
                                  File(widget.project.photoPaths.first),
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (widget.project.photoPaths.isNotEmpty)
                        const SizedBox(width: 16),
                      // Generated
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "AI Redesigned",
                              style: BrandTypography.caption.copyWith(
                                color: BrandColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => Dialog.fullscreen(
                                    child: Stack(
                                      children: [
                                        InteractiveViewer(
                                          minScale: 0.5,
                                          maxScale: 4.0,
                                          child: Center(
                                            child: Image.network(
                                              widget.estimate.designImageUrl!,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 20,
                                          right: 20,
                                          child: FloatingActionButton(
                                            mini: true,
                                            backgroundColor: Colors.white,
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Icon(
                                              Icons.close,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                  BrandRadius.lg,
                                ),
                                child: Stack(
                                  children: [
                                    Image.network(
                                      widget.estimate.designImageUrl!,
                                      height: 150,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) => Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(
                                            Icons.broken_image,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.7),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          "TAP TO VIEW",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],

                // Items by Category
                ..._buildItemsByCategory(currencyFormat),

                const SizedBox(height: 24),

                // Cost Summary
                _buildCostSummary(currencyFormat),

                const SizedBox(height: 24),

                // Explanation
                if (widget.estimate.explanation != null)
                  _buildExplanation(widget.estimate.explanation!),

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
        color = BrandColors.warning;
        text = "PENDING";
        break;
      case EstimateStatus.approved:
        color = BrandColors.success;
        text = "APPROVED";
        break;
      case EstimateStatus.rejected:
        color = BrandColors.error;
        text = "REJECTED";
        break;
      case EstimateStatus.revised:
        color = BrandColors.info;
        text = "REVISED";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: BrandShadows.light,
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
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
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

    for (final item in widget.estimate.items) {
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
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandRadius.xxl),
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
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _getCategoryName(category),
                    style: BrandTypography.h5.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  currencyFormat.format(total),
                  style: BrandTypography.h5.copyWith(
                    color: theme.colorScheme.primary,
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
    final theme = Theme.of(context);
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
                      style: BrandTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${item.quantity.toStringAsFixed(0)} ${item.unit} × ${currencyFormat.format(item.rate)}",
                      style: BrandTypography.caption.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                currencyFormat.format(item.amount),
                style: BrandTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          if (item.notes != null) ...[
            const SizedBox(height: 4),
            Text(
              item.notes!,
              style: BrandTypography.caption.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCostSummary(NumberFormat currencyFormat) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shadowColor: theme.shadowColor.withOpacity(0.2),
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandRadius.xxl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSummaryRow(
              "Subtotal",
              currencyFormat.format(widget.estimate.subtotal),
              false,
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              "Tax (18% GST)",
              currencyFormat.format(widget.estimate.tax),
              false,
            ),
            const Divider(height: 24),
            _buildSummaryRow(
              "TOTAL ESTIMATE",
              currencyFormat.format(widget.estimate.total),
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isBold) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? BrandTypography.h4.copyWith(color: theme.colorScheme.onSurface)
              : BrandTypography.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
        ),
        Text(
          value,
          style: isBold
              ? BrandTypography.h4.copyWith(color: BrandColors.accent)
              : BrandTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
        ),
      ],
    );
  }

  Widget _buildExplanation(String explanation) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shadowColor: theme.shadowColor.withOpacity(0.1),
      color: theme.colorScheme.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BrandRadius.xxl),
        side: BorderSide(color: theme.colorScheme.primary.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Estimate Explanation",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              explanation,
              style: BrandTypography.bodySmall.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color, // Adaptive background
        boxShadow: BrandShadows
            .medium, // Shadows might need tweaking for dark mode in general, but keeping consistent
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isExporting ? null : () => _exportPdf(context),
                icon: _isExporting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : Icon(
                        Icons.picture_as_pdf,
                        color: theme.colorScheme.primary,
                      ), // Explicit color
                label: Text(_isExporting ? "Exporting..." : "Export PDF"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: theme.colorScheme.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BrandRadius.xl),
                  ),
                  foregroundColor:
                      theme.colorScheme.primary, // Ensure text is primary color
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
                  backgroundColor: BrandColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BrandRadius.xl),
                  ),
                  elevation: 2,
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
    setState(() => _isExporting = true);
    try {
      final estimateProvider = context.read<EstimateProvider>();
      // Run in a slight microtask to allow UI to update
      await Future.delayed(const Duration(milliseconds: 100));
      await estimateProvider.printPdf(widget.estimate);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✓ PDF generated successfully!"),
            backgroundColor: BrandColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: BrandColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareEstimate(BuildContext context) async {
    setState(() => _isSharing = true);
    try {
      final text =
          '''
Budget Estimate - ${widget.project.name}

Total: ₹${widget.estimate.total.toStringAsFixed(0)}
Version: ${widget.estimate.version}
Status: ${widget.estimate.status.name.toUpperCase()}

Generated by AI Interior Design Automation
      ''';

      await Share.share(text);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error sharing: $e"),
            backgroundColor: BrandColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _approveEstimate(BuildContext context) {
    final estimateProvider = context.read<EstimateProvider>();
    estimateProvider.approveEstimate(
      widget.project.id,
      widget.estimate.id,
      widget.project.clientDetails.name,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✓ Estimate approved!"),
        backgroundColor: BrandColors.success,
      ),
    );
  }
}
