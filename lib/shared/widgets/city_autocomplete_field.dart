import 'dart:async';
import 'package:flutter/material.dart';
import 'package:savarii/core/services/city_geolocation_service.dart';
import 'package:savarii/core/theme/app_colors.dart';
import 'package:savarii/core/theme/app_text_styles.dart';

/// A reusable city autocomplete input field with district + state disambiguation.
///
/// Uses Nominatim (OSM) to cover every Indian city, town, village, and hamlet.
/// Shows suggestions as: "City" (bold) + "District, State" (caption).
/// Emits [CitySuggestion] with canonical "City, District, State" on selection.
class CityAutocompleteField extends StatefulWidget {
  final String label;
  final String hint;
  final CitySuggestion? selectedCity;
  final ValueChanged<CitySuggestion> onSelected;
  final VoidCallback onCleared;
  final IconData prefixIcon;

  const CityAutocompleteField({
    super.key,
    required this.label,
    required this.hint,
    required this.selectedCity,
    required this.onSelected,
    required this.onCleared,
    this.prefixIcon = Icons.location_on_outlined,
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<CitySuggestion> _suggestions = [];
  bool _isLoading = false;
  bool _isFocused = false;
  // Guard: prevents re-fetch when setting text programmatically
  bool _isSelecting = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Pre-fill if already selected (e.g., edit mode)
    if (widget.selectedCity != null) {
      _textController.text = widget.selectedCity!.fullName;
    }
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(() {
      if (mounted) setState(() => _isFocused = _focusNode.hasFocus);
      // Dismiss dropdown when focus is lost
      if (!_focusNode.hasFocus && mounted) {
        setState(() => _suggestions = []);
      }
    });
  }

  @override
  void didUpdateWidget(CityAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When selectedCity changes externally (e.g., swap locations)
    if (widget.selectedCity != oldWidget.selectedCity) {
      _isSelecting = true;
      _textController.text = widget.selectedCity?.fullName ?? '';
      if (mounted) setState(() => _suggestions = []);
      Future.microtask(() => _isSelecting = false);
    }
  }

  void _onTextChanged() {
    if (_isSelecting) return;
    final text = _textController.text;
    // If user edits after selecting, clear the bound selection
    if (widget.selectedCity != null && text != widget.selectedCity!.fullName) {
      widget.onCleared();
    }
    _debounce?.cancel();
    if (text.trim().length < 2) {
      if (mounted) setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      return;
    }
    // Show loading immediately so user sees feedback
    if (mounted) setState(() => _isLoading = true);
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(text);
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.trim().length < 2) {
      if (mounted) setState(() { _suggestions = []; _isLoading = false; });
      return;
    }
    try {
      final results = await CityGeolocationService.fetchCitySuggestions(query);
      if (mounted) setState(() {
        _suggestions = results;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() { _suggestions = []; _isLoading = false; });
    }
  }

  void _selectSuggestion(CitySuggestion suggestion) {
    _isSelecting = true;
    _textController.text = suggestion.fullName;
    if (mounted) setState(() { _suggestions = []; _isLoading = false; });
    _focusNode.unfocus();
    widget.onSelected(suggestion);
    Future.microtask(() => _isSelecting = false);
  }

  void _clearSelection() {
    _isSelecting = true;
    _textController.clear();
    if (mounted) setState(() { _suggestions = []; _isLoading = false; });
    widget.onCleared();
    Future.microtask(() {
      _isSelecting = false;
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ─────────────────────────────────────────────────────────
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // ── Text input ────────────────────────────────────────────────────
        AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused
                  ? AppColors.primaryAccent.withOpacity(0.45)
                  : AppColors.secondaryGreyBlue.withOpacity(0.15),
              width: _isFocused ? 1.5 : 1.0,
            ),
          ),
          child: TextField(
            controller: _textController,
            focusNode: _focusNode,
            style: AppTextStyles.bodyMedium,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.secondaryGreyBlue.withOpacity(0.5),
              ),
              prefixIcon: Icon(
                widget.prefixIcon,
                color: AppColors.primaryAccent,
                size: 20,
              ),
              suffixIcon: _buildSuffixIcon(),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          ),
        ),

        // ── Suggestion dropdown ───────────────────────────────────────────
        if (_isLoading || _suggestions.isNotEmpty)
          _buildDropdown(),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primaryAccent,
          ),
        ),
      );
    }
    if (_textController.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.close,
            size: 18, color: AppColors.secondaryGreyBlue),
        onPressed: _clearSelection,
        splashRadius: 18,
      );
    }
    return null;
  }

  Widget _buildDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 240),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: AppColors.secondaryGreyBlue.withOpacity(0.1),
        ),
      ),
      child: _isLoading && _suggestions.isEmpty
          // ── Loading spinner ────────────────────────────────────────────
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primaryAccent,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Searching locations…',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondaryGreyBlue,
                    ),
                  ),
                ],
              ),
            )
          // ── Results list ───────────────────────────────────────────────
          : ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: AppColors.secondaryGreyBlue.withOpacity(0.08),
              ),
              itemBuilder: (context, index) {
                final s = _suggestions[index];
                // Subtitle shows "District, State" — disambiguates same-named villages
                final subtitle = [
                  if (s.district.isNotEmpty && s.district != s.city)
                    s.district,
                  if (s.state.isNotEmpty && s.state != s.city) s.state,
                ].join(', ');

                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _selectSuggestion(s),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    child: Row(
                      children: [
                        // Location pin icon
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.primaryAccent,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // City name + district, state
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.city,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (subtitle.isNotEmpty)
                                Text(
                                  subtitle,
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.secondaryGreyBlue,
                                    fontSize: 11,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Tap-to-fill arrow hint
                        const Icon(
                          Icons.north_west,
                          size: 12,
                          color: AppColors.secondaryGreyBlue,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
