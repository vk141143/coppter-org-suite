import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import '../../../core/config/app_config.dart';

class DriverMapboxWidget extends StatefulWidget {
  const DriverMapboxWidget({super.key});

  @override
  State<DriverMapboxWidget> createState() => _DriverMapboxWidgetState();
}

class _DriverMapboxWidgetState extends State<DriverMapboxWidget> {
  String get mapboxToken => AppConfig.mapboxToken;
  final String viewId = 'driver-mapbox-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      _registerMapView();
    }
  }

  void _registerMapView() {
    ui_web.platformViewRegistry.registerViewFactory(viewId, (int viewId) {
      final mapDiv = html.DivElement()
        ..id = 'map-$viewId'
        ..style.width = '100%'
        ..style.height = '100%';

      final script = html.ScriptElement()
        ..src = 'https://api.mapbox.com/mapbox-gl-js/v2.15.0/mapbox-gl.js'
        ..async = true;

      final cssLink = html.LinkElement()
        ..rel = 'stylesheet'
        ..href = 'https://api.mapbox.com/mapbox-gl-js/v2.15.0/mapbox-gl.css';

      html.document.head?.append(cssLink);
      html.document.head?.append(script);

      script.onLoad.listen((_) {
        final jsCode = '''
          mapboxgl.accessToken = '$mapboxToken';
          
          // Get user's current location
          navigator.geolocation.getCurrentPosition(
            function(position) {
              const userLng = position.coords.longitude;
              const userLat = position.coords.latitude;
              
              const map = new mapboxgl.Map({
                container: 'map-$viewId',
                style: 'mapbox://styles/mapbox/streets-v12',
                center: [userLng, userLat],
                zoom: 14
              });

              // Add navigation controls
              map.addControl(new mapboxgl.NavigationControl());
              map.addControl(new mapboxgl.GeolocateControl({
                positionOptions: { enableHighAccuracy: true },
                trackUserLocation: true,
                showUserHeading: true
              }));

              // Add driver marker (current location)
              const driverMarker = new mapboxgl.Marker({ color: '#0F5132' })
                .setLngLat([userLng, userLat])
                .setPopup(new mapboxgl.Popup().setHTML('<h3>Your Location</h3>'))
                .addTo(map);

              // Add customer marker (destination)
              const customerLng = userLng + 0.01;
              const customerLat = userLat + 0.01;
              const customerMarker = new mapboxgl.Marker({ color: '#FF6F00' })
                .setLngLat([customerLng, customerLat])
                .setPopup(new mapboxgl.Popup().setHTML('<h3>Customer Location</h3>'))
                .addTo(map);

              // Add route line
              map.on('load', function() {
                map.addSource('route', {
                  'type': 'geojson',
                  'data': {
                    'type': 'Feature',
                    'properties': {},
                    'geometry': {
                      'type': 'LineString',
                      'coordinates': [
                        [userLng, userLat],
                        [customerLng, customerLat]
                      ]
                    }
                  }
                });
                
                map.addLayer({
                  'id': 'route',
                  'type': 'line',
                  'source': 'route',
                  'layout': {
                    'line-join': 'round',
                    'line-cap': 'round'
                  },
                  'paint': {
                    'line-color': '#0F5132',
                    'line-width': 4,
                    'line-opacity': 0.7
                  }
                });
              });

              // Fit map to show both markers
              const bounds = new mapboxgl.LngLatBounds();
              bounds.extend([userLng, userLat]);
              bounds.extend([customerLng, customerLat]);
              map.fitBounds(bounds, { padding: 80 });
            },
            function(error) {
              // Fallback to default location if geolocation fails
              const map = new mapboxgl.Map({
                container: 'map-$viewId',
                style: 'mapbox://styles/mapbox/streets-v12',
                center: [-0.1276, 51.5074],
                zoom: 13
              });

              map.addControl(new mapboxgl.NavigationControl());
              
              const driverMarker = new mapboxgl.Marker({ color: '#0F5132' })
                .setLngLat([-0.1276, 51.5074])
                .addTo(map);

              const customerMarker = new mapboxgl.Marker({ color: '#FF6F00' })
                .setLngLat([-0.1176, 51.5174])
                .addTo(map);
            }
          );
        ''';
        html.document.body?.append(html.ScriptElement()..text = jsCode);
      });

      return mapDiv;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 60, color: Color(0xFF0F5132)),
              SizedBox(height: 8),
              Text('Map View', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F5132))),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: HtmlElementView(viewType: viewId),
    );
  }
}
