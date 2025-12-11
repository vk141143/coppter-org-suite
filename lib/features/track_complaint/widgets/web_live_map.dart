import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

class WebLiveMap extends StatefulWidget {
  const WebLiveMap({super.key});

  @override
  State<WebLiveMap> createState() => _WebLiveMapState();
}

class _WebLiveMapState extends State<WebLiveMap> {
  static const String mapboxToken = 'pk.eyJ1IjoidmsxNDEiLCJhIjoiY21pd3IxcHdxMHg5bzNmczhja3k5YnhqNCJ9.Ge02AurSSJIEEnDKCLoBHw';
  final String viewId = 'mapbox-${DateTime.now().millisecondsSinceEpoch}';

  @override
  void initState() {
    super.initState();
    _registerMapView();
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

              map.addControl(new mapboxgl.NavigationControl());
              map.addControl(new mapboxgl.GeolocateControl({
                positionOptions: { enableHighAccuracy: true },
                trackUserLocation: true
              }));

              const customerMarker = new mapboxgl.Marker({ color: '#FF6F00' })
                .setLngLat([userLng, userLat])
                .setPopup(new mapboxgl.Popup().setHTML('<h3>Your Location</h3>'))
                .addTo(map);

              const driverLng = userLng + 0.01;
              const driverLat = userLat + 0.01;
              const driverMarker = new mapboxgl.Marker({ color: '#0F5132' })
                .setLngLat([driverLng, driverLat])
                .setPopup(new mapboxgl.Popup().setHTML('<h3>Driver</h3>'))
                .addTo(map);

              map.on('load', function() {
                map.addSource('route', {
                  'type': 'geojson',
                  'data': {
                    'type': 'Feature',
                    'geometry': {
                      'type': 'LineString',
                      'coordinates': [[driverLng, driverLat], [userLng, userLat]]
                    }
                  }
                });
                map.addLayer({
                  'id': 'route',
                  'type': 'line',
                  'source': 'route',
                  'paint': { 'line-color': '#0F5132', 'line-width': 4, 'line-opacity': 0.7 }
                });
              });

              const bounds = new mapboxgl.LngLatBounds();
              bounds.extend([userLng, userLat]);
              bounds.extend([driverLng, driverLat]);
              map.fitBounds(bounds, { padding: 80 });

              let step = 0;
              const animate = () => {
                step += 0.0001;
                driverMarker.setLngLat([driverLng - (step * 10), driverLat - (step * 10)]);
                if (step < 0.01) requestAnimationFrame(animate);
              };
              setTimeout(animate, 1000);
            },
            function(error) {
              const map = new mapboxgl.Map({
                container: 'map-$viewId',
                style: 'mapbox://styles/mapbox/streets-v12',
                center: [-0.1276, 51.5074],
                zoom: 13
              });
              map.addControl(new mapboxgl.NavigationControl());
              new mapboxgl.Marker({ color: '#0F5132' }).setLngLat([-0.1276, 51.5074]).addTo(map);
              new mapboxgl.Marker({ color: '#FF6F00' }).setLngLat([-0.1176, 51.5174]).addTo(map);
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
    final theme = Theme.of(context);
    
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            HtmlElementView(viewType: viewId),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text('Live', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
