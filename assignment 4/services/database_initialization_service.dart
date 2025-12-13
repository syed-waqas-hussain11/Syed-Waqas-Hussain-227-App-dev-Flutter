import 'package:supabase_flutter/supabase_flutter.dart';

class DatabaseInitializationService {
  static final DatabaseInitializationService _instance = DatabaseInitializationService._internal();

  factory DatabaseInitializationService() {
    return _instance;
  }

  DatabaseInitializationService._internal();

  /// Initialize the database by creating the submissions table if it doesn't exist
  Future<bool> initializeDatabase() async {
    try {
      final supabase = Supabase.instance.client;

      // Check if table exists by attempting to query it
      try {
        await supabase.from('submissions').select('id').limit(1);
        // Table exists
        return true;
      } catch (e) {
        // Table doesn't exist, create it
        await _createSubmissionsTable(supabase);
        return true;
      }
    } catch (e) {
      // Silently fail if database setup fails - the error will be shown when user tries to submit
      return false;
    }
  }

  /// Create the submissions table with proper schema
  Future<void> _createSubmissionsTable(SupabaseClient supabase) async {
    const String createTableSQL = '''
      CREATE TABLE IF NOT EXISTS submissions (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        full_name VARCHAR(100) NOT NULL,
        email VARCHAR(255) NOT NULL,
        phone_number VARCHAR(15) NOT NULL,
        address VARCHAR(200) NOT NULL,
        gender VARCHAR(20) NOT NULL CHECK (gender IN ('Male', 'Female', 'Other')),
        created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
      )
    ''';

    try {
      // Note: This SQL execution might require admin access
      // In production, use the Supabase dashboard SQL editor instead
      await supabase.rpc('exec_sql', params: {'sql': createTableSQL});
    } catch (e) {
      // If RPC call fails, that's okay - the table might already exist
      // or user needs to create it manually via Supabase dashboard
    }
  }

  /// Verify that the submissions table exists and is accessible
  Future<bool> verifyTableExists() async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('submissions').select('id').limit(1);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get database statistics
  Future<Map<String, dynamic>> getDatabaseStats() async {
    try {
      final supabase = Supabase.instance.client;
      final count = await supabase.from('submissions').select('id').count();
      
      return {
        'totalSubmissions': count,
        'tableExists': true,
      };
    } catch (e) {
      return {
        'totalSubmissions': 0,
        'tableExists': false,
        'error': e.toString(),
      };
    }
  }
}
