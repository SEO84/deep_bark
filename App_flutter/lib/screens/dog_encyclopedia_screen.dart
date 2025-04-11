// lib/screens/dog_encyclopedia_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/dog_breed_service.dart';
import '../models/dog_breed_model.dart' as models;
import 'package:geocoding/geocoding.dart';
import '../services/app_localizations.dart';
import 'package:provider/provider.dart';
import '../services/locale_provider.dart';
import 'package:google_maps_custom_marker/google_maps_custom_marker.dart';
import '../models/mix_dog.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class DogEncyclopediaScreen extends StatefulWidget {
  const DogEncyclopediaScreen({super.key});

  @override
  State<DogEncyclopediaScreen> createState() => _DogEncyclopediaScreenState();
}

class _DogEncyclopediaScreenState extends State<DogEncyclopediaScreen>
    with SingleTickerProviderStateMixin {
  final DogBreedService _breedService = DogBreedService();
  List<dynamic> _breeds = [];
  List<dynamic> _filteredBreeds = [];
  bool _isLoading = true;
  String _searchQuery = '';
  Map<String, String>? _breedNameMapping;
  late TabController _tabController;

  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadBreedNameMapping();
    _loadBreeds();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.index == 1) {
      _setupMarkers().then((_) => setState(() {}));
    }
  }

  Future<void> _loadBreedNameMapping() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/data/breed_name_mapping.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      setState(() {
        _breedNameMapping = Map<String, String>.from(jsonData['mapping']);
      });
    } catch (e) {
      print('견종 이름 매핑 파일 로드 오류: $e');
    }
  }

  Future<void> _loadBreeds() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final languageCode = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
      final breeds = await _breedService.getAllBreeds(languageCode);
      setState(() {
        _breeds = breeds;
        _filteredBreeds = breeds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('견종 데이터를 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _setupMarkers() async {
    _markers = Set<Marker>();
    for (var breed in _filteredBreeds.where((breed) => breed.originLatLng != null)) {
      Marker pawMarker = await GoogleMapsCustomMarker.createCustomMarker(
        marker: Marker(
          markerId: MarkerId(breed.id),
          position: LatLng(
              breed.originLatLng!.latitude,
              breed.originLatLng!.longitude
          ),
          infoWindow: InfoWindow(
            title: _getBreedName(breed),
            snippet: breed.origin,
            onTap: () {
              Navigator.pushNamed(
                context,
                '/breed_detail',
                arguments: {'breed': breed},
              );
            },
          ),
        ),
        shape: MarkerShape.circle,
        backgroundColor: Colors.white,
        title: '🐾',
        textStyle: TextStyle(fontSize: 15, color: Colors.brown)
      );
      _markers.add(pawMarker);
    }
  }

  void _filterBreeds(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredBreeds = _breeds;
      } else {
        final languageCode = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
        _filteredBreeds = _breeds.where((breed) {
          if (breed is models.DogBreed) {
            final name = languageCode == 'en' ? breed.nameEn : breed.nameKo;
            return name.toLowerCase().contains(query.toLowerCase());
          } else if (breed is MixDog) {
            final name = languageCode == 'en' ? breed.nameEn : breed.nameKo;
            return name.toLowerCase().contains(query.toLowerCase());
          }
          return false;
        }).toList();
      }
    });
  }

  String _getBreedName(dynamic breed) {
    final languageCode = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
    if (breed is models.DogBreed) {
      return languageCode == 'en' ? breed.nameEn : breed.nameKo;
    } else if (breed is MixDog) {
      return languageCode == 'en' ? breed.nameEn : breed.nameKo;
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageCode = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(languageCode == 'en' ? 'Dog Encyclopedia' : '견종 백과'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          splashFactory: NoSplash.splashFactory,
          tabs: [
            Tab(icon: Icon(Icons.list), text: localizations.translate('list')),
            Tab(icon: Icon(Icons.map), text: localizations.translate('world_map')),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: languageCode == 'en' ? 'Search breeds...' : '견종 검색...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _filterBreeds,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              localizations.translate('loading_breeds'),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : _filteredBreeds.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  localizations.translate('no_search_results'),
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadBreeds,
                            child: ListView.builder(
                              itemCount: _filteredBreeds.length,
                              itemBuilder: (context, index) {
                                final breed = _filteredBreeds[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(8),
                                    leading: breed.imageUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              breed.imageUrl!,
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  width: 60,
                                                  height: 60,
                                                  color: Colors.grey[300],
                                                  child: Icon(Icons.pets, color: Colors.grey[600]),
                                                );
                                              },
                                            ),
                                          )
                                        : Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[300],
                                            child: Icon(Icons.pets, color: Colors.grey[600]),
                                          ),
                                    title: Text(
                                      _getBreedName(breed),
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('${localizations.translate('origin')}: ${breed.origin}'),
                                        if (breed.size != null)
                                          Text('${localizations.translate('size')}: ${breed.size}'),
                                      ],
                                    ),
                                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/breed_detail',
                                        arguments: {'breed': breed},
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                _isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              localizations.translate('loading_map'),
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(30, 0),
                          zoom: 2,
                        ),
                        markers: _markers,
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                          Factory<OneSequenceGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        }.toSet(),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
