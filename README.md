# Laser Mirror Mini

A time-based puzzle game built with Flutter where players manipulate mirrors and optical elements to guide laser beams to their targets.

## Features

### Game Mechanics
- **Mirror Reflection**: Rotate mirrors to reflect laser beams at perfect angles (θ incident = θ reflected)
- **Beam Splitters**: Divide a single laser into multiple perpendicular beams
- **Portals**: Teleport laser beams between linked portal pairs
- **Color Filters**: Allow only specific laser colors to pass through
- **Obstacles**: Block laser paths and add complexity to puzzles

### Game Modes
- **Campaign**: 50 handcrafted levels across 5 chapters
  - Chapter 1: Basic Mirrors (10 levels)
  - Chapter 2: Splitters (10 levels)
  - Chapter 3: Portals (10 levels)
  - Chapter 4: Color Filters (10 levels)
  - Chapter 5: Mixed Mechanics (10 levels)
- **Puzzle Rush**: Time-attack mode with 10 random levels in 5 minutes
- **Daily Challenge**: Procedurally generated daily puzzle

### Progression System
- **Star Ratings**: Earn 1-3 stars based on completion time and rotation count
- **Crystals**: In-game currency earned from completing levels
- **Achievements**: 5 unique achievements to unlock
- **Level Packs**: Purchase additional level packs from the shop

### Shop System
- **Power-ups**: Trajectory hints that show laser path for 3 seconds
- **Skins**: Cosmetic customization options (Neon, Classic)
- **Level Packs**: Additional challenge levels

### Technical Features
- Accurate laser physics simulation with ray tracing
- SQLite local storage for progress and achievements
- Haptic feedback for interactions
- Audio support (extensible)
- Replay system with ghost solutions
- 60 FPS target with optimized rendering
- Low energy consumption

## Installation

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher

### Setup
1. Clone or download this project
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── game_element.dart       # Game elements (mirrors, targets, etc.)
│   ├── game_state.dart         # Game state management
│   ├── laser_beam.dart         # Laser path representation
│   └── level.dart              # Level configuration
├── screens/                     # UI screens
│   ├── main_menu_screen.dart
│   ├── level_select_screen.dart
│   ├── game_screen.dart
│   ├── shop_screen.dart
│   └── achievements_screen.dart
├── widgets/                     # Reusable widgets
│   └── game_board.dart         # Game board rendering
├── services/                    # Business logic
│   ├── game_controller.dart    # Game state controller
│   ├── laser_physics.dart      # Laser simulation engine
│   ├── database_service.dart   # Local storage
│   ├── audio_service.dart      # Audio management
│   ├── achievement_service.dart
│   ├── replay_service.dart
│   ├── puzzle_rush_service.dart
│   └── daily_challenge_service.dart
└── utils/                       # Utilities
    └── level_data.dart         # Level definitions
```

## Game Rules

### Objective
Guide laser beams from sources to targets by rotating optical elements.

### Controls
- **Tap** an element to rotate it 90 degrees clockwise
- Fixed elements (gray) cannot be rotated
- Use the hint power-up to preview the laser path

### Scoring
- Complete levels as quickly as possible with minimal rotations
- Earn 3 stars by meeting both time and rotation requirements
- Unlock achievements for special accomplishments

### Constraints
- Some levels have rotation limits
- Some levels have time limits
- Breaking constraints reduces star rating

## Achievements

1. **One Beam Two Goals**: Activate two targets with a single laser beam
2. **Speed of Light**: Complete a level in under 10 seconds
3. **Pure Optics**: Complete a level without unnecessary rotations
4. **Perfectionist**: Get 3 stars on 10 levels
5. **Master Puzzler**: Complete all levels in a chapter

## Development

### Key Systems

#### Laser Physics Engine
Located in `lib/services/laser_physics.dart`, implements:
- Ray tracing with accurate reflection angles
- Beam splitting at splitter elements
- Portal teleportation
- Color filtering
- Obstacle collision detection

#### Database Schema
SQLite database with tables:
- `progress`: Level completion data with star ratings
- `inventory`: Player currency and purchased items
- `achievements`: Achievement unlock status
- `daily_challenge`: Daily challenge cache

#### Level Design
Levels are defined in `lib/utils/level_data.dart` with:
- Grid dimensions
- Element positions and properties
- Constraints (time/rotation limits)
- Star requirements
- Tutorial text (for new mechanics)

## Performance

- Target: 60 FPS
- Optimized rendering with CustomPainter
- Efficient laser tracing with bounce limits
- Minimal memory allocation during gameplay

## Localization

Currently supports English (EN). The codebase is structured for easy expansion to additional languages.

## Credits

Built with Flutter/Dart using native solutions without game engines (no Flame).

## License

All rights reserved.
