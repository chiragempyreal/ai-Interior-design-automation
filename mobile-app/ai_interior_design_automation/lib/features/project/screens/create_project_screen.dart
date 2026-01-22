import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/brand_colors.dart';
import '../models/project_model.dart';
import '../providers/project_provider.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 8; // Increased to 8
  bool _isGenerating = false;

  // KEY: Form Keys for validation per step
  final _step1Key = GlobalKey<FormState>();

  // STEP 1: Basics
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _localityController = TextEditingController();
  PropertyType _propertyType = PropertyType.residential;
  final List<String> _selectedCategories = [];
  final List<String> _selectedSpaceTypes = []; // Living Room, Bedroom...
  final _otherSpaceController = TextEditingController();

  // STEP 2: Measurements
  final _areaController = TextEditingController();
  final _heightController = TextEditingController();
  String _areaUnit = 'sqft';
  String _heightUnit = 'feet';
  String _lightLevel = 'Good - Few Windows';
  String _ventilation = 'Average';
  String _condition = 'Empty/Unfurnished';
  int _numberOfRooms = 2; // Default

  // STEP 3: Photos
  final ImagePicker _picker = ImagePicker();
  final List<File> _projectPhotos = [];
  final List<File> _inspirationPhotos = [];

  // STEP 4: Design Style
  String _selectedStyle = '';
  final List<String> _selectedVibes = [];
  final List<String> _selectedThemes = [];
  final List<String> _accentStyles = [];

  // STEP 5: Materials
  // Storing as General preferences for now to simplify UI
  String _flooringMat = 'Vitrified Tiles';
  String _wallFinish = 'Paint';
  String _ceilingType = 'False Ceiling (POP)';
  String _furnitureStyle = 'Modern Modular';
  final List<String> _uiPrimaryColors = [];
  double _colorIntensity = 0.5;

  // STEP 6: Tech & Amenities
  final List<String> _lightingTypes = [];
  final List<String> _lightingFixtures = [];
  String _smartHome = 'Traditional Only';
  final List<String> _smartIntegrations = [];
  final List<String> _windowCoverings = [];
  final List<String> _amenities = [];

  // STEP 7: Budget & Timeline
  double _budget = 800000;
  final _requirementsController = TextEditingController();
  String _timeline = 'Standard (1-3 months)';
  String _occupancy = 'Property is vacant';
  String _budgetBreakdown = 'Flexible';

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    _areaController.dispose();
    _heightController.dispose();
    _requirementsController.dispose();
    _otherSpaceController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Validation Logic
    if (_currentStep == 0) {
      if (!_step1Key.currentState!.validate()) return;
      if (_selectedSpaceTypes.isEmpty) {
        _showSnack("Please select at least one room type");
        return;
      }
    }
    if (_currentStep == 1) {
      if (_areaController.text.isEmpty) {
        _showSnack("Please enter carpet area");
        return;
      }
    }
    // Photo upload is now optional - no minimum requirement
    if (_currentStep == 3 && _selectedStyle.isEmpty) {
      _showSnack("Please select a primary design style");
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(duration: 300.ms, curve: Curves.easeInOut);
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: 300.ms, curve: Curves.easeInOut);
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _pickImage(bool isInspiration, ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        if (isInspiration) {
          _inspirationPhotos.add(File(image.path));
        } else {
          _projectPhotos.add(File(image.path));
        }
      });
    }
  }

  void _showImageSourceModal(bool isInspiration) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                "Select Image Source",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: BrandColors.primary),
              title: Text("Take Photo", style: theme.textTheme.bodyLarge),
              onTap: () {
                context.pop();
                _pickImage(isInspiration, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: BrandColors.primary,
              ),
              title: Text(
                "Choose from Gallery",
                style: theme.textTheme.bodyLarge,
              ),
              onTap: () {
                context.pop();
                _pickImage(isInspiration, ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _isGenerating = true);

    // Map simplified state variables to the complex model
    final project = ProjectModel(
      name: _nameController.text,
      clientDetails: ClientDetails(
        name: "Current User", // Mock
        email: "user@example.com",
      ),
      propertyDetails: PropertyDetails(
        type: _propertyType,
        categories: _selectedCategories,
        spaceTypes: _selectedSpaceTypes.map((s) => s.trim()).toList(),
        city: _cityController.text,
        locality: _localityController.text,
        carpetArea: double.tryParse(_areaController.text) ?? 0,
        areaUnit: _areaUnit,
        ceilingHeight: double.tryParse(_heightController.text) ?? 10,
        ceilingHeightUnit: _heightUnit,
        lightAvailability: _lightLevel,
        ventilation: _ventilation,
        currentCondition: _condition,
        numberOfRooms: _numberOfRooms,
      ),
      designPreferences: DesignPreferences(
        primaryStyle: _selectedStyle,
        accentStyles: _accentStyles,
        moods: _selectedVibes,
        themes: _selectedThemes,
        materials: MaterialPreferences(
          flooring: {'General': _flooringMat},
          wallFinish: {'General': _wallFinish},
          ceilingType: {'General': _ceilingType},
          furnitureStyle: _furnitureStyle,
        ),
        palette: ColorPalette(
          primaryColors: _uiPrimaryColors,
          intensity: _colorIntensity,
        ),
      ),
      technicalRequirements: TechnicalRequirements(
        lightingTypes: _lightingTypes,
        lightingFixtures: _lightingFixtures,
        smartHomeLevel: _smartHome,
        smartIntegrations: _smartIntegrations,
        windowTreatments: {'General': _windowCoverings.join(', ')},
        amenities: _amenities,
        budget: BudgetDetails(
          totalBudget: _budget,
          breakdownPreference: _budgetBreakdown,
        ),
        timeline: TimelineDetails(
          durationExpectation: _timeline,
          occupancyStatus: _occupancy,
        ),
        specialRequirements: {'notes': _requirementsController.text},
      ),
      photoPaths: _projectPhotos.map((e) => e.path).toList(),
      inspirationPaths: _inspirationPhotos.map((e) => e.path).toList(),
    );

    try {
      final provider = context.read<ProjectProvider>();
      // 1. Create Project & Upload Photos -> API
      final createdProject = await provider.addProject(project);

      // 2. Trigger AI Generation → API
      final previewResponse = await provider.generatePreview(createdProject.id);

      // Extract data from backend response
      String? aiPreviewUrl;
      String? originalImageUrl;

      if (previewResponse != null && previewResponse['data'] != null) {
        final data = previewResponse['data'];
        aiPreviewUrl = data['previewUrl'];
        originalImageUrl = data['originalUrl'];

        print("🎨 AI Preview URL: $aiPreviewUrl");
        print("📸 Original Image URL: $originalImageUrl");
      }

      // Build full URLs for images
      final String baseUrl = 'https://team1api.empyreal.in';
      final List<String> backendPhotoPaths = originalImageUrl != null
          ? [baseUrl + originalImageUrl]
          : [];

      // Use ORIGINAL project (which has all user inputs) and only update images
      final displayProject = project.copyWith(
        aiPreviewUrl: aiPreviewUrl,
        photoPaths: backendPhotoPaths.isNotEmpty
            ? backendPhotoPaths
            : project.photoPaths,
      );

      print("✅ Final Display Project:");
      print("   ID: ${createdProject.id}");
      print("   Name: ${displayProject.name}");
      print("   Photo Paths: ${displayProject.photoPaths}");
      print("   AI Preview: ${displayProject.aiPreviewUrl}");
      print("   Area: ${displayProject.propertyDetails.carpetArea}");
      print(
        "   Budget: ${displayProject.technicalRequirements.budget.totalBudget}",
      );
      print("   Style: ${displayProject.designPreferences.primaryStyle}");

      // Simulate AI time for better UX
      await Future.delayed(2.seconds);

      // 3. Success → Navigate
      if (mounted) {
        setState(() => _isGenerating = false);
        // Navigate with project that has USER'S INPUT DATA + BACKEND IMAGES
        context.push('/project-preview', extra: displayProject);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);

        final errorMsg = e.toString();
        // Check for 401 Unauthorized
        if (errorMsg.contains("401")) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (c) => AlertDialog(
              title: const Text("Session Expired"),
              content: const Text(
                "Your session has expired. Please log in again to submit your project.",
              ),
              actions: [
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text("Log In"),
                ),
              ],
            ),
          );
        } else {
          _showSnack("Error: ${errorMsg.replaceAll('Exception:', '')}");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isGenerating) return _buildAiLoader();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: theme.iconTheme.color,
          ),
          onPressed: _prevStep,
        ),
        title: Column(
          children: [
            Text(
              "Step ${_currentStep + 1} of $_totalSteps",
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              _getStepTitle(_currentStep),
              style: TextStyle(
                color: theme.textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            color: BrandColors.primary,
            minHeight: 4,
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildStep5(),
                _buildStep6(),
                _buildStep7(),
                _buildStep8(), // Review Screen
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildAiLoader() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                "https://cdn.dribbble.com/users/1186261/screenshots/3718681/loading_gif.gif",
                height: 120,
                errorBuilder: (c, o, s) => const Icon(
                  Icons.auto_awesome,
                  size: 80,
                  color: BrandColors.primary,
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1500.ms),
              const SizedBox(height: 32),
              Text(
                "Creating Your Custom Design",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Our AI is analyzing your space and applying your selected style...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),
              // Steps
              _buildLoaderStep("Analyzing floor plan...", 500, isDark),
              _buildLoaderStep("Matching furniture styles...", 1500, isDark),
              _buildLoaderStep("Optimizing lighting...", 2500, isDark),
              _buildLoaderStep("Generating final render...", 3500, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoaderStep(String text, int delay, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ).animate().fadeIn(delay: delay.ms).slideY(),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return "Project Basics";
      case 1:
        return "Measurements";
      case 2:
        return "Photos";
      case 3:
        return "Design Style";
      case 4:
        return "Materials";
      case 5:
        return "Lighting & Tech";
      case 6:
        return "Final Details";
      case 7:
        return "Review & Submit";
      default:
        return "";
    }
  }

  // STEP 8: REVIEW
  Widget _buildStep8() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Review Your Project"),
          _buildReviewCard(
            "Basics",
            "${_nameController.text}\n${_propertyType.name.toUpperCase()}\nArea: ${_areaController.text} $_areaUnit",
            () => _pageController.jumpToPage(0),
          ),
          _buildReviewCard(
            "Style",
            "Primary: $_selectedStyle\nVibes: ${_selectedVibes.join(', ')}",
            () => _pageController.jumpToPage(3),
          ),
          _buildReviewCard(
            "Materials",
            "Floor: $_flooringMat\nWall: $_wallFinish",
            () => _pageController.jumpToPage(4),
          ),
          _buildReviewCard(
            "Budget & Timeline",
            "Budget: ₹${(_budget / 100000).toStringAsFixed(1)}L\n${_timeline}",
            () => _pageController.jumpToPage(6),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String title, String content, VoidCallback onEdit) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50], // Card background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.transparent : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: BrandColors.primary),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      color: theme.scaffoldBackgroundColor,
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: BrandColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          _currentStep == _totalSteps - 1 ? "Generate AI Preview" : "Next",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // --- STEPS ---

  // STEP 1: BASICS
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader("Tell us about your project"),
            _buildLabel("Project Name*"),
            TextFormField(
              controller: _nameController,
              style: Theme.of(context).textTheme.bodyMedium,
              validator: (v) => v!.isEmpty ? "Required" : null,
              decoration: _inputDeco("e.g. Dream Living Room"),
            ),

            _buildLabel("Property Type*"),
            _buildChipGroup(
              PropertyType.values.map((e) => e.name.toUpperCase()).toList(),
              (val) => setState(
                () => _propertyType = PropertyType.values.byName(
                  val.toLowerCase(),
                ),
              ),
              _propertyType.name.toUpperCase(),
            ),

            _buildLabel("Project Category*"),
            _buildMultiSelectChipGroup([
              "New Construction",
              "Renovation",
              "Remodeling",
              "Furniture Only",
            ], _selectedCategories),

            _buildLabel("Space / Room Type*"),
            Wrap(
              spacing: 8,
              children:
                  [
                    "Living Room",
                    "Bedroom",
                    "Kitchen",
                    "Bathroom",
                    "Dining Room",
                    "Study/Office",
                    "Kids Room",
                    "Full Home",
                    "Other",
                  ].map((room) {
                    final isSelected = _selectedSpaceTypes.contains(room);
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    return FilterChip(
                      label: Text(room),
                      selected: isSelected,
                      onSelected: (v) {
                        setState(() {
                          if (v)
                            _selectedSpaceTypes.add(room);
                          else
                            _selectedSpaceTypes.remove(room);
                        });
                      },
                      selectedColor: BrandColors.primary.withOpacity(0.2),
                      checkmarkColor: BrandColors.primary,
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[100],
                      labelStyle: TextStyle(
                        color: isSelected
                            ? BrandColors.primary
                            : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isDark
                              ? Colors.transparent
                              : Colors.grey[300]!,
                        ),
                      ),
                      side: BorderSide.none,
                    );
                  }).toList(),
            ),

            if (_selectedSpaceTypes.contains("Other"))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextFormField(
                  controller: _otherSpaceController,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: _inputDeco("Specify room type..."),
                ),
              ),

            _buildLabel("Property Location*"),
            TextFormField(
              controller: _cityController,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: _inputDeco("City"),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _localityController,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: _inputDeco("Area/Locality"),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 2: MEASUREMENTS
  Widget _buildStep2() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Space Details"),

          _buildLabel("Total Carpet Area*"),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _areaController,
                  style: theme.textTheme.bodyMedium,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco("400"),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _areaUnit,
                dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                items: ["sqft", "sqm", "sq yards"]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _areaUnit = v!),
                underline: Container(),
              ),
            ],
          ),

          if (_selectedSpaceTypes.contains("Full Home"))
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLabel("Number of Rooms*"),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(
                        () => _numberOfRooms > 1 ? _numberOfRooms-- : null,
                      ),
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: theme.iconTheme.color,
                      ),
                    ),
                    Text(
                      "$_numberOfRooms",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _numberOfRooms++),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: theme.iconTheme.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),

          _buildLabel("Ceiling Height"),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _heightController,
                  style: theme.textTheme.bodyMedium,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco("10"),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _heightUnit,
                dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                items: ["feet", "meters"]
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _heightUnit = v!),
                underline: Container(),
              ),
            ],
          ),

          _buildLabel("Natural Light Availability"),
          _buildChipGroup(
            ["Excellent", "Good", "Moderate", "Low"],
            (v) => setState(() => _lightLevel = v),
            _lightLevel.split(' ')[0], // Simple match
          ),

          _buildLabel("Current Condition"),
          DropdownButtonFormField<String>(
            value: _condition,
            isExpanded: true,
            dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
            items:
                [
                  "Empty/Unfurnished",
                  "Partially Furnished",
                  "Fully Furnished",
                  "Under Construction",
                  "Requires Renovation",
                ].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
            onChanged: (v) => setState(() => _condition = v!),
            decoration: _inputDeco(""),
          ),
        ],
      ),
    );
  }

  // STEP 3: PHOTOS
  Widget _buildStep3() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Show us your space"),
          const SizedBox(height: 4),
          Text(
            "Upload photos of your space (optional)",
            style: TextStyle(
              color: isDark ? Colors.white60 : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionIcon(
                  Icons.camera_alt,
                  "Camera",
                  () => _pickImage(false, ImageSource.camera),
                ),
                _buildActionIcon(
                  Icons.photo_library,
                  "Gallery",
                  () => _pickImage(false, ImageSource.gallery),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _projectPhotos.length,
            itemBuilder: (c, i) => Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_projectPhotos[i], fit: BoxFit.cover),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => setState(() => _projectPhotos.removeAt(i)),
                    child: const Icon(Icons.cancel, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 40),
          _buildLabel("Reference / Inspiration Images"),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                InkWell(
                  onTap: () => _showImageSourceModal(true),
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.add_photo_alternate,
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                  ),
                ),
                ..._inspirationPhotos.map(
                  (file) => Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        file,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: DESIGN STYLE
  Widget _buildStep4() {
    final styles = [
      "Modern",
      "Contemporary",
      "Minimal",
      "Scandinavian",
      "Industrial",
      "Boho",
      "Classic",
      "Luxurious",
    ];
    final vibes = [
      "Cozy ☕",
      "Airy ☀️",
      "Luxurious 💎",
      "Minimal ✨",
      "Vibrant 🎨",
      "Calm 🌿",
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Choose your style"),

          _buildLabel("Primary Style*"),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: styles.length,
            itemBuilder: (c, i) {
              final isSelected = _selectedStyle == styles[i];
              return GestureDetector(
                onTap: () => setState(() => _selectedStyle = styles[i]),
                child: AnimatedContainer(
                  duration: 200.ms,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BrandColors.primary
                        : (isDark ? Colors.grey[800] : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? BrandColors.primary
                          : (isDark ? Colors.transparent : Colors.grey[300]!),
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: BrandColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      styles[i],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          _buildLabel("Design Vibe"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vibes.map((v) {
              final isSelected = _selectedVibes.contains(v);
              return FilterChip(
                label: Text(v),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    if (val)
                      _selectedVibes.add(v);
                    else
                      _selectedVibes.remove(v);
                  });
                },
                backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                selectedColor: isDark
                    ? BrandColors.primary.withOpacity(0.3)
                    : const Color(0xFFFFF3E0),
                checkmarkColor: isDark ? BrandColors.primary : Colors.orange,
                labelStyle: TextStyle(
                  color: isDark
                      ? (isSelected ? BrandColors.primary : Colors.white70)
                      : Colors.black87,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isDark ? Colors.transparent : Colors.grey[300]!,
                  ),
                ),
                side: BorderSide.none,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // STEP 5: MATERIALS
  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Materials & Finishes"),

          _buildLabel("Flooring Preference"),
          _buildDropdown(
            [
              "Vitrified Tiles",
              "Italian Marble",
              "Wooden/Laminate",
              "Granite",
              "Carpet",
            ],
            _flooringMat,
            (v) => setState(() => _flooringMat = v!),
          ),

          _buildLabel("Wall Finish"),
          _buildDropdown(
            [
              "Paint",
              "Wallpaper",
              "Texture Paint",
              "Wood Paneling",
              "Stone Cladding",
            ],
            _wallFinish,
            (v) => setState(() => _wallFinish = v!),
          ),

          _buildLabel("Ceiling Treatment"),
          _buildDropdown(
            [
              "False Ceiling (POP)",
              "Wooden Ceiling",
              "Exposed Beams",
              "Simple POP",
              "None",
            ],
            _ceilingType,
            (v) => setState(() => _ceilingType = v!),
          ),

          _buildLabel("Furniture Style"),
          _buildDropdown(
            [
              "Modern Modular",
              "Classic Wooden",
              "Industrial Metal",
              "Custom Built-in",
            ],
            _furnitureStyle,
            (v) => setState(() => _furnitureStyle = v!),
          ),

          _buildLabel("Color Palette"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                [
                  Colors.white,
                  Colors.black,
                  Colors.brown,
                  Colors.grey,
                  Colors.red[100],
                  Colors.blue[100],
                  Colors.green[100],
                  Colors.teal,
                  Colors.indigo,
                  Colors.amber,
                ].map((c) {
                  final cStr = c.toString();
                  final selected = _uiPrimaryColors.contains(cStr);
                  return GestureDetector(
                    onTap: () => setState(() {
                      if (selected)
                        _uiPrimaryColors.remove(cStr);
                      else if (_uiPrimaryColors.length < 3)
                        _uiPrimaryColors.add(cStr);
                    }),
                    child: CircleAvatar(
                      backgroundColor: c,
                      radius: 20,
                      child: selected
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 10),
          _buildLabel("Color Intensity"),
          Slider(
            value: _colorIntensity,
            onChanged: (v) => setState(() => _colorIntensity = v),
            activeColor: BrandColors.primary,
            label: "Intensity",
          ),
        ],
      ),
    );
  }

  // STEP 6: TECH
  Widget _buildStep6() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Lighting & Amenities"),

          _buildLabel("Lighting Type"),
          _buildMultiSelectChipGroup([
            "Ambient",
            "Task",
            "Accent",
            "Natural",
          ], _lightingTypes),

          _buildLabel("Fixtures"),
          _buildMultiSelectChipGroup([
            "Chandeliers",
            "Pendants",
            "Recessed",
            "Track Lights",
            "LED Strips",
          ], _lightingFixtures),

          _buildLabel("Smart Home"),
          _buildDropdown(
            ["Traditional Only", "Smart Lighting", "Fully Automated"],
            _smartHome,
            (v) => setState(() => _smartHome = v!),
          ),

          _buildLabel("Window Coverings"),
          _buildMultiSelectChipGroup([
            "Curtains",
            "Blinds",
            "Sheer",
            "Motorized",
          ], _windowCoverings),

          _buildLabel("Amenities (Optional)"),
          _buildMultiSelectChipGroup([
            "Fireplace",
            "Indoor Plants",
            "Bar Unit",
            "Coffee Stn.",
            "Pet Friendly",
            "Pooja Unit",
            "Home Office",
            "Gym Space",
          ], _amenities),
        ],
      ),
    );
  }

  // STEP 7: BUDGET
  Widget _buildStep7() {
    String budgetLabel = "₹${(_budget / 100000).toStringAsFixed(1)} Lakhs";
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Budget & Details"),

          _buildLabel("Total Budget: $budgetLabel"),
          Slider(
            value: _budget,
            min: 50000,
            max: 5000000,
            divisions: 50,
            activeColor: BrandColors.primary,
            onChanged: (v) => setState(() => _budget = v),
          ),

          _buildLabel("Timeline"),
          _buildDropdown(
            [
              "Urgent (< 1 month)",
              "Standard (1-3 months)",
              "Flexible (3-6 months)",
              "No Rush",
            ],
            _timeline,
            (v) => setState(() => _timeline = v!),
          ),

          _buildLabel("Occupancy Status"),
          _buildChipGroup(
            ["Property is vacant", "Currently occupied", "Under construction"],
            (v) => setState(() => _occupancy = v),
            _occupancy,
          ),

          _buildLabel("Special Requirements / Notes"),
          TextFormField(
            controller: _requirementsController,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 5,
            decoration: _inputDeco("Accessibility, brands, specific needs..."),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white70 : Colors.grey[700],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey[500]),
      filled: true,
      fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildChipGroup(
    List<String> labels,
    Function(String) onSelect,
    String selected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((l) {
        final isSelected = selected.contains(l); // simplified check
        return ChoiceChip(
          label: Text(l),
          selected: isSelected,
          onSelected: (_) => onSelect(l),
          selectedColor: BrandColors.primary,
          labelStyle: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
          ),
          backgroundColor: isDark ? Colors.grey[800] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? Colors.transparent : Colors.grey[200]!,
            ),
          ),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectChipGroup(
    List<String> labels,
    List<String> selectedList,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((l) {
        final isSelected = selectedList.contains(l);
        return FilterChip(
          label: Text(l),
          selected: isSelected,
          onSelected: (val) {
            setState(() {
              if (val)
                selectedList.add(l);
              else
                selectedList.remove(l);
            });
          },
          selectedColor: isDark
              ? BrandColors.primary.withOpacity(0.3)
              : const Color(0xFFE8F5E9),
          checkmarkColor: isDark ? BrandColors.primary : Colors.green,
          backgroundColor: isDark ? Colors.grey[800] : Colors.white,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : Colors.black87,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: isDark ? Colors.transparent : Colors.grey[200]!,
            ),
          ),
          side: BorderSide.none,
        );
      }).toList(),
    );
  }

  Widget _buildDropdown(
    List<String> items,
    String current,
    Function(String?) onChange,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(current) ? current : items.first,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28, color: BrandColors.primary),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
