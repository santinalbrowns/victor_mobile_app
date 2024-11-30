import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class StoreFinder extends StatefulWidget {
  @override
  _StoreFinderState createState() => _StoreFinderState();
}

class _StoreFinderState extends State<StoreFinder> {
  final TextEditingController _searchController = TextEditingController();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  // Sample store data
  final List<Store> stores = [
    Store(
        name: "1. Chichiri Shopping Mall",
        address: "Masauko chipembere Hwy",
        latLng: LatLng(-15.801631643934156, 35.0343850153446)),
    Store(
        name: "2. Gateway Mall",
        address: "Kenyatta Rd",
        latLng: LatLng(-13.970239264888706, 33.74213839494702)),
    Store(
        name: "3. Shoprite lilongwe",
        address: "Kirk Rd",
        latLng: LatLng(-13.98553115975188, 33.76902379494731)),
    Store(
        name: "4. Mzuzu Mall",
        address: "M1 Rd near Mzuzu Roundabout",
        latLng: LatLng(-11.461529972091364, 34.01449459673878)),
  ];

  @override
  void initState() {
    super.initState();
    _markers = stores
        .map((store) => Marker(
              markerId: MarkerId(store.name),
              position: store.latLng,
              infoWindow: InfoWindow(title: store.name, snippet: store.address),
            ))
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Store Finder'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer(); // Open the drawer
          },
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              child: Text(
                'Stores',
                style: TextStyle(fontSize: 24),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: stores.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(stores[index].name),
                    subtitle: Text(stores[index].address),
                    onTap: () {
                      _mapController?.animateCamera(
                        CameraUpdate.newLatLng(stores[index].latLng),
                      );
                      Navigator.of(context)
                          .pop(); // Close the drawer after selecting a store
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for stores...',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Implement search functionality here
              },
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(-15.801631643934156,
                    35.0343850153446), // Initial map position
                zoom: 12,
              ),
              markers: _markers,
            ),
          ),
        ],
      ),
    );
  }
}

class Store {
  final String name;
  final String address;
  final LatLng latLng;

  Store({required this.name, required this.address, required this.latLng});
}
