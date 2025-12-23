import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class JourneyAi extends StatefulWidget {
  const JourneyAi({super.key});

  @override
  State<JourneyAi> createState() => _JourneyAiState();
}

class _JourneyAiState extends State<JourneyAi> {
  final TextEditingController _promptController = TextEditingController();
  final AiService _aiService = AiService();
  bool _isLoading = false;
  bool _isLoadingHistory = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadConversationHistory();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversationHistory() async {
    try {
      await _aiService.loadConversationHistory();
      setState(() {
        _isLoadingHistory = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load chat history: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    final userMessage = ConversationMessage(
      content: message,
      role: 'user',
      timestamp: DateTime.now(),
    );

    // Add user message to service history and update UI
    _aiService.conversationHistory.add(userMessage);
    setState(() {
      _isLoading = true;
    });

    _promptController.clear();
    _scrollToBottom();

    try {
      // Send message to AI service
      final response = await _aiService.sendMessage(message);

      final assistantMessage = ConversationMessage(
        content: response,
        role: 'assistant',
        timestamp: DateTime.now(),
      );

      // Add AI response to service history and update UI
      _aiService.conversationHistory.add(assistantMessage);
      setState(() {
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _aiService.conversationHistory.add(ConversationMessage(
          content: 'Error: ${e.toString()}',
          role: 'assistant',
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
  }

  Future<void> _clearChatHistory() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text(
            'Clear Chat History',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to clear all messages? This action cannot be undone.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.amber)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _aiService.deleteAllConversationsFromBackend();
                  if (mounted) {
                    setState(() {
                      // conversationHistory is cleared by the service
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chat history cleared'),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error clearing history: ${e.toString()}'),
                      ),
                    );
                  }
                }
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'AI Trainer',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          if (_aiService.conversationHistory.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.amber),
              onPressed: _clearChatHistory,
              tooltip: 'Clear chat history',
            ),
        ],
      ),
      body: _isLoadingHistory
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
              ),
            )
          : Column(
              children: [
                // Messages list
                Expanded(
                  child: _aiService.conversationHistory.isEmpty
                      ? Center(
                          child: Text(
                            'Start a conversation with your AI trainer',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _aiService.conversationHistory.length,
                          itemBuilder: (context, index) {
                            final message = _aiService.conversationHistory[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildMessageBubble(message),
                            );
                          },
                        ),
                ),
                // Loading indicator
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Color(0xFF1A1A1A)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'AI is thinking...',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                // Input field
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    border: Border(
                      top: BorderSide(color: Colors.grey[700]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promptController,
                          enabled: !_isLoading,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Ask your trainer...',
                            hintStyle: TextStyle(color: Colors.grey[600]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Colors.grey[700]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.amber),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onSubmitted: _isLoading
                              ? null
                              : (value) => _sendMessage(value),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _isLoading
                            ? null
                            : () => _sendMessage(_promptController.text),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _isLoading ? Colors.grey[700] : Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.send,
                            color: _isLoading
                                ? Colors.grey[600]
                                : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildMessageBubble(ConversationMessage message) {
    return Align(
      alignment: message.role == 'user' ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.role == 'user' ? Colors.amber : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: message.role == 'user'
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: message.role == 'user' ? const Color(0xFF1A1A1A) : Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: message.role == 'user'
                    ? const Color(0xFF1A1A1A).withOpacity(0.7)
                    : Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }
}