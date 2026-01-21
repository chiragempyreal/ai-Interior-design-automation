import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/constants/brand_colors.dart';
import '../../project/providers/project_provider.dart';
import '../../project/models/project_model.dart';

// Import new screens
import '../../project/screens/project_list_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../profile/screens/profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // List of screens for navigation
    final List<Widget> _screens = [
      const _HomeTab(), // Index 0: Home
      const ProjectListScreen(), // Index 1: Projects
      const StatsScreen(), // Index 2: Stats
      const ProfileScreen(), // Index 3: Profile
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    final theme = Theme.of(context);
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: BrandShadows
            .light, // Shadows might be invisible in dark mode, which is fine
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, Icons.home_outlined, 'Home', 0),
          _buildNavItem(
            Icons.grid_view_rounded,
            Icons.grid_view_outlined,
            'Projects',
            1,
          ),
          _buildNavItem(
            Icons.bar_chart_rounded,
            Icons.bar_chart_outlined,
            'Stats',
            2,
          ),
          _buildNavItem(Icons.person, Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
    int index,
  ) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    // If selected, use Theme's selectedItemColor. If not, use unselected widget color from theme
    final iconColor = isSelected
        ? (theme.bottomNavigationBarTheme.selectedItemColor ??
              theme.colorScheme.primary)
        : (theme.bottomNavigationBarTheme.unselectedItemColor ??
              theme.iconTheme.color);

    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: iconColor,
              size: 26,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white, // Adaptive accent color
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Extracted Home Tab logic to keep main file clean
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab>
    with SingleTickerProviderStateMixin {
  int _selectedTab = 0; // 0 = Room Decor, 1 = AI Designer
  String _selectedFilter = 'All';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildToggleTabs(),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCameraActions(),
                  const SizedBox(height: 32),
                  _buildProjectsGrid(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);
    // Force white icons in dark mode for contrast
    final iconColor = theme.brightness == Brightness.dark
        ? Colors.white
        : theme.iconTheme.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.menu, color: iconColor),
            onPressed: () {},
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.search, size: 28, color: iconColor),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: iconColor,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTabs() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 56,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark ? Colors.white.withOpacity(0.05) : theme.dividerColor,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: AnimatedContainer(
                  duration: 200.ms,
                  decoration: BoxDecoration(
                    color: _selectedTab == 0
                        ? BrandColors.accent
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _selectedTab == 0
                        ? [
                            BoxShadow(
                              color: BrandColors.accent.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: _selectedTab == 0
                            ? BrandColors
                                  .textDark // Dark icon on accent bg
                            : (isDark ? Colors.white : theme.iconTheme.color),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Room Decor",
                        style: TextStyle(
                          color: _selectedTab == 0
                              ? BrandColors
                                    .textDark // Dark text on accent bg
                              : (isDark
                                    ? Colors.white
                                    : theme.textTheme.bodyMedium?.color),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 1),
                child: AnimatedContainer(
                  duration: 200.ms,
                  decoration: BoxDecoration(
                    color: _selectedTab == 1
                        ? BrandColors.primaryLight
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: _selectedTab == 1
                            ? BrandColors.textDark
                            : (isDark ? Colors.white70 : theme.iconTheme.color),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Ai Designer",
                        style: TextStyle(
                          color: _selectedTab == 1
                              ? BrandColors.textDark
                              : (isDark
                                    ? Colors.white70
                                    : theme.textTheme.bodyMedium?.color),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraActions() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Specific dark color from screenshot analysis
    final cardColor = isDark ? const Color(0xFF1E1E1E) : theme.cardTheme.color;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(
                '/image-input',
                extra: {'source': ImageSource.camera},
              ),
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Camera",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        const Icon(
                          Icons.camera_alt_outlined,
                          size: 24,
                          color: BrandColors.accent,
                        ),
                      ],
                    ),
                    Text(
                      "A picture",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey[400]
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(
                '/image-input',
                extra: {'source': ImageSource.gallery},
              ),
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.transparent,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gallery",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        Icon(
                          Icons.file_upload_outlined,
                          size: 24,
                          color: isDark ? Colors.white30 : theme.primaryColor,
                        ),
                      ],
                    ),
                    Text(
                      "Upload file",
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? Colors.grey[400]
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildProjectsGrid() {
    final projectProvider = context.watch<ProjectProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Filter Logic
    var projects = projectProvider.projects;
    if (_selectedFilter == 'Free') {
      projects = projects
          .where((p) => p.status == ProjectStatus.draft)
          .toList();
    } else if (_selectedFilter == 'Paid') {
      projects = projects
          .where(
            (p) =>
                p.status == ProjectStatus.approved ||
                p.status == ProjectStatus.generated,
          )
          .toList();
    }
    // Take first 4 after filtering
    final displayProjects = projects.take(4).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Design my Home",
                style: BrandTypography.h5.copyWith(
                  color: isDark ? Colors.white : theme.colorScheme.onBackground,
                  fontSize: 18,
                ),
              ),
              Text(
                "See All",
                style: TextStyle(
                  color: BrandColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _selectedFilter = 'All'),
                child: _buildFilterChip("All", _selectedFilter == 'All'),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedFilter = 'Free'),
                child: _buildFilterChip("Free", _selectedFilter == 'Free'),
              ),
              GestureDetector(
                onTap: () => setState(() => _selectedFilter = 'Paid'),
                child: _buildFilterChip("Paid", _selectedFilter == 'Paid'),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: BrandColors.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.filter_list,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        displayProjects.isEmpty
            ? _buildEmptyState()
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: displayProjects.length,
                itemBuilder: (context, index) {
                  return _buildProjectCard(displayProjects[index], index);
                },
              ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? BrandColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? (isDark ? BrandColors.textDark : Colors.white)
                : (isDark
                      ? Colors.grey[500]
                      : theme.colorScheme.onBackground.withOpacity(0.6)),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(ProjectModel project, int index) {
    FileImage? image;
    if (project.photoPaths.isNotEmpty) {
      image = FileImage(File(project.photoPaths.first));
    }

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/generate-scope', extra: project),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark ? const Color(0xFF1E1E1E) : theme.cardTheme.color,
          image: image != null
              ? DecorationImage(image: image, fit: BoxFit.cover)
              : null,
          boxShadow: isDark ? [] : BrandShadows.light,
        ),
        child: Stack(
          children: [
            if (image == null)
              Center(
                child: Icon(
                  Icons.folder_outlined,
                  color: isDark ? Colors.white10 : Colors.grey[300],
                  size: 40,
                ),
              ),
            if (image != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
              ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (image != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getPropertyTypeName(project.propertyDetails.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  Text(
                    project.name,
                    style: TextStyle(
                      color: (image != null || isDark)
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.folder_open,
              size: 48,
              color: theme.dividerColor.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              "No Designs Yet",
              style: TextStyle(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 14,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/create-project'),
              child: const Text(
                "Create First Project",
                style: TextStyle(
                  color: BrandColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPropertyTypeName(propertyType) {
    // Helper to cleanup enum string
    final typeString = propertyType.toString().split('.').last;
    return typeString[0].toUpperCase() + typeString.substring(1);
  }
}

// End _HomeTab
