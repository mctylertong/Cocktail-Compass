import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../viewmodels/shopping_list_viewmodel.dart';
import '../config/app_theme.dart';

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen({Key? key}) : super(key: key);

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShoppingListViewModel>().initialize();
    });
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
        title: Text(
          'Shopping List',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<ShoppingListViewModel>(
            builder: (context, vm, child) {
              if (vm.isEmpty) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                ),
                color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
                onSelected: (value) => _handleMenuAction(context, value, vm),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.copy_rounded,
                          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text('Copy to Clipboard',
                          style: TextStyle(
                            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'check_all',
                    child: Row(
                      children: [
                        Icon(Icons.check_box_rounded,
                          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text('Check All',
                          style: TextStyle(
                            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'uncheck_all',
                    child: Row(
                      children: [
                        Icon(Icons.check_box_outline_blank_rounded,
                          color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text('Uncheck All',
                          style: TextStyle(
                            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (vm.checkedCount > 0)
                    PopupMenuItem(
                      value: 'remove_checked',
                      child: Row(
                        children: [
                          Icon(Icons.delete_sweep_rounded,
                            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text('Remove Checked',
                            style: TextStyle(
                              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'clear_all',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever_rounded, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        const Text('Clear All', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<ShoppingListViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGold),
            );
          }

          if (vm.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.textMuted.withValues(alpha: 0.1)
                          : AppTheme.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.shopping_cart_outlined,
                      size: 56,
                      color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your shopping list is empty',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add ingredients from drink details',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? AppTheme.textMuted.withValues(alpha: 0.15)
                          : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${vm.checkedCount} of ${vm.totalCount} items',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
                      ),
                    ),
                    if (vm.totalCount > 0)
                      SizedBox(
                        width: 100,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: vm.checkedCount / vm.totalCount,
                            backgroundColor: isDark
                                ? AppTheme.textMuted.withValues(alpha: 0.2)
                                : AppTheme.lightSurfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
                            minHeight: 6,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Items list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // Unchecked items
                    if (vm.uncheckedItems.isNotEmpty) ...[
                      _buildSectionHeader(context, 'To Buy', vm.uncheckedCount, isDark),
                      ...vm.uncheckedItems.map((item) => _buildItemTile(context, item, vm, isDark)),
                    ],

                    // Checked items
                    if (vm.checkedItems.isNotEmpty) ...[
                      _buildSectionHeader(context, 'Completed', vm.checkedCount, isDark),
                      ...vm.checkedItems.map((item) => _buildItemTile(context, item, vm, isDark)),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        backgroundColor: AppTheme.primaryGold,
        foregroundColor: AppTheme.backgroundDark,
        elevation: 2,
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 12),
      child: Row(
        children: [
          Icon(
            title == 'To Buy' ? Icons.shopping_bag_outlined : Icons.check_circle_outline_rounded,
            size: 18,
            color: AppTheme.primaryGold,
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, ShoppingItem item, ShoppingListViewModel vm, bool isDark) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        vm.removeItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} removed'),
            backgroundColor: isDark ? AppTheme.surfaceLight : AppTheme.lightTextPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'Undo',
              textColor: AppTheme.primaryGold,
              onPressed: () {
                vm.addItem(item.name, fromDrink: item.fromDrink);
              },
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => vm.toggleItem(item.id),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? AppTheme.textMuted.withValues(alpha: 0.15)
                      : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  // Checkbox
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: item.isChecked
                          ? AppTheme.primaryGold
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: item.isChecked
                            ? AppTheme.primaryGold
                            : (isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary),
                        width: 2,
                      ),
                    ),
                    child: item.isChecked
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: AppTheme.backgroundDark,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration: item.isChecked ? TextDecoration.lineThrough : null,
                            color: item.isChecked
                                ? (isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary)
                                : (isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary),
                          ),
                        ),
                        if (item.fromDrink != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            'From: ${item.fromDrink}',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Delete button
                  GestureDetector(
                    onTap: () => vm.removeItem(item.id),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, String action, ShoppingListViewModel vm) {
    switch (action) {
      case 'share':
        Clipboard.setData(ClipboardData(text: vm.toShareableText()));
        if (context.mounted) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Shopping list copied to clipboard'),
              backgroundColor: isDark ? AppTheme.surfaceLight : AppTheme.lightTextPrimary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
        break;
      case 'check_all':
        vm.checkAll();
        break;
      case 'uncheck_all':
        vm.uncheckAll();
        break;
      case 'remove_checked':
        _showConfirmDialog(
          context,
          'Remove Checked Items',
          'Are you sure you want to remove all checked items?',
          () => vm.removeCheckedItems(),
        );
        break;
      case 'clear_all':
        _showConfirmDialog(
          context,
          'Clear Shopping List',
          'Are you sure you want to remove all items from your shopping list?',
          () => vm.clearAll(),
        );
        break;
    }
  }

  void _showConfirmDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          message,
          style: TextStyle(
            color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.surfaceDark : AppTheme.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Add Item',
          style: TextStyle(
            color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.backgroundDark
                : AppTheme.lightBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppTheme.textMuted.withValues(alpha: 0.2)
                  : AppTheme.lightTextSecondary.withValues(alpha: 0.1),
            ),
          ),
          child: TextField(
            controller: controller,
            autofocus: true,
            style: TextStyle(
              color: isDark ? AppTheme.textPrimary : AppTheme.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Enter ingredient name',
              hintStyle: TextStyle(
                color: isDark ? AppTheme.textMuted : AppTheme.lightTextSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                context.read<ShoppingListViewModel>().addItem(value);
                Navigator.pop(context);
              }
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppTheme.textSecondary : AppTheme.lightTextSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<ShoppingListViewModel>().addItem(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(
              'Add',
              style: TextStyle(
                color: AppTheme.primaryGold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
