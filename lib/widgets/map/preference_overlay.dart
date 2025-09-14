import 'package:flutter/material.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/models/filter_options.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart'; // Add this import

class PreferenceOverlay extends StatefulWidget {
  final RenderBox buttonRenderBox;
  final VoidCallback onClose;
  final FilterOptions initialOptions;
  final Function(FilterOptions) onUpdate;

  const PreferenceOverlay({
    Key? key,
    required this.buttonRenderBox,
    required this.onClose,
    required this.initialOptions,
    required this.onUpdate,
  }) : super(key: key);

  @override
  State<PreferenceOverlay> createState() => _PreferenceOverlayState();
}

class _PreferenceOverlayState extends State<PreferenceOverlay> {
  late FilterOptions _currentOptions;

  @override
  void initState() {
    super.initState();
    _currentOptions = widget.initialOptions.copyWith();
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }

  Widget _buildVeganRow(BuildContext context, VeganTags veganTag) {
    final tagInfo = veganTags[veganTag]!;
    final isSelected = _currentOptions.selectedVeganTags.contains(veganTag);

    return SizedBox(
      height: 34,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              _currentOptions.selectedVeganTags.remove(veganTag);
            } else {
              _currentOptions.selectedVeganTags.add(veganTag);
            }
            widget.onUpdate(_currentOptions);
          });
        },
        child: Row(
          children: [
            Checkbox(
              value: isSelected,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: null,
              visualDensity: VisualDensity.compact,
            ),
            // 將圖標和文字並排
            SizedBox(height: 22, width: 22, child: tagInfo.image),
            const SizedBox(width: 8),
            Text(tagInfo.title, style: Theme.of(context).textTheme.bodyMedium),
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
        width: 240,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSectionHeader(context, 'Opening Hours'),
              SizedBox(
                height: 32,
                child: ToggleButtons(
                  isSelected: [_currentOptions.isOpenNow, !_currentOptions.isOpenNow],
                  onPressed: (index) {
                    setState(() {
                      _currentOptions.isOpenNow = (index == 0);
                      widget.onUpdate(_currentOptions);
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  color: Theme.of(context).colorScheme.onSurface,
                  selectedColor: Theme.of(context).colorScheme.onPrimary,
                  fillColor: Theme.of(context).colorScheme.primary,
                  borderColor: Theme.of(context).colorScheme.outline,
                  selectedBorderColor: Theme.of(context).colorScheme.primary,
                  constraints: const BoxConstraints(minHeight: 28.0, minWidth: 90.0),
                  children: const [Text('Open Now'), Text('Not Limited')],
                ),
              ),
              _buildSectionHeader(context, 'Price'),
              SizedBox(
                height: 32,
                child: RangeSlider(
                  values: _currentOptions.priceRange,
                  min: 0,
                  max: 5,
                  divisions: 5,
                  labels: RangeLabels(
                    '\$' * _currentOptions.priceRange.start.round(),
                    '\$' * _currentOptions.priceRange.end.round(),
                  ),
                  activeColor: Theme.of(context).colorScheme.primary,
                  inactiveColor: Theme.of(context).colorScheme.surfaceDim,
                  onChanged: (values) {
                    setState(() {
                      _currentOptions.priceRange = values;
                      widget.onUpdate(_currentOptions);
                    });
                  },
                ),
              ),
              _buildSectionHeader(context, 'Rating'),
              SfSliderTheme(
                data: SfSliderThemeData(
                  thumbColor: Theme.of(context).colorScheme.primary,
                  activeTrackColor: Theme.of(context).colorScheme.surfaceDim, // Track from 0 to pointer
                  inactiveTrackColor: Theme.of(context).colorScheme.primary, // Track from pointer to 5
                  // You might need to set other properties like active/inactive tick and label colors
                  // if their defaults are not suitable with these changes.
                  // For example:
                  // activeTickColor: Theme.of(context).colorScheme.surfaceDim,
                  // inactiveTickColor: Theme.of(context).colorScheme.primary,
                  // activeLabelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87)),
                  // inactiveLabelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.87)),
                  activeTrackHeight: 4,
                  inactiveTrackHeight: 6,
                ),
                child: SfSlider(
                  value: _currentOptions.minRating,
                  min: 0,
                  max: 5,
                  interval: 1,
                  showTicks: true,
                  showLabels: true,
                  // activeColor and inactiveColor are now controlled by SfSliderThemeData
                  onChanged: (value) {
                    setState(() {
                      _currentOptions.minRating = value;
                      widget.onUpdate(_currentOptions);
                    });
                  },
                ),
              ),
              _buildSectionHeader(context, 'Vegan Options'),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: VeganTags.values.length,
                itemBuilder: (context, index) {
                  final veganTag = VeganTags.values[index];
                  return _buildVeganRow(context, veganTag);
                },
              ),
            ],
          ),
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
          right: (MediaQuery.of(context).size.width - buttonPosition.dx - buttonSize.width),
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
