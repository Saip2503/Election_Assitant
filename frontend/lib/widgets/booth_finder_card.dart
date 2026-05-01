import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import '../theme/civic_pulse_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/l10n_service.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.location);
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _handleSearch() async {
    setState(() => _isSearching = true);
    // In a real app, you'd call Google Places API here to get LatLng
    // For now, we simulate a slight shift to show interactivity
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isSearching = false;
      // Mock logic: move marker slightly
      _boothLocation = LatLng(
        _boothLocation.latitude + (DateTime.now().second % 10) * 0.001,
        _boothLocation.longitude + (DateTime.now().second % 10) * 0.001,
      );
    });
    _mapController?.animateCamera(CameraUpdate.newLatLng(_boothLocation));
  }

  static const _mockBooth = _BoothData(
    boothNumber: 'Polling Booth No. 142',
    name: 'Zilla Parishad School, New Panvel',
    address:
        'Sector 5, Near Khandeshwar Railway Station, New Panvel (E), Maharashtra 410206',
    queueStatus: 'Low Wait Time (~10 mins)',
    queueLevel: 0.25,
    blo: 'Mr. Ramesh Kumar',
    helpline: '1950',
  );

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
            booth: _mockBooth,
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
                    onPressed: () {},
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
}

class _Facility {
  final IconData icon;
  final String label;
  const _Facility({required this.icon, required this.label});
}
