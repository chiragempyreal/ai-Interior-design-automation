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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _generatedImage = null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Room Visualizer")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.2),
                  ),
                  image: _image != null
                      ? DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _image == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 48,
                            color: AppColors.primary,
                          ),
                          SizedBox(height: 12),
                          Text("Tap to upload room photo"),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Design Preferences",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    "e.g. Modern living room with sage green tones and wooden furniture...",
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading || _image == null ? null : _generate,
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text("Generate New Design"),
            ),
            if (_generatedImage != null) ...[
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                "AI Proposal",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(File(_generatedImage!)),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  final provider = context.read<ProjectProvider>();
                  if (provider.projects.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("No Project Selected!")),
                    );
                    return;
                  }
                  final project = provider.projects.last;

                  final scope = ScopeGenerator.generateScope(
                    propertyType: project.propertyDetails.type,
                    carpetArea: project.propertyDetails.carpetArea,
                    style: _promptController.text.isNotEmpty
                        ? _promptController.text
                        : "Modern",
                    roomTypes: ["Living Area", "Kitchen", "Master Bedroom"],
                  );

                  final quote = CostCalculator.calculate(scope);

                  context.push(
                    '/quote',
                    extra: {'quote': quote, 'projectName': project.name},
                  );
                },
                child: const Text("Create Quote from this Design"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
