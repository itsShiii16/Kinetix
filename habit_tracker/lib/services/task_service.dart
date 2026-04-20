import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class TaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _taskCollection =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  CollectionReference<Map<String, dynamic>> get _logCollection =>
      _firestore.collection('users').doc(_userId).collection('task_logs');

  String _todayKey() {
    final today = DateTime.now();
    return "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
  }

  Future<void> createTask(TaskModel task) async {
    await _taskCollection.doc(task.id).set({
      ...task.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'deletedAt': null,
    });
  }

  Stream<List<TaskModel>> getActiveTasks() {
    return _taskCollection
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      final tasks = snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data(), doc.id);
      }).toList();

      tasks.sort((a, b) {
        if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
        if (a.isPriority != b.isPriority) return a.isPriority ? -1 : 1;
        return 0;
      });

      return tasks;
    });
  }

  Stream<List<TaskModel>> getDeletedTasks() {
    return _taskCollection
        .where('isDeleted', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskCollection.doc(task.id).update({
      'title': task.title,
      'subtitle': task.subtitle,
      'category': task.category,
      'type': task.type,
      'current': task.current,
      'total': task.total,
      'isDone': task.isDone,
      'isPriority': task.isPriority,
      'isDeleted': task.isDeleted,
      'repeatDays': task.repeatDays,
      'remindersEnabled': task.remindersEnabled,
      'reminders': task.reminders,
      'startDate': task.startDate,
      'endDate': task.endDate,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleTaskCompletion(TaskModel task) async {
    final dateKey = _todayKey();
    final newValue = !task.isDone;

    await _taskCollection.doc(task.id).update({
      'isDone': newValue,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final logQuery = await _logCollection
        .where('taskId', isEqualTo: task.id)
        .where('date', isEqualTo: dateKey)
        .get();

    if (logQuery.docs.isNotEmpty) {
      await logQuery.docs.first.reference.update({
        'isCompleted': newValue,
      });
    } else {
      await _logCollection.add({
        'taskId': task.id,
        'category': task.category,
        'date': dateKey,
        'isCompleted': newValue,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> softDeleteTask(String taskId) async {
    await _taskCollection.doc(taskId).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> restoreTask(String taskId) async {
    await _taskCollection.doc(taskId).update({
      'isDeleted': false,
      'deletedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> hardDeleteTask(String taskId) async {
    final logs = await _logCollection.where('taskId', isEqualTo: taskId).get();

    for (final doc in logs.docs) {
      await doc.reference.delete();
    }

    await _taskCollection.doc(taskId).delete();
  }
}