import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../services/ai_image_service.dart';
import '../../project/providers/project_provider.dart';
import '../../ai_engine/logic/scope_generator.dart';
import '../../ai_engine/logic/cost_calculator.dart';

class UploadRoomScreen extends StatefulWidget {
  const UploadRoomScreen({super.key});

  @override
  State<UploadRoomScreen> createState() => _UploadRoomScreenState();
}

class _UploadRoomScreenState extends State<UploadRoomScreen> {
  File? _image;
  final _picker = ImagePicker();
  final _promptController = TextEditingController();
  final _aiService = AiImageService();

  bool _isLoading = false;
  String? _generatedImage;
  bool _showPromptInput = false; // Toggle to show input after photo

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _generatedImage = null;
        _showPromptInput = true; // Show input after picking
      });
    }
  }

  Future<void> _generate() async {
    if (_image == null) return;

    setState(() => _isLoading = true);

    // Simulate API Call
    final result = await _aiService.generateInteriorDesign(
      _image!,
      _promptController.text,
    );

    setState(() {
      _isLoading = false;
      _generatedImage = result;
    });
  }

  void _createQuote() {
    final provider = context.read<ProjectProvider>();
    // If no project, we might need to handle it.
    // For now, assuming user will link it or we create a dummy one.
    // If provider projects empty, maybe create a temporary one?
    // Let's stick to existing logic: require project.
    if (provider.projects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No Project Selected! Please create one first.")),
      );
      // Optional: Navigate to create project?
      return;
    }
    final project = provider.projects.last;

    final scope = ScopeGenerator.generateScope(
      propertyType: project.propertyDetails.type,
      carpetArea: project.propertyDetails.carpetArea,
      style: _promptController.text.isNotEmpty ? _promptController.text : "Modern",
      roomTypes: ["Living Area", "Kitchen", "Master Bedroom"],
    );

    final quote = CostCalculator.calculate(scope);

    context.push(
      '/quote',
      extra: {'quote': quote, 'projectName': project.name},
    );
  }

  @override
  Widget build(BuildContext context) {
    // If image is generated, show result view
    if (_generatedImage != null) {
      return _buildResultView();
    }

    // Camera/Scanner View
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Background Image (if picked) or Camera Preview Placeholder
          Positioned.fill(
            child: _image != null
                ? Image.file(_image!, fit: BoxFit.cover)
                : Container(
                    color: Colors.black,
                    child: Center(
                      child: Icon(Icons.camera_alt, color: Colors.grey[800], size: 100),
                    ),
                  ),
          ),
          
          // 2. Overlay (Scanner Frame) - Only if no image picked yet & not loading
          if (_image == null)
            Positioned.fill(
              child: _buildScannerOverlay(),
            ),

          // 3. Top Controls
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => context.pop(),
                ),
                if (_image == null)
                Row(
                  children: [
                    const Icon(Icons.flash_off, color: Colors.white),
                    const SizedBox(width: 20),
                    const Icon(Icons.flip_camera_ios, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),

          // 4. Bottom Controls (Shutter / Prompt)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : _showPromptInput 
                  ? _buildPromptInput() 
                  : _buildCameraControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              // Corner markers could be added here for decorative effect
              const Center(
                child: Text(
                  "Align room in frame",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Gallery
        IconButton(
          icon: const Icon(Icons.photo_library_outlined, color: Colors.white, size: 30),
          onPressed: () => _pickImage(ImageSource.gallery),
        ),
        
        // Shutter
        GestureDetector(
          onTap: () => _pickImage(ImageSource.camera),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              color: Colors.transparent,
            ),
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
          ),
        ),
        
        // Spacer / Flip (Visual balance)
        const SizedBox(width: 50), 
      ],
    );
  }

  Widget _buildPromptInput() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
           TextField(
              controller: _promptController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: "Describe your dream style (e.g., 'Modern Minimalist')...",
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                 TextButton(
                  onPressed: () {
                    setState(() {
                      _image = null;
                      _showPromptInput = false;
                    });
                  },
                  child: const Text("Retake", style: TextStyle(color: Colors.white70)),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _generate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text("Generate Design"),
                ),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("AI Proposal", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close),
           onPressed: () {
             setState(() {
               _generatedImage = null;
               _showPromptInput = false;
               _image = null;
             });
           },
        ),
      ),
      body: Stack( // Using Stack to handle potential overflow with scrolling if needed
        children: [
          Positioned.fill(
             child: Image.file(File(_generatedImage!), fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _createQuote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("View Cost Estimate"),
                ),
                const SizedBox(height: 12),
                 TextButton(
                  onPressed: _generate, // Regenerate
                  child: const Text("Try Another Style", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
