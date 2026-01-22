import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../services/project_service.dart';

class ProjectProvider extends ChangeNotifier {
  final ProjectService _projectService = ProjectService();

  List<ProjectModel> _projects = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> _stats = {'total': 0, 'pending': 0, 'completed': 0};
  Map<String, dynamic> get stats => _stats;

  List<ProjectModel> get projects => List.unmodifiable(_projects);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch Stats
  Future<void> fetchStats() async {
    try {
      _stats = await _projectService.getStats();
      notifyListeners();
    } catch (_) {
      // Silent fail for stats
    }
  }

  // Initial Fetch
  Future<void> fetchProjects() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await _projectService.getProjects();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create Project
  Future<ProjectModel> addProject(ProjectModel project) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final createdProject = await _projectService.createProject(project);

      // Upload Photos if any
      if (project.photoPaths.isNotEmpty) {
        await _projectService.uploadPhotos(
          createdProject.id,
          project.photoPaths,
        );
      }

      // Add to local list immediately
      _projects.add(createdProject);

      return createdProject;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Generate Preview (AI)
  Future<dynamic> generatePreview(String projectId) async {
    _isLoading = true;
    notifyListeners();

    try {
      return await _projectService.generatePreview(projectId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  // Update Project
  Future<void> updateProject(ProjectModel project) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updated = await _projectService.updateProject(project);
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = updated;
      }
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete Project
  Future<void> deleteProject(String projectId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _projectService.deleteProject(projectId);
      _projects.removeWhere((p) => p.id == projectId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper for budget (kept from original)
  String formatBudget(double value) {
    if (value >= 100000) {
      return "${(value / 100000).toStringAsFixed(1)}L";
    }
    return "${(value / 1000).toStringAsFixed(0)}k";
  }
}
