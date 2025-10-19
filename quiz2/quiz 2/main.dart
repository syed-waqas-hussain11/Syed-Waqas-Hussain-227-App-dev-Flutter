import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'models/contact.dart';
import 'helpers/database_helper.dart';
import 'services/firestore_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts CRUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        scaffoldBackgroundColor: const Color(0xFFF2FBFF),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black87,
          centerTitle: true,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 2,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF4F46E5),
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
      ),
      home: const ContactsPage(),
    );
  }
}

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final db = DatabaseHelper.instance;
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final list = await db.getContacts();
    setState(() => contacts = list);
  }

  Future<void> _showForm({Contact? contact}) async {
    final result = await Navigator.of(context).push<bool?>(
      MaterialPageRoute<bool?>(
        builder: (_) => ContactEditPage(contact: contact),
        fullscreenDialog: true,
      ),
    );
    if (result == true) {
      _loadContacts();
    }
  }

  Future<void> _deleteContact(int id) async {
    await db.deleteContact(id);
    _loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showForm()),
        ],
      ),
      body: Column(
        children: [
          // header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF06B6D4), Color(0xFF4F46E5)],
              ),
            ),
            child: Row(
              children: const [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Color(0xFFFFFFFF),
                  child: Icon(Icons.contact_phone, color: Color(0xFF4F46E5)),
                ),
                SizedBox(width: 12),
                Text(
                  'Contacts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: contacts.isEmpty
                  ? Center(
                      child: Text(
                        'No contacts yet. Tap + to add one.',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      itemCount: contacts.length,
                      itemBuilder: (context, i) {
                        final c = contacts[i];
                        return Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundImage:
                                  c.imagePath != null && c.imagePath!.isNotEmpty
                                  ? FileImage(File(c.imagePath!))
                                        as ImageProvider
                                  : null,
                              backgroundColor: const Color(0xFFE0FBFF),
                              child: c.imagePath == null || c.imagePath!.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Color(0xFF06B6D4),
                                    )
                                  : null,
                            ),
                            title: Text(
                              c.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text('${c.email}\nAge: ${c.age}'),
                            isThreeLine: true,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Color(0xFF4F46E5),
                                  ),
                                  onPressed: () => _showForm(contact: c),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Delete contact?'),
                                        content: const Text(
                                          'This action cannot be undone.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (ok == true) _deleteContact(c.id!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),

          // footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Color(0x11000000), blurRadius: 6)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${contacts.length} contacts',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showForm(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add Contact'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showForm(),
        icon: const Icon(Icons.person_add),
        label: const Text('Add'),
      ),
    );
  }
}

class ContactForm extends StatefulWidget {
  final Contact? contact;

  const ContactForm({super.key, this.contact});

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class ContactEditPage extends StatelessWidget {
  final Contact? contact;

  const ContactEditPage({super.key, this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact == null ? 'Add Contact' : 'Edit Contact'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF2FBFF), Color(0xFFEFF0FF)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ContactForm(contact: contact),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      _nameCtrl.text = widget.contact!.name;
      _emailCtrl.text = widget.contact!.email;
      _ageCtrl.text = widget.contact!.age.toString();
      _imagePath = widget.contact!.imagePath;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  // Progress dialog state
  void _showProgress(BuildContext context, String title) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            LinearProgressIndicator(value: null),
            SizedBox(height: 12),
            Text('Please wait...'),
          ],
        ),
      ),
    );
  }

  void _updateProgress(BuildContext context, double progress) {
    // For simplicity we will not update the dialog content dynamically here.
    // Implementing a fully reactive progress dialog would require a StatefulBuilder or separate state.
  }

  void _dismissProgress(BuildContext context) {
    try {
      Navigator.of(context, rootNavigator: true).pop();
    } catch (_) {}
  }

  void _showError(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
    final db = DatabaseHelper.instance;
    try {
      // show progress indicator
      _showProgress(context, 'Saving contact...');

      if (widget.contact == null) {
        final c = Contact(
          name: name,
          email: email,
          age: age,
          imagePath: _imagePath,
        );
        final localId = await db.insertContact(c);
        String? uploadedUrl;
        if (_imagePath != null && _imagePath!.isNotEmpty) {
          final file = File(_imagePath!);
          uploadedUrl = await FirestoreService.instance.uploadImage(
            file,
            onProgress: (p) {
              _updateProgress(context, p);
            },
          );
        }
        final saved = c.copyWith(id: localId);
        await FirestoreService.instance.saveContact(
          saved,
          imageUrl: uploadedUrl,
        );
      } else {
        final c = widget.contact!.copyWith(
          name: name,
          email: email,
          age: age,
          imagePath: _imagePath,
        );
        await db.updateContact(c);
        String? uploadedUrl;
        if (_imagePath != null && _imagePath!.isNotEmpty) {
          final file = File(_imagePath!);
          uploadedUrl = await FirestoreService.instance.uploadImage(
            file,
            onProgress: (p) {
              _updateProgress(context, p);
            },
          );
        }
        await FirestoreService.instance.saveContact(c, imageUrl: uploadedUrl);
      }
    } catch (e) {
      // show error to user (only if widget still mounted)
      if (mounted) {
        _showError(context, 'Failed to save contact: ${e.toString()}');
      } else {
        debugPrint('Failed to save contact: $e');
      }
      return;
    } finally {
      // dismiss progress only if still mounted
      if (mounted) _dismissProgress(context);
    }
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 42,
                    backgroundImage:
                        _imagePath != null && _imagePath!.isNotEmpty
                        ? FileImage(File(_imagePath!))
                        : null,
                    child: _imagePath == null || _imagePath!.isEmpty
                        ? const Icon(Icons.camera_alt, size: 30)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.contact == null ? 'New Contact' : 'Edit Contact',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add a name, email and age. You may also attach a picture.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter a name'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter an email'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _ageCtrl,
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter age';
                      }
                      final n = int.tryParse(v.trim());
                      if (n == null || n <= 0) {
                        return 'Enter a valid age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _save,
                          child: Text(
                            widget.contact == null ? 'Add' : 'Update',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
