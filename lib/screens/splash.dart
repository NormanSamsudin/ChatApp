import 'package:flutter/material.dart';

// loading screen when firebase is figuring out
class SplashScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat'),
      ),
      body: const Center(
        child: Text('Loading')
      ),
    );
  }
}
