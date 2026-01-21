import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ProjectProvider extends ChangeNotifier {
  final List<ProjectModel> _projects = [];

  List<ProjectModel> get projects => List.unmodifiable(_projects);

  void addProject(ProjectModel project) {
    _projects.add(project);
    notifyListeners();
  }

  // Demo Logic for Budget Range formatting
  String formatBudget(double value) {
    if (value >= 100000) {
      return "${(value / 100000).toStringAsFixed(1)}L";
    }
    return "${(value / 1000).toStringAsFixed(0)}k";
  }
}
