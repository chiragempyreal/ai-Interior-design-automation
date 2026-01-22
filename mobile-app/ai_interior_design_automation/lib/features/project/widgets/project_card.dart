import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/project_model.dart';

class ProjectCard extends StatelessWidget {
  final ProjectModel project;
  final int index;

  const ProjectCard({super.key, required this.project, this.index = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Status colors & text
    final statusColor = project.status == ProjectStatus.approved
        ? Colors.green
        : Colors.orange;

    final statusText = project.status == ProjectStatus.draft
        ? 'Draft'
        : 'Active';

    final dateStr =
        "${project.createdAt.day}/${project.createdAt.month}/${project.createdAt.year}";

    return GestureDetector(
          onTap: () => context.push('/generate-scope', extra: project),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: isDark ? const Color(0xFF1E1E1E) : theme.cardTheme.color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // IMAGE SECTION (Fixed Aspect Ratio Logic)
                Expanded(
                  flex: 12, // Gives slightly more weight to image
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: _buildProjectImage(),
                      ),

                      // Date Badge (Overlay)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: Text(
                            dateStr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // CONTENT SECTION
                Expanded(
                  flex: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(10), // Reduced from 12
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min, // shrink wrap
                      children: [
                        // Title with overflow protection
                        Text(
                          project.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black87,
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Specs line
                        Text(
                          "${project.propertyDetails.carpetArea.toInt()} sqft • ${project.propertyDetails.type.name.toUpperCase()}",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white54 : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const Spacer(), // Pushes status to bottom
                        // Footer with Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                statusText.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),

                            CircleAvatar(
                              radius: 10,
                              backgroundColor: isDark
                                  ? Colors.white10
                                  : Colors.grey[100],
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 10,
                                color: isDark
                                    ? Colors.white54
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms, delay: (50 * index).ms)
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildProjectImage() {
    // Priority 1: AI Generated Preview (The user wants to see the "After" image if available)
    if (project.aiPreviewUrl != null && project.aiPreviewUrl!.isNotEmpty) {
      return Image.network(
        project.aiPreviewUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackImage(),
      );
    }

    // Priority 2: User Uploaded Photos
    if (project.photoPaths.isNotEmpty) {
      final path = project.photoPaths.first;
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } else {
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      }
    }

    // Fallback
    return _buildPlaceholder();
  }

  Widget _buildFallbackImage() {
    // If AI image fails, try original
    if (project.photoPaths.isNotEmpty) {
      final path = project.photoPaths.first;
      if (path.startsWith('http')) {
        return Image.network(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } else {
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      }
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF2C2C2C),
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Colors.white24,
          size: 28,
        ),
      ),
    );
  }
}
