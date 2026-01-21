import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/brand_colors.dart';
import '../../project/models/project_model.dart';

class ImageInputScreen extends StatefulWidget {
  final ProjectModel? project;
  final ImageSource? autoPickSource;

  const ImageInputScreen({super.key, this.project, this.autoPickSource});

  @override
  State<ImageInputScreen> createState() => _ImageInputScreenState();
}

class _ImageInputScreenState extends State<ImageInputScreen> {
  File? _selectedImage;
  bool _isGenerating = false;
  final _aiPromptController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.autoPickSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage(widget.autoPickSource!);
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showError("Failed to pick image: $e");
    }
  }

  Future<void> _generateAiImage() async {
    if (_aiPromptController.text.isEmpty) {
      _showError("Please enter a description for the room.");
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Simulate/Call AI Generation
      // In a real flow, we'd pass a placeholder file or byte array
      // representing the generated image from the service.
      // For now, using the service to "process" (simulated in service).
      // We need a dummy file to pass to the current service signature or update service.
      // Assuming service returns a path or URL.

      // Temporary hack: Just simulate success for UI flow if service needs a file input
      // Ideally, the service should accept a prompt and return a path/url.

      // Let's assume we want to mock a generated result for the hackathon data flow
      await Future.delayed(const Duration(seconds: 3));

      // Ideally we get a path back. For consistent API, let's say we succeeded.
      // In a real partial implementation, we might not have a file yet.
      // We will show a success message.

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("AI Image Generated! (Mock)"),
            backgroundColor: BrandColors.success,
          ),
        );
        // For now, we don't set _selectedImage unless we possess a real asset path
        // In production, we'd download the generated image to a temp file.
      }
    } catch (e) {
      _showError("AI Generation failed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: BrandColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _continue() {
    if (_selectedImage == null && !_isGenerating) {
      // Allow continue if testing without image or handle logic
      // Ideally require image. Logic:
      // if (_selectedImage == null) return _showError("Please select or generate an image.");
    }

    // Navigate to Scope Generator
    // Pass the project and the image path
    // If we have a project passed in, use it. Otherwise rely on provider/state.
    if (widget.project != null) {
      // We might want to attach the image path to the project model if it supported it,
      // or pass it along as extra data.
      context.push('/generate-scope', extra: widget.project);
    } else {
      context.pop(); // Fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show the source button if allowed (or all if not specified)
    final showGallery =
        widget.autoPickSource == null ||
        widget.autoPickSource == ImageSource.gallery;
    final showCamera =
        widget.autoPickSource == null ||
        widget.autoPickSource == ImageSource.camera;

    return Scaffold(
      backgroundColor: BrandColors.background,
      appBar: AppBar(
        title: const Text("Visual Input"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: BrandColors.textDark,
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Visualize Your Space",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: BrandColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Upload a photo or let AI generate one for you.",
              style: TextStyle(color: BrandColors.textBody, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Preview Section
            if (_selectedImage != null)
              _buildImagePreview()
            else
              _buildPlaceholderPreview(),

            const SizedBox(height: 32),

            // Options Grid
            Row(
              children: [
                if (showGallery)
                  Expanded(
                    child: _buildOptionCard(
                      icon: Icons.photo_library_outlined,
                      label: "Gallery",
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                if (showGallery && showCamera) const SizedBox(width: 16),
                if (showCamera)
                  Expanded(
                    child: _buildOptionCard(
                      icon: Icons.camera_alt_outlined,
                      label: "Camera",
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAiGenerationCard(),

            const SizedBox(height: 40),

            // Continue Button
            ElevatedButton(
              onPressed: _selectedImage != null ? _continue : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: BrandColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                shadowColor: BrandColors.primary.withOpacity(0.4),
                disabledBackgroundColor: Colors.grey[300],
              ),
              child: const Text(
                "Generate Project Scope",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Center(
      child: Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: BrandShadows.medium,
          border: Border.all(color: Colors.white, width: 6),
          image: DecorationImage(
            image: FileImage(_selectedImage!),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 12,
              left: 10,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 20,
                child: IconButton(
                  icon: const Icon(
                    Icons.refresh,
                    color: BrandColors.textDark,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() => _selectedImage = null);
                  },
                ),
              ),
            ),
          ],
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildPlaceholderPreview() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: BrandColors.border.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.add_a_photo_outlined,
          size: 64,
          color: BrandColors.textLight.withOpacity(0.5),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: BrandShadows.light,
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          children: [
            Icon(icon, color: BrandColors.primary, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: BrandColors.textDark,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAiGenerationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BrandColors.primary.withOpacity(0.05),
            BrandColors.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: BrandColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: BrandColors.accent, size: 24),
              const SizedBox(width: 8),
              const Text(
                "Generate with AI",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: BrandColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiPromptController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText:
                  "Describe your dream room (e.g., 'Modern minimalist living room with beige tones')...",
              hintStyle: TextStyle(color: BrandColors.textHint, fontSize: 13),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isGenerating ? null : _generateAiImage,
              style: OutlinedButton.styleFrom(
                foregroundColor: BrandColors.primary,
                side: const BorderSide(color: BrandColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isGenerating
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          BrandColors.primary,
                        ),
                      ),
                    )
                  : const Text("Generate Image"),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
}
