import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localservicemarket/core/theme/app_colors.dart';
import 'package:localservicemarket/core/widgets/app_card.dart';
import 'package:localservicemarket/domain/entities/user.dart';
import 'package:localservicemarket/presentation/customer/discovery/bloc/discovery_cubit.dart';
import 'package:localservicemarket/presentation/customer/discovery/bloc/discovery_state.dart';

class MapViewPage extends StatelessWidget {
  const MapViewPage({super.key, required this.customer});

  final Customer customer;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscoveryCubit, DiscoveryState>(
      builder: (context, state) {
        final center = LatLng(state.latitude, state.longitude);
        final markers = state.providers
            .map(
              (p) => Marker(
                markerId: MarkerId(p.userId),
                position: LatLng(p.latitude, p.longitude),
                infoWindow: InfoWindow(
                  title: p.name,
                  snippet: '${p.averageRating} ★ rating',
                ),
              ),
            )
            .toSet();

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: center, zoom: 13),
                  markers: markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  onMapCreated: (_) {},
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place_rounded, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${state.providers.length} providers nearby',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
