import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/brand_colors.dart';
import '../../project/providers/project_provider.dart';
import '../../project/models/project_model.dart';

// Import new screens
import '../../project/screens/project_list_screen.dart';
import '../../stats/screens/stats_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../project/widgets/project_card.dart';

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
  String _selectedFilter = 'All'; // All, Residential, Commercial
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => context.read<ProjectProvider>().fetchProjects());
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
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
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCameraActions(),
                  const SizedBox(height: 24),
                  _buildProjectsSection(),
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
                icon: Icon(
                  Icons.notifications_none,
                  size: 28,
                  color: iconColor,
                ),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: BrandColors.accent,
                child: const Icon(Icons.person, color: Colors.white, size: 20),
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
                  ),
                  child: Center(
                    child: Text(
                      "Room Decor",
                      style: TextStyle(
                        color: _selectedTab == 0
                            ? BrandColors.textDark
                            : (isDark
                                  ? Colors.white
                                  : theme.textTheme.bodyMedium?.color),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  child: Center(
                    child: Text(
                      "AI Designer",
                      style: TextStyle(
                        color: _selectedTab == 1
                            ? BrandColors.textDark
                            : (isDark
                                  ? Colors.white70
                                  : theme.textTheme.bodyMedium?.color),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          hintText: "Search projects...",
          hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.grey),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: isDark ? const Color(0xFF1E1E1E) : theme.cardTheme.color,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildCameraActions() {
    // Kept existing implementation but streamlined
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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
                height: 100,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.camera_alt_outlined,
                      color: BrandColors.accent,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Camera",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
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
                height: 100,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.transparent,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      color: theme.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Gallery",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
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
    );
  }

  Widget _buildProjectsSection() {
    final projectProvider = context.watch<ProjectProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (projectProvider.isLoading) {
      return _buildSkeletonLoader();
    }

    // Filtering Logic
    var projects = projectProvider.projects;

    // Search Filter
    if (_searchController.text.isNotEmpty) {
      projects = projects
          .where(
            (p) => p.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    }

    // Category Filter
    if (_selectedFilter != 'All') {
      final type = _selectedFilter == 'Residential'
          ? PropertyType.residential
          : PropertyType.commercial;
      projects = projects.where((p) => p.propertyDetails.type == type).toList();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Projects",
                style: TextStyle(
                  color: isDark ? Colors.white : theme.colorScheme.onBackground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // Filter Chips
              Row(
                children: [
                  _buildFilterChip('All'),
                  _buildFilterChip('Residential'),
                  _buildFilterChip('Commercial'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        projects.isEmpty
            ? _buildEmptyState()
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 600
                      ? 3
                      : 2,
                  childAspectRatio: 0.65, // Taller for content
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: projects.length > 4
                    ? 4
                    : projects.length, // Limit to 4 on home
                itemBuilder: (context, index) {
                  return ProjectCard(project: projects[index], index: index);
                },
              ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    // ... existing filter chip code ...
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? BrandColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: Text(
          label == 'Residential'
              ? 'Res'
              : (label == 'Commercial' ? 'Com' : label),
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white70
                      : Colors.black54),
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: 4,
      itemBuilder: (_, __) => Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
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
}

// End _HomeTab
