// Lab4 Davi Chaves 2026
// Coke Machine

import 'package:flutter/material.dart';

void main() {
  runApp(Lab4());
}

class Lab4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: "Lab 4", home: CokeMachineHome());
  }
}

class CokeMachineHome extends StatefulWidget {
  @override
  CokeMachineHomeState createState() => CokeMachineHomeState();
}

class CokeMachineHomeState extends State<CokeMachineHome> {
  final List<String> columns = ["A", "B", "C", "D", "E"];
  final List<String> rows = ["0", "1", "2", "3", "4"];

  String? selectedColumn;
  String? selectedRow;
  final Set<String> boughtCans = {};

  void _onColumnPressed(String col) {
    setState(() {
      selectedColumn = col;
    });
  }

  void _onRowPressed(String row) {
    setState(() {
      selectedRow = row;
    });
  }

  void _onBuyPressed() {
    if (selectedColumn != null && selectedRow != null) {
      final canId = "$selectedColumn$selectedRow";
      setState(() {
        if (!boughtCans.contains(canId)) {
          boughtCans.add(canId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lab 4 - Davi Chaves")),
      body: Center(
        child: Column(
          children: [
            // Info Area
            Text("Selected: ${selectedColumn ?? '_'}${selectedRow ?? '_'}"),

            // The Grid Construction
            Column(
              children: [
                // Top Header Row: Spacer + Column Buttons (A, B, C...)
                Row(
                  children: [
                    // Spacer for the top-left corner
                    SizedBox(width: 50.0, height: 50.0),
                    // Column Buttons
                    ...columns.map(
                      (col) => Container(
                        width: 50.0,
                        height: 50.0,
                        child: FloatingActionButton(
                          onPressed: () => _onColumnPressed(col),
                          child: Text(col),
                        ),
                      ),
                    ),
                  ],
                ),

                // Grid Rows: Row Button + Grid Cells
                ...rows.map((row) {
                  return Row(
                    children: [
                      // Row Button (Left side)
                      FloatingActionButton(
                        onPressed: () => _onRowPressed(row),
                        child: Text(row),
                      ),
                      // Grid Cells for this row
                      ...columns.map((col) {
                        final canId = "$col$row";
                        final bool isBought = boughtCans.contains(canId);
                        return Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black),
                          ),
                          child: Center(child: isBought ? null : Text(canId)),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ],
            ),

            // Buy Button
            FloatingActionButton(
              onPressed: (selectedColumn != null && selectedRow != null)
                  ? _onBuyPressed
                  : null,
              child: Text("Buy"),
            ),
          ],
        ),
      ),
    );
  }
}
