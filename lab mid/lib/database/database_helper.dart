import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/patient.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('patients.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const textTypeNullable = 'TEXT';

    await db.execute('''
      CREATE TABLE patients (
        id $idType,
        name $textType,
        age $intType,
        gender $textType,
        phone $textType,
        email $textType,
        address $textType,
        bloodGroup $textType,
        medicalHistory $textType,
        profileImagePath $textTypeNullable,
        documentPath $textTypeNullable,
        createdAt $textType,
        updatedAt $textType
      )
    ''');
  }

  // Create - Insert a new patient
  Future<Patient> create(Patient patient) async {
    final db = await instance.database;
    final id = await db.insert('patients', patient.toMap());
    return patient.copyWith(id: id);
  }

  // Read - Get a single patient by id
  Future<Patient?> readPatient(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'patients',
      columns: [
        'id',
        'name',
        'age',
        'gender',
        'phone',
        'email',
        'address',
        'bloodGroup',
        'medicalHistory',
        'profileImagePath',
        'documentPath',
        'createdAt',
        'updatedAt',
      ],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Read - Get all patients
  Future<List<Patient>> readAllPatients() async {
    final db = await instance.database;
    const orderBy = 'name ASC';
    final result = await db.query('patients', orderBy: orderBy);
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  // Read - Search patients by name
  Future<List<Patient>> searchPatients(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'patients',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  // Update - Update a patient
  Future<int> update(Patient patient) async {
    final db = await instance.database;
    return db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  // Delete - Delete a patient
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Close database
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
