import 'package:flutter/material.dart';

class PropertyDetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Property Details')),
      body: Center(
        child: Text('Detailed view of selected property'),
      ),
    );
  }
}