import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/submission.dart';

class SubmissionService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String _tableName = 'submissions';

  // Create a new submission
  Future<Submission> createSubmission(Submission submission) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .insert(submission.toMap())
          .select()
          .single();

      return Submission.fromMap(response);
    } catch (e) {
      throw Exception('Failed to create submission: $e');
    }
  }

  // Read all submissions
  Future<List<Submission>> getAllSubmissions() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);

      return List<Submission>.from(
        (response as List).map((x) => Submission.fromMap(x as Map<String, dynamic>)),
      );
    } catch (e) {
      throw Exception('Failed to fetch submissions: $e');
    }
  }

  // Read a single submission by ID
  Future<Submission> getSubmissionById(String id) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('id', id)
          .single();

      return Submission.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch submission: $e');
    }
  }

  // Update a submission
  Future<Submission> updateSubmission(Submission submission) async {
    try {
      if (submission.id == null) {
        throw Exception('Submission ID is required for update');
      }

      final response = await _supabase
          .from(_tableName)
          .update(submission.toMap())
          .eq('id', submission.id!)
          .select()
          .single();

      return Submission.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update submission: $e');
    }
  }

  // Delete a submission
  Future<void> deleteSubmission(String id) async {
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete submission: $e');
    }
  }
}
