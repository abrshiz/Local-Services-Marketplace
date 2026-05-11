import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class BookingNotesWidget extends StatefulWidget {
  final Function(String) onNotesChanged;

  const BookingNotesWidget({super.key, required this.onNotesChanged});

  @override
  State<BookingNotesWidget> createState() => _BookingNotesWidgetState();
}

class _BookingNotesWidgetState extends State<BookingNotesWidget> {
  final _notesController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Details',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 14),
          // Address field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Service Address',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _addressController,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter service address',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.secondary,
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0),
                  suffixIcon: IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.my_location_rounded,
                      size: 18,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Notes field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Special Instructions (Optional)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                onChanged: widget.onNotesChanged,
                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                decoration: InputDecoration(
                  hintText:
                      'E.g. Focus on kitchen and bathrooms, bring eco-friendly products...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(153),
                    height: 1.4,
                  ),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 8),
              // Quick note suggestions
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    [
                          'Pet at home',
                          'Ring doorbell',
                          'Call on arrival',
                          'Key under mat',
                        ]
                        .map(
                          (suggestion) => GestureDetector(
                            onTap: () {
                              final current = _notesController.text;
                              _notesController.text = current.isEmpty
                                  ? suggestion
                                  : '$current, $suggestion';
                              widget.onNotesChanged(_notesController.text);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add_rounded,
                                    size: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    suggestion,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
