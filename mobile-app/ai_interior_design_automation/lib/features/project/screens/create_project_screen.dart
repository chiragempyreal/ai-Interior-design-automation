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
    if (_currentStep == 2) {
      if (_projectPhotos.length < 1) { // Prompt says 3, keeping 1 for dev ease
        _showSnack("Please upload at least 1 photo of your space");
        return;
      }
    }
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
              leading: const Icon(Icons.photo_library, color: BrandColors.primary),
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
        spaceTypes: _selectedSpaceTypes,
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

    context.read<ProjectProvider>().addProject(project);

    // Show Loading/AI Preview simulation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => const _AiProcessingDialog(),
    );

    Future.delayed(const Duration(seconds: 4), () { // Longer delay for effect
      if (mounted) {
        Navigator.of(context).pop(); 
        context.push('/generate-scope', extra: project);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: _prevStep,
        ),
        title: Column(
          children: [
            Text(
              "Step ${_currentStep + 1} of $_totalSteps",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              _getStepTitle(_currentStep),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
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
            backgroundColor: Colors.grey[200],
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
      case 0: return "Project Basics";
      case 1: return "Measurements";
      case 2: return "Photos";
      case 3: return "Design Style";
      case 4: return "Materials";
      case 5: return "Lighting & Tech";
      case 6: return "Final Details";
      default: return "";
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
              validator: (v) => v!.isEmpty ? "Required" : null,
              decoration: _inputDeco("e.g. Dream Living Room"),
            ),
            
            _buildLabel("Property Type*"),
            _buildChipGroup(
              PropertyType.values.map((e) => e.name.toUpperCase()).toList(),
              (val) => setState(() => _propertyType = PropertyType.values.byName(val.toLowerCase())), 
              _propertyType.name.toUpperCase()
            ),

            _buildLabel("Project Category*"),
            _buildMultiSelectChipGroup(
              ["New Construction", "Renovation", "Remodeling", "Furniture Only"],
              _selectedCategories,
            ),

            _buildLabel("Space / Room Type*"),
            Wrap(
              spacing: 8,
              children: [
                 "Living Room", "Bedroom", "Kitchen", "Bathroom",
                 "Dining Room", "Study/Office", "Kids Room", "Full Home", "Other"
              ].map((room) {
                 final isSelected = _selectedSpaceTypes.contains(room);
                 return FilterChip(
                   label: Text(room),
                   selected: isSelected,
                   onSelected: (v) {
                     setState(() {
                       if (v) _selectedSpaceTypes.add(room);
                       else _selectedSpaceTypes.remove(room);
                     });
                   },
                   selectedColor: BrandColors.primary.withOpacity(0.1),
                   checkmarkColor: BrandColors.primary,
                   backgroundColor: Colors.grey[100],
                   labelStyle: TextStyle(color: isSelected ? BrandColors.primary : Colors.black87),
                 );
              }).toList(),
            ),
            
            if (_selectedSpaceTypes.contains("Other"))
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextFormField(
                  controller: _otherSpaceController,
                  decoration: _inputDeco("Specify room type..."),
                ),
              ),

             _buildLabel("Property Location*"),
             TextFormField(
               controller: _cityController,
               decoration: _inputDeco("City"),
             ),
             const SizedBox(height: 10),
             TextFormField(
               controller: _localityController,
               decoration: _inputDeco("Area/Locality"),
             ),
          ],
        ),
      ),
    );
  }

  // STEP 2: MEASUREMENTS
  Widget _buildStep2() {
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
                   keyboardType: TextInputType.number,
                   decoration: _inputDeco("400"),
                 ),
               ),
               const SizedBox(width: 10),
               DropdownButton<String>(
                 value: _areaUnit,
                 items: ["sqft", "sqm", "sq yards"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
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
                      IconButton(onPressed: () => setState(() => _numberOfRooms > 1 ? _numberOfRooms-- : null), icon: const Icon(Icons.remove_circle_outline)),
                      Text("$_numberOfRooms", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(onPressed: () => setState(() => _numberOfRooms++), icon: const Icon(Icons.add_circle_outline)),
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
                   keyboardType: TextInputType.number,
                   decoration: _inputDeco("10"),
                 ),
               ),
               const SizedBox(width: 10),
               DropdownButton<String>(
                 value: _heightUnit,
                 items: ["feet", "meters"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                 onChanged: (v) => setState(() => _heightUnit = v!),
                 underline: Container(),
               ),
             ],
           ),

           _buildLabel("Natural Light Availability"),
           _buildChipGroup(
             ["Excellent", "Good", "Moderate", "Low"],
             (v) => setState(() => _lightLevel = v),
             _lightLevel.split(' ')[0] // Simple match
           ),

           _buildLabel("Current Condition"),
           DropdownButtonFormField<String>(
             value: _condition,
             isExpanded: true,
             items: [
               "Empty/Unfurnished",
               "Partially Furnished",
               "Fully Furnished",
               "Under Construction",
               "Requires Renovation"
             ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
             onChanged: (v) => setState(() => _condition = v!),
             decoration: _inputDeco(""),
           ),
        ],
      ),
    );
  }

  // STEP 3: PHOTOS
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Show us your space"),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionIcon(Icons.camera_alt, "Camera", () => _pickImage(false, ImageSource.camera)),
                _buildActionIcon(Icons.photo_library, "Gallery", () => _pickImage(false, ImageSource.gallery)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8),
            itemCount: _projectPhotos.length,
            itemBuilder: (c, i) => Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(_projectPhotos[i], fit: BoxFit.cover)),
                Positioned(top: 4, right: 4, child: InkWell(onTap: () => setState(() => _projectPhotos.removeAt(i)), child: const Icon(Icons.cancel, color: Colors.white))),
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
                    width: 100, height: 100,
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.add_photo_alternate, color: Colors.grey),
                  ),
                ),
                ..._inspirationPhotos.map((file) => Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: DESIGN STYLE
  Widget _buildStep4() {
    final styles = ["Modern", "Contemporary", "Minimal", "Scandinavian", "Industrial", "Boho", "Classic", "Luxurious"];
    final vibes = ["Cozy ☕", "Airy ☀️", "Luxurious 💎", "Minimal ✨", "Vibrant 🎨", "Calm 🌿"];

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
               mainAxisSpacing: 10
             ),
             itemCount: styles.length,
             itemBuilder: (c, i) {
                final isSelected = _selectedStyle == styles[i];
                return GestureDetector(
                   onTap: () => setState(() => _selectedStyle = styles[i]),
                   child: AnimatedContainer(
                     duration: 200.ms,
                     decoration: BoxDecoration(
                       color: isSelected ? BrandColors.primary : Colors.white,
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(color: isSelected ? BrandColors.primary : Colors.grey[300]!),
                       boxShadow: [
                         if(isSelected) BoxShadow(color: BrandColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))
                       ]
                     ),
                     child: Center(
                        child: Text(
                          styles[i],
                          style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
                        )
                     ),
                   ),
                );
             },
           ),

           _buildLabel("Design Vibe"),
           Wrap(
             spacing: 8, runSpacing: 8,
             children: vibes.map((v) {
                final isSelected = _selectedVibes.contains(v);
                return FilterChip(
                  label: Text(v),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if(val) _selectedVibes.add(v);
                      else _selectedVibes.remove(v);
                    });
                  },
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFFFFF3E0),
                  checkmarkColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey[300]!)),
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
          _buildDropdown(["Vitrified Tiles", "Italian Marble", "Wooden/Laminate", "Granite", "Carpet"], _flooringMat, (v) => setState(() => _flooringMat = v!)),

          _buildLabel("Wall Finish"),
           _buildDropdown(["Paint", "Wallpaper", "Texture Paint", "Wood Paneling", "Stone Cladding"], _wallFinish, (v) => setState(() => _wallFinish = v!)),

          _buildLabel("Ceiling Treatment"),
           _buildDropdown(["False Ceiling (POP)", "Wooden Ceiling", "Exposed Beams", "Simple POP", "None"], _ceilingType, (v) => setState(() => _ceilingType = v!)),

          _buildLabel("Furniture Style"),
           _buildDropdown(["Modern Modular", "Classic Wooden", "Industrial Metal", "Custom Built-in"], _furnitureStyle, (v) => setState(() => _furnitureStyle = v!)),
          
          _buildLabel("Color Palette"),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12, runSpacing: 12,
            children: [
              Colors.white, Colors.black, Colors.brown, Colors.grey, 
              Colors.red[100], Colors.blue[100], Colors.green[100],
              Colors.teal, Colors.indigo, Colors.amber
            ].map((c) {
               final cStr = c.toString();
               final selected = _uiPrimaryColors.contains(cStr);
               return GestureDetector(
                 onTap: () => setState(() {
                    if(selected) _uiPrimaryColors.remove(cStr);
                    else if (_uiPrimaryColors.length < 3) _uiPrimaryColors.add(cStr);
                 }),
                 child: CircleAvatar(
                   backgroundColor: c,
                   radius: 20,
                   child: selected ? const Icon(Icons.check, color: Colors.white) : null,
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
          _buildMultiSelectChipGroup(["Ambient", "Task", "Accent", "Natural"], _lightingTypes),

          _buildLabel("Fixtures"),
          _buildMultiSelectChipGroup(["Chandeliers", "Pendants", "Recessed", "Track Lights", "LED Strips"], _lightingFixtures),

          _buildLabel("Smart Home"),
          _buildDropdown(["Traditional Only", "Smart Lighting", "Fully Automated"], _smartHome, (v) => setState(() => _smartHome = v!)),

          _buildLabel("Window Coverings"),
          _buildMultiSelectChipGroup(["Curtains", "Blinds", "Sheer", "Motorized"], _windowCoverings),

          _buildLabel("Amenities (Optional)"),
          _buildMultiSelectChipGroup([
            "Fireplace", "Indoor Plants", "Bar Unit", "Coffee Stn.", 
            "Pet Friendly", "Pooja Unit", "Home Office", "Gym Space"
          ], _amenities),
        ],
      ),
    );
  }

  // STEP 7: BUDGET
  Widget _buildStep7() {
    String budgetLabel = "₹${(_budget/100000).toStringAsFixed(1)} Lakhs";
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader("Budget & Details"),
          
          _buildLabel("Total Budget: $budgetLabel"),
          Slider(
            value: _budget,
            min: 50000, max: 5000000,
            divisions: 50,
            activeColor: BrandColors.primary,
            onChanged: (v) => setState(() => _budget = v),
          ),
          
          _buildLabel("Timeline"),
          _buildDropdown([
            "Urgent (< 1 month)", "Standard (1-3 months)",
            "Flexible (3-6 months)", "No Rush"
          ], _timeline, (v) => setState(() => _timeline = v!)),

          _buildLabel("Occupancy Status"),
          _buildChipGroup(
             ["Property is vacant", "Currently occupied", "Under construction"], 
             (v) => setState(() => _occupancy = v), 
             _occupancy
          ),

          _buildLabel("Special Requirements / Notes"),
          TextFormField(
            controller: _requirementsController,
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
      child: Text(text, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
      child: Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700])),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildChipGroup(List<String> labels, Function(String) onSelect, String selected) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: labels.map((l) {
        final isSelected = selected.contains(l); // simplified check
        return ChoiceChip(
          label: Text(l),
          selected: isSelected,
          onSelected: (_) => onSelect(l),
          selectedColor: BrandColors.primary,
          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey[200]!)),
        );
      }).toList(),
    );
  }

   Widget _buildMultiSelectChipGroup(List<String> labels, List<String> selectedList) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: labels.map((l) {
        final isSelected = selectedList.contains(l); 
        return FilterChip(
          label: Text(l),
          selected: isSelected,
          onSelected: (val) {
             setState(() {
               if(val) selectedList.add(l);
               else selectedList.remove(l);
             });
          },
          selectedColor: const Color(0xFFE8F5E9),
          checkmarkColor: Colors.green,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Colors.grey[200]!)),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown(List<String> items, String current, Function(String?) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(current) ? current : items.first,
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: onChange,
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, VoidCallback onTap) {
      return InkWell(
         onTap: onTap,
         child: Column(
           children: [
             Icon(icon, size: 28, color: BrandColors.primary),
             const SizedBox(height: 4),
             Text(label, style: const TextStyle(fontSize: 12)),
           ],
         ),
      );
  }

}

class _AiProcessingDialog extends StatelessWidget {
  const _AiProcessingDialog();
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
             Image.network(
                "https://cdn.dribbble.com/users/1186261/screenshots/3718681/loading_gif.gif", 
                height: 80,
                // Fallback icon if network fails in simulator
                errorBuilder: (c, o, s) => const Icon(Icons.auto_awesome, size: 60, color: BrandColors.primary),
             ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds),
            const SizedBox(height: 24),
            const Text(
              "Creating Your Custom Design",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   _buildCheckItem("Analyzing space layout...", 200),
                   _buildCheckItem("Applying modern style...", 1500),
                   _buildCheckItem("Selecting furniture...", 2800),
                   _buildCheckItem("Generating photorealistic render...", 3500),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text, int delayMs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
           const Icon(Icons.check_circle, color: Colors.green, size: 16),
           const SizedBox(width: 8),
           Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ).animate().fadeIn(delay: delayMs.ms).slideX(),
    );
  }
}
