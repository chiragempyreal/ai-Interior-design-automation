import 'package:flutter/foundation.dart';
import '../models/scope_model.dart';
import '../services/ai_scope_service.dart';
import '../../project/models/project_model.dart';

class ScopeProvider extends ChangeNotifier {
  final AiScopeService _scopeService = AiScopeService();

  // State
  final Map<String, ScopeModel> _scopes = {};
  bool _isGenerating = false;
  String? _error;

  // Getters
  Map<String, ScopeModel> get scopes => Map.unmodifiable(_scopes);
  bool get isGenerating => _isGenerating;
  String? get error => _error;

  ScopeModel? getScopeByProjectId(String projectId) {
    return _scopes[projectId];
  }

  /// Generate AI scope for a project
  Future<ScopeModel?> generateScope(ProjectModel project) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final scope = await _scopeService.generateScope(project);
      _scopes[project.id] = scope;
      _isGenerating = false;
      notifyListeners();
      return scope;
    } catch (e) {
      _error = e.toString();
      _isGenerating = false;
      notifyListeners();
      return null;
    }
  }

  /// Update scope (edit tasks, phases, etc.)
  void updateScope(ScopeModel scope) {
    _scopes[scope.projectId] = scope;
    notifyListeners();
  }

  /// Delete scope
  void deleteScope(String projectId) {
    _scopes.remove(projectId);
    notifyListeners();
  }

  /// Update a specific phase
  void updatePhase(String projectId, PhaseModel updatedPhase) {
    final scope = _scopes[projectId];
    if (scope != null) {
      final updatedPhases = scope.phases.map((phase) {
        return phase.id == updatedPhase.id ? updatedPhase : phase;
      }).toList();

      _scopes[projectId] = scope.copyWith(phases: updatedPhases);
      notifyListeners();
    }
  }

  /// Update a specific task
  void updateTask(String projectId, String phaseId, TaskModel updatedTask) {
    final scope = _scopes[projectId];
    if (scope != null) {
      final updatedPhases = scope.phases.map((phase) {
        if (phase.id == phaseId) {
          final updatedTasks = phase.tasks.map((task) {
            return task.id == updatedTask.id ? updatedTask : task;
          }).toList();
          return phase.copyWith(tasks: updatedTasks);
        }
        return phase;
      }).toList();

      _scopes[projectId] = scope.copyWith(phases: updatedPhases);
      notifyListeners();
    }
  }

  /// Add a new task to a phase
  void addTask(String projectId, String phaseId, TaskModel newTask) {
    final scope = _scopes[projectId];
    if (scope != null) {
      final updatedPhases = scope.phases.map((phase) {
        if (phase.id == phaseId) {
          final updatedTasks = [...phase.tasks, newTask];
          return phase.copyWith(tasks: updatedTasks);
        }
        return phase;
      }).toList();

      _scopes[projectId] = scope.copyWith(phases: updatedPhases);
      notifyListeners();
    }
  }

  /// Remove a task from a phase
  void removeTask(String projectId, String phaseId, String taskId) {
    final scope = _scopes[projectId];
    if (scope != null) {
      final updatedPhases = scope.phases.map((phase) {
        if (phase.id == phaseId) {
          final updatedTasks = phase.tasks.where((task) => task.id != taskId).toList();
          return phase.copyWith(tasks: updatedTasks);
        }
        return phase;
      }).toList();

      _scopes[projectId] = scope.copyWith(phases: updatedPhases);
      notifyListeners();
    }
  }

  /// Get scope suggestions
  List<String> getScopeSuggestions(PropertyType type) {
    return _scopeService.getScopeSuggestions(type);
  }

  /// Clear all scopes
  void clearAll() {
    _scopes.clear();
    _error = null;
    notifyListeners();
  }
}
