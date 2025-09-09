import 'package:animate_do/animate_do.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class CarouselSection extends StatelessWidget {
  final List<Map<String, String>> carouselItems;

  const CarouselSection({super.key, required this.carouselItems});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CarouselSlider(
        options: CarouselOptions(
          height: 160,
          autoPlay: true,
          enlargeCenterPage: true,
          enlargeFactor: 0.25,
          viewportFraction: 0.75,
          autoPlayInterval: const Duration(seconds: 5),
          autoPlayCurve: Curves.fastOutSlowIn,
        ),
        items: carouselItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return ZoomIn(
            duration: const Duration(milliseconds: 700),
            delay: Duration(milliseconds: index * 200),
            child: ElasticIn(
              duration: const Duration(milliseconds: 900),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade200, width: 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Bounce(
                        from: 10,
                        duration: const Duration(seconds: 2),
                        infinite: true,
                        child: Text(
                          item['icon']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                      const SizedBox(height: 8),
                      JelloIn(
                        duration: const Duration(milliseconds: 800),
                        child: Text(
                          item['title']!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      FlipInY(
                        duration: const Duration(milliseconds: 700),
                        delay: const Duration(milliseconds: 200),
                        child: Flexible(
                          child: Text(
                            item['description']!,
                            style: const TextStyle(fontSize: 11, height: 1.3),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
