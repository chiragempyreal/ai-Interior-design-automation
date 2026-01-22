import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/brand_colors.dart';
import '../../estimate/models/estimate_model.dart';
import '../../project/models/project_model.dart';
import '../../estimate/services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';

class QuoteReviewScreen extends StatefulWidget {
  final ProjectModel project;
  final EstimateModel estimate;

  const QuoteReviewScreen({
    super.key,
    required this.project,
    required this.estimate,
  });

  @override
  State<QuoteReviewScreen> createState() => _QuoteReviewScreenState();
}

class _QuoteReviewScreenState extends State<QuoteReviewScreen> {
  late EstimateModel _currentEstimate;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _currentEstimate = widget.estimate;
  }

  String _fmt(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    ).format(amount);
  }

  Future<void> _approveQuote() async {
    // Logic to approve quote
    // Update status in provider
    // In a real app, this would call an API
    
    // For now, update local state
    setState(() {
      _currentEstimate = _currentEstimate.copyWith(
        status: EstimateStatus.approved,
      );
    });
    
    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Quote Approved Successfully!"),
        backgroundColor: BrandColors.success,
      ),
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    try {
      final pdfService = PdfService();
      // Only pass estimate as per service definition
      final file = await pdfService.generateEstimatePdf(_currentEstimate);

      // Share
      await Share.shareXFiles([XFile(file.path)], text: 'Project Quotation for ${widget.project.name}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Export failed: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = _currentEstimate.status == EstimateStatus.approved;

    return Scaffold(
      backgroundColor: BrandColors.background,
      appBar: AppBar(
        title: const Text("Quote Review"),
        backgroundColor: BrandColors.surface,
        foregroundColor: BrandColors.textDark,
        elevation: 0,
        actions: [
          if (isApproved)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BrandColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BrandColors.success),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: BrandColors.success),
                  const SizedBox(width: 4),
                  Text(
                    "APPROVED",
                    style: TextStyle(
                      color: BrandColors.success,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Total Card
            _buildTotalCard(),
            
            const SizedBox(height: 24),
            
            // Actions Row
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.edit_note,
                    label: "Revise",
                    onTap: () {
                      context.pop(); // Go back to revise
                    },
                    isPrimary: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: isApproved ? Icons.download : Icons.check_circle_outline, 
                    label: isApproved ? "Export PDF" : "Approve",
                    onTap: isApproved ? _exportPdf : _approveQuote,
                    isPrimary: true,
                    isLoading: _isExporting,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Itemized List Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cost Breakdown",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: BrandColors.textDark,
                  ),
                ),
                Text(
                  "${_currentEstimate.items.length} Items",
                  style: TextStyle(color: BrandColors.textBody),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _currentEstimate.items.length,
              itemBuilder: (context, index) {
                return _buildItemCard(_currentEstimate.items[index]);
              },
            ),
            
            const SizedBox(height: 40),
            
            // Footer
            Text(
              "Prices are subject to change based on market rates.",
              style: TextStyle(
                color: BrandColors.textHint,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: BrandColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: BrandShadows.medium,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Estimate",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _fmt(_currentEstimate.total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem("Subtotal", _currentEstimate.subtotal),
                Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                _buildSummaryItem("Tax (18%)", _currentEstimate.tax),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSummaryItem(String label, double value) {
    return Column(
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
          _fmt(value),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isPrimary ? BrandColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: BrandColors.border),
          boxShadow: isPrimary ? BrandShadows.light : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(
                    isPrimary ? Colors.white : BrandColors.primary,
                  ),
                ),
              )
            else ...[
              Icon(
                icon,
                color: isPrimary ? Colors.white : BrandColors.textBody,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : BrandColors.textBody,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX();
  }

  Widget _buildItemCard(EstimateItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: BrandShadows.light,
        border: Border.all(color: Colors.transparent),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BrandColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getCategoryIcon(item.category),
              color: BrandColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: BrandColors.textDark,
                    fontSize: 15,
                  ),
                ),
                if (item.notes != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      item.notes!,
                      style: TextStyle(
                        color: BrandColors.textHint,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  "${item.quantity} ${item.unit} × ${_fmt(item.rate)}",
                  style: TextStyle(
                    color: BrandColors.textBody,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _fmt(item.amount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: BrandColors.primary,
              fontSize: 15,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  IconData _getCategoryIcon(EstimateCategory category) {
    switch (category) {
      case EstimateCategory.design: return Icons.brush;
      case EstimateCategory.materials: return Icons.category;
      case EstimateCategory.labor: return Icons.engineering;
      case EstimateCategory.furniture: return Icons.chair;
      case EstimateCategory.lighting: return Icons.lightbulb;
      case EstimateCategory.accessories: return Icons.local_florist;
      default: return Icons.attach_money;
    }
  }
}
