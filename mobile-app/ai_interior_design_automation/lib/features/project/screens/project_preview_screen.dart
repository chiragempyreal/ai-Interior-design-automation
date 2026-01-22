import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/brand_colors.dart';
import '../models/project_model.dart';
// import '../providers/project_provider.dart'; // Uncomment if needed for actions

class ProjectPreviewScreen extends StatefulWidget {
  final ProjectModel project;

  const ProjectPreviewScreen({super.key, required this.project});

  @override
  State<ProjectPreviewScreen> createState() => _ProjectPreviewScreenState();
}

class _ProjectPreviewScreenState extends State<ProjectPreviewScreen> {
  // Mocking Before/After images for now since we don't have real AI generation yet or local paths might be simpler
  late String _beforeImage;
  final String _afterImage =
      "https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80"; // Mock Render

  double _sliderValue = 0.5;

  @override
  void initState() {
    super.initState();
    // Use the first project photo as 'Before', or a placeholder
    if (widget.project.photoPaths.isNotEmpty) {
      _beforeImage = widget.project.photoPaths.first;
    } else {
      _beforeImage = ""; // Handle no image case
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "AI Preview",
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.iconTheme.color),
          onPressed: () => context.go('/dashboard'), // Exit flow
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: theme.iconTheme.color),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sharing preview...")),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.download, color: theme.iconTheme.color),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Saving image...")));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SLIDER SECTION
            SizedBox(
              height: 400,
              child: Stack(
                children: [
                  // AFTER IMAGE (Background)
                  Positioned.fill(
                    child: Image.network(
                      _afterImage,
                      fit: BoxFit.cover,
                      loadingBuilder: (c, child, p) => p == null
                          ? child
                          : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (c, o, s) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                  // BEFORE IMAGE (Foreground - Clipped)
                  if (_beforeImage.isNotEmpty)
                    Positioned.fill(
                      child: ClipRect(
                        clipper: _SliderClipper(_sliderValue),
                        child: _buildBeforeImage(),
                      ),
                    ),

                  // SLIDER HANDLE
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return GestureDetector(
                          onHorizontalDragUpdate: (details) {
                            setState(() {
                              _sliderValue =
                                  (details.localPosition.dx /
                                          constraints.maxWidth)
                                      .clamp(0.0, 1.0);
                            });
                          },
                          child: Stack(
                            children: [
                              Positioned(
                                left: constraints.maxWidth * _sliderValue - 1.5,
                                top: 0,
                                bottom: 0,
                                child: Container(width: 3, color: Colors.white),
                              ),
                              Positioned(
                                left: constraints.maxWidth * _sliderValue - 15,
                                top: constraints.maxHeight / 2 - 15,
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.compare_arrows,
                                    size: 18,
                                    color: BrandColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // LABELS
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: _buildLabel("Before"),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: _buildLabel("After"),
                  ),
                ],
              ),
            ),

            // DETAILS SECTION
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.project.designPreferences.primaryStyle.isNotEmpty
                        ? widget.project.designPreferences.primaryStyle
                        : "Modern",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Here is a preview of your new ${widget.project.propertyDetails.spaceTypes.firstOrNull ?? "Room"}. We've applied your selected style and materials.",
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _buildInfoChip(
                        Icons.palette,
                        widget.project.designPreferences.primaryStyle.isEmpty
                            ? "Style"
                            : widget.project.designPreferences.primaryStyle,
                        isDark,
                      ),
                      _buildInfoChip(
                        Icons.square_foot,
                        "${widget.project.propertyDetails.carpetArea} ${widget.project.propertyDetails.areaUnit}",
                        isDark,
                      ),
                      _buildInfoChip(
                        Icons.attach_money,
                        "Budget: ₹${(widget.project.technicalRequirements.budget.totalBudget) / 1000}k",
                        isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Scope Generator / Quote
                  context.push('/generate-scope', extra: widget.project);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: BrandColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Get Full Quote",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.pop(); // Go back to edit
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Regenerate",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Chat mock
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Opening Chat...")),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(
                        color: isDark ? Colors.grey[600]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Chat Designer",
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: BrandColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeforeImage() {
    if (_beforeImage.isEmpty) return Container(color: Colors.grey);
    if (_beforeImage.startsWith('http')) {
      return Image.network(_beforeImage, fit: BoxFit.cover);
    }
    return Image.file(File(_beforeImage), fit: BoxFit.cover);
  }
}

class _SliderClipper extends CustomClipper<Rect> {
  final double value;
  _SliderClipper(this.value);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * value, size.height);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) => true;
}
