import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  final String nom;
  final String nomMin;
  final String wilaya;
  final String description;
  final List<dynamic> categorie;
  final List<dynamic> tags;
  final List<dynamic> images;

  Place({
    required this.nom,
    required this.wilaya,
    required this.description,
    required this.categorie,
    required this.tags,
    required this.images,
  }) : nomMin = nom.toLowerCase();

  factory Place.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final nom = data['nom'] ?? '';
    return Place(
      nom: nom,
      wilaya: data['wilaya'] ?? '',
      description: data['description'] ?? '',
      categorie: List.from(data['categorie'] ?? []),
      tags: List.from(data['tags'] ?? []),
      images: List.from(data['images'] ?? []),
    );
  }
}
