import 'package:equatable/equatable.dart';

enum TaskPriority { low, medium, high, critical }

enum TaskStatus { pending, inProgress, completed, blocked }

class ScopeModel extends Equatable {
  final String id;
  final String projectId;
  final List<PhaseModel> phases;
  final int totalDuration; // in days
  final DateTime generatedAt;
  final String? aiPrompt;
  final String? aiResponse;

  const ScopeModel({
    required this.id,
    required this.projectId,
    required this.phases,
    required this.totalDuration,
    required this.generatedAt,
    this.aiPrompt,
    this.aiResponse,
  });

  ScopeModel copyWith({
    String? id,
    String? projectId,
    List<PhaseModel>? phases,
    int? totalDuration,
    DateTime? generatedAt,
    String? aiPrompt,
    String? aiResponse,
  }) {
    return ScopeModel(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      phases: phases ?? this.phases,
      totalDuration: totalDuration ?? this.totalDuration,
      generatedAt: generatedAt ?? this.generatedAt,
      aiPrompt: aiPrompt ?? this.aiPrompt,
      aiResponse: aiResponse ?? this.aiResponse,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'phases': phases.map((phase) => phase.toJson()).toList(),
      'totalDuration': totalDuration,
      'generatedAt': generatedAt.toIso8601String(),
      'aiPrompt': aiPrompt,
      'aiResponse': aiResponse,
    };
  }

  factory ScopeModel.fromJson(Map<String, dynamic> json) {
    return ScopeModel(
      id: json['id'],
      projectId: json['projectId'],
      phases: (json['phases'] as List)
          .map((phase) => PhaseModel.fromJson(phase))
          .toList(),
      totalDuration: json['totalDuration'],
      generatedAt: DateTime.parse(json['generatedAt']),
      aiPrompt: json['aiPrompt'],
      aiResponse: json['aiResponse'],
    );
  }

  @override
  List<Object?> get props => [id, projectId, phases, totalDuration, generatedAt];
}

class PhaseModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<TaskModel> tasks;
  final int duration; // in days
  final int order;
  final List<String> dependencies; // IDs of phases that must complete first

  const PhaseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.tasks,
    required this.duration,
    required this.order,
    this.dependencies = const [],
  });

  PhaseModel copyWith({
    String? id,
    String? name,
    String? description,
    List<TaskModel>? tasks,
    int? duration,
    int? order,
    List<String>? dependencies,
  }) {
    return PhaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      tasks: tasks ?? this.tasks,
      duration: duration ?? this.duration,
      order: order ?? this.order,
      dependencies: dependencies ?? this.dependencies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'duration': duration,
      'order': order,
      'dependencies': dependencies,
    };
  }

  factory PhaseModel.fromJson(Map<String, dynamic> json) {
    return PhaseModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      tasks: (json['tasks'] as List)
          .map((task) => TaskModel.fromJson(task))
          .toList(),
      duration: json['duration'],
      order: json['order'],
      dependencies: List<String>.from(json['dependencies'] ?? []),
    );
  }

  @override
  List<Object?> get props => [id, name, tasks, duration, order];
}

class TaskModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final int duration; // in days
  final List<String> resources; // Required resources/materials
  final double estimatedCost;
  final TaskPriority priority;
  final TaskStatus status;

  const TaskModel({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    this.resources = const [],
    this.estimatedCost = 0.0,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
  });

  TaskModel copyWith({
    String? id,
    String? name,
    String? description,
    int? duration,
    List<String>? resources,
    double? estimatedCost,
    TaskPriority? priority,
    TaskStatus? status,
  }) {
    return TaskModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      duration: duration ?? this.duration,
      resources: resources ?? this.resources,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      priority: priority ?? this.priority,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'duration': duration,
      'resources': resources,
      'estimatedCost': estimatedCost,
      'priority': priority.name,
      'status': status.name,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      duration: json['duration'],
      resources: List<String>.from(json['resources'] ?? []),
      estimatedCost: json['estimatedCost']?.toDouble() ?? 0.0,
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
    );
  }

  @override
  List<Object?> get props => [id, name, duration, estimatedCost, priority, status];
}
