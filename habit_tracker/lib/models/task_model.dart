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
    required this.icon,
    required this.color,
  });

  // --- COPY WITH (for state updates later) ---
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
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  // --- FROM MAP (for Firebase later) ---
  factory TaskModel.fromMap(Map<String, dynamic> map, String id) {
    return TaskModel(
      id: id,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      category: map['category'] ?? '',
      type: map['type'] ?? 'simple',
      current: map['current'],
      total: map['total'],
      isDone: map['isDone'] ?? false,
      isPriority: map['isPriority'] ?? false,
      icon: Icons.task_alt_rounded, // fallback for now
      color: Colors.white, // fallback for now
    );
  }

  // --- TO MAP (for Firebase later) ---
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
    };
  }
}