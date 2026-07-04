import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../local/question_seed.dart';
import '../models/quiz_model.dart';
import '../models/stages_seed.dart';

class MigrationService {
  MigrationService._();
  
  static final _db = FirebaseFirestore.instance;

  /// Call this once to upload all local questions and stages to Firestore
  static Future<void> uploadSeedData() async {
    debugPrint('🚀 Starting data migration...');

    // 1. Upload Questions
    final questionBatch = _db.batch();
    for (final q in kSeedQuestions) {
      final docRef = _db.collection('questions').doc(q.id);
      questionBatch.set(docRef, q.toMap());
    }
    await questionBatch.commit();
    debugPrint('✅ Uploaded ${kSeedQuestions.length} questions.');

    // 2. Upload Stages
    final allStages = [...kEasyStages, ...kMediumStages, ...kHardStages];
    final stageBatch = _db.batch();
    for (final s in allStages) {
      final docRef = _db.collection('stages').doc(s.id);
      stageBatch.set(docRef, s.toMap());
    }
    await stageBatch.commit();
    debugPrint('🎉 Migration complete!');
  }
}
