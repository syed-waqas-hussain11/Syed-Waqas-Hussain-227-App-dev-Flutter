import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/submission.dart';
import '../services/submission_service.dart';

enum ViewType { grid, list, stats }

class SubmissionsDataViewScreen extends StatefulWidget {
  const SubmissionsDataViewScreen({super.key});

  @override
  State<SubmissionsDataViewScreen> createState() =>
      _SubmissionsDataViewScreenState();
}

class _SubmissionsDataViewScreenState extends State<SubmissionsDataViewScreen> {
  final _submissionService = SubmissionService();
  late Future<List<Submission>> _submissionsFuture;
  ViewType _viewType = ViewType.grid;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Submissions Data View',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 24),
        ),
        actions: [
          _buildViewToggleButtons(),
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
              return _buildErrorWidget(snapshot.error);
            }

            final submissions = snapshot.data ?? [];

            if (submissions.isEmpty) {
              return _buildEmptyStateWidget();
            }

            return _buildViewContent(submissions);
          },
        ),
      ),
    );
  }

  Widget _buildViewToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          _buildViewToggleButton(ViewType.grid, Icons.grid_3x3_rounded, 'Grid'),
          const SizedBox(width: 4),
          _buildViewToggleButton(ViewType.list, Icons.list_rounded, 'List'),
          const SizedBox(width: 4),
          _buildViewToggleButton(
            ViewType.stats,
            Icons.bar_chart_rounded,
            'Stats',
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggleButton(ViewType type, IconData icon, String label) {
    final isSelected = _viewType == type;
    return Tooltip(
      message: label,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected
              ? Colors.white.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white),
          onPressed: () {
            setState(() => _viewType = type);
          },
        ),
      ),
    );
  }

  Widget _buildViewContent(List<Submission> submissions) {
    switch (_viewType) {
      case ViewType.grid:
        return _buildGridView(submissions);
      case ViewType.list:
        return _buildListView(submissions);
      case ViewType.stats:
        return _buildStatsView(submissions);
    }
  }

  Widget _buildGridView(List<Submission> submissions) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.95,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: submissions.length,
        itemBuilder: (context, index) {
          final submission = submissions[index];
          return _buildSubmissionCard(submission);
        },
      ),
    );
  }

  Widget _buildSubmissionCard(Submission submission) {
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
          // Header with avatar and name
          Flex(
            direction: Axis.horizontal,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF00D4FF), const Color(0xFF00BCD4)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  // ...existing code...
                  // replaced `.characters.first` to avoid needing the characters package
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
          // Contact info
          Flex(
            direction: Axis.vertical,
            children: [
              _buildInfoRow(Icons.email_rounded, submission.email, 10),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.phone_rounded, submission.phoneNumber, 10),
            ],
          ),
          const Spacer(),
          // Timestamp
          Text(
            DateFormat(
              'MMM dd, yyyy',
            ).format(submission.createdAt ?? DateTime.now()),
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, double fontSize) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF00D4FF)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              color: const Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListView(List<Submission> submissions) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submission = submissions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB3E5FC), width: 1.5),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00D4FF),
                        const Color(0xFF00BCD4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    // ...existing code...
                    // replaced `.characters.first` to avoid needing the characters package
                    submission.fullName.isNotEmpty
                        ? submission.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Flex(
                    direction: Axis.vertical,
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Text(
                              submission.phoneNumber,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7B8FA3),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FFFE),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              submission.gender,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF00D4FF),
                                fontWeight: FontWeight.w700,
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
  }

  Widget _buildStatsView(List<Submission> submissions) {
    final genderStats = _calculateGenderStats(submissions);
    final submissionsThisMonth = _calculateMonthlySubmissions(submissions);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Flex(
        direction: Axis.vertical,
        children: [
          // Overall Statistics
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [const Color(0xFF00D4FF), const Color(0xFF00BCD4)],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D4FF).withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Flex(
              direction: Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Submissions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  submissions.length.toString(),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Gender Distribution
          Text(
            'Gender Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A1628),
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.1,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: genderStats.length,
            itemBuilder: (context, index) {
              final entry = genderStats.entries.toList()[index];
              return _buildStatCard(entry.key, entry.value, submissions.length);
            },
          ),
          const SizedBox(height: 20),

          // Monthly Breakdown
          Text(
            'This Month',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E7FF), width: 1.5),
              color: Colors.white,
            ),
            padding: const EdgeInsets.all(20),
            child: Flex(
              direction: Axis.vertical,
              children: [
                _buildStatRow('Submissions', submissionsThisMonth.toString()),
                const SizedBox(height: 12),
                _buildStatRow('Total Ever', submissions.length.toString()),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Latest Submissions
          Text(
            'Latest Submissions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A1628),
            ),
          ),
          const SizedBox(height: 12),
          ...submissions.take(3).map((submission) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFB3E5FC),
                    width: 1.5,
                  ),
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(14),
                child: Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(
                      child: Flex(
                        direction: Axis.vertical,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            submission.fullName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Color(0xFF0A1628),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat(
                              'MMM dd, yyyy • hh:mm a',
                            ).format(submission.createdAt ?? DateTime.now()),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF7B8FA3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FFFE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        submission.gender,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF00D4FF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, int total) {
    final percentage = total > 0
        ? (count / total * 100).toStringAsFixed(0)
        : '0';
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E7FF), width: 1.5),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(12),
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF00D4FF),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$percentage%',
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF7B8FA3),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Flex(
      direction: Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF4B5563),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0A1628),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_rounded, size: 64, color: Color(0xFFFF4081)),
          const SizedBox(height: 16),
          Text(
            'Error loading submissions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF0A1628),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF4B5563)),
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

  Widget _buildEmptyStateWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_rounded, size: 80, color: Color(0xFFB3E5FC)),
          const SizedBox(height: 16),
          Text(
            'No Submissions Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0A1628),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first submission to see data here',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: const Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }

  Map<String, int> _calculateGenderStats(List<Submission> submissions) {
    final stats = {'Male': 0, 'Female': 0, 'Other': 0};
    for (var submission in submissions) {
      if (stats.containsKey(submission.gender)) {
        stats[submission.gender] = stats[submission.gender]! + 1;
      }
    }
    return stats;
  }

  int _calculateMonthlySubmissions(List<Submission> submissions) {
    final now = DateTime.now();
    return submissions.where((submission) {
      final created = submission.createdAt ?? DateTime.now();
      return created.year == now.year && created.month == now.month;
    }).length;
  }
}
