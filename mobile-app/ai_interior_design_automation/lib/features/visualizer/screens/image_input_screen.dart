import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/brand_colors.dart';
import '../../project/models/project_model.dart';
import 'package:provider/provider.dart';
import '../../project/providers/project_provider.dart';

class ImageInputScreen extends StatefulWidget {
  final ProjectModel? project;
  final ImageSource? autoPickSource;

  const ImageInputScreen({super.key, this.project, this.autoPickSource});

  @override
  State<ImageInputScreen> createState() => _ImageInputScreenState();
}

class _ImageInputScreenState extends State<ImageInputScreen> {
  File? _selectedImage;
  String? _generatedImageUrl; // Store API Result
  bool _isGenerating = false;
  final _aiPromptController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Auto-pick logic if needed
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
          _generatedImageUrl = null; // Reset on new selection
        });
      }
    } catch (e) {
      _showError("Failed to pick image: $e");
    }
  }

  Future<void> _generateAiImage() async {
    if (_selectedImage == null) {
      _showError("Please upload an image first.");
      return;
    }
    if (_aiPromptController.text.isEmpty) {
      _showError("Please enter a description for the room.");
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Call Real Service via Provider
      final url = await context.read<ProjectProvider>().visualizeRoom(
        _selectedImage!,
        _aiPromptController.text,
      );

      if (mounted) {
        setState(() {
          _generatedImageUrl = url;
          _isGenerating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("AI Image Generated Successfully!"),
            backgroundColor: BrandColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        _showError("AI Generation failed: $e");
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
    if (widget.project != null) {
      context.push('/generate-scope', extra: widget.project);
    } else {
      // Navigate to create project flow
      context.push('/create-project');
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

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Visual Input",
          style: BrandTypography.h4.copyWith(
            color: theme.colorScheme.onBackground,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: theme.colorScheme.onBackground,
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
              style: BrandTypography.h3.copyWith(
                color: theme.colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Upload a photo or let AI generate one for you.",
              style: BrandTypography.bodyRegular.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Preview Section
            if (_selectedImage != null)
              _buildImagePreview()
            else
              _buildPlaceholderPreview(),

            const SizedBox(height: 32),

            // Options Grid (Only show if image not yet generated, or allow changing)
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
                backgroundColor: theme.primaryColor,
                foregroundColor:
                    theme.colorScheme.onPrimary, // Adaptive text color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BrandRadius.xxl),
                ),
                elevation: 4,
                shadowColor: theme.primaryColor.withOpacity(0.4),
                disabledBackgroundColor: theme.disabledColor,
              ),
              child: Text(
                "Generate Project Scope",
                style: BrandTypography.h5.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final theme = Theme.of(context);

    // Determine what to show: File or Network (Generated)
    ImageProvider? imageProvider;
    bool isGenerated = false;

    if (_generatedImageUrl != null) {
      imageProvider = NetworkImage(_generatedImageUrl!);
      isGenerated = true;
    } else if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    }

    return Center(
      child: Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          boxShadow: BrandShadows.medium,
          border: Border.all(
            color: isGenerated ? BrandColors.success : theme.cardTheme.color!,
            width: isGenerated ? 2 : 6,
          ),
          image: imageProvider != null
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
        ),
        child: Stack(
          children: [
            // Reset Button
            Positioned(
              top: 12,
              left: 10,
              child: CircleAvatar(
                backgroundColor: theme.canvasColor, // Adapts to theme
                radius: 20,
                child: IconButton(
                  icon: Icon(
                    Icons.refresh,
                    color: theme.iconTheme.color,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedImage = null;
                      _generatedImageUrl = null;
                    });
                  },
                ),
              ),
            ),

            // Badge for Generated
            if (isGenerated)
              Positioned(
                top: 12,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: BrandColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        "AI GENERATED",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildPlaceholderPreview() {
    final theme = Theme.of(context);
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(BrandRadius.lg),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.add_a_photo_outlined,
          size: 64,
          color: theme.disabledColor,
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BrandRadius.xxl),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(BrandRadius.xxl),
          boxShadow: BrandShadows.light,
        ),
        child: Column(
          children: [
            Icon(icon, color: theme.primaryColor, size: 32),
            const SizedBox(height: 12),
            Text(
              label,
              style: BrandTypography.h5.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAiGenerationCard() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(BrandRadius.xxl),
        border: Border.all(color: theme.primaryColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: BrandColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "Generate with AI",
                style: BrandTypography.h5.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _aiPromptController,
            maxLines: 2,
            style: BrandTypography.bodyRegular.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText:
                  "Describe your dream room (e.g., 'Modern minimalist living room with beige tones')...",
              hintStyle: BrandTypography.bodySmall.copyWith(
                color: theme.hintColor,
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(BrandRadius.xl),
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
                foregroundColor: theme.primaryColor,
                side: BorderSide(color: theme.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(BrandRadius.xl),
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
                          theme.primaryColor,
                        ),
                      ),
                    )
                  : Text(
                      "Generate Image",
                      style: BrandTypography.h5.copyWith(
                        color: theme.primaryColor,
                      ),
                    ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }
}
