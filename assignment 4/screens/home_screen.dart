import 'package:flutter/material.dart';
import '../models/submission.dart';
import '../services/submission_service.dart';
import '../utils/validation_helper.dart';
import 'submissions_list_screen.dart';
import 'submissions_data_view_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _submissionService = SubmissionService();

  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;

  String _selectedGender = '';
  bool _isLoading = false;
  Submission? _editingSubmission;
  late Future<List<Submission>> _submissionsFuture;

  final List<String> genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _addressController = TextEditingController();
    _submissionsFuture = _submissionService.getAllSubmissions();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _refreshSubmissions() {
    setState(() {
      _submissionsFuture = _submissionService.getAllSubmissions();
    });
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _fullNameController.clear();
    _emailController.clear();
    _phoneNumberController.clear();
    _addressController.clear();
    setState(() {
      _selectedGender = '';
      _editingSubmission = null;
    });
  }

  void _loadSubmissionForEdit(Submission submission) {
    setState(() {
      _editingSubmission = submission;
      _fullNameController.text = submission.fullName;
      _emailController.text = submission.email;
      _phoneNumberController.text = submission.phoneNumber;
      _addressController.text = submission.address;
      _selectedGender = submission.gender;
    });
    ScrollController scrollController = ScrollController();
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final submission = Submission(
        id: _editingSubmission?.id,
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        address: _addressController.text.trim(),
        gender: _selectedGender,
      );

      if (_editingSubmission != null) {
        await _submissionService.updateSubmission(submission);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✓ Submission updated successfully!'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        await _submissionService.createSubmission(submission);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✓ Submission created successfully!'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }

      if (mounted) {
        _resetForm();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✗ Error: $e'),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteSubmission() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Submission'),
        content: const Text('Are you sure you want to delete this submission? This action cannot be undone.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted && _editingSubmission != null) {
      try {
        await _submissionService.deleteSubmission(_editingSubmission!.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✓ Submission deleted successfully!'),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          _resetForm();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✗ Error: $e'),
              backgroundColor: const Color(0xFFFF6B6B),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Submission',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: IconButton(
              icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubmissionsDataViewScreen(),
                  ),
                );
              },
              tooltip: 'Data Overview',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
            ),
            child: IconButton(
              icon: const Icon(Icons.list_alt_rounded, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubmissionsListScreen(),
                  ),
                );
                if (result is Submission) {
                  _loadSubmissionForEdit(result);
                }
              },
              tooltip: 'View All Submissions',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFF0F9FF),
              const Color(0xFFE0F7FF),
              const Color(0xFFCCF0FF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_editingSubmission != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00D4FF).withOpacity(0.12),
                          const Color(0xFF00BCD4).withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withOpacity(0.4),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF00D4FF),
                                const Color(0xFF00BCD4),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00D4FF).withOpacity(0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Editing submission',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  letterSpacing: 0.2,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'You are updating an existing submission',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _resetForm,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5E7EB),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF6B7280),
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _deleteSubmission,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.delete_rounded,
                              color: Color(0xFFFF6B6B),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Text(
                'Create Your Submission',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A1628),
                  fontSize: 30,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Fill in all the details below to submit your information',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4B5563),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 36),
              _buildFormField(
                controller: _fullNameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_rounded,
                validator: ValidationHelper.validateFullName,
              ),
              const SizedBox(height: 18),
              _buildFormField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: ValidationHelper.validateEmail,
              ),
              const SizedBox(height: 18),
              _buildFormField(
                controller: _phoneNumberController,
                label: 'Phone Number',
                hint: 'Enter your phone number',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: ValidationHelper.validatePhoneNumber,
              ),
              const SizedBox(height: 18),
              _buildFormField(
                controller: _addressController,
                label: 'Address',
                hint: 'Enter your full address',
                icon: Icons.location_on_rounded,
                maxLines: 3,
                validator: ValidationHelper.validateAddress,
              ),
              const SizedBox(height: 24),
              _buildGenderField(),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D4FF),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: const Color(0xFF00D4FF).withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _editingSubmission != null
                                  ? Icons.update_rounded
                                  : Icons.check_circle_rounded,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _editingSubmission != null
                                  ? 'Update Submission'
                                  : 'Submit Form',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (_editingSubmission != null) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _resetForm,
                    icon: const Icon(Icons.close_rounded, size: 20),
                    label: const Text(
                      'Cancel Edit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFD1D5DB),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      foregroundColor: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
              
              // Recent Submissions Section
              Text(
                'Your Submissions',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0A1628),
                  fontSize: 24,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 16),
              
              FutureBuilder<List<Submission>>(
                future: _submissionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'Error loading submissions',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  final submissions = snapshot.data ?? [];

                  if (submissions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Text(
                        'No submissions yet. Create one above!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: submissions.length.clamp(0, 5),
                    itemBuilder: (context, index) {
                      final submission = submissions[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFB3E5FC),
                              width: 1.5,
                            ),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00D4FF).withOpacity(0.2),
                                      const Color(0xFF00BCD4).withOpacity(0.15),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Color(0xFF00D4FF),
                                  size: 22,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      submission.fullName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Color(0xFF0A1628),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      submission.email,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF4B5563),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _loadSubmissionForEdit(submission),
                                icon: const Icon(Icons.edit_rounded, size: 16),
                                label: const Text('Edit'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00D4FF),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  elevation: 2,
                                ),
                              ),
                              const SizedBox(width: 6),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Submission', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0A1628))),
                                      content: const Text('Are you sure you want to delete this submission?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF4B5563))),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text('Delete', style: TextStyle(color: Color(0xFFFF4081), fontWeight: FontWeight.w700)),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true && mounted) {
                                    try {
                                      await _submissionService.deleteSubmission(submission.id!);
                                      _refreshSubmissions();
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: const Text('✓ Submission deleted', style: TextStyle(fontWeight: FontWeight.w600)),
                                            backgroundColor: const Color(0xFF00C853),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error: $e'),
                                            backgroundColor: const Color(0xFFFF4081),
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                icon: const Icon(Icons.delete_rounded, size: 16),
                                label: const Text('Delete'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF4081),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  elevation: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1628),
              letterSpacing: 0.3,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color(0xFF0A1628),
            height: 1.4,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: Color(0xFF7B8FA3),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, size: 20),
            filled: true,
            fillColor: const Color(0xFFF0FFFE),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFB3E5FC), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFB3E5FC), width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00D4FF), width: 2.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF4081), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF4081), width: 2.5),
            ),
            contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Gender',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A1628),
              letterSpacing: 0.3,
            ),
          ),
        ),
        FormField<String>(
          validator: (value) => ValidationHelper.validateGender(
              _selectedGender.isEmpty ? null : _selectedGender),
          builder: (FormFieldState<String> field) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FFFE),
                    border: Border.all(
                      color: field.hasError
                          ? const Color(0xFFFF4081)
                          : const Color(0xFFB3E5FC),
                      width: field.hasError ? 2 : 1.5,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text(
                      'Select Gender',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF7B8FA3),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    value: _selectedGender.isEmpty ? null : _selectedGender,
                    items: genders.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            Icon(
                              value == 'Male'
                                  ? Icons.male_rounded
                                  : value == 'Female'
                                      ? Icons.female_rounded
                                      : Icons.person_rounded,
                              color: const Color(0xFF00D4FF),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              value,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF0A1628),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedGender = newValue ?? '';
                      });
                      field.didChange(newValue);
                    },
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0A1628),
                    ),
                    dropdownColor: Colors.white,
                    isDense: false,
                    itemHeight: 52,
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 14, top: 8),
                    child: Text(
                      field.errorText!,
                      style: const TextStyle(
                        color: Color(0xFFFF4081),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
