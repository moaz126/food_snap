import 'package:flutter/material.dart';
import 'package:food_snap/core/theme/app_palette.dart';
import 'package:food_snap/domain/entities/food_record.dart';
import 'package:food_snap/presentation/home/widgets/food_history_tile.dart';

class SlidableHistoryTile extends StatefulWidget {
  final FoodRecord record;
  final VoidCallback onTap;
  final VoidCallback onDeleteConfirmed;

  const SlidableHistoryTile({
    super.key,
    required this.record,
    required this.onTap,
    required this.onDeleteConfirmed,
  });

  @override
  State<SlidableHistoryTile> createState() => _SlidableHistoryTileState();
}

class _SlidableHistoryTileState extends State<SlidableHistoryTile>
    with SingleTickerProviderStateMixin {
  static const double _actionWidth = 72.0;

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      lowerBound: 0,
      upperBound: _actionWidth,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _controller.value =
        (_controller.value - details.delta.dx).clamp(0.0, _actionWidth);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_controller.value > _actionWidth * 0.4) {
      _controller.animateTo(_actionWidth, curve: Curves.easeOut);
    } else {
      _controller.animateTo(0, curve: Curves.easeOut);
    }
  }

  void _close() {
    _controller.animateTo(0, curve: Curves.easeOut);
  }

  Future<void> _onDeleteTap() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Scan?'),
        content: const Text('This scan will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Delete',
              style: TextStyle(color: ctx.appPalette.coral),
            ),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirmed == true) {
      widget.onDeleteConfirmed();
    } else {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Delete action background
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _onDeleteTap,
                    child: Container(
                      width: _actionWidth,
                      color: palette.coral,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Tile slides left
              Transform.translate(
                offset: Offset(-_controller.value, 0),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onHorizontalDragUpdate: _onHorizontalDragUpdate,
                  onHorizontalDragEnd: _onHorizontalDragEnd,
                  onTap: _controller.value > 1 ? _close : widget.onTap,
                  child: FoodHistoryTile(
                    record: widget.record,
                    onTap: _controller.value > 1 ? _close : widget.onTap,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
