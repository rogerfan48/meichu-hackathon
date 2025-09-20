import 'package:flutter/material.dart';

// Mock data models - TODO: Replace with actual models
class FlashcardModel {
  final String id;
  final String front;
  final String back;
  final String? imageUrl;
  final List<String> tags;
  final int likes;
  final int dislikes;

  FlashcardModel({
    required this.id,
    required this.front,
    required this.back,
    this.imageUrl,
    required this.tags,
    required this.likes,
    required this.dislikes,
  });
}

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  State<FlashcardPage> createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> with TickerProviderStateMixin {
  int _selectedTabIndex = 0;
  List<FlashcardModel> _allCards = []; // TODO: Connect to backend
  List<String> _availableTags = ['English', 'Math', 'Science', 'History']; // TODO: Connect to backend
  List<String> _selectedTags = [];

  // Game state
  bool _isGameMode = false;
  int _currentCardIndex = 0;
  bool _isCardFlipped = false;
  int _gameScore = 0;
  int _totalGameCards = 0;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFlashcards(); // TODO: Connect to backend
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadFlashcards() {
    // TODO: Load flashcards from backend
    setState(() {
      _allCards = [
        FlashcardModel(
          id: '1',
          front: 'Apple',
          back: '蘋果',
          tags: ['English'],
          likes: 5,
          dislikes: 1,
        ),
        FlashcardModel(
          id: '2',
          front: 'Dog',
          back: '狗',
          tags: ['English'],
          likes: 3,
          dislikes: 0,
        ),
        FlashcardModel(
          id: '3',
          front: '2 + 2 = ?',
          back: '4',
          tags: ['Math'],
          likes: 2,
          dislikes: 0,
        ),
      ];
    });
  }

  List<FlashcardModel> get _filteredCards {
    if (_selectedTags.isEmpty) return _allCards;
    return _allCards.where((card) => 
        card.tags.any((tag) => _selectedTags.contains(tag))
    ).toList();
  }

  void _startGame() {
    final gameCards = _filteredCards;
    if (gameCards.isEmpty) {
      _showSnackBar('No cards available for selected tags');
      return;
    }

    setState(() {
      _isGameMode = true;
      _currentCardIndex = 0;
      _isCardFlipped = false;
      _gameScore = 0;
      _totalGameCards = gameCards.length;
    });
  }

  void _endGame() {
    setState(() {
      _isGameMode = false;
    });
    _showSnackBar('Game finished! Score: $_gameScore/$_totalGameCards');
  }

  void _nextCard(bool isCorrect) {
    if (isCorrect) {
      _gameScore++;
    }
    
    // TODO: Record like/dislike for learning analytics

    if (_currentCardIndex < _filteredCards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _isCardFlipped = false;
      });
    } else {
      _endGame();
    }
  }

  void _flipCard() {
    setState(() {
      _isCardFlipped = !_isCardFlipped;
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showAddCardDialog() {
    String front = '';
    String back = '';
    List<String> selectedCardTags = [];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Card'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => front = value,
                decoration: const InputDecoration(
                  labelText: 'Front',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (value) => back = value,
                decoration: const InputDecoration(
                  labelText: 'Back',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Tags:'),
              Wrap(
                spacing: 8.0,
                children: _availableTags.map((tag) {
                  final isSelected = selectedCardTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (selected) {
                      setDialogState(() {
                        if (selected) {
                          selectedCardTags.add(tag);
                        } else {
                          selectedCardTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (front.isNotEmpty && back.isNotEmpty) {
                setState(() {
                  _allCards.add(FlashcardModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    front: front,
                    back: back,
                    tags: selectedCardTags,
                    likes: 0,
                    dislikes: 0,
                  ));
                });
                Navigator.pop(context);
                _showSnackBar('Card added successfully!');
                // TODO: Add card to backend
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteCard(FlashcardModel card) {
    setState(() {
      _allCards.removeWhere((c) => c.id == card.id);
    });
    _showSnackBar('Card deleted');
    // TODO: Delete card from backend
  }

  void _generateImage(FlashcardModel card) {
    // TODO: Implement AI image generation
    _showSnackBar('AI image generation not implemented yet');
  }

  Widget _buildCardManagement() {
    return Column(
      children: [
        // Add Card Button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _showAddCardDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add New Card'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
        
        // Cards List
        Expanded(
          child: _allCards.isEmpty
              ? const Center(
                  child: Text(
                    'No cards available.\nAdd some cards to get started!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: _allCards.length,
                  itemBuilder: (context, index) {
                    final card = _allCards[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        title: Text(card.front),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(card.back),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 4,
                              children: card.tags.map((tag) => Chip(
                                label: Text(tag, style: const TextStyle(fontSize: 10)),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              )).toList(),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit),
                                title: Text('Edit'),
                              ),
                            ),
                            if (card.imageUrl == null)
                              const PopupMenuItem(
                                value: 'generate_image',
                                child: ListTile(
                                  leading: Icon(Icons.auto_awesome),
                                  title: Text('Generate Image'),
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Delete'),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                // TODO: Implement edit card
                                _showSnackBar('Edit card not implemented yet');
                                break;
                              case 'generate_image':
                                _generateImage(card);
                                break;
                              case 'delete':
                                _deleteCard(card);
                                break;
                            }
                          },
                        ),
                        leading: card.imageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.network(
                                  card.imageUrl!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGameMode() {
    if (!_isGameMode) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.games, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Game Mode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select tags and start practicing!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Tag Selection
            const Text(
              'Select Tags:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: _availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton(
              onPressed: _startGame,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 48),
              ),
              child: const Text('Start Game'),
            ),
          ],
        ),
      );
    }

    // Game is active
    final gameCards = _filteredCards;
    if (_currentCardIndex >= gameCards.length) {
      return const Center(child: Text('No more cards'));
    }

    final currentCard = gameCards[_currentCardIndex];

    return Column(
      children: [
        // Progress bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('Score: $_gameScore/$_totalGameCards'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentCardIndex + 1) / _totalGameCards,
              ),
            ],
          ),
        ),
        
        // Card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: _flipCard,
              child: Card(
                elevation: 8,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: _isCardFlipped 
                          ? [Colors.green.shade100, Colors.green.shade50]
                          : [Colors.blue.shade100, Colors.blue.shade50],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (currentCard.imageUrl != null && !_isCardFlipped)
                        Image.network(
                          currentCard.imageUrl!,
                          height: 150,
                          fit: BoxFit.contain,
                        ),
                      const SizedBox(height: 24),
                      Text(
                        _isCardFlipped ? currentCard.back : currentCard.front,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isCardFlipped ? 'Tap to flip back' : 'Tap to reveal answer',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // Action buttons (only show when card is flipped)
        if (_isCardFlipped)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _nextCard(false),
                    icon: const Icon(Icons.thumb_down),
                    label: const Text('Incorrect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _nextCard(true),
                    icon: const Icon(Icons.thumb_up),
                    label: const Text('Correct'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
        // Voice recognition button (placeholder)
        if (_isCardFlipped)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                // TODO: Implement voice recognition
                _showSnackBar('Voice recognition not implemented yet');
              },
              child: const Icon(Icons.mic),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
        automaticallyImplyLeading: false,
        bottom: _isGameMode ? null : TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          tabs: const [
            Tab(text: 'Manage Cards', icon: Icon(Icons.view_list)),
            Tab(text: 'Game Mode', icon: Icon(Icons.games)),
          ],
        ),
        actions: _isGameMode ? [
          IconButton(
            onPressed: _endGame,
            icon: const Icon(Icons.close),
            tooltip: 'End Game',
          ),
        ] : null,
      ),
      body: _isGameMode 
          ? _buildGameMode()
          : _selectedTabIndex == 0 
              ? _buildCardManagement()
              : _buildGameMode(),
    );
  }
}