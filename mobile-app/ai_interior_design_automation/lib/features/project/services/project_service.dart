import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/project_model.dart';
import 'package:http_parser/http_parser.dart';

class ProjectService {
  final ApiClient _apiClient = ApiClient();

  // Get Stats
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await _apiClient.get(ApiConstants.projectStats);
      return response.data; // Expect { total: 10, pending: 2, completed: 8 }
    } catch (e) {
      return {'total': 0, 'pending': 0, 'completed': 0}; // Fallback
    }
  }

  // Get Pending Projects (for Dashboard)
  Future<List<ProjectModel>> getPendingProjects() async {
    try {
      final response = await _apiClient.get(ApiConstants.projectPending);
      final List data = response.data;
      // We might need a fromJson that handles the API structure.
      // For now assuming it matches or we map it.
      return data.map((json) => ProjectModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Get All Projects
  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await _apiClient.get(ApiConstants.projects);
      final List data =
          response.data['data'] ??
          response.data; // Handle { data: [...] } or [...]
      return data.map((json) => ProjectModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  // Create Project
  Future<ProjectModel> createProject(ProjectModel project) async {
    try {
      // Match exact API schema from Swagger docs
      final payload = {
        'title': project.name.trim().isNotEmpty
            ? project.name.trim()
            : 'Untitled Project',
        'clientName': project.clientDetails.name.isNotEmpty
            ? project.clientDetails.name
            : 'Guest User',
        'clientEmail': project.clientDetails.email.isNotEmpty
            ? project.clientDetails.email
            : 'guest@example.com',
        'projectType': project.propertyDetails.type == PropertyType.residential
            ? 'Residential'
            : 'Commercial',
        'status': 'draft',
        'propertyType': project.propertyDetails.type.name.toLowerCase(),
        'spaceType': project.propertyDetails.spaceTypes.isNotEmpty
            ? project.propertyDetails.spaceTypes.first
            : 'Living Room',
        'area': project.propertyDetails.carpetArea > 0
            ? project.propertyDetails.carpetArea
            : 400,
        'location': {
          'city': project.propertyDetails.city.isNotEmpty
              ? project.propertyDetails.city
              : 'Mumbai',
          'pincode': project.propertyDetails.pincode.isNotEmpty
              ? project.propertyDetails.pincode
              : '400001',
        },
        'budget': {
          'min': (project.technicalRequirements.budget.totalBudget * 0.8)
              .round(),
          'max': (project.technicalRequirements.budget.totalBudget * 1.2)
              .round(),
        },
      };

      print("DEBUG: Sending API-Matched Create Project Payload: $payload");

      final response = await _apiClient.post(
        ApiConstants.projects,
        data: payload,
      );

      print("DEBUG: Create Project Response: ${response.data}");

      // Return the created project model from response
      return ProjectModel.fromJson(response.data);
    } catch (e) {
      if (e is DioException) {
        print(
          "DEBUG: Create Project API Error: ${e.response?.statusCode} - ${e.response?.data}",
        );
      }
      throw Exception("Failed to create project: $e");
    }
  }

  // Upload Photos
  Future<void> uploadPhotos(String projectId, List<String> filePaths) async {
    if (filePaths.isEmpty) return;

    try {
      // Build list of MultipartFile objects
      List<MultipartFile> photoFiles = [];

      for (var path in filePaths) {
        final file = File(path);
        String fileName = path.split('/').last;

        // Determine content type based on file extension
        String extension = fileName.split('.').last.toLowerCase();
        MediaType contentType;

        switch (extension) {
          case 'jpg':
          case 'jpeg':
            contentType = MediaType('image', 'jpeg');
            break;
          case 'png':
            contentType = MediaType('image', 'png');
            break;
          case 'webp':
            contentType = MediaType('image', 'webp');
            break;
          default:
            contentType = MediaType('image', 'jpeg');
        }

        photoFiles.add(
          await MultipartFile.fromFile(
            file.path,
            filename: fileName,
            contentType: contentType,
          ),
        );
      }

      // Create FormData with photos array
      final formData = FormData.fromMap({'photos': photoFiles});

      print(
        "DEBUG: Uploading ${photoFiles.length} photos to project $projectId",
      );

      await _apiClient.post(
        ApiConstants.projectUpload(projectId),
        data: formData,
      );

      print("DEBUG: Photos uploaded successfully");
    } catch (e) {
      if (e is DioException) {
        print(
          "DEBUG: Upload Photos API Error: ${e.response?.statusCode} - ${e.response?.data}",
        );
      }
      throw Exception("Failed to upload photos: $e");
    }
  }

  // Generate Preview (AI Trigger)
  Future<dynamic> generatePreview(String projectId) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.projectPreview(projectId),
      );
      return response.data;
    } catch (e) {
      throw Exception("AI preview generation failed: $e");
    }
  }

  // Update Project
  Future<ProjectModel> updateProject(ProjectModel project) async {
    try {
      final payload = {'title': project.name, 'status': project.status.name};

      final response = await _apiClient.put(
        '${ApiConstants.projects}/${project.id}',
        data: payload,
      );
      return ProjectModel.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to update project: $e");
    }
  }

  // Delete Project
  Future<void> deleteProject(String projectId) async {
    try {
      await _apiClient.delete('${ApiConstants.projects}/$projectId');
    } catch (e) {
      throw Exception("Failed to delete project: $e");
    }
  }
}
