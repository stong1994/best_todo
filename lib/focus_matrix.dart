import 'package:flutter/material.dart';

class FocusMatrix extends StatelessWidget {
  final List<String> importantUrgent;
  final List<String> importantNotUrgent;
  final List<String> notImportantUrgent;
  final List<String> notImportantNotUrgent;
  final Function(String) onPressed;

  FocusMatrix({
    required this.importantUrgent,
    required this.importantNotUrgent,
    required this.notImportantUrgent,
    required this.notImportantNotUrgent,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: [
        _buildFocusGrid(
          title: 'Important and Urgent',
          items: importantUrgent,
          color: Colors.red,
        ),
        _buildFocusGrid(
          title: 'Important but Not Urgent',
          items: importantNotUrgent,
          color: Colors.orange,
        ),
        _buildFocusGrid(
          title: 'Not Important but Urgent',
          items: notImportantUrgent,
          color: Colors.yellow,
        ),
        _buildFocusGrid(
          title: 'Not Important and Not Urgent',
          items: notImportantNotUrgent,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildFocusGrid({
    required String title,
    required List<String> items,
    required Color color,
  }) {
    return Card(
      color: color,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                    items[index],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  onTap: () => onPressed(items[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
