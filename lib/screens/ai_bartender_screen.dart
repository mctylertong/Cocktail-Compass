import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ai_bartender_viewmodel.dart';
import '../config/app_theme.dart';

class AIBartenderScreen extends StatefulWidget {
  const AIBartenderScreen({Key? key}) : super(key: key);

  @override
  State<AIBartenderScreen> createState() => _AIBartenderScreenState();
}

class _AIBartenderScreenState extends State<AIBartenderScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AIBartenderViewModel>().initialize();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    context.read<AIBartenderViewModel>().sendMessage(message);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.accentEmerald,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'AI Bartender',
              style: TextStyle(
                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
            ),
            tooltip: 'New Conversation',
            onPressed: () {
              context.read<AIBartenderViewModel>().startNewConversation();
            },
          ),
        ],
      ),
      body: Consumer<AIBartenderViewModel>(
        builder: (context, vm, child) {
          if (!vm.isConfigured) {
            return _buildSetupPrompt(context, isDark);
          }

          return Column(
            children: [
              // Quick suggestions
              _buildQuickSuggestions(context, vm, isDark),

              // Messages list
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  itemCount: vm.messages.length + (vm.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == vm.messages.length && vm.isLoading) {
                      return _buildTypingIndicator(context, isDark);
                    }
                    return _buildMessageBubble(context, vm.messages[index], isDark);
                  },
                ),
              ),

              // Input area
              _buildInputArea(context, vm, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSetupPrompt(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                size: 64,
                color: AppTheme.error.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'AI Bartender Unavailable',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'The AI Bartender service is currently unavailable.\nPlease try again later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryGold,
                side: BorderSide(color: AppTheme.primaryGold.withValues(alpha: 0.5)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSuggestions(BuildContext context, AIBartenderViewModel vm, bool isDark) {
    if (vm.isLoading || vm.messages.length > 2) {
      return const SizedBox.shrink();
    }

    final suggestions = [
      {'label': 'Refreshing', 'type': 'refreshing', 'icon': Icons.ac_unit_rounded},
      {'label': 'Classic', 'type': 'classic', 'icon': Icons.star_rounded},
      {'label': 'Party', 'type': 'party', 'icon': Icons.celebration_rounded},
      {'label': 'Romantic', 'type': 'romantic', 'icon': Icons.favorite_rounded},
      {'label': 'Mocktail', 'type': 'mocktail', 'icon': Icons.local_cafe_rounded},
      {'label': 'Surprise', 'type': 'adventurous', 'icon': Icons.casino_rounded},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'QUICK SUGGESTIONS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
                color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: suggestions.map((s) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => vm.getQuickRecommendation(s['type'] as String),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.textMuted.withValues(alpha: 0.2)
                                : AppTheme.lightTextSecondary.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              s['icon'] as IconData,
                              size: 16,
                              color: AppTheme.primaryGold,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              s['label'] as String,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, ChatMessage message, bool isDark) {
    final isUser = message.role == MessageRole.user;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.accentEmerald.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: AppTheme.accentEmerald,
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.primaryGold
                    : message.isError
                        ? AppTheme.error.withValues(alpha: 0.1)
                        : (isDark ? AppTheme.surfaceDark : AppTheme.lightSurface),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                  bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: message.isError
                            ? AppTheme.error.withValues(alpha: 0.3)
                            : (isDark
                                ? AppTheme.textMuted.withValues(alpha: 0.2)
                                : AppTheme.lightTextSecondary.withValues(alpha: 0.1)),
                      ),
              ),
              child: SelectableText(
                message.content,
                style: TextStyle(
                  color: isUser
                      ? AppTheme.backgroundDark
                      : message.isError
                          ? AppTheme.error
                          : (isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 10),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.person_rounded,
                size: 18,
                color: AppTheme.primaryGold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.accentEmerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.smart_toy_rounded,
              size: 18,
              color: AppTheme.accentEmerald,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
              border: Border.all(
                color: isDark
                    ? AppTheme.textMuted.withValues(alpha: 0.2)
                    : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, isDark),
                const SizedBox(width: 6),
                _buildDot(1, isDark),
                const SizedBox(width: 6),
                _buildDot(2, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.primaryGold.withValues(alpha: 0.3 + (0.5 * (1 - (value - value.floor())))),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputArea(BuildContext context, AIBartenderViewModel vm, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundMedium : AppTheme.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppTheme.textMuted.withValues(alpha: 0.2)
                : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark
                      ? AppTheme.textMuted.withValues(alpha: 0.2)
                      : AppTheme.lightTextSecondary.withValues(alpha: 0.15),
                ),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                style: TextStyle(
                  color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask the bartender...',
                  hintStyle: TextStyle(
                    color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
                enabled: !vm.isLoading,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: vm.isLoading
                ? AppTheme.primaryGold.withValues(alpha: 0.5)
                : AppTheme.primaryGold,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: vm.isLoading ? null : _sendMessage,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.all(14),
                child: Icon(
                  Icons.send_rounded,
                  color: AppTheme.backgroundDark,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
