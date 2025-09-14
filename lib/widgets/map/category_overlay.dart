import 'package:flutter/material.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/models/filter_options.dart';

class CategoryOverlay extends StatefulWidget {
  final RenderBox buttonRenderBox;
  final VoidCallback onClose;
  final FilterOptions initialOptions;
  final Function(FilterOptions) onUpdate;

  const CategoryOverlay({
    Key? key,
    required this.buttonRenderBox,
    required this.onClose,
    required this.initialOptions,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<CategoryOverlay> createState() => _CategoryOverlayState();
}

class _CategoryOverlayState extends State<CategoryOverlay> {
  late FilterOptions _currentOptions;

  @override
  void initState() {
    super.initState();
    _currentOptions = widget.initialOptions.copyWith();
  }

  Widget _buildGenreRow(BuildContext context, GenreTags genre) {
    final tagInfo = genreTags[genre]!;
    final isSelected = _currentOptions.selectedGenres.contains(genre);

    return SizedBox(
      height: 34,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _currentOptions.selectedGenres.remove(genre);
            } else {
              _currentOptions.selectedGenres.add(genre);
            }
            widget.onUpdate(_currentOptions);
          });
        },
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: null, // onChanged 交給 InkWell 處理，避免重複觸發
              // 使用 VisualDensity.compact 來縮小 Checkbox 的預設空間
              visualDensity: VisualDensity.compact,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: tagInfo.color,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(tagInfo.title, style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.black,
              )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonPosition = widget.buttonRenderBox.localToGlobal(Offset.zero);
    final buttonSize = widget.buttonRenderBox.size;

    Widget filterPanel = Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(24),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentOptions.selectedGenres = Set.from(GenreTags.values);
                      widget.onUpdate(_currentOptions);
                    });
                  },
                  child: const Text("Select All"),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    setState(() {
                      _currentOptions.selectedGenres.clear();
                      widget.onUpdate(_currentOptions);
                    });
                  },
                  child: const Text("Clear All"),
                ),
              ],
            ),
            const Divider(height: 7, thickness: 1),
            Flexible(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: GenreTags.values.length,
                itemBuilder: (context, index) {
                  final genre = GenreTags.values[index];
                  return _buildGenreRow(context, genre);
                },
              ),
            ),
          ],
        ),
      ),
    );

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            child: Container(color: Colors.transparent),
          ),
        ),
        Positioned(
          top: buttonPosition.dy + buttonSize.height + 8,
          right: (MediaQuery.of(context).size.width * 0.05),
          width: 240,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: filterPanel,
          ),
        ),
      ],
    );
  }
}
