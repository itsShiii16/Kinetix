import 'package:flutter/material.dart';

class TaskModel {
  final String id;
  final String title;
  final String subtitle;
  final String category; // Lifestyle, School, Work, Home
  final String type; // simple | progress
  final int? current;
  final int? total;
  final bool isDone;
  final bool isPriority;
  final bool isDeleted;
  final IconData icon;
  final Color color;

  TaskModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.type,
    this.current,
    this.total,
    required this.isDone,
    required this.isPriority,
    required this.isDeleted,
    required this.icon,
    required this.color,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? category,
    String? type,
    int? current,
    int? total,
    bool? isDone,
    bool? isPriority,
    bool? isDeleted,
    IconData? icon,
    Color? color,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      category: category ?? this.category,
      type: type ?? this.type,
      current: current ?? this.current,
      total: total ?? this.total,
      isDone: isDone ?? this.isDone,
      isPriority: isPriority ?? this.isPriority,
      isDeleted: isDeleted ?? this.isDeleted,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    final category = (map['category'] ?? '').toString();

    return TaskModel(
      id: id,
      title: (map['title'] ?? '').toString(),
      subtitle: (map['subtitle'] ?? '').toString(),
      category: category,
      type: (map['type'] ?? 'simple').toString(),
      current: map['current'] is int ? map['current'] as int : null,
      total: map['total'] is int ? map['total'] as int : null,
      isDone: map['isDone'] ?? false,
      isPriority: map['isPriority'] ?? false,
      isDeleted: map['isDeleted'] ?? false,
      icon: _iconFromCategory(category),
      color: _colorFromCategory(category),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'type': type,
      'current': current,
      'total': total,
      'isDone': isDone,
      'isPriority': isPriority,
      'isDeleted': isDeleted,
    };
  }

  static IconData _iconFromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'lifestyle':
        return Icons.self_improvement_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'work':
        return Icons.work_rounded;
      case 'home':
        return Icons.home_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  static Color _colorFromCategory(String category) {
    switch (category.toLowerCase()) {
      case 'lifestyle':
        return const Color(0xFF56CCF2);
      case 'school':
        return const Color(0xFFB4A6FF);
      case 'work':
        return const Color(0xFFFF9A62);
      case 'home':
        return const Color(0xFF7EE6A2);
      default:
        return Colors.white;
    }
  }
}