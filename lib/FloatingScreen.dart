import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import 'BackGroundScreen.dart';
import 'pip_view.dart';

class FloatingScreen extends StatefulWidget {
  const FloatingScreen({super.key});

  @override
  State<FloatingScreen> createState() => _FloatingScreenState();
}

class _FloatingScreenState extends State<FloatingScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(children: [
            // There will be a carausal of images here, which will be displayed inside the contianer.
            CarouselSlider(
              options: CarouselOptions(
                // the height will be the height of the container
                height: MediaQuery.of(context).size.height,
                enableInfiniteScroll: false,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                autoPlayCurve: Curves.fastOutSlowIn,
              ),
              items: [
                "https://picsum.photos/id/3/800/500.jpg",
                "https://picsum.photos/id/7/800/500.jpg",
                "https://picsum.photos/id/9/800/500.jpg",
              ].map((String imageUrl) {
                return Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                );
              }).toList(),
            ),
            Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                    icon: const Icon(
                      Icons.picture_in_picture,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // when this button is pressed the screen should be minimized to the bottom left corner,
                      // and the background screen should be visible.
                      
                    })),
          ])),
    );
  }
}
