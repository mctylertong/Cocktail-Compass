import 'package:flutter/material.dart';

/// A reusable pagination controls widget
class PaginationControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final String itemsInfo; // e.g., "1-10 of 25"
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final Function(int page)? onPageSelected;
  final bool showPageNumbers;
  final bool compact;

  const PaginationControls({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsInfo,
    this.onPreviousPage,
    this.onNextPage,
    this.onPageSelected,
    this.showPageNumbers = true,
    this.compact = false,
  }) : super(key: key);

  bool get hasPreviousPage => currentPage > 1;
  bool get hasNextPage => currentPage < totalPages;

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();

    if (compact) {
      return _buildCompactControls(context);
    }

    return _buildFullControls(context);
  }

  Widget _buildCompactControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            itemsInfo,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 20),
                onPressed: hasPreviousPage ? onPreviousPage : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Previous page',
              ),
              Text(
                '$currentPage / $totalPages',
                style: const TextStyle(fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, size: 20),
                onPressed: hasNextPage ? onNextPage : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'Next page',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Items info
          Text(
            itemsInfo,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),

          // Page controls
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Previous button
              _buildNavButton(
                icon: Icons.chevron_left,
                onPressed: hasPreviousPage ? onPreviousPage : null,
                tooltip: 'Previous page',
              ),

              // Page numbers
              if (showPageNumbers && totalPages <= 7)
                ..._buildPageNumbers()
              else if (showPageNumbers)
                ..._buildCondensedPageNumbers(),

              // Next button
              _buildNavButton(
                icon: Icons.chevron_right,
                onPressed: hasNextPage ? onNextPage : null,
                tooltip: 'Next page',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      tooltip: tooltip,
      splashRadius: 20,
      color: onPressed != null ? Colors.grey[800] : Colors.grey[400],
    );
  }

  List<Widget> _buildPageNumbers() {
    return List.generate(totalPages, (index) {
      final page = index + 1;
      final isCurrentPage = page == currentPage;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: InkWell(
          onTap: isCurrentPage ? null : () => onPageSelected?.call(page),
          borderRadius: BorderRadius.circular(4),
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isCurrentPage ? Colors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$page',
              style: TextStyle(
                color: isCurrentPage ? Colors.white : Colors.grey[700],
                fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    });
  }

  List<Widget> _buildCondensedPageNumbers() {
    final List<Widget> widgets = [];
    final List<int> pagesToShow = _getPageNumbersToShow();

    int? previousPage;
    for (final page in pagesToShow) {
      // Add ellipsis if there's a gap
      if (previousPage != null && page - previousPage > 1) {
        widgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text('...'),
          ),
        );
      }

      final isCurrentPage = page == currentPage;
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: InkWell(
            onTap: isCurrentPage ? null : () => onPageSelected?.call(page),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrentPage ? Colors.green : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '$page',
                style: TextStyle(
                  color: isCurrentPage ? Colors.white : Colors.grey[700],
                  fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );

      previousPage = page;
    }

    return widgets;
  }

  List<int> _getPageNumbersToShow() {
    final Set<int> pages = {};

    // Always show first and last page
    pages.add(1);
    pages.add(totalPages);

    // Show current page and neighbors
    if (currentPage > 1) pages.add(currentPage - 1);
    pages.add(currentPage);
    if (currentPage < totalPages) pages.add(currentPage + 1);

    // If close to start, show more from start
    if (currentPage <= 3) {
      for (int i = 1; i <= 4 && i <= totalPages; i++) {
        pages.add(i);
      }
    }

    // If close to end, show more from end
    if (currentPage >= totalPages - 2) {
      for (int i = totalPages; i >= totalPages - 3 && i >= 1; i--) {
        pages.add(i);
      }
    }

    return pages.toList()..sort();
  }
}

/// A simple page size selector dropdown
class PageSizeSelector extends StatelessWidget {
  final int currentPageSize;
  final List<int> options;
  final ValueChanged<int> onChanged;

  const PageSizeSelector({
    Key? key,
    required this.currentPageSize,
    this.options = const [5, 10, 20, 50],
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Show: ',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        DropdownButton<int>(
          value: currentPageSize,
          underline: const SizedBox.shrink(),
          items: options.map((size) {
            return DropdownMenuItem<int>(
              value: size,
              child: Text('$size'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}
