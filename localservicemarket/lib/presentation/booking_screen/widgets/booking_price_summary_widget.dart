import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';

class BookingPriceSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> service;
  final String selectedPaymentMethod;
  final Function(String) onPaymentMethodChanged;

  const BookingPriceSummaryWidget({
    super.key,
    required this.service,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
  });

  static const List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'CARD', 'label': 'Credit/Debit Card', 'icon': 'card'},
    {'id': 'WALLET', 'label': 'Wallet', 'icon': 'wallet'},
    {'id': 'CASH', 'label': 'Cash on Service', 'icon': 'cash'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final basePrice = service['basePrice'] as double;
    const serviceFee = 8.50;
    const discount = 0.0;
    final total = basePrice + serviceFee - discount;
    final isHourly = service['priceType'] == 'HOURLY';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price breakdown header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Price Breakdown',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _PriceRow(
                    label: isHourly
                        ? 'Base Rate (1 hr)'
                        : 'Service Price (Fixed)',
                    value: '\$${basePrice.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: 'Platform Fee',
                    value: '\$${serviceFee.toStringAsFixed(2)}',
                    valueColor: theme.colorScheme.onSurfaceVariant,
                  ),
                  if (discount > 0) ...[
                    const SizedBox(height: 8),
                    _PriceRow(
                      label: 'Loyalty Discount',
                      value: '-\$${discount.toStringAsFixed(2)}',
                      valueColor: AppTheme.success,
                    ),
                  ],
                  const SizedBox(height: 12),
                  Divider(color: theme.colorScheme.outlineVariant),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        '\$${total.toStringAsFixed(2)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Divider(
              color: theme.colorScheme.outlineVariant,
              height: 1,
              indent: 16,
              endIndent: 16,
            ),
            // Payment method
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Method',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._paymentMethods.map(
                    (method) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PaymentMethodTile(
                        method: method,
                        isSelected: selectedPaymentMethod == method['id'],
                        onTap: () =>
                            onPaymentMethodChanged(method['id'] as String),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _PriceRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? theme.colorScheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final Map<String, dynamic> method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(10),
              ),
              child: CustomIconWidget(
                iconName: method['icon'] as String,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                method['label'] as String,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppTheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primary
                      : theme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
