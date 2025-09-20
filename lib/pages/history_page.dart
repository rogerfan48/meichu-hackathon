import 'package:flutter/material.dart';

// Mock data models - TODO: Replace with actual models
class SessionModel {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> fileNames;
  final String? summary;
  final int cardCount;

  SessionModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.fileNames,
    this.summary,
    required this.cardCount,
  });
}

class FileModel {
  final String id;
  final String name;
  final String type;
  final double sizeMB;
  final DateTime uploadedAt;
  final bool isProcessed;

  FileModel({
    required this.id,
    required this.name,
    required this.type,
    required this.sizeMB,
    required this.uploadedAt,
    required this.isProcessed,
  });
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<SessionModel> _sessions = []; // TODO: Connect to backend
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    // TODO: Load sessions from backend
    setState(() {
      _isLoading = true;
    });

    // Mock data
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _sessions = [
            SessionModel(
              id: '1',
              name: 'Machine Learning Study Session',
              createdAt: DateTime.now().subtract(const Duration(days: 2)),
              updatedAt: DateTime.now().subtract(const Duration(hours: 3)),
              fileNames: ['ml_notes.pdf', 'algorithms.txt'],
              summary: 'Comprehensive study of machine learning algorithms including supervised and unsupervised learning methods.',
              cardCount: 25,
            ),
            SessionModel(
              id: '2', 
              name: 'Flutter Development',
              createdAt: DateTime.now().subtract(const Duration(days: 5)),
              updatedAt: DateTime.now().subtract(const Duration(days: 1)),
              fileNames: ['flutter_widgets.md', 'state_management.pdf'],
              summary: 'Flutter app development fundamentals and state management patterns.',
              cardCount: 18,
            ),
            SessionModel(
              id: '3',
              name: 'Physics Concepts',
              createdAt: DateTime.now().subtract(const Duration(days: 7)),
              updatedAt: DateTime.now().subtract(const Duration(days: 3)),
              fileNames: ['quantum_mechanics.pdf'],
              summary: null,
              cardCount: 12,
            ),
          ];
          _isLoading = false;
        });
      }
    });
  }

  void _deleteSession(SessionModel session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: Text('Are you sure you want to delete "${session.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _sessions.removeWhere((s) => s.id == session.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Session "${session.name}" deleted')),
              );
              // TODO: Delete session from backend
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _openSessionDetail(SessionModel session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SessionDetailPage(session: session),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sessions History'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Sessions Yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Create your first session in the Upload page!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          session.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Created ${_formatDate(session.createdAt)}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.update, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Updated ${_formatDate(session.updatedAt)}',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.description, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${session.fileNames.length} files',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.style, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  '${session.cardCount} cards',
                                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                ),
                              ],
                            ),
                            if (session.summary != null) ...[
                              const SizedBox(height: 8),
                              Text(
                                session.summary!,
                                style: TextStyle(color: Colors.grey[700], fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteSession(session);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete, color: Colors.red),
                                title: Text('Delete Session'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _openSessionDetail(session),
                      ),
                    );
                  },
                ),
    );
  }
}

// Session Detail Page
class SessionDetailPage extends StatefulWidget {
  final SessionModel session;

  const SessionDetailPage({super.key, required this.session});

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  List<FileModel> _files = []; // TODO: Connect to backend
  bool _isLoading = false;
  bool _isGeneratingSummary = false;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _loadFiles() {
    // TODO: Load files from backend
    setState(() {
      _isLoading = true;
    });

    // Mock data
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _files = widget.session.fileNames.map((name) => FileModel(
            id: name,
            name: name,
            type: name.split('.').last.toUpperCase(),
            sizeMB: (1 + (name.length % 10)) * 0.5,
            uploadedAt: widget.session.createdAt,
            isProcessed: true,
          )).toList();
          _isLoading = false;
        });
      }
    });
  }

  void _addFile() {
    // TODO: Implement file picker and upload
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add file functionality not implemented yet')),
    );
  }

  void _regenerateSummary() {
    setState(() {
      _isGeneratingSummary = true;
    });

    // TODO: Call backend to regenerate summary
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isGeneratingSummary = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Summary regenerated successfully!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addFile,
            tooltip: 'Add File',
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary Section
          if (widget.session.summary != null) ...[
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _isGeneratingSummary ? null : _regenerateSummary,
                          icon: _isGeneratingSummary 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(_isGeneratingSummary ? 'Generating...' : 'Regenerate'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.session.summary!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Files Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Files',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addFile,
                        icon: const Icon(Icons.add),
                        label: const Text('Add File'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _files.length,
                          itemBuilder: (context, index) {
                            final file = _files[index];
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _getFileTypeColor(file.type),
                                  child: Text(
                                    file.type,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(file.name),
                                subtitle: Text(
                                  '${file.sizeMB.toStringAsFixed(1)} MB • ${_formatDate(file.uploadedAt)}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (file.isProcessed)
                                      const Icon(Icons.check_circle, color: Colors.green, size: 20)
                                    else
                                      const Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
                                    IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () {
                                        // TODO: Show file options
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'txt':
      case 'md':
        return Colors.blue;
      case 'doc':
      case 'docx':
        return Colors.indigo;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}