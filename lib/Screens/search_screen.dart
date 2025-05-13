import 'package:app_pfe/Screens/place_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/places_search_service.dart';
import 'explorer_screen.dart';


class PlaceSearchPage extends StatefulWidget {
  @override
  _PlaceSearchPageState createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  String searchTerm = '';
  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    Query? query = PlaceSearchService.getFilteredQuery(searchTerm, selectedCategory);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => ExplorerScreen(),//hya nrmlmn navigator.pop (lpush fl explore screen) mais n7itha psq ki ndkhol ml search screen mkch navigator.push
        ),
        title: Container(
          width: double.infinity,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(30),
          ),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher un lieu...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                searchTerm = value.trim();
              });
            },
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),


      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Historique',
                    selected: selectedCategory == 'historique',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'historique' ? null : 'historique';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Culturel',
                    selected: selectedCategory == 'culturel',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'culturel' ? null : 'culturel';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Naturel',
                    selected: selectedCategory == 'naturel',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'naturel' ? null : 'naturel';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterButton(
                    label: 'Amusement',
                    selected: selectedCategory == 'amusement',
                    onTap: () {
                      setState(() {
                        selectedCategory = selectedCategory == 'amusement' ? null : 'amusement';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          // Show results or prompt depending on searchTerm
          if (searchTerm.isEmpty)
            const Expanded(
              child: Center(child: Text('Entrer un lieu a chercher pour demmarer')),
            )
          else if (query != null)
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: query.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Aucun lieu trouve.'));
                  }
                  final places = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index].data() as Map<String, dynamic>;
                      final imageUrl = (place['images'] as List?)?.first ?? '';
                      final nom = place['nom'] ?? 'Sans nom';
                      final description = place['description'] ?? 'Sans description';

                      return InkWell(
                          onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaceDetailsScreen(
                              placeId: places[index].id,
                              placeData: place,
                            ),
                          ),
                        );
                      },
                      child:Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              // Show image if available, otherwise show icon
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                ),
                                child: (imageUrl.isNotEmpty)
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        Icon(Icons.image, size: 40, color: Colors.grey),
                                  ),
                                )
                                    : Center(child: Icon(Icons.image, size: 40, color: Colors.grey)),
                              ),

                              const SizedBox(width: 12),
                              // Title and subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nom,
                                      style: TextStyle(fontSize: 16,color: Colors.green[800], fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),);
                    },
                  );

                },
              ),
            )
          else
            const Expanded(
              child: Center(child: Text('Entrer un lieu a chercher pour demmarer')),
            ),
        ],
      ),
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }
}
