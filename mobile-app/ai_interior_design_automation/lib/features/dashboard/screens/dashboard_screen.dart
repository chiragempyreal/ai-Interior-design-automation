import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
      const _HomeTab(),             // Index 0: Home
      const ProjectListScreen(),    // Index 1: Projects
      const StatsScreen(),          // Index 2: Stats
      const ProfileScreen(),        // Index 3: Profile
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home, Icons.home_outlined, 'Home', 0),
          _buildNavItem(Icons.grid_view_rounded, Icons.grid_view_outlined, 'Projects', 1),
          _buildNavItem(Icons.bar_chart_rounded, Icons.bar_chart_outlined, 'Stats', 2),
          _buildNavItem(Icons.person, Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    final isSelected = _selectedIndex == index;
    
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
              color: isSelected ? Colors.black : Colors.grey,
              size: 26,
            ),
            if (isSelected) 
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.orange, // Accent dot
                    shape: BoxShape.circle,
                  ),
                ),
              )
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

class _HomeTabState extends State<_HomeTab> with SingleTickerProviderStateMixin {
  int _selectedTab = 0; // 0 = Room Decor, 1 = AI Designer
  late TabController _tabController;
  final Color _accentOrange = const Color(0xFFFF8A65); 

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () {}, 
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, size: 28, color: Colors.black),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.notifications_none, size: 28, color: Colors.black),
                onPressed: () {},
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildToggleTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = 0),
                child: AnimatedContainer(
                  duration: 200.ms,
                  decoration: BoxDecoration(
                    color: _selectedTab == 0 ? _accentOrange : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _selectedTab == 0
                        ? [BoxShadow(color: _accentOrange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_outlined, color: _selectedTab == 0 ? Colors.white : Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "Room Decor",
                        style: TextStyle(
                          color: _selectedTab == 0 ? Colors.white : Colors.grey[600],
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
                    color: _selectedTab == 1 ? Colors.black87 : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: _selectedTab == 1 ? Colors.white : Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "Ai Designer",
                        style: TextStyle(
                          color: _selectedTab == 1 ? Colors.white : Colors.grey[600],
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/image-input', extra: {'source': ImageSource.camera}),
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Camera",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        Icon(Icons.camera_alt_outlined, size: 28, color: _accentOrange),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "A picture",
                      style: TextStyle(fontSize: 12, color: Colors.brown[300]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push('/image-input', extra: {'source': ImageSource.gallery}),
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Gallery",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E2723),
                          ),
                        ),
                        Icon(Icons.file_upload_outlined, size: 28, color: _accentOrange),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Upload file",
                      style: TextStyle(fontSize: 12, color: Colors.brown[300]),
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
    // Show only first 4 items in Home Tab
    final projects = context.watch<ProjectProvider>().projects.take(4).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Design my Home",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              // Could link to Projects Tab, but for now just text
              Text(
                "See All",
                style: TextStyle(color: _accentOrange, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              _buildFilterChip("All", true),
              _buildFilterChip("Free", false),
              _buildFilterChip("Paid", false),
              Container( 
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accentOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.filter_list, color: Colors.white, size: 20),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        projects.isEmpty
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
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return _buildProjectCard(projects[index], index);
                },
              ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _accentOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

    return GestureDetector(
      onTap: () => context.push('/generate-scope', extra: project),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
          image: image != null
              ? DecorationImage(image: image, fit: BoxFit.cover)
              : null,
        ),
        child: Stack(
          children: [
            if (image != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  ),
                ),
              ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Draft", 
                      style: TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    project.name,
                    style: const TextStyle(
                      color: Colors.white,
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
    return Center(
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 8),
          Text(
            "No Designs Yet",
            style: TextStyle(color: Colors.grey[400]),
          ),
          TextButton(
             onPressed: () => context.push('/create-project'),
             child: Text("Create First Project", style: TextStyle(color: _accentOrange)),
          ),
        ],
      ),
    );
  }

  String _getPropertyTypeName(propertyType) {
    final typeString = propertyType.toString().split('.').last;
    return typeString[0].toUpperCase() + typeString.substring(1);
  }
} // End _HomeTab