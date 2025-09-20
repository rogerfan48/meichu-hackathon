import 'package:flutter/material.dart';

// TODO: Add file_picker package to pubspec.yaml
// For now, using mock file representation
class MockFile {
  final String name;
  final String extension;
  final int size;

  MockFile({required this.name, required this.extension, required this.size});
}

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> with TickerProviderStateMixin {
  List<MockFile> _selectedFiles = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _currentSessionName = '';
  List<String> _sessions = []; // TODO: Connect to backend
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _loadSessions(); // TODO: Connect to backend
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadSessions() {
    // TODO: Load sessions from backend
    setState(() {
      _sessions = ['Study Session 1', 'Work Documents', 'Research Papers'];
    });
  }

  Future<void> _pickFiles() async {
    // TODO: Implement actual file picking with file_picker package
    // For now, adding mock files for UI demonstration
    setState(() {
      _selectedFiles.addAll([
        MockFile(name: 'document.pdf', extension: 'pdf', size: 2048000),
        MockFile(name: 'notes.txt', extension: 'txt', size: 1024),
      ]);
    });
  }

  Future<void> _takePhoto() async {
    // TODO: Implement camera capture with image_picker package
    // For now, adding mock photo file for UI demonstration
    setState(() {
      _selectedFiles.add(
        MockFile(
          name: 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg', 
          extension: 'jpg', 
          size: 1536000
        ),
      );
    });
    _showSnackBar('Photo captured successfully!');
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) {
      _showSnackBar('Please select files first');
      return;
    }

    if (_currentSessionName.isEmpty) {
      _showSnackBar('Please create or select a session');
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // TODO: Implement actual upload logic
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _uploadProgress = (i + 1) / 10;
      });
    }

    setState(() {
      _isUploading = false;
      _selectedFiles.clear();
    });

    _showSnackBar('Files uploaded successfully!');
    // TODO: Generate summary and add to flashcards
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showCreateSessionDialog() {
    String newSessionName = '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Session'),
        content: TextField(
          onChanged: (value) => newSessionName = value,
          decoration: const InputDecoration(
            hintText: 'Enter session name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newSessionName.trim().isNotEmpty) {
                setState(() {
                  _sessions.add(newSessionName.trim());
                  _currentSessionName = newSessionName.trim();
                });
                Navigator.pop(context);
                // TODO: Create session in backend
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return Card(
      child: InkWell(
        onTap: _isUploading ? null : _pickFiles,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _isUploading
                  ? AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _animationController.value * 2.0 * 3.14159,
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            size: 64,
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      },
                    )
                  : Icon(
                      Icons.folder_open,
                      size: 64,
                      color: Colors.grey,
                    ),
              const SizedBox(height: 16),
              Text(
                _isUploading 
                    ? 'Uploading...' 
                    : 'Select Files to Upload',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Supported: PDF, DOC, DOCX, TXT, PNG, JPG',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              if (!_isUploading)
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Choose Files'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              if (_isUploading) ...[
                const SizedBox(height: 16),
                LinearProgressIndicator(value: _uploadProgress),
                const SizedBox(height: 8),
                Text('${(_uploadProgress * 100).toInt()}%'),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add more files button
        Card(
          child: ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add More Files'),
            onTap: _isUploading ? null : _pickFiles,
            tileColor: Colors.blue.shade50,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Selected files header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Selected Files (${_selectedFiles.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: _isUploading ? null : () {
                setState(() {
                  _selectedFiles.clear();
                });
              },
              child: const Text('Clear All'),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Files list
        Expanded(
          child: Card(
            child: _selectedFiles.isEmpty 
                ? const Center(
                    child: Text(
                      'No files selected',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _selectedFiles[index];
                      return ListTile(
                        leading: Icon(_getFileIcon(file.extension)),
                        title: Text(
                          file.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('${(file.size / 1024).toStringAsFixed(1)} KB'),
                        trailing: IconButton(
                          onPressed: _isUploading ? null : () => _removeFile(index),
                          icon: const Icon(Icons.close),
                          tooltip: 'Remove file',
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Files'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _showCreateSessionDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Create New Session',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Session Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Session',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _currentSessionName.isEmpty ? null : _currentSessionName,
                      hint: const Text('Choose a session'),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: _sessions.map((session) {
                        return DropdownMenuItem<String>(
                          value: session,
                          child: Text(session),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _currentSessionName = value ?? '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Take Photo Button
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _takePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Main content area with scrollable content
            Expanded(
              child: _selectedFiles.isEmpty ? _buildUploadArea() : _buildFileManagement(),
            ),

            // Upload Button (always at bottom)
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadFiles,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isUploading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Uploading...'),
                      ],
                    )
                  : const Text(
                      'Upload & Generate Summary',
                      style: TextStyle(fontSize: 16),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}