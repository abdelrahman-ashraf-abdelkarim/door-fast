import 'package:captain_app/core/constants.dart';
import 'package:captain_app/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryMapCard extends StatelessWidget {
  final Order order;

  const DeliveryMapCard({super.key, required this.order});

  Future<void> _openMap(double lat, double lng) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final lat = order.deliveryLat;
    final lng = order.deliveryLng;

    // ❌ لو مفيش location
    if (lat == null || lng == null) {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'موقع التوصيل غير متوفر',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    // ✅ لو فيه location
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 260,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'captain_app',
                ),

                /// خط بين الاستلام والتوصيل
                if (order.pickupLat != null && order.pickupLng != null)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          LatLng(order.pickupLat!, order.pickupLng!),
                          LatLng(lat, lng),
                        ],
                        strokeWidth: 4,
                        color: AppColors.primaryTeal,
                      ),
                    ],
                  ),

                /// الماركرز
                MarkerLayer(
                  markers: [
                    if (order.pickupLat != null && order.pickupLng != null)
                      Marker(
                        point: LatLng(order.pickupLat!, order.pickupLng!),
                        width: 44,
                        height: 44,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.store,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    Marker(
                      point: LatLng(lat, lng),
                      width: 52,
                      height: 52,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            /// Gradient Overlay
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black26],
                ),
              ),
            ),

            /// Address + Button
            Positioned(
              right: 12,
              left: 12,
              bottom: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.deliveryLocation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Material(
                    color: AppColors.primaryTeal,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () =>
                          _openMap(order.deliveryLat!, order.deliveryLng!),
                      borderRadius: BorderRadius.circular(16),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(Icons.open_in_new, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// Attribution
            const Positioned(
              left: 10,
              top: 10,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    '© OpenStreetMap',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
