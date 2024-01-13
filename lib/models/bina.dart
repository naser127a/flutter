import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum HasarTipi {
  agir(renk: Colors.red),
  orta(renk: Color.fromARGB(255, 183, 116, 14)),
  hafif(renk: Colors.green);

  final Color renk;
  //constract
  const HasarTipi({required this.renk});

  String toJson() => name;
  factory HasarTipi.fromJson(String name) => values.byName(name);
}

class Bina {
  static const String koleksiyonAdi = 'Binalar';

  final String? id;
  final String isim;
  final LatLng konum;
  final HasarTipi? hasarTipi;

  Bina({
    this.id,
    required this.isim,
    required this.konum,
    this.hasarTipi,
  });

  Bina.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        isim = json['isim'],
        konum = LatLng.fromJson(json['konum'])!,
        hasarTipi = (json['hasar Tipi'] == null
            ? null
            : HasarTipi.fromJson(json['hasar Tipi']));

  Map<String, dynamic> toJson() => {
        'id': id,
        'isim': isim,
        'konum': konum.toJson(),
        'hasar Tipi': hasarTipi?.toJson()
      };
  static CollectionReference<Map<String, dynamic>> get dbKoleksiyon =>
      FirebaseFirestore.instance.collection(koleksiyonAdi);

  static Future<List<Bina>> get tumBinalar async => (await dbKoleksiyon.get())
      .docs
      .map((doc) => Bina.fromJson(doc.data() as Map<String, dynamic>))
      .toList();

  Future<DocumentReference<Map<String, dynamic>>> ekle() async =>
      await dbKoleksiyon.add(toJson());
}
