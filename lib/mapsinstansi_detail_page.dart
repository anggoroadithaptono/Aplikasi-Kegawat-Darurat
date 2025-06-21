import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyLocation {
  final LatLng coordinates;
  final IconData icon;
  final String name;
  final String address;
  final String phoneNumber;
  final double rating;
  final int reviews;
  final String category;
  final String distanceTime;
  final List<String> tags;
  final List<String> photos;
  final List<Review> reviewsList;
  final String? openUntil;
  final String? specialNote;

  EmergencyLocation({
    required this.coordinates,
    required this.icon,
    required this.name,
    required this.address,
    required this.phoneNumber,
    this.rating = 4.6,
    this.reviews = 99,
    this.category = "Instansi",
    this.distanceTime = "10 mnt",
    this.tags = const [],
    this.photos = const [],
    this.reviewsList = const [],
    this.openUntil,
    this.specialNote,
  });
}

class Review {
  final String author;
  final String comment;
  final double? rating;

  Review({required this.author, required this.comment, this.rating});
}

class InstansiMapPage extends StatelessWidget {
  const InstansiMapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maps Instansi"),
        backgroundColor: Colors.red,
      ),
      body: FlutterMap(
        options: MapOptions(
          // Initial center set to a point in Surabaya
          initialCenter: LatLng(-7.28, 112.75), // Centered for Surabaya
          initialZoom: 12, // Zoom out a bit to see more locations
        ),
        children: [
          // OpenStreetMap Tile Layer
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          ),
          // Marker layer for all emergency locations
          MarkerLayer(
            markers: _buildMarkers(context),
          ),
        ],
      ),
    );
  }

  // Helper method to build a list of markers from emergency locations
  List<Marker> _buildMarkers(BuildContext context) {
    // List of emergency locations
    final locations = [
      EmergencyLocation(
        coordinates: LatLng(-7.311133, 112.797166),
        icon: Icons.local_police,
        name: "POLSEK Rungkut",
        address: "Rungkut Barata, Surabaya, 60320",
        phoneNumber: "0318710600",
        category: "Kepolisian",
        rating: 4.5,
        reviews: 120,
        distanceTime: "5 mnt",
        // Using a placeholder image for now, ensure 'assets/polisi.jpg' exists or use NetworkImage
        photos: ["https://placehold.co/400x200/FF0000/FFFFFF?text=POLSEK+Rungkut"],
        reviewsList: [
          Review(author: "Andi", comment: "Petugas ramah dan cepat."),
        ],
        openUntil: "Buka 24 jam",
      ),
      // New Emergency Location 1: Hospital
      EmergencyLocation(
        coordinates: LatLng(-7.2917, 112.7667), // Approximate location of RS Premier Surabaya
        icon: Icons.local_hospital,
        name: "RS Premier Surabaya",
        address: "Jl. Ngagel Jaya Utara No.2, Pucang Sewu, Kec. Gubeng, Surabaya",
        phoneNumber: "0315993211",
        category: "Kesehatan",
        rating: 4.7,
        reviews: 350,
        distanceTime: "15 mnt",
        photos: ["https://placehold.co/400x200/0000FF/FFFFFF?text=RS+Premier+Surabaya"], // Placeholder image
        reviewsList: [
          Review(author: "Budi", comment: "Pelayanan sangat baik dan fasilitas lengkap."),
        ],
        openUntil: "Buka 24 jam",
      ),
      // New Emergency Location 2: Fire Station
      EmergencyLocation(
        coordinates: LatLng(-7.2530, 112.7489), // Approximate location of Dinas Pemadam Kebakaran
        icon: Icons.fire_truck,
        name: "Dinas Pemadam Kebakaran Kota Surabaya",
        address: "Jl. Pasar Besar No.19, Alun-alun Contong, Kec. Bubutan, Surabaya",
        phoneNumber: "0313551525",
        category: "Pemadam Kebakaran",
        rating: 4.8,
        reviews: 210,
        distanceTime: "10 mnt",
        photos: ["https://placehold.co/400x200/FFA500/FFFFFF?text=Pemadam+Kebakaran"], // Placeholder image
        reviewsList: [
          Review(author: "Cici", comment: "Respon cepat dan sigap."),
        ],
        openUntil: "Buka 24 jam",
      ),
      // New Emergency Location 3: Another Police Station (Polrestabes Surabaya)
      EmergencyLocation(
        coordinates: LatLng(-7.2657, 112.7533), // Approximate location of Polrestabes Surabaya
        icon: Icons.local_police,
        name: "Polrestabes Surabaya",
        address: "Jl. Sikatan No.1, Krembangan Sel., Kec. Krembangan, Surabaya",
        phoneNumber: "0313523450",
        category: "Kepolisian",
        rating: 4.6,
        reviews: 500,
        distanceTime: "20 mnt",
        photos: ["https://placehold.co/400x200/800080/FFFFFF?text=Polrestabes+Surabaya"], // Placeholder image
        reviewsList: [
          Review(author: "Dedi", comment: "Pusat kepolisian yang terorganisir."),
        ],
        openUntil: "Buka 24 jam",
      ),
    ];

    // Map each location to a Marker widget
    return locations.map((loc) {
      return Marker(
        point: loc.coordinates,
        width: 80,
        height: 80,
        child: GestureDetector(
          onTap: () => _showDetailSheet(context, loc), // Show detail sheet on tap
          child: Column(
            children: [
              Icon(loc.icon, color: Colors.red, size: 36), // Location icon
              Text(loc.name, style: const TextStyle(fontSize: 10), maxLines: 1) // Location name
            ],
          ),
        ),
      );
    }).toList();
  }

  // Method to display the bottom sheet with location details
  void _showDetailSheet(BuildContext context, EmergencyLocation loc) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)), // Rounded top corners
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content height
            children: [
              // Location Name and Call Button
              Row(
                children: [
                  Icon(loc.icon, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      loc.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  // Call Button
                  IconButton(
                    onPressed: () async {
                      final uri = Uri.parse("tel:${loc.phoneNumber}");
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        // Handle error: could not launch URL (e.g., show a message)
                        print('Could not launch ${loc.phoneNumber}');
                      }
                    },
                    icon: const Icon(Icons.call, color: Colors.blue),
                  )
                ],
              ),
              const SizedBox(height: 8),
              // Location Address
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(loc.address))
                ],
              ),
              const SizedBox(height: 12),
              // Rating, Reviews, Category, Distance/Time
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text('${loc.rating} (${loc.reviews} ulasan)'),
                  const SizedBox(width: 16),
                  Text(loc.category, style: TextStyle(color: Colors.grey)),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(loc.distanceTime),
                ],
              ),
              const SizedBox(height: 12),
              // Tags (if any)
              if (loc.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  children: loc.tags.map((tag) => Chip(label: Text(tag))).toList(),
                ),
                const SizedBox(height: 12),
              ],
              // Open Until / Special Note
              if (loc.openUntil != null || loc.specialNote != null) ...[
                Row(
                  children: [
                    if (loc.openUntil != null)
                      Text(loc.openUntil!, style: TextStyle(fontWeight: FontWeight.bold)),
                    if (loc.openUntil != null && loc.specialNote != null)
                      const SizedBox(width: 8),
                    if (loc.specialNote != null)
                      Expanded(child: Text(loc.specialNote!, style: TextStyle(color: Colors.red))),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              // Photos Carousel
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: loc.photos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    // Use Image.network for placeholder images
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        loc.photos[index],
                        width: 100,
                        fit: BoxFit.cover,
                        // Add error handling for images
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            color: Colors.grey[200],
                            child: Icon(Icons.error_outline, color: Colors.grey),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              // Action Buttons: Arah (Directions) and Telepon (Call)
              Row(
                children: [
                  _buildButton(Icons.directions, "Arah", () async {
                    // Launch Google Maps for directions
                    final googleMapsUrl = Uri.parse(
                        "https://www.google.com/maps/dir/?api=1&destination=${loc.coordinates.latitude},${loc.coordinates.longitude}");
                    if (await canLaunchUrl(googleMapsUrl)) {
                      await launchUrl(googleMapsUrl);
                    } else {
                      print('Could not launch Google Maps');
                    }
                  }),
                  const SizedBox(width: 8),
                  _buildButton(Icons.call, "Telepon", () async {
                    final uri = Uri.parse("tel:${loc.phoneNumber}");
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      print('Could not launch ${loc.phoneNumber}');
                    }
                  }),
                ],
              ),
              const SizedBox(height: 12),
              // Reviews List
              if (loc.reviewsList.isNotEmpty) ...[
                const Text("Ulasan:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: loc.reviewsList.map((review) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '${review.author}: "${review.comment}"' +
                            (review.rating != null ? ' (${review.rating} Bintang)' : ''),
                        style: TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              ]
            ],
          ),
        );
      },
    );
  }

  // Helper method to build a styled button
  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white, // Text and icon color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners for buttons
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}

