import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_colors.dart';
import '../../providers/property_provider.dart';
import '../../services/supabase_service.dart';
import '../../providers/saved_properties_provider.dart';
import '../../providers/chat_provider.dart';
import '../../models/property_model.dart';
import '../../data/owner_directory.dart';
import '../../utils/map_launcher.dart';
import '../../widgets/property_location_map.dart';

/// Detailed view of a rental property.
class TenantPropertyDetailsScreen extends StatefulWidget {
  final String propertyId;

  const TenantPropertyDetailsScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  State<TenantPropertyDetailsScreen> createState() => _TenantPropertyDetailsScreenState();
}

class _TenantPropertyDetailsScreenState extends State<TenantPropertyDetailsScreen> {
  bool _isDescriptionExpanded = false;

  /// Loaded straight from the database when the feed does not hold this
  /// property — the normal case for an assistant result, a saved item or a
  /// deep link, since the feed only ever holds a slice of the catalogue.
  PropertyModel? _fetched;
  bool _loading = false;
  bool _notFound = false;

  /// The owner's own profile, when the listing belongs to a real account.
  /// Without it the screen showed a name invented from the owner id, which
  /// then disagreed with the name on the conversation.
  Map<String, dynamic>? _ownerProfile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureLoaded());
  }

  Future<void> _ensureLoaded() async {
    if (!mounted) return;
    final pool = context.read<PropertyProvider>().lookupPool;
    for (final p in pool) {
      if (p.id == widget.propertyId) {
        _loadOwner(p.ownerId);
        return;
      }
    }

    setState(() => _loading = true);
    final property = await SupabaseService().getPropertyById(widget.propertyId);
    if (!mounted) return;
    setState(() {
      _fetched = property;
      _notFound = property == null;
      _loading = false;
    });

    if (property != null) _loadOwner(property.ownerId);
  }

  Future<void> _loadOwner(String ownerId) async {
    final profile = await SupabaseService().getOwnerProfile(ownerId);
    if (!mounted || profile == null) return;
    setState(() => _ownerProfile = profile);
  }

  /// Shown while the row is being fetched, and if it turns out not to exist.
  Widget _buildPlaceholder(AppColors colors) {
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Center(
        child: _notFound
            ? Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'This property is no longer available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary, fontSize: 15),
                ),
              )
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              ),
      ),
    );
  }

  /// Opens the native Android share sheet (WhatsApp, Messenger, Bluetooth,
  /// Instagram, etc.) with a description and a deep link that reopens this
  /// exact property inside the app.
  Future<void> _shareProperty(BuildContext context, PropertyModel property) async {
    // Clickable https link (works in WhatsApp/Messenger/etc). The hosted page
    // redirects to the dwellwise://property/<id> deep link and opens the app.
    final link = 'https://ihsamin01.github.io/DwellWise/?id=${property.id}';
    final price =
        '৳${property.price.toInt()}${property.priceFor.isNotEmpty ? ' / ${property.priceFor}' : ''}';
    final message = '🏠 ${property.title}\n'
        '📍 ${property.address}\n'
        '💰 $price\n\n'
        'View this rental on DwellWise:\n$link';

    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      message,
      subject: property.title,
      // Required on iPad; harmless elsewhere.
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  /// Opens the phone's default dialer with the owner's number pre-filled.
  Future<void> _callOwner(BuildContext context, String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.replaceAll(' ', ''));
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the dialer.')),
      );
    }
  }

  Future<void> _openInMaps(BuildContext context, PropertyModel property) async {
    final ok = (property.latitude != 0 || property.longitude != 0)
        ? await MapLauncher.openCoordinates(
            property.latitude, property.longitude,
            label: property.title)
        : await MapLauncher.openAddress(property.address);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  void _handleSaveToggle(BuildContext context, SavedPropertiesProvider savedProvider, PropertyModel property) {
    final isSaved = savedProvider.isSaved(property.id);
    savedProvider.toggleSave(property.id, property: property);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSaved ? 'Removed from favorites' : 'Added to favorites'),
        backgroundColor: isSaved ? const Color(0xff6B7280) : const Color(0xff10B981),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final propertyProvider = context.watch<PropertyProvider>();
    final savedProvider = context.watch<SavedPropertiesProvider>();

    final allProperties = propertyProvider.lookupPool;

    // The feed first, then whatever was fetched by id. There is deliberately
    // no stand-in here: this used to fall back to a hardcoded flat, so every
    // listing the feed did not hold opened that same invented property.
    PropertyModel? found;
    for (final p in allProperties) {
      if (p.id == widget.propertyId) {
        found = p;
        break;
      }
    }

    // Final so the null check below promotes it inside the callbacks further
    // down, which a reassignable local would not.
    final property = found ?? _fetched;
    if (property == null) {
      return _buildPlaceholder(colors);
    }

    final isSaved = savedProvider.isSaved(property.id);
    final directory = OwnerDirectory.forId(property.ownerId);
    final profileName = (_ownerProfile?['name'] as String?)?.trim();
    final owner = profileName == null || profileName.isEmpty
        ? directory
        : OwnerInfo(
            id: property.ownerId,
            name: profileName,
            rating: directory.rating,
            reviewCount: directory.reviewCount,
            isVerified: _ownerProfile?['verification_status'] == 'verified',
            phone: (_ownerProfile?['phone_number'] as String?)?.isNotEmpty ==
                    true
                ? _ownerProfile!['phone_number'] as String
                : directory.phone,
          );

    return Scaffold(
      backgroundColor: colors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              bottom: BorderSide(color: colors.border, width: 1.0),
            ),
          ),
          child: AppBar(
            backgroundColor: colors.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: colors.primary, size: 24),
              onPressed: () => context.go('/home'),
            ),
            title: Text(
              'DwellWise',
              style: TextStyle(
                color: colors.primary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.share_outlined, color: colors.primary, size: 24),
                onPressed: () => _shareProperty(context, property),
              ),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.favorite : Icons.favorite_border,
                  color: isSaved ? const Color(0xffDC2626) : colors.primary,
                  size: 24,
                ),
                onPressed: () => _handleSaveToggle(context, savedProvider, property),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. IMAGE CAROUSEL SECTION (300px height)
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  _DetailsCarousel(imageUrls: property.imageUrls),
                  // Verified Badge (top-left)
                  if (property.isVerified)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xff10B981),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 2. PROPERTY INFO SECTION (white card, no border)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '৳${property.price.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'per month',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    property.propertyType,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    property.title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 3. LOCATION SECTION (white card)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.location_on, color: colors.primary, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.address,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${property.area}, Dhaka',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 4. KEY INFO ROW (white card)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildKeyInfoItem(colors, Icons.king_bed, '${property.beds} Bed'),
                  _buildKeyInfoItem(colors, Icons.bathtub, '${property.baths} Bath'),
                  _buildKeyInfoItem(colors, Icons.square_foot, '${property.sizeSqFt.toInt()} sqft'),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 5. KEY FACILITIES SECTION (white card)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Key Facilities',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridItemFacilities(facilities: property.facilities),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 6. ABOUT PROPERTY SECTION (white card)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About this property',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    property.description,
                    maxLines: _isDescriptionExpanded ? null : 4,
                    overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isDescriptionExpanded = !_isDescriptionExpanded;
                      });
                    },
                    child: Text(
                      _isDescriptionExpanded ? 'Read less' : 'Read more',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 7. LOCATION MAP SECTION (white card)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openInMaps(context, property),
                        child: Text(
                          'Open Maps',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Live map preview (OpenStreetMap — no API key needed).
                  PropertyLocationMap(
                    latitude: property.latitude,
                    longitude: property.longitude,
                    address: property.address,
                    label: property.title,
                    pinColor: colors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 8. PROPERTY OWNER SECTION (white card with border left)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 0),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(
                  left: BorderSide(color: colors.primary, width: 4.0),
                ),
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROPERTY OWNER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Owner Photo circle
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.primaryTint,
                        ),
                        child: Icon(Icons.person, color: colors.primary, size: 28),
                      ),
                      const SizedBox(width: 12),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  owner.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                if (owner.isVerified) ...const [
                                  SizedBox(width: 6),
                                  Icon(Icons.verified, color: Color(0xff10B981), size: 14),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                ..._buildStarIcons(owner.rating),
                                const SizedBox(width: 6),
                                Text(
                                  '${owner.rating.toStringAsFixed(1)} (${owner.reviewCount} reviews)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // 9. CONTACT SECTION (white card buttons)
            Container(
              color: colors.surface,
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  // Message Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // The chat row has to exist before it can be opened,
                        // so both sides land on the same conversation id.
                        final messenger = ScaffoldMessenger.of(context);
                        final chatId = await context
                            .read<ChatProvider>()
                            .startConversationWithOwner(
                              ownerId: property.ownerId,
                              ownerName: owner.name,
                              propertyId: property.id,
                            );
                        if (!context.mounted) return;
                        if (chatId == null) {
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'This owner is not on DwellWise yet, so the '
                                'conversation cannot be opened.',
                              ),
                              backgroundColor: Color(0xffDC2626),
                            ),
                          );
                          return;
                        }
                        context.push('/chat/$chatId');
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xff1F2937), // Dark Gray
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Message',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Contact Owner Phone Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _callOwner(context, owner.phone),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xff1877F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.phone_outlined, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Contact Owner',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // bottom clearance padding
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStarIcons(double rating) {
    return List.generate(5, (index) {
      final threshold = index + 1;
      IconData icon;
      if (rating >= threshold) {
        icon = Icons.star;
      } else if (rating >= threshold - 0.5) {
        icon = Icons.star_half;
      } else {
        icon = Icons.star_border;
      }
      return Icon(icon, color: Color(0xff1877F2), size: 14);
    });
  }

  Widget _buildKeyInfoItem(AppColors colors, IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: colors.primary, size: 24),
        const SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _DetailsCarousel extends StatefulWidget {
  final List<String> imageUrls;
  const _DetailsCarousel({Key? key, required this.imageUrls}) : super(key: key);

  @override
  State<_DetailsCarousel> createState() => _DetailsCarouselState();
}

