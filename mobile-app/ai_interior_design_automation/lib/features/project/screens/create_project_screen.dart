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
  final int _totalSteps = 7;

  // KEY: Form Keys for validation per step
  final _step1Key = GlobalKey<FormState>();

  // STEP 1: Basics
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _localityController = TextEditingController();
  PropertyType _propertyType = PropertyType.residential;
  List<String> _selectedCategories = [];
  List<String> _selectedSpaceTypes = [];

  // STEP 2: Measurements
  final _areaController = TextEditingController();
  final _heightController = TextEditingController();
  String _areaUnit = 'sqft';
  String _lightLevel = 'Good - Few Windows';
  String _ventilation = 'Good';
  String _condition = 'Empty/Unfurnished';

  // STEP 3: Photos
  final ImagePicker _picker = ImagePicker();
  List<File> _projectPhotos = [];
  List<File> _inspirationPhotos = [];

  // STEP 4: Design Style
  String _selectedStyle = '';
  List<String> _selectedVibes = [];
  List<String> _selectedThemes = [];

  // STEP 5: Materials
  String _flooringCheck = 'Vitrified Tiles';
  String _wallFinish = 'Paint';
  List<String> _uiPrimaryColors = [];

  // STEP 6: Tech
  List<String> _selectedLighting = [];
  String _smartHome = 'Traditional';

  // STEP 7: Budget & Timeline
  double _budget = 500000;
  final _requirementsController = TextEditingController();
  String _timeline = 'Standard (1-3 months)';

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    _localityController.dispose();
    _areaController.dispose();
    _heightController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_step1Key.currentState!.validate()) return;
      if (_selectedSpaceTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select at least one room type")),
        );
        return;
      }
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
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text("Select Image Source", style: BrandTypography.h5),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: BrandColors.primary),
              title: const Text("Take Photo"),
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
              title: const Text("Choose from Gallery"),
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

  void _submit() {
    final project = ProjectModel(
      name: _nameController.text,
      clientDetails: ClientDetails(
        name: "Current User", // Mock
        email: "user@example.com",
      ),
      propertyDetails: PropertyDetails(
        type: _propertyType,
        categories: _selectedCategories,
        spaceTypes: _selectedSpaceTypes,
        city: _cityController.text,
        locality: _localityController.text,
        carpetArea: double.tryParse(_areaController.text) ?? 0,
        areaUnit: _areaUnit,
        ceilingHeight: double.tryParse(_heightController.text) ?? 10,
        lightAvailability: _lightLevel,
        ventilation: _ventilation,
        currentCondition: _condition,
      ),
      designPreferences: DesignPreferences(
        primaryStyle: _selectedStyle,
        moods: _selectedVibes,
        themes: _selectedThemes,
        materials: MaterialPreferences(
          flooring: _flooringCheck,
          wallFinish: _wallFinish,
        ),
        palette: ColorPalette(primaryColors: _uiPrimaryColors),
      ),
      technicalRequirements: TechnicalRequirements(
        lightingTypes: _selectedLighting,
        smartHomeLevel: _smartHome,
        budget: BudgetDetails(totalBudget: _budget),
        timeline: TimelineDetails(durationExpectation: _timeline),
        specialRequirements: {'notes': _requirementsController.text},
      ),
      photoPaths: _projectPhotos.map((e) => e.path).toList(),
      inspirationPaths: _inspirationPhotos.map((e) => e.path).toList(),
    );

    context.read<ProjectProvider>().addProject(project);

    // Show Loading/AI Preview simulation then navigate
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const _AiProcessingDialog(),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss Dialog
        context.push('/generate-scope', extra: project);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: _prevStep,
        ),
        title: Column(
          children: [
            Text(
              "Step ${_currentStep + 1} of $_totalSteps",
              style: BrandTypography.caption.copyWith(
                color: BrandColors.textLight,
              ),
            ),
            Text(
              _getStepTitle(_currentStep),
              style: BrandTypography.bodyRegular.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text("Skip", style: TextStyle(color: BrandColors.primary)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: BrandColors.border,
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
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
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
      default:
        return "";
    }
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: BrandColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: Text(
          _currentStep == _totalSteps - 1 ? "Generate AI Preview" : "Next",
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1Key,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader("Tell us about your project"),
            const SizedBox(height: 24),
            _buildLabel("Project Name*"),
            TextFormField(
              controller: _nameController,
              validator: (v) => v!.isEmpty ? "Required" : null,
              decoration: _inputDeco("e.g. Dream Living Room"),
            ),
            const SizedBox(height: 20),

            _buildLabel("Property Type*"),
            Wrap(
              spacing: 8,
              children: PropertyType.values.map((e) {
                final isSelected = _propertyType == e;
                return ChoiceChip(
                  label: Text(e.name.toUpperCase()),
                  selected: isSelected,
                  onSelected: (v) => setState(() => _propertyType = e),
                  selectedColor: BrandColors.accent,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : BrandColors.textBody,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            _buildLabel("Space / Room Type*"),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  [
                    "Living Room",
                    "Bedroom",
                    "Kitchen",
                    "Bathroom",
                    "Office",
                    "Full Home",
                  ].map((room) {
                    final isSelected = _selectedSpaceTypes.contains(room);
                    return FilterChip(
                      label: Text(room),
                      selected: isSelected,
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _selectedSpaceTypes.add(room);
                          } else {
                            _selectedSpaceTypes.remove(room);
                          }
                        });
                      },
                      selectedColor: BrandColors.primary.withOpacity(0.2),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),

            _buildLabel("Location"),
            TextFormField(
              controller: _cityController,
              decoration: _inputDeco("City"),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _localityController,
              decoration: _inputDeco("Area / Locality"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Space Details"),
          const SizedBox(height: 24),
          _buildLabel("Total Carpet Area*"),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _areaController,
                  keyboardType: TextInputType.number,
                  decoration: _inputDeco("400"),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _areaUnit,
                items: ["sqft", "sqm"]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _areaUnit = v!),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildLabel("Condition"),
          Wrap(
            spacing: 8,
            children: ["Empty", "Furnished", "Under Construction"]
                .map(
                  (e) => ChoiceChip(
                    label: Text(e),
                    selected: _condition == e,
                    onSelected: (v) => setState(() => _condition = e),
                    selectedColor: BrandColors.accent,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Photos"),
          const SizedBox(height: 10),
          Text(
            "Upload at least 1 photo for best results.",
            style: BrandTypography.bodySmall,
          ),
          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _projectPhotos.length + 1,
            itemBuilder: (context, index) {
              if (index == _projectPhotos.length) {
                return InkWell(
                  onTap: () => _showImageSourceModal(false),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: BrandColors.primary,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.add_a_photo,
                        size: 30,
                        color: BrandColors.primary,
                      ),
                    ),
                  ),
                );
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(_projectPhotos[index], fit: BoxFit.cover),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    final styles = ["Modern", "Minimal", "Industrial", "Boho", "Classic"];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Design Style"),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: styles.length,
            itemBuilder: (c, i) {
              final style = styles[i];
              final isSelected = _selectedStyle == style;
              return GestureDetector(
                onTap: () => setState(() => _selectedStyle = style),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BrandColors.primary.withOpacity(0.1)
                        : Colors.white,
                    border: Border.all(
                      color: isSelected
                          ? BrandColors.primary
                          : BrandColors.border,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      style,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? BrandColors.primary : Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Materials & Finishes"),
          const SizedBox(height: 20),
          _buildLabel("Flooring Preference"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  "Vitrified Tiles",
                  "Wooden / Laminate",
                  "Italian Marble",
                  "Granite",
                  "Carpet",
                ].map((e) {
                  return ChoiceChip(
                    label: Text(e),
                    selected: _flooringCheck == e,
                    onSelected: (v) => setState(() => _flooringCheck = e),
                    selectedColor: BrandColors.primary.withOpacity(0.2),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
          _buildLabel("Wall Finish"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  "Paint (Standard)",
                  "Premium Emulsion",
                  "Wallpaper",
                  "Texture Paint",
                  "Panelling",
                ].map((e) {
                  return ChoiceChip(
                    label: Text(e),
                    selected: _wallFinish == e,
                    onSelected: (v) => setState(() => _wallFinish = e),
                    selectedColor: BrandColors.primary.withOpacity(0.2),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
          _buildLabel("Color Palette Preference"),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children:
                [
                  Colors.white,
                  Colors.grey,
                  Colors.brown,
                  Colors.blueGrey,
                  Colors.teal,
                  Colors.indigo,
                  Color(0xFF5D4037),
                ].map((color) {
                  final colorCode = color.value.toString(); // Simple ID
                  final isSelected = _uiPrimaryColors.contains(colorCode);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected)
                          _uiPrimaryColors.remove(colorCode);
                        else
                          _uiPrimaryColors.add(colorCode);
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? BrandColors.primary
                              : Colors.grey[300]!,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: color.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep6() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Lighting & Technology"),
          const SizedBox(height: 20),
          _buildLabel("Lighting Preferences"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                [
                  "False Ceiling Lights",
                  "Chandeliers",
                  "Wall Sconces",
                  "Floor Lamps",
                  "Cove Lighting",
                  "Track Lights",
                ].map((e) {
                  final isSelected = _selectedLighting.contains(e);
                  return FilterChip(
                    label: Text(e),
                    selected: isSelected,
                    onSelected: (v) {
                      setState(() {
                        if (v)
                          _selectedLighting.add(e);
                        else
                          _selectedLighting.remove(e);
                      });
                    },
                    selectedColor: BrandColors.accent.withOpacity(0.2),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
          _buildLabel("Smart Home Requirements"),
          Column(
            children:
                [
                  "Traditional (None)",
                  "Basic (Smart Bulbs)",
                  "Integrated (Alexa/Google)",
                  "Full Automation (Crestron/Lutron)",
                ].map((e) {
                  return RadioListTile<String>(
                    title: Text(e, style: BrandTypography.bodyRegular),
                    value: e,
                    groupValue: _smartHome,
                    onChanged: (v) => setState(() => _smartHome = v!),
                    activeColor: BrandColors.primary,
                    contentPadding: EdgeInsets.zero,
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep7() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Final Details"),
          const SizedBox(height: 20),
          _buildLabel(
            "Budget Range: ₹${(_budget / 100000).toStringAsFixed(1)}L",
          ),
          Slider(
            value: _budget,
            min: 100000,
            max: 5000000,
            divisions: 50,
            onChanged: (v) => setState(() => _budget = v),
            activeColor: BrandColors.accent,
          ),
          const SizedBox(height: 20),
          _buildLabel("Special Requirements"),
          TextFormField(
            controller: _requirementsController,
            maxLines: 4,
            decoration: _inputDeco("Any specifics..."),
          ),
        ],
      ),
    );
  }

  // --- HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Text(title, style: BrandTypography.h3);
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 4.0),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

class _AiProcessingDialog extends StatelessWidget {
  const _AiProcessingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: BrandColors.primary),
            const SizedBox(height: 20),
            Text("🎨 Creating Your Custom Design", style: BrandTypography.h5),
            const SizedBox(height: 10),
            const Text(
              "Analyzing requirements...\nMatching style...",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().scale();
  }
}
