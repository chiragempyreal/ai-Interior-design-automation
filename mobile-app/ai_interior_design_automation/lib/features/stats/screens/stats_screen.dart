import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../project/providers/project_provider.dart';
import '../../../core/constants/brand_colors.dart';
import '../../../core/services/notification_service.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final projectProvider = context.watch<ProjectProvider>();
    final projects = projectProvider.projects;
    final stats = projectProvider.stats;

    // Calculate generic revenue (sum of budgets)
    double totalValue = 0;
    for (var p in projects) {
      totalValue += p.technicalRequirements.budget.totalBudget;
    }

    // Format revenue
    String revenueText = "₹${(totalValue / 100000).toStringAsFixed(1)}L";
    if (totalValue == 0) revenueText = "₹0";

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Analytics",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn().slideX(),
                  IconButton(
                    onPressed: () {
                      NotificationService.showNotification(
                        title: "Weekly Summary",
                        body: "You have 2 pending projects to review.",
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        shape: BoxShape.circle,
                        boxShadow: BrandShadows.light,
                      ),
                      child: Icon(
                        Icons.notifications_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Overview of your design business",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.white54 : Colors.black54,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),

              // Key Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      "Est. Revenue",
                      revenueText,
                      projects.isNotEmpty ? "+12%" : "0%",
                      Colors.green,
                      Icons.attach_money,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard(
                      context,
                      "Projects",
                      "${stats['total'] ?? projects.length}",
                      "+${stats['pending'] ?? 0} Pending",
                      BrandColors.primary,
                      Icons.folder_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Chart Section
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: isDark ? [] : BrandShadows.light,
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Monthly Activity",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Last 6 Months",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildMonthlyChart(context),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 32),

              // Breakdown
              Text(
                "Cost Breakdown",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E1E1E)
                      : theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.transparent,
                  ),
                ),
                child: Column(
                  children: [
                    _buildCostBreakdownItem(
                      context,
                      "Materials",
                      0.6,
                      const Color(0xFF6C63FF),
                    ),
                    _buildCostBreakdownItem(
                      context,
                      "Labor",
                      0.25,
                      const Color(0xFFFF6584),
                    ),
                    _buildCostBreakdownItem(
                      context,
                      "Design Fees",
                      0.15,
                      const Color(0xFFFFC045),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String trend,
    Color trendColor,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: theme.shadowColor.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: trendColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey[500],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context) {
    final projectProvider = context.watch<ProjectProvider>();
    final projects = projectProvider.projects;

    // Calculate last 6 months data
    final now = DateTime.now();
    final monthData = <String, int>{};

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final monthKey = '${month.month}-${month.year}';
      monthData[monthKey] = 0;
    }

    // Count projects per month
    for (var project in projects) {
      final createdDate = project.createdAt;
      final monthKey = '${createdDate.month}-${createdDate.year}';
      if (monthData.containsKey(monthKey)) {
        monthData[monthKey] = (monthData[monthKey] ?? 0) + 1;
      }
    }

    // Find max for scaling
    final maxCount = monthData.values.isEmpty
        ? 1
        : monthData.values.reduce((a, b) => a > b ? a : b);
    final scaledMax = maxCount == 0 ? 1.0 : maxCount.toDouble();

    // Build bars
    final bars = <Widget>[];
    int index = 0;
    monthData.forEach((key, count) {
      final month = DateTime(
        int.parse(key.split('-')[1]),
        int.parse(key.split('-')[0]),
        1,
      );
      final monthLabel = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][month.month - 1];
      final isActive = index == monthData.length - 1;
      bars.add(
        _buildBar(context, monthLabel, count / scaledMax, isActive: isActive),
      );
      index++;
    });

    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bars,
      ),
    );
  }

  Widget _buildBar(
    BuildContext context,
    String label,
    double pct, {
    bool isActive = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: 1000.ms,
          curve: Curves.easeOutExpo,
          width: 8, // Thinner, more modern
          height: 100 * pct,
          decoration: BoxDecoration(
            color: isActive
                ? BrandColors.primary
                : (isDark ? Colors.white24 : Colors.grey[300]),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            color: isActive
                ? (isDark ? Colors.white : Colors.black87)
                : (isDark ? Colors.white38 : Colors.grey[400]),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCostBreakdownItem(
    BuildContext context,
    String label,
    double pct,
    Color color,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                "${(pct * 100).toInt()}%",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: pct,
                  backgroundColor: isDark ? Colors.white10 : Colors.grey[100],
                  color: color,
                  minHeight: 6,
                ),
              )
              .animate()
              .fadeIn(delay: 400.ms)
              .scaleX(begin: 0, alignment: Alignment.centerLeft),
        ],
      ),
    );
  }
}
