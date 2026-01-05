// ignore_for_file: deprecated_member_use, dead_code

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:bitrack_mobile_flutter/base/res/media.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/base/widgets/plate_input_formatter.dart';

class PlateSearchBar extends StatefulWidget {
  final String? value;
  final ValueChanged<String>? onChanged;

  final List<String>? suggestionPlates;
  final int maxSuggestions;

  final VoidCallback? onTapFilter;

  final String hintText;

  const PlateSearchBar({
    super.key,
    this.value,
    this.onChanged,
    this.suggestionPlates,
    this.maxSuggestions = 10,
    this.onTapFilter,
    this.hintText = 'Search License Plate...',
  });

  @override
  State<PlateSearchBar> createState() => _PlateSearchBarState();
}

class _PlateSearchBarState extends State<PlateSearchBar> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  Timer? _debounce;
  List<String> _suggestions = const [];

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  final GlobalKey _fieldKey = GlobalKey();

  bool get _isOverlayShown => _overlayEntry != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
    _focusNode.addListener(_handleFocusChange);

    _recomputeSuggestions(_controller.text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowOverlay();
    });
  }

  @override
  void didUpdateWidget(covariant PlateSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newText = widget.value ?? '';
    if (oldWidget.value != widget.value && newText != _controller.text) {
      _controller.value = _controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
        composing: TextRange.empty,
      );
      _recomputeSuggestions(newText);
      _maybeShowOverlay(forceRefresh: true);
    }

    if (!identical(oldWidget.suggestionPlates, widget.suggestionPlates)) {
      _recomputeSuggestions(_controller.text);
      _maybeShowOverlay(forceRefresh: true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus) {
      _removeOverlay();
      return;
    }

    _maybeShowOverlay();
  }

  String _normalize(String s) => s.toUpperCase().replaceAll('-', '').trim();

  void _recomputeSuggestions(String value) {
    final plates = widget.suggestionPlates;
    if (plates == null || plates.isEmpty) {
      _suggestions = const [];
      return;
    }

    final q = _normalize(value);

    if (q.isEmpty) {
      _suggestions = plates.take(widget.maxSuggestions).toList();
      return;
    }

    final out = <String>[];
    for (final p in plates) {
      if (_normalize(p).contains(q)) {
        out.add(p);
        if (out.length == widget.maxSuggestions) break;
      }
    }
    _suggestions = out;
  }

  void _onChanged(String value) {
    widget.onChanged?.call(value);

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;

      setState(() {
        _recomputeSuggestions(value);
      });

      _maybeShowOverlay(forceRefresh: true);
    });
  }

  void _selectPlate(String plate) {
    _controller.value = _controller.value.copyWith(
      text: plate,
      selection: TextSelection.collapsed(offset: plate.length),
      composing: TextRange.empty,
    );

    widget.onChanged?.call(plate);

    _removeOverlay();
    _focusNode.unfocus();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    setState(() {
      _suggestions = const [];
    });
    _removeOverlay();
  }

  void _maybeShowOverlay({bool forceRefresh = false}) {
    final hasFocus = _focusNode.hasFocus;
    final hasSuggestions = _suggestions.isNotEmpty;

    if (!(hasFocus && hasSuggestions)) {
      _removeOverlay();
      return;
    }

    if (_isOverlayShown && !forceRefresh) return;

    if (_isOverlayShown && forceRefresh) {
      _overlayEntry?.markNeedsBuild();
      return;
    }

    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        final box = _fieldKey.currentContext?.findRenderObject() as RenderBox?;
        final size = box?.size ?? const Size(300, 48);

        final maxHeight = MediaQuery.of(context).size.height * 0.45;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: const SizedBox.expand(),
              ),
            ),

            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 8),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: size.width,
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  decoration: BoxDecoration(
                    color: AppStyles.whiteColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey.shade200,
                      ),
                      itemBuilder: (context, index) {
                        final plate = _suggestions[index];
                        return InkWell(
                          onTap: () => _selectPlate(plate),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: Text(
                              plate,
                              style: AppStyles.textSm.copyWith(
                                color: AppStyles.blackColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final showFilterButton = widget.onTapFilter != null;
    final showFilterButton = false;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                final hasText = value.text.isNotEmpty;

                return Container(
                  key: _fieldKey,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: const <TextInputFormatter>[
                      PlateInputFormatter(),
                    ],
                    onChanged: _onChanged,
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(10),
                        child: SvgPicture.asset(AppMedia.searchIcon),
                      ),
                      suffixIcon: hasText
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: _clear,
                            )
                          : null,
                      hintText: widget.hintText,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      filled: true,
                      fillColor: AppStyles.whiteColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (showFilterButton) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                _removeOverlay();
                widget.onTapFilter?.call();
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: AppStyles.whiteColor,
                  border: Border.all(
                    width: 2,
                    color: AppStyles.borderLightGray,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7),
                  child: SvgPicture.asset(AppMedia.filterIcon),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
