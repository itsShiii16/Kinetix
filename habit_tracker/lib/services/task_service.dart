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

  CollectionReference get _taskCollection =>
      _firestore.collection('users').doc(_userId).collection('tasks');

  CollectionReference get _logCollection =>
      _firestore.collection('users').doc(_userId).collection('task_logs');

  // =============================
  // CREATE TASK
  // =============================
  Future<void> createTask(TaskModel task) async {
    await _taskCollection.doc(task.id).set({
      'title': task.title,
      'subtitle': task.subtitle,
      'category': task.category,
      'type': task.type,
      'current': task.current,
      'total': task.total,
      'isPriority': task.isPriority,
      'isDeleted': false,
      'deletedAt': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =============================
  // GET ACTIVE TASKS
  // =============================
  Stream<List<TaskModel>> getActiveTasks() {
    return _taskCollection
        .where('isDeleted', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  // =============================
  // UPDATE TASK
  // =============================
  Future<void> updateTask(TaskModel task) async {
    await _taskCollection.doc(task.id).update({
      'title': task.title,
      'subtitle': task.subtitle,
      'category': task.category,
      'type': task.type,
      'current': task.current,
      'total': task.total,
      'isPriority': task.isPriority,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // =============================
  // TOGGLE COMPLETE (TODAY LOG)
  // =============================
  Future<void> toggleTaskCompletion(TaskModel task) async {
    final today = DateTime.now();
    final dateKey =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final logQuery = await _logCollection
        .where('taskId', isEqualTo: task.id)
        .where('date', isEqualTo: dateKey)
        .get();

    if (logQuery.docs.isNotEmpty) {
      // toggle existing log
      final doc = logQuery.docs.first;
      final current = doc['isCompleted'] as bool;

      await doc.reference.update({
        'isCompleted': !current,
      });
    } else {
      // create new log
      await _logCollection.add({
        'taskId': task.id,
        'date': dateKey,
        'isCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // =============================
  // SOFT DELETE
  // =============================
  Future<void> softDeleteTask(String taskId) async {
    await _taskCollection.doc(taskId).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  // =============================
  // RESTORE TASK
  // =============================
  Future<void> restoreTask(String taskId) async {
    await _taskCollection.doc(taskId).update({
      'isDeleted': false,
      'deletedAt': null,
    });
  }

  // =============================
  // HARD DELETE
  // =============================
  Future<void> hardDeleteTask(String taskId) async {
    // delete task
    await _taskCollection.doc(taskId).delete();

    // delete related logs
    final logs = await _logCollection
        .where('taskId', isEqualTo: taskId)
        .get();

    for (var doc in logs.docs) {
      await doc.reference.delete();
    }
  }
}