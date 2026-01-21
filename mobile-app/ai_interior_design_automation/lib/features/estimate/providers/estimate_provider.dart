import 'package:flutter/foundation.dart';
import '../models/estimate_model.dart';
import '../services/estimate_service.dart';
import '../services/pdf_service.dart';
import '../../project/models/project_model.dart';
import '../../ai_scope/models/scope_model.dart';
import '../../cost_config/models/cost_config_model.dart';

class EstimateProvider extends ChangeNotifier {
  final EstimateService _estimateService = EstimateService();
  final PdfService _pdfService = PdfService();

  // State
  final Map<String, List<EstimateModel>> _estimatesByProject = {};
  bool _isGenerating = false;
  String? _error;

  // Getters
  Map<String, List<EstimateModel>> get estimatesByProject => Map.unmodifiable(_estimatesByProject);
  bool get isGenerating => _isGenerating;
  String? get error => _error;

  List<EstimateModel> getAllEstimates() {
    return _estimatesByProject.values.expand((list) => list).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<EstimateModel> getEstimatesByProjectId(String projectId) {
    return _estimatesByProject[projectId] ?? [];
  }

  EstimateModel? getLatestEstimate(String projectId) {
    final estimates = _estimatesByProject[projectId];
    if (estimates == null || estimates.isEmpty) return null;
    return estimates.reduce((a, b) => a.version > b.version ? a : b);
  }

  /// Generate new estimate
  Future<EstimateModel?> generateEstimate({
    required ProjectModel project,
    required ScopeModel scope,
    required CostConfigModel costConfig,
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final estimate = await _estimateService.generateEstimate(
        project: project,
        scope: scope,
        costConfig: costConfig,
      );

      // Add to list
      if (_estimatesByProject[project.id] == null) {
        _estimatesByProject[project.id] = [];
      }
      _estimatesByProject[project.id]!.add(estimate);

      _isGenerating = false;
      notifyListeners();
      return estimate;
    } catch (e) {
      _error = e.toString();
      _isGenerating = false;
      notifyListeners();
      return null;
    }
  }

  /// Update estimate status
  void updateEstimateStatus(String projectId, String estimateId, EstimateStatus status) {
    final estimates = _estimatesByProject[projectId];
    if (estimates != null) {
      final index = estimates.indexWhere((e) => e.id == estimateId);
      if (index != -1) {
        estimates[index] = estimates[index].copyWith(status: status);
        notifyListeners();
      }
    }
  }

  /// Approve estimate
  void approveEstimate(String projectId, String estimateId, String approvedBy) {
    final estimates = _estimatesByProject[projectId];
    if (estimates != null) {
      final index = estimates.indexWhere((e) => e.id == estimateId);
      if (index != -1) {
        estimates[index] = estimates[index].copyWith(
          status: EstimateStatus.approved,
          approvedAt: DateTime.now(),
          approvedBy: approvedBy,
        );
        notifyListeners();
      }
    }
  }

  /// Reject estimate
  void rejectEstimate(String projectId, String estimateId, String reason) {
    final estimates = _estimatesByProject[projectId];
    if (estimates != null) {
      final index = estimates.indexWhere((e) => e.id == estimateId);
      if (index != -1) {
        estimates[index] = estimates[index].copyWith(
          status: EstimateStatus.rejected,
          rejectionReason: reason,
        );
        notifyListeners();
      }
    }
  }

  /// Create revision
  Future<EstimateModel?> createRevision({
    required ProjectModel project,
    required ScopeModel scope,
    required CostConfigModel costConfig,
    required EstimateModel previousEstimate,
  }) async {
    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final newEstimate = await _estimateService.generateEstimate(
        project: project,
        scope: scope,
        costConfig: costConfig,
      );

      // Increment version
      final revisedEstimate = newEstimate.copyWith(
        version: previousEstimate.version + 1,
        status: EstimateStatus.revised,
      );

      _estimatesByProject[project.id]!.add(revisedEstimate);

      _isGenerating = false;
      notifyListeners();
      return revisedEstimate;
    } catch (e) {
      _error = e.toString();
      _isGenerating = false;
      notifyListeners();
      return null;
    }
  }

  /// Optimize estimate for budget
  void optimizeForBudget(String projectId, String estimateId, double targetBudget) {
    final estimates = _estimatesByProject[projectId];
    if (estimates != null) {
      final index = estimates.indexWhere((e) => e.id == estimateId);
      if (index != -1) {
        final optimized = _estimateService.optimizeForBudget(
          estimates[index],
          targetBudget,
        );
        estimates[index] = optimized;
        notifyListeners();
      }
    }
  }

  /// Generate PDF
  Future<void> generatePdf(EstimateModel estimate) async {
    try {
      await _pdfService.generateEstimatePdf(estimate);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Print PDF
  Future<void> printPdf(EstimateModel estimate) async {
    try {
      await _pdfService.printPdf(estimate);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Delete estimate
  void deleteEstimate(String projectId, String estimateId) {
    final estimates = _estimatesByProject[projectId];
    if (estimates != null) {
      estimates.removeWhere((e) => e.id == estimateId);
      notifyListeners();
    }
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    final allEstimates = getAllEstimates();
    final totalEstimates = allEstimates.length;
    final approvedCount = allEstimates.where((e) => e.status == EstimateStatus.approved).length;
    final pendingCount = allEstimates.where((e) => e.status == EstimateStatus.pending).length;
    final totalValue = allEstimates.fold<double>(0, (sum, e) => sum + e.total);

    return {
      'total': totalEstimates,
      'approved': approvedCount,
      'pending': pendingCount,
      'totalValue': totalValue,
    };
  }

  /// Clear all
  void clearAll() {
    _estimatesByProject.clear();
    _error = null;
    notifyListeners();
  }
}
