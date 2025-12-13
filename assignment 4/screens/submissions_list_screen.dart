import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/submission.dart';
import '../services/submission_service.dart';

class SubmissionsListScreen extends StatefulWidget {
  const SubmissionsListScreen({super.key});

  @override
  State<SubmissionsListScreen> createState() => _SubmissionsListScreenState();
}

class _SubmissionsListScreenState extends State<SubmissionsListScreen> {
  final _submissionService = SubmissionService();
  late Future<List<Submission>> _submissionsFuture;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _submissionsFuture = _submissionService.getAllSubmissions();
  }

  void _refreshSubmissions() {
    setState(() {
      _submissionsFuture = _submissionService.getAllSubmissions();
    });
  }

  Future<void> _deleteSubmission(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Submission',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF0A1628),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this submission? This action cannot be undone.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF4B5563)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                color: Color(0xFFFF4081),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _submissionService.deleteSubmission(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '✓ Submission deleted successfully!',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: const Color(0xFF00C853),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          _refreshSubmissions();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✗ Error: $e'),
              backgroundColor: const Color(0xFFFF4081),
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
          'All Submissions',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
            ),
            child: IconButton(
              icon: Icon(
                _isGridView ? Icons.list_rounded : Icons.grid_3x3_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                setState(() => _isGridView = !_isGridView);
              },
              tooltip: _isGridView ? 'Switch to List' : 'Switch to Grid',
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.25),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 24,
              ),
              onPressed: _refreshSubmissions,
              tooltip: 'Refresh',
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
        child: FutureBuilder<List<Submission>>(
          future: _submissionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D4FF)),
                  strokeWidth: 4,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_rounded,
                      size: 64,
                      color: Color(0xFFFF4081),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading submissions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF0A1628),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _refreshSubmissions,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4FF),
                      ),
                    ),
                  ],
                ),
              );
            }

            final submissions = snapshot.data ?? [];

            if (submissions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.inbox_rounded,
                      size: 80,
                      color: Color(0xFFB3E5FC),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Submissions Yet',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0A1628),
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first submission to see it here',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF4B5563),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create Submission'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4FF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (_isGridView) {
              return _buildGridView(submissions);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final submission = submissions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFB3E5FC),
                        width: 1.5,
                      ),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00D4FF).withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      collapsedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      tilePadding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            submission.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: Color(0xFF0A1628),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            submission.email,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FFFE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.expand_more_rounded,
                          color: Color(0xFF00D4FF),
                          size: 24,
                        ),
                      ),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FFFE),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: const Color(0xFFB3E5FC),
                                width: 1.5,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDetailRow('Full Name', submission.fullName),
                              const SizedBox(height: 18),
                              _buildDetailRow('Email', submission.email),
                              const SizedBox(height: 18),
                              _buildDetailRow('Phone', submission.phoneNumber),
                              const SizedBox(height: 18),
                              _buildDetailRow('Address', submission.address),
                              const SizedBox(height: 18),
                              _buildDetailRow('Gender', submission.gender),
                              const SizedBox(height: 18),
                              _buildDetailRow(
                                'Submitted',
                                submission.createdAt != null
                                    ? DateFormat(
                                        'MMM dd, yyyy • hh:mm a',
                                      ).format(submission.createdAt!)
                                    : 'N/A',
                              ),
                              const SizedBox(height: 28),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context, submission);
                                    },
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      size: 18,
                                    ),
                                    label: const Text('Edit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00D4FF),
                                      elevation: 2,
                                      shadowColor: const Color(
                                        0xFF00D4FF,
                                      ).withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _deleteSubmission(submission.id!),
                                    icon: const Icon(
                                      Icons.delete_rounded,
                                      size: 18,
                                    ),
                                    label: const Text('Delete'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF4081),
                                      elevation: 2,
                                      shadowColor: const Color(
                                        0xFFFF4081,
                                      ).withOpacity(0.4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
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
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: Color(0xFF4B5563),
              letterSpacing: 0.2,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Color(0xFF0A1628),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView(List<Submission> submissions) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.95,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFB3E5FC), width: 1.5),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D4FF), Color(0xFF00BCD4)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      submission.fullName.isNotEmpty
                          ? submission.fullName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          submission.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF0A1628),
                          ),
                        ),
                        Text(
                          submission.gender,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF4B5563),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: const Color(0xFFB3E5FC), thickness: 1, height: 12),
              const SizedBox(height: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.email_rounded,
                          size: 14,
                          color: Color(0xFF00D4FF),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            submission.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_rounded,
                          size: 14,
                          color: Color(0xFF00D4FF),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            submission.phoneNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF4B5563),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context, submission);
                      },
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D4FF),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _deleteSubmission(submission.id!),
                      icon: const Icon(Icons.delete_rounded, size: 16),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4081),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
