import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;

  final TextEditingController _nameController = TextEditingController();

  Timer? _hungerTimer;
  Timer? _winTimer;

  int _consecutiveHappiness = 0; 
  bool _gameOver = false;
  bool _gameWon = false;

  @override
  void initState() {
    super.initState();
    _startTimers();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _startTimers() {
    // Timer for hunger increase (every 5 seconds)
    _hungerTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_gameOver || _gameWon) return;
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        _checkLossCondition();
      });
    });

    // Timer for win condition tracking (every 1 second)
    _winTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_gameOver || _gameWon) return;
      
      setState(() {
        // Check if happiness is high enough
        if (happinessLevel >= 80) {
          _consecutiveHappiness++;
          
          // Check win condition (180 seconds = 3 minutes)
          if (_consecutiveHappiness >= 180) {
            _gameWon = true;
            _hungerTimer?.cancel();
            _winTimer?.cancel();
          }
        } else {
          // Reset counter if happiness drops below 80
          _consecutiveHappiness = 0;
        }
      });
    });
  }

  void _checkLossCondition() {
    // Loss condition: hunger reaches 100 AND happiness is 10 or below
    if (hungerLevel >= 100 && happinessLevel <= 10) {
      _gameOver = true;
      _hungerTimer?.cancel();
      _winTimer?.cancel();
    }
  }

  Color _moodColor(int happinessLevel) {
    if (happinessLevel >= 80) {
      return const Color.fromARGB(255, 113, 165, 115); // Green for happy
    } else if (happinessLevel >= 50) {
      return const Color.fromARGB(255, 144, 140, 99); // Yellow for neutral
    } else {
      return const Color.fromARGB(255, 182, 121, 117); // Red for sad
    }
  }

  void _playWithPet() {
    if (_gameOver || _gameWon) return;
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
      _checkLossCondition();
    });
  }

  void _feedPet() {
    if (_gameOver || _gameWon) return;
    setState(() {
      hungerLevel = (hungerLevel - 20).clamp(0, 100);
      _updateHappiness();
      _checkLossCondition();
    });
  }

  void _updateHappiness() {
    if (hungerLevel < 30) {
      happinessLevel = (happinessLevel - 5).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  void _updateHunger() {
    hungerLevel = (hungerLevel + 5).clamp(0, 100);
    if (hungerLevel >= 100) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    }
  }

  void _setName() {
    final input = _nameController.text.trim();
    if (input.isNotEmpty) {
      setState(() => petName = input);
      _nameController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _restartGame() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    
    setState(() {
      petName = "Your Pet";
      happinessLevel = 50;
      hungerLevel = 50;
      _consecutiveHappiness = 0;
      _gameOver = false;
      _gameWon = false;
      _nameController.clear();
    });
    
    _startTimers();
  }

  @override
  Widget build(BuildContext context) {
    // Show Game Over screen
    if (_gameOver) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('💀 Game Over!', 
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.red)),
              SizedBox(height: 16),
              Text('$petName was too hungry and unhappy...', 
                style: TextStyle(fontSize: 18)),
              SizedBox(height: 32),
              ElevatedButton(onPressed: _restartGame, child: Text('Try Again')),
            ],
          ),
        ),
      );
    }

    // Show Win screen
    if (_gameWon) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎉 You Win!', 
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.green)),
              SizedBox(height: 16),
              Text('$petName was happy for 3 whole minutes!', 
                style: TextStyle(fontSize: 18)),
              SizedBox(height: 32),
              ElevatedButton(onPressed: _restartGame, child: Text('Play Again')),
            ],
          ),
        ),
      );
    }

    // Progress toward win (in seconds)
    double winProgress = _consecutiveHappiness / 180.0;

    return Scaffold(
      appBar: AppBar(title: Text('Digital Pet')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Pet name input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Enter pet name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(onPressed: _setName, child: Text('Set Name')),
                ],
              ),
              SizedBox(height: 24),

              // Pet image with mood-based color filter
              ColorFiltered(
                colorFilter: ColorFilter.mode(_moodColor(happinessLevel), BlendMode.modulate),
                child: Image.asset('assets/propellerdog.png'),
              ),
              SizedBox(height: 16),

              // Pet stats
              Text('Name: $petName', style: TextStyle(fontSize: 20)),
              SizedBox(height: 8),
              Text('Happiness: $happinessLevel', style: TextStyle(fontSize: 20)),
              SizedBox(height: 8),
              Text('Hunger: $hungerLevel', style: TextStyle(fontSize: 20)),
              SizedBox(height: 16),

              // Win progress bar (only shows when happiness > 80)
              if (happinessLevel > 80) ...[
                Text('Keep it up! Happy time: ${_consecutiveHappiness}s / 180s', 
                  style: TextStyle(color: Colors.green)),
                SizedBox(height: 8),
                LinearProgressIndicator(
                  value: winProgress,
                  backgroundColor: Colors.grey[300],
                  color: Colors.green,
                  minHeight: 10,
                ),
                SizedBox(height: 16),
              ],

              // Action buttons
              ElevatedButton(onPressed: _playWithPet, child: Text('Play with Your Pet')),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _feedPet, child: Text('Feed Your Pet')),
            ],
          ),
        ),
      ),
    );
  }
}