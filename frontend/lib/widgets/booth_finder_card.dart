import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../theme/civic_pulse_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
import '../services/external_links_service.dart';
import 'shared_card_shell.dart';

class BoothFinderCard extends ConsumerStatefulWidget {
  final String? location;
  const BoothFinderCard({super.key, this.location});

  @override
  ConsumerState<BoothFinderCard> createState() => _BoothFinderCardState();
}

class _BoothFinderCardState extends ConsumerState<BoothFinderCard> {
  late final TextEditingController _controller;
  GoogleMapController? _mapController;
  LatLng _boothLocation = const LatLng(18.9894, 73.1175); // New Panvel
  bool _isSearching = false;
  _BoothData _currentBooth = _mockBooths[0];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.location);
    if (widget.location != null && widget.location!.isNotEmpty) {
      // Small delay to allow map to load before initial search if location provided
      Future.delayed(const Duration(milliseconds: 500), _handleSearch);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _handleSearch() async {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simple keyword-based mock geocoding
    _BoothData selectedBooth = _mockBooths[0]; // Default: Panvel
    LatLng newLocation = const LatLng(18.9894, 73.1175);

    if (query.contains('mumbai')) {
      selectedBooth = _mockBooths[1];
      newLocation = const LatLng(19.0760, 72.8777);
    } else if (query.contains('pune')) {
      selectedBooth = _mockBooths[2];
      newLocation = const LatLng(18.5204, 73.8567);
    } else if (query.contains('delhi')) {
      selectedBooth = _mockBooths[3];
      newLocation = const LatLng(28.6139, 77.2090);
    } else if (query.contains('bangalore') || query.contains('bengaluru')) {
      selectedBooth = _mockBooths[4];
      newLocation = const LatLng(12.9716, 77.5946);
    } else if (query.contains('hyderabad')) {
      selectedBooth = _mockBooths[5];
      newLocation = const LatLng(17.3850, 78.4867);
    } else {
      // Deterministic shift based on text length for "any other" address
      final hash = query.length;
      newLocation = LatLng(
        18.9894 + (hash % 10) * 0.01,
        73.1175 + (hash % 15) * 0.01,
      );
      selectedBooth = _mockBooths[0].copyWith(
        address: _controller.text,
        name: 'Primary School, ${_controller.text.split(',').first}',
      );
    }

    if (mounted) {
      setState(() {
        _isSearching = false;
        _boothLocation = newLocation;
        _currentBooth = selectedBooth;
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _boothLocation, zoom: 14),
        ),
      );
    }
  }

  static final List<_BoothData> _mockBooths = [
    const _BoothData(
      boothNumber: 'Booth No. 142',
      name: 'Zilla Parishad School, New Panvel',
      address: 'Sector 5, Near Khandeshwar Station, New Panvel (E), Maharashtra',
      queueStatus: 'Low Wait Time (~10 mins)',
      queueLevel: 0.25,
      blo: 'Mr. Ramesh Kumar',
      helpline: '1950',
    ),
    const _BoothData(
      boothNumber: 'Booth No. 88',
      name: 'Municipal School, Dadar',
      address: 'Dadar West, Near Flower Market, Mumbai, Maharashtra',
      queueStatus: 'Moderate Wait (~25 mins)',
      queueLevel: 0.55,
      blo: 'Ms. Priya Sharma',
      helpline: '1950',
    ),
    const _BoothData(
      boothNumber: 'Booth No. 201',
      name: 'Modern College, Shivajinagar',
      address: 'Ganeshkhind Road, Shivajinagar, Pune, Maharashtra',
      queueStatus: 'Busy (~45 mins)',
      queueLevel: 0.85,
      blo: 'Mr. Suresh Patil',
      helpline: '1950',
    ),
    const _BoothData(
      boothNumber: 'Booth No. 12',
      name: 'Kendriya Vidyalaya, RK Puram',
      address: 'RK Puram Sector 4, New Delhi',
      queueStatus: 'Low Wait Time (~5 mins)',
      queueLevel: 0.15,
      blo: 'Mr. Anil Tyagi',
      helpline: '1950',
    ),
    const _BoothData(
      boothNumber: 'Booth No. 54',
      name: 'Government School, Indiranagar',
      address: 'Double Road, Indiranagar, Bengaluru, Karnataka',
      queueStatus: 'Moderate Wait (~15 mins)',
      queueLevel: 0.40,
      blo: 'Ms. Kavitha Rao',
      helpline: '1950',
    ),
    const _BoothData(
      boothNumber: 'Booth No. 310',
      name: 'Public School, Jubilee Hills',
      address: 'Road No. 36, Jubilee Hills, Hyderabad, Telangana',
      queueStatus: 'Low Wait Time (~10 mins)',
      queueLevel: 0.30,
      blo: 'Mr. Venkatesh G.',
      helpline: '1950',
    ),
  ];

  static const _facilities = [
    _Facility(icon: Icons.accessible_forward, label: 'Ramp Access'),
    _Facility(icon: Icons.wc, label: 'Restrooms'),
    _Facility(icon: Icons.local_drink, label: 'Drinking Water'),
    _Facility(icon: Icons.elderly, label: 'Priority Queue'),
  ];

  @override
  Widget build(BuildContext context) {
    return CardShell(
      headerIcon: Icons.location_on_outlined,
      headerLabel: ref.tr('booth_finder'),
      title: ref.tr('booth_finder'),
      subtitle: ref.tr('booth_subtitle'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Search field ──
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: ref.tr('search_booth_hint'),
                    hintStyle: TextStyle(color: CivicPulseTheme.outline),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: CivicPulseTheme.primary,
                    ),
                    filled: true,
                    fillColor: CivicPulseTheme.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: CivicPulseTheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  onSubmitted: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _isSearching ? null : _handleSearch,
                style: FilledButton.styleFrom(
                  backgroundColor: CivicPulseTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                child: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(ref.tr('find')),
              ),
            ],
          ),

          // Show mock result always (or after search)
          const SizedBox(height: 20),
          _BoothResult(
            booth: _currentBooth,
            facilities: _facilities,
            location: _boothLocation,
            onMapCreated: _onMapCreated,
            ref: ref,
          ),
        ],
      ),
    );
  }
}

