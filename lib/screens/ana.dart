import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_odev/models/bina.dart';
import 'package:uuid/uuid.dart';

class AnaEkran extends StatefulWidget {
  const AnaEkran({Key? key}) : super(key: key);

  @override
  State<AnaEkran> createState() => _AnaEkranDurumu();
}

class _AnaEkranDurumu extends State<AnaEkran> {
  @override
  void initState() {
    super.initState();

    // Tüm binaları getir ve bu bilgilerle harita üzerinde işlemleri gerçekleştir
    Bina.tumBinalar.then((binalar) {
      var cekilenPoligonlar = binalar
          .map((bina) => createPolygon(
                bina.konum,
                bina.hasarTipi ?? HasarTipi.orta,
              ))
          .toSet();

      var cekilenIsaretler = binalar
          .map((bina) => createMarker(
                bina.konum,
                bina.isim,
              ))
          .toSet();

      setState(() {
        polygons.addAll(cekilenPoligonlar);
        markers.addAll(cekilenIsaretler);
      });
    });
  }

  Polygon createPolygon(LatLng latLng, HasarTipi hasarTipi) {
    const boyut = 0.0005;

    return Polygon(
      polygonId: PolygonId(const Uuid().v4()),
      points: [
        LatLng(latLng.latitude + boyut, latLng.longitude + boyut),
        LatLng(latLng.latitude + boyut, latLng.longitude - boyut),
        LatLng(latLng.latitude - boyut, latLng.longitude - boyut),
        LatLng(latLng.latitude - boyut, latLng.longitude + boyut),
      ],
      fillColor: hasarTipi.renk.withOpacity(0.3),
      strokeColor: hasarTipi.renk,
      strokeWidth: 2,
    );
  }

  Marker createMarker(LatLng latLng, String isim) {
    return Marker(
      markerId: MarkerId(const Uuid().v4()),
      position: latLng,
      alpha: 0.8,
      infoWindow: InfoWindow(
        title: isim,
      ),
    );
  }

  bool isDialogOpen = false;

  Set<Marker> markers = {};
  Set<Polygon> polygons = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nasır akraa",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(38.33307760484841, 38.43966606225209),
          zoom: 14,
        ),
        markers: markers,
        polygons: polygons,
        onTap: (LatLng latLng) async {
          if (isDialogOpen) return;

          setState(() {
            isDialogOpen = true;
          });

          showDialog(
            context: context,
            builder: (BuildContext context) {
              String yerAdi = '';
              HasarTipi hasarTipi = HasarTipi.orta;

              return AlertDialog(
                title: const Text('Yer ekle'),
                content: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    TextField(
                      onChanged: (deger) {
                        yerAdi = deger;
                      },
                      decoration: const InputDecoration(
                        labelText: 'İsim',
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<HasarTipi>(
                      value: hasarTipi,
                      onChanged: (HasarTipi? deger) {
                        hasarTipi = deger!;
                      },
                      items: HasarTipi.values
                          .map((hasarTipi) => DropdownMenuItem(
                                value: hasarTipi,
                                child: Text(hasarTipi.name),
                              ))
                          .toList(),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    child: const Text('Ekle'),
                    onPressed: () async {
                      setState(() {
                        polygons.add(createPolygon(latLng, hasarTipi));
                        markers.add(createMarker(latLng, yerAdi));
                      });

                      await Bina(
                        isim: yerAdi,
                        konum: latLng,
                        hasarTipi: hasarTipi,
                      ).ekle();

                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('İptal'),
                    onPressed: () async {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          ).whenComplete(() async {
            await Future.delayed(const Duration(milliseconds: 500));

            setState(() {
              isDialogOpen = false;
            });
          });
        },
      ),
    );
  }
}
