import 'package:flutter/material.dart';

void main() {
  runApp(const HW2Davi());
}

class HW2Davi extends StatelessWidget {
  const HW2Davi({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HW2 Davi Chaves',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HW2DaviPage(title: 'HW2 Davi Chaves'),
    );
  }
}

class HW2DaviPage extends StatefulWidget {
  const HW2DaviPage({super.key, required this.title});

  final String title;

  @override
  State<HW2DaviPage> createState() => _HW2DaviPageState();
}

class _HW2DaviPageState extends State<HW2DaviPage> {
  int gridSizeX = 5;
  int gridSizeY = 5;
  int robotX = 0;
  int robotY = 0;

  void _moveNorth() {
    setState(() {
      if (robotY > 0) {
        robotY -= 1;
      }
    });
  }

  void _moveSouth() {
    setState(() {
      if (robotY < gridSizeY - 1) {
        robotY += 1;
      }
    });
  }

  void _moveEast() {
    setState(() {
      if (robotX < gridSizeX - 1) {
        robotX += 1;
      }
    });
  }

  void _moveWest() {
    setState(() {
      if (robotX > 0) {
        robotX -= 1;
      }
    });
  }

  // Build the grid for the robot
  Widget _buildGrid() {
    return SizedBox(
      width: 300,
      height: 300,
      child: GridView.builder(
        // using gridview to build the grid
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSizeX,
        ),
        itemCount: gridSizeX * gridSizeY,
        itemBuilder: (context, index) {
          // calculate the x and y coordinates of the current cell
          int x = index % gridSizeX;
          int y = index ~/ gridSizeX;
          // check if the robot is at the current cell
          bool isRobotHere = (x == robotX && y == robotY);

          return Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.black)),
            child: Center(
              child: Text(
                isRobotHere ? 'R' : '',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildGrid(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _moveNorth,
                  child: const Text('North'),
                ),
                ElevatedButton(onPressed: _moveWest, child: const Text('West')),
                ElevatedButton(onPressed: _moveEast, child: const Text('East')),
                ElevatedButton(
                  onPressed: _moveSouth,
                  child: const Text('South'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
