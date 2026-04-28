import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../screens/profile_form_screen.dart';
import '../screens/profile_detail_screen.dart';
import '../widgets/profile_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(builder: (context, provider, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Phone Booth'),
          actions: [
            IconButton(
              icon: Icon(provider.mapView ? Icons.list : Icons.map),
              onPressed: provider.toggleMapView,
            ),
          ],
        ),
        body: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.hasError && provider.nearbyProfiles.isEmpty
                ? Center(child: Text(provider.errorMessage))
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ProfileFormScreen()),
                                  );
                                },
                                icon: const Icon(Icons.add_box),
                                label: const Text('Create Profile'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: provider.mapView
                            ? _MapViewSection(provider: provider)
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: provider.nearbyProfiles.length,
                                itemBuilder: (context, index) {
                                  final profile = provider.nearbyProfiles[index];
                                  return GestureDetector(
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ProfileDetailScreen(profile: profile),
                                      ),
                                    ),
                                    child: ProfileCard(profile: profile),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      );
    });
  }
}

class _MapViewSection extends StatefulWidget {
  final UserProvider provider;
  const _MapViewSection({required this.provider});

  @override
  State<_MapViewSection> createState() => _MapViewSectionState();
}

class _MapViewSectionState extends State<_MapViewSection> {
  GoogleMapController? mapController;
  LatLng? currentLatLng;

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    try {
      final pos = await widget.provider.locationService.determinePosition();
      if (mounted) {
        setState(() {
          currentLatLng = LatLng(pos.latitude, pos.longitude);
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final markers = widget.provider.nearbyProfiles.map((profile) {
      return Marker(
        markerId: MarkerId(profile.uid),
        position: LatLng(profile.location.latitude, profile.location.longitude),
        infoWindow: InfoWindow(
          title: profile.name,
          snippet: profile.skills.isNotEmpty ? profile.skills.first.title : 'Skill provider',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileDetailScreen(profile: profile)),
            );
          },
        ),
      );
    }).toSet();

    final initialPosition = currentLatLng ?? const LatLng(0, 0);

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialPosition, zoom: 12),
      markers: markers,
      myLocationEnabled: true,
      onMapCreated: (controller) {
        mapController = controller;
      },
    );
  }
}
