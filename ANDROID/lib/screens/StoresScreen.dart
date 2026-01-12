import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StoresScreen extends StatelessWidget {
  final List stores;
  final Map<String, dynamic> coordinatesUsed;

  const StoresScreen({
    Key? key,
    required this.stores,
    required this.coordinatesUsed,
  }) : super(key: key);

  // CALL SHOP
  void _callShop(String phone) async {
    final uri = Uri.parse("tel:$phone");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  // OPEN MAPS
void _openMaps(String url) async {
  try {
    final latLng = url.split("query=").last; // Extract "lat,lon"

    final googleMapsUri = Uri.parse("geo:$latLng?q=$latLng");
    final googleMapsAppUri = Uri.parse("comgooglemaps://?q=$latLng");

    // 1. Try opening Google Maps app
    if (await canLaunchUrl(googleMapsAppUri)) {
      await launchUrl(googleMapsAppUri, mode: LaunchMode.externalApplication);
      return;
    }

    // 2. Try opening using geo: scheme
    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
      return;
    }

    // 3. Fallback → open browser Google Maps link
    final webUri = Uri.parse(url);
    await launchUrl(webUri, mode: LaunchMode.externalApplication);

  } catch (e) {
    print("MAP ERROR: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nearby Agro Stores",
          style: TextStyle(color: Colors.black87),
        ),
        elevation: 1,
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),

      backgroundColor: const Color(0xFFF5F5F5),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stores.length,
        itemBuilder: (context, index) {
          final shop = stores[index];

          final String name = shop["name"] ?? "Unknown Store";
          final String address = shop["address"] ?? "No Address Available";
          final String phone = shop["phone"] ?? "";
          final String link = shop["maps_link"] ?? "";

          return Card(
            elevation: 2,
            color: Colors.white,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STORE NAME
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ADDRESS ROW
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on,
                          size: 20, color: Colors.red),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // BUTTON ROW
                  Row(
                    children: [
                      // CALL BUTTON
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              phone.isNotEmpty ? () => _callShop(phone) : null,
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // MAP BUTTON
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openMaps(link),
                          icon: const Icon(Icons.map),
                          label: const Text("Open"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            elevation: 1,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
