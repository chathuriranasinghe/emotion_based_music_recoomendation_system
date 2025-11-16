import 'package:flutter/material.dart';

class RecommendationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Emotions'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recommended for you',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16),
            RecommendationCard(
              title: 'Uplifting Melodies',
              description:
                  'Feel-good tunes to keep your spirit high and optimistic.',
              imageUrl: 'assets/recommendation1.jpg',
            ),
            RecommendationCard(
              title: 'Soothing Sounds',
              description:
                  'Calm and peaceful music for a tranquil mind and relaxation.',
              imageUrl: 'assets/recommendation2.jpg',
            ),
            RecommendationCard(
              title: 'Energetic',
              description:
                  'High-Energy Beats and music to get you moving and boost your energy.',
              imageUrl: 'assets/recommendation3.jpg',
            ),
            RecommendationCard(
              title: 'Concentration Tracks',
              description:
                  'Music to help you stay focused and productive.',
              imageUrl: 'assets/recommendation4.jpg',
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Emotions'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: 'Music'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: 1, // Set to 1 for Emotions screen
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  RecommendationCard({
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}