class _BoothResult extends StatelessWidget {
  final _BoothData booth;
  final List<_Facility> facilities;
  final LatLng location;
  final Function(GoogleMapController) onMapCreated;
  final WidgetRef ref;

  const _BoothResult({
    required this.booth,
    required this.facilities,
    required this.location,
    required this.onMapCreated,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CivicPulseTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC3C6D1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              color: Colors.grey.withValues(alpha: 0.1),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Stack(
                children: [
                  GoogleMap(
                    onMapCreated: onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: location,
                      zoom: 15,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('booth'),
                        position: location,
                        infoWindow: InfoWindow(title: booth.name),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                  ),
                  // PointerInterceptor prevents HTML elements from swallowing clicks on web
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: PointerInterceptor(
                      child: const Material(
                        color: Colors.white,
                        elevation: 2,
                        shape: CircleBorder(),
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Icons.my_location,
                            size: 18,
                            color: CivicPulseTheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Header row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEBF0F8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.how_to_vote,
                  color: CivicPulseTheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ref.tr('found_booth'),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: CivicPulseTheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _QueueBadge(level: booth.queueLevel, status: booth.queueStatus, ref: ref),
              ],
            ),
          ),
          // Booth details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booth.boothNumber,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: CivicPulseTheme.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booth.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: CivicPulseTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: CivicPulseTheme.outline,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        booth.address,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: CivicPulseTheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Queue progress
                Row(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 16,
                      color: CivicPulseTheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      ref.tr('current_queue'),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      booth.queueStatus,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: CivicPulseTheme.tertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: LinearProgressIndicator(
                    value: booth.queueLevel,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFC3C6D1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      CivicPulseTheme.tertiaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Facilities
                Text(
                  ref.tr('facilities'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: facilities
                      .map(
                        (f) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(9999),
                            border: Border.all(color: const Color(0xFFC3C6D1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                f.icon,
                                size: 14,
                                color: CivicPulseTheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                f.label,
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(color: const Color(0xFF43474F)),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                // Help section
                Text(
                  ref.tr('need_help'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _HelpTile(
                        icon: Icons.person_outline,
                        label: ref.tr('blo'),
                        value: booth.blo,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _HelpTile(
                        icon: Icons.phone_outlined,
                        label: ref.tr('district_helpline'),
                        value: booth.helpline,
                        isPhone: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => ExternalLinksService.launchURL(ExternalLinksService.pollingStationSearch),
                    icon: const Icon(Icons.directions_outlined, size: 16),
                    label: Text(ref.tr('get_directions')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: CivicPulseTheme.primary,
                      side: const BorderSide(color: CivicPulseTheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isPhone;
  const _HelpTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isPhone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC3C6D1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: CivicPulseTheme.outline),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: CivicPulseTheme.outline,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isPhone
                  ? CivicPulseTheme.secondary
                  : const Color(0xFF191C1D),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueBadge extends StatelessWidget {
  final double level;
  final String status;
  final WidgetRef ref;
  const _QueueBadge({required this.level, required this.status, required this.ref});

  @override
  Widget build(BuildContext context) {
    final color = level < 0.4
        ? CivicPulseTheme.tertiaryContainer
        : CivicPulseTheme.secondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        level < 0.4 ? ref.tr('low_wait') : ref.tr('busy'),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ── Data models ──────────────────────────────────────────────────────────

class _BoothData {
  final String boothNumber, name, address, queueStatus, blo, helpline;
  final double queueLevel;
  const _BoothData({
    required this.boothNumber,
    required this.name,
    required this.address,
    required this.queueStatus,
    required this.queueLevel,
    required this.blo,
    required this.helpline,
  });

  _BoothData copyWith({
    String? boothNumber,
    String? name,
    String? address,
    String? queueStatus,
    double? queueLevel,
    String? blo,
    String? helpline,
  }) {
    return _BoothData(
      boothNumber: boothNumber ?? this.boothNumber,
      name: name ?? this.name,
      address: address ?? this.address,
      queueStatus: queueStatus ?? this.queueStatus,
      queueLevel: queueLevel ?? this.queueLevel,
      blo: blo ?? this.blo,
      helpline: helpline ?? this.helpline,
    );
  }
}

class _Facility {
  final IconData icon;
  final String label;
  const _Facility({required this.icon, required this.label});
}
