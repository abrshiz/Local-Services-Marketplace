import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
                  snippet: '${p.averageRating} ★',
                ),
              ),
            )
            .toSet();

        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: center, zoom: 13),
              markers: markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (_) {},
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    '${state.providers.length} providers within 25 km',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
