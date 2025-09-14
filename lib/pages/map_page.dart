import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:showcaseview/showcaseview.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';
import 'package:foodie/services/theme.dart';
import 'package:flutter/material.dart' hide BottomSheet;
import 'package:foodie/services/map_position.dart';
import 'package:foodie/services/location_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:foodie/repositories/restaurant_repo.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/repositories/user_repo.dart';
import 'package:foodie/services/storage_service.dart';
import 'package:foodie/view_models/all_restaurants_vm.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:foodie/widgets/map/bottom_sheet.dart';
import 'package:foodie/models/filter_options.dart';
import 'package:foodie/enums/genre_tag.dart';
import 'package:foodie/enums/vegan_tag.dart';
import 'package:foodie/widgets/map/search_bar.dart';
import 'package:foodie/widgets/map/category_button.dart';
import 'package:foodie/widgets/map/preference_button.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  late FilterOptions _filterOptions;
  GoogleMapController? _mapController;

  String? _lightMapStyle;
  String? _darkMapStyle;

  RestaurantDetailViewModel? _selectedRestaurantDetailVM;
  final double _sheetHeight = 200;

  final Map<Color, BitmapDescriptor> _markerIconCache = {};

  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey _preferenceKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _filterOptions = FilterOptions(
      selectedGenres: GenreTags.values.toSet(),
      selectedVeganTags: {VeganTags.nonVegetarian},
      isOpenNow: false,
      minRating: 0.0,
      priceRange: const RangeValues(0, 4),
    );
    final String? id = context.read<MapPositionService>().id;
    if (id != null) {
      _selectedRestaurantDetailVM = RestaurantDetailViewModel(
        restaurantId: id,
        restaurantRepository: context.read<RestaurantRepository>(),
        reviewRepository: context.read<ReviewRepository>(),
        userRepository: context.read<UserRepository>(),
        storageService: context.read<StorageService>(),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<MapPositionService>().updateId(null);
      });
    }
    _loadMapStyles();
    _centerOnUserLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mapPositionService = context.read<MapPositionService>();
      final id = mapPositionService.id;

      if (id != null) {
        _triggerBottomSheetForRestaurant(id);
        mapPositionService.updateId(null);
      } else if (mapPositionService.startTutorialOnLoad) {
        ShowCaseWidget.of(
          context,
        ).startShowCase([_searchKey, _categoryKey, _preferenceKey, _locationKey]);
        mapPositionService.consumeTutorial();
      }
    });
  }

  Future<void> _loadMapStyles() async {
    _lightMapStyle = await rootBundle.loadString('assets/map_styles/light_mode.json');
    _darkMapStyle = await rootBundle.loadString('assets/map_styles/dark_mode.json');
    _updateMapStyle();
  }

  void _updateMapStyle() {
    if (_mapController == null) return;

    final bool isDarkMode = context.read<ThemeService>().isDarkMode;

    if (isDarkMode && _darkMapStyle != null) {
      _mapController!.setMapStyle(_darkMapStyle);
    } else if (!isDarkMode && _lightMapStyle != null) {
      _mapController!.setMapStyle(_lightMapStyle);
    }
  }

  Future<void> _centerOnUserLocation() async {
    try {
      final locationService = context.read<LocationService>();
      final position = await locationService.getCurrentPosition();

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 16.0),
      );
    } catch (e) {
      print("Failed to get user location: $e");
    }
  }

  @override
  void dispose() {
    _selectedRestaurantDetailVM?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<BitmapDescriptor> _createCustomMarker(Color color) async {
    if (_markerIconCache.containsKey(color)) {
      return _markerIconCache[color]!;
    }

    const String svgTemplate = '''
    <svg width="100" height="120" viewBox="-5 -5 110 125" xmlns="http://www.w3.org/2000/svg">
      <path 
        fill="#FILL_COLOR#" 
        stroke="#FILL_COLOR_DARK#" 
        stroke-width="4" 
        d="M50 0 C22.38 0 0 22.38 0 50 C0 85 50 120 50 120 S100 85 100 50 C100 22.38 77.62 0 50 0 Z"
      />
      <circle fill="#FILL_COLOR_DARK#" cx="50" cy="50" r="25"/>
    </svg>
    ''';

    final HSLColor hslColor = HSLColor.fromColor(color);
    final HSLColor darkerHslColor = hslColor.withLightness(
      (hslColor.lightness - 0.15).clamp(0.0, 1.0),
    );
    final Color darkerColor = darkerHslColor.toColor();

    final String mainColorString = '#${color.value.toRadixString(16).substring(2)}';
    final String darkColorString = '#${darkerColor.value.toRadixString(16).substring(2)}';

    final String finalSvgString = svgTemplate
        .replaceAll('#FILL_COLOR#', mainColorString)
        .replaceAll('#FILL_COLOR_DARK#', darkColorString);

    final PictureInfo pictureInfo = await vg.loadPicture(SvgStringLoader(finalSvgString), null);
    final ui.Image image = await pictureInfo.picture.toImage(120, 150);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    final bitmapDescriptor = BitmapDescriptor.fromBytes(uint8List);

    _markerIconCache[color] = bitmapDescriptor;
    return bitmapDescriptor;
  }

  Future<Set<Marker>> _createMarkers(List<RestaurantItem> restaurants) async {
    final List<Future<Marker>> markerFutures =
        restaurants
            .where(
              (restaurant) =>
                  _filterOptions.selectedGenres.contains(restaurant.genreTag.toGenreTags()),
            )
            .where((restaurant) => (restaurant.veganTag.level <= _filterOptions.maxVeganLevel))
            .where((restaurant) {
              if (restaurant.averageRating == null) return true;
              if (restaurant.averageRating! < _filterOptions.minRating) return false;
              if (restaurant.averagePriceLevel == null) return true;
              return restaurant.averagePriceLevel! >= _filterOptions.priceRange.start &&
                  restaurant.averagePriceLevel! <= _filterOptions.priceRange.end;
            })
            .map((restaurant) async {
              return Marker(
                markerId: MarkerId(restaurant.restaurantId),
                position: LatLng(restaurant.latitude, restaurant.longitude),
                icon: await _createCustomMarker(restaurant.genreTag.color),
                onTap: () {
                  if (_selectedRestaurantDetailVM?.restaurantId != restaurant.restaurantId) {
                    _selectedRestaurantDetailVM?.dispose();
                    final newVM = RestaurantDetailViewModel(
                      restaurantId: restaurant.restaurantId,
                      restaurantRepository: context.read<RestaurantRepository>(),
                      reviewRepository: context.read<ReviewRepository>(),
                      userRepository: context.read<UserRepository>(),
                      storageService: context.read<StorageService>(),
                    );
                    setState(() {
                      _selectedRestaurantDetailVM = newVM;
                    });
                  }
                },
              );
            })
            .toList();

    return Future.wait(markerFutures).then((markers) => markers.toSet());
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    final allRestaurants = context.read<AllRestaurantViewModel>().restaurants;
    final queryList = query.split(' ');

    final foundRestaurant = allRestaurants.firstWhere(
      (item) => queryList.every((q) => item.restaurantName.toLowerCase().contains(q.toLowerCase())),
      orElse:
          () => RestaurantItem(
            restaurantId: '',
            restaurantName: '',
            latitude: 0.0,
            longitude: 0.0,
            genreTag: genreTags[GenreTags.fastFood]!,
            veganTag: veganTags[VeganTags.nonVegetarian]!,
            averageRating: null,
            averagePriceLevel: null,
          ),
    );

    if (foundRestaurant.restaurantId.isNotEmpty) {
      final targetPosition = LatLng(foundRestaurant.latitude, foundRestaurant.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(targetPosition, 16.0));
      _triggerBottomSheetForRestaurant(foundRestaurant.restaurantId);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("No restaurant found for '$query'")));
    }
  }

  void _triggerBottomSheetForRestaurant(String restaurantId) {
    if (_selectedRestaurantDetailVM?.restaurantId != restaurantId) {
      _selectedRestaurantDetailVM?.dispose();
      final newVM = RestaurantDetailViewModel(
        restaurantId: restaurantId,
        restaurantRepository: context.read<RestaurantRepository>(),
        reviewRepository: context.read<ReviewRepository>(),
        userRepository: context.read<UserRepository>(),
        storageService: context.read<StorageService>(),
      );
      setState(() {
        _selectedRestaurantDetailVM = newVM;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng initialPosition = context.read<MapPositionService>().position;
    final allRestaurantViewModel = context.watch<AllRestaurantViewModel>();
    final restaurants = allRestaurantViewModel.restaurants;
    final restaurantMarkers = _createMarkers(restaurants);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<Set<Marker>>(
              future: _createMarkers(restaurants),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: context.read<MapPositionService>().position,
                    zoom: 15,
                  ),
                  markers: snapshot.data ?? {},
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _updateMapStyle();
                  },
                  onTap: (LatLng position) {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _selectedRestaurantDetailVM?.dispose();
                      _selectedRestaurantDetailVM = null;
                    });
                  },
                  onCameraMove: (position) {
                    context.read<MapPositionService>().updatePosition(position.target);
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                );
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Showcase(
                        key: _searchKey,
                        title: 'Search Restaurants',
                        description:
                            'You can type here to search for any restaurant by name or keyword.',
                        targetShapeBorder: const OvalBorder(),
                        targetPadding: const EdgeInsets.all(16),
                        child: SearchBarWidget(
                          controller: _searchController,
                          onSubmitted: _performSearch,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Showcase(
                      key: _categoryKey,
                      title: 'Filter by Category',
                      description: 'Tap here to select your favorite food categories.',
                      targetShapeBorder: const CircleBorder(),
                      targetPadding: const EdgeInsets.all(16),
                      child: CategoryButton(
                        options: _filterOptions,
                        onUpdate: (newOptions) => setState(() => _filterOptions = newOptions),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Showcase(
                      key: _preferenceKey,
                      title: 'Set Preferences',
                      description: 'Set your preferences like price range and dietary options.',
                      targetShapeBorder: const CircleBorder(),
                      targetPadding: const EdgeInsets.all(16),
                      child: PreferenceButton(
                        options: _filterOptions,
                        onUpdate: (newOptions) => setState(() => _filterOptions = newOptions),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _centerOnUserLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _selectedRestaurantDetailVM != null ? 0 : -_sheetHeight,
            left: 0,
            right: 0,
            height: _sheetHeight,
            child: _buildBottomSheet(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSheet() {
    if (_selectedRestaurantDetailVM == null) {
      return const SizedBox.shrink();
    }
    return ChangeNotifierProvider.value(
      value: _selectedRestaurantDetailVM!,
      child: const BottomSheet(),
    );
  }
}
