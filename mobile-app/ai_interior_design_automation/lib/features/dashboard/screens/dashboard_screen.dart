import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../project/providers/project_provider.dart';
import '../../estimate/providers/estimate_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // UI Helper: extracted to keep the build method clean
  // Soft Mint/Earth tones based on the reference image
  final Color _bgSoft = const Color(0xFFF4F7F6); 
  final Color _cardWhite = Colors.white;
  final Color _accentBlack = const Color(0xFF1E1E1E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgSoft, // Soft grey-mint background
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    
                    // Welcome Section
                    _buildWelcomeSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Statistics Cards (Styled as Horizontal Categories)
                    _buildStatisticsCards(),
                    
                    const SizedBox(height: 32),
                    
                    // Quick Actions
                    _buildQuickActions(),
                    
                    const SizedBox(height: 32),
                    
                    // Recent Projects
                    _buildRecentProjects(),
                    
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Modern Bottom Navigation
      bottomNavigationBar: _buildBottomNavBar(),
      
      // Floating Action Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-project'),
        backgroundColor: _accentBlack, // Dark button like "Get Started" in image
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Project',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ).animate().scale(delay: 300.ms),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Profile Avatar - Clean Look
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // Using a darker icon or image to match the clean aesthetic
            child: const Icon(Icons.person, color: Color(0xFF2D3436), size: 28),
          ).animate().scale(delay: 100.ms),
          
          const Spacer(),
          
          // Notification Bell - Styled like the 'Cart' icon in reference
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF2D3436),
                    size: 24,
                  ),
                ),
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF6B6B), // Soft Red alert
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().scale(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Matches the "Stylish" background text vibe
          Text(
            'Welcome Back',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
              letterSpacing: 1.0,
            ),
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 8),
          
          // Matches "Design Your Perfect Furniture Space"
          Text(
            'Design Your\nDream Space',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: _accentBlack,
              height: 1.1,
              letterSpacing: -0.5,
              fontSize: 32,
            ),
          ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final projectProvider = context.watch<ProjectProvider>();
    final estimateProvider = context.watch<EstimateProvider>();
    final stats = estimateProvider.getStatistics();
    
    final totalProjects = projectProvider.projects.length;
    final totalEstimates = stats['total'] ?? 0;
    final approvedEstimates = stats['approved'] ?? 0;
    final totalValue = stats['totalValue'] ?? 0.0;

    return SizedBox(
      height: 180, // Taller for the "Chair Card" look
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        children: [
          // Soft Green (Matches "Pure Comfort" / Green Chair)
          _buildStatCard(
            'Projects',
            totalProjects.toString(),
            Icons.folder_outlined,
            const Color(0xFFE8F5E9), // Soft Mint
            const Color(0xFF2E7D32), // Dark Green Text
            0,
          ),
          const SizedBox(width: 20),
          // Soft Beige/Brown (Matches "Luxury Sit")
          _buildStatCard(
            'Estimates',
            totalEstimates.toString(),
            Icons.receipt_long_outlined,
            const Color(0xFFF5F0E1), // Beige
            const Color(0xFF795548), // Brown Text
            100,
          ),
          const SizedBox(width: 20),
          // Soft Blue
          _buildStatCard(
            'Approved',
            approvedEstimates.toString(),
            Icons.check_circle_outline,
            const Color(0xFFE3F2FD), // Soft Blue
            const Color(0xFF1565C0), // Dark Blue Text
            200,
          ),
          const SizedBox(width: 20),
          // Soft Purple
          _buildStatCard(
            'Total Value',
            '₹${(totalValue / 100000).toStringAsFixed(1)}L',
            Icons.currency_rupee,
            const Color(0xFFF3E5F5), // Soft Purple
            const Color(0xFF7B1FA2), // Dark Purple Text
            300,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color accentColor,
    int delay,
  ) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // White card
        borderRadius: BorderRadius.circular(32), // High border radius
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04), // Ultra subtle shadow
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon Circle
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: _accentBlack,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: _accentBlack,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ),
        
        const SizedBox(height: 20),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Create\nProject',
                  Icons.add_circle_outline,
                  const Color(0xFFFFF0E6), // Soft Orange
                  const Color(0xFFFF8A65),
                  () => context.push('/create-project'),
                  0,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildActionCard(
                  'View\nEstimates',
                  Icons.receipt_outlined,
                  const Color(0xFFE0F2F1), // Soft Teal
                  const Color(0xFF26A69A),
                  () {},
                  100,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    Color iconColor,
    VoidCallback onTap,
    int delay,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          // Removed strong shadow for flat pastel look
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _accentBlack.withOpacity(0.8),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay.ms).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildRecentProjects() {
    final projectProvider = context.watch<ProjectProvider>();
    final projects = projectProvider.projects;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Projects',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _accentBlack,
                ),
              ),
              if (projects.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Icon(Icons.arrow_forward_ios, size: 12),
                ),
            ],
          ).animate().fadeIn(delay: 500.ms),
        ),
        
        const SizedBox(height: 20),
        
        if (projects.isEmpty)
          _buildEmptyState()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: projects.length > 5 ? 5 : projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return _buildProjectCard(project, index);
            },
          ),
      ],
    );
  }

  Widget _buildProjectCard(project, int index) {
    // Randomly assign soft pastel backgrounds for the "Image" placeholder
    final bgColors = [
      const Color(0xFFE0F7FA), // Cyan
      const Color(0xFFF3E5F5), // Purple
      const Color(0xFFE8F5E9), // Green
      const Color(0xFFFFF3E0), // Orange
      const Color(0xFFECEFF1), // Blue Grey
    ];
    
    final iconColors = [
      const Color(0xFF00BCD4),
      const Color(0xFFAB47BC),
      const Color(0xFF66BB6A),
      const Color(0xFFFFA726),
      const Color(0xFF78909C),
    ];
    
    final colorIndex = index % bgColors.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/generate-scope', extra: project),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Project Icon / Image Placeholder
                // Matches the "Chair Image" visual weight
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: bgColors[colorIndex],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.home_work_outlined, // Changed to outlined for cleaner look
                    color: iconColors[colorIndex],
                    size: 32,
                  ),
                ),
                
                const SizedBox(width: 20),
                
                // Project Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _accentBlack,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_getPropertyTypeName(project.propertyDetails.type)} • ${project.propertyDetails.carpetArea.toInt()} sq ft',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // "Tag" style for price
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _bgSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '₹${(project.technicalRequirements.budget.totalBudget / 100000).toStringAsFixed(1)}L',
                          style: TextStyle(
                            color: _accentBlack,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add_business_outlined,
              color: Colors.grey[400],
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Start Designing',
            style: TextStyle(
              color: _accentBlack,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first project space',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_filled, 'Home', 0),
          _buildNavItem(Icons.grid_view_rounded, 'Projects', 1),
          const SizedBox(width: 48), // Space for floating FAB
          _buildNavItem(Icons.bar_chart_rounded, 'Stats', 2),
          _buildNavItem(Icons.person_outline_rounded, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _accentBlack : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          // If selected, icon is white. If not, grey.
          color: isSelected ? Colors.white : Colors.grey[400],
          size: 24,
        ),
      ),
    );
  }

  String _getPropertyTypeName(propertyType) {
    final typeString = propertyType.toString().split('.').last;
    // Capitalize first letter
    return typeString[0].toUpperCase() + typeString.substring(1);
  }
}