class _DetailsCarouselState extends State<_DetailsCarousel> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.imageUrls.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_pageController.hasClients) {
          final next = (_currentIndex + 1) % widget.imageUrls.length;
          _pageController.animateToPage(
            next,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final images = widget.imageUrls.isNotEmpty
        ? widget.imageUrls
        : ['https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?auto=format&fit=crop&w=600&q=80'];

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: images.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: images[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: colors.placeholder),
              errorWidget: (context, url, err) => const Icon(Icons.error),
            );
          },
        ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? const Color(0xff1877F2)
                        : Colors.white.withOpacity(0.5),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class GridItemFacilities extends StatelessWidget {
  final List<String> facilities;

  const GridItemFacilities({
    Key? key,
    required this.facilities,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final list = facilities.isEmpty ? ['WiFi', 'Parking', 'Gym', 'Security'] : facilities;

    // Render facilities as rows of two so the card wraps its content exactly
    // (a shrink-wrapped GridView reserves extra vertical space).
    final rows = <Widget>[];
    for (var i = 0; i < list.length; i += 2) {
      final hasSecond = i + 1 < list.length;
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: i + 2 < list.length ? 14 : 0),
          child: Row(
            children: [
              Expanded(child: _tile(colors, list[i])),
              const SizedBox(width: 12),
              Expanded(
                child: hasSecond ? _tile(colors, list[i + 1]) : const SizedBox(),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }

  Widget _tile(AppColors colors, String fac) {
    IconData facIcon = Icons.star;
    switch (fac.toLowerCase()) {
      case 'wifi':
        facIcon = Icons.wifi;
        break;
      case 'parking':
      case 'garage':
        facIcon = Icons.local_parking;
        break;
      case 'gym':
        facIcon = Icons.fitness_center;
        break;
      case 'lift':
        facIcon = Icons.elevator;
        break;
      case 'backup':
        facIcon = Icons.power;
        break;
      case 'security':
      case 'cctv':
        facIcon = Icons.security;
        break;
      case 'gas':
        facIcon = Icons.local_fire_department;
        break;
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colors.primaryTint,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(facIcon, color: colors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            fac,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
