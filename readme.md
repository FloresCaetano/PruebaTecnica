# Tiny Swords — 2D Top-Down Technical Demo

Project built in **Godot 4.6.2** using strongly-typed **GDScript**. This technical demo implements a modular 2D top-down combat and movement system, with advanced AI via Behavior Trees and a hierarchical Finite State Machine (FSM) for the main character.

---

## Instructions to Open and Run the Project

### Requirements and Versions
*   **Engine:** Godot Engine **4.6.2**.
*   **Required Addons:**
    *   **LimboAI** (v1.8.0): AI engine for Behavior Trees and FSM.
    *   **Shaker** (v1.0.7): Camera/screen shake system for impact feedback.
*   **Original Assets:** Tiny Swords (Pixel Frog).

### Steps to Run
1.  Download or clone this repository.
2.  Import the project into Godot Engine.
3.  Make sure the **LimboAI** and **Shaker** addons are enabled under `Project -> Project Settings -> Plugins`.
4.  Open and run the main scene: [demo_sector.tscn](scenery/sectors/demo_sector.tscn) (located at `res://scenery/sectors/demo_sector.tscn`).

### Controls
*   **Movement:** `W`, `A`, `S`, `D` (8-directional top-down movement).
*   **Attack:** `J` (executes a melee attack combo).
*   **Parry (Perfect Block):** `K` (fully blocks damage during a small time window).
*   **Pause Menu:** `Esc` (opens/closes the pause menu. *Note:* the menu does not stop the game).


---

## Project Architecture: Composition over Inheritance

### 1. Strict Component Decoupling
Nodes inside the `components/` folder are designed to be blind and self-contained:
*   [HealthComponent](components/health/health_component.gd): Exclusively manages health points, mutates its own variables, and emits state signals (`damage_taken`, `died`, `max_health_changed`). It never assumes the type of its parent node.
*   [HitboxComponent](components/hitbox/hitbox_component.gd): Physical damage area (`Area2D`) that deals damage to any area it touches that owns a `HurtboxComponent`.
*   [HurtboxComponent](components/hurtbox/hurtbox_component.gd): Physical damage-receiving area (`Area2D`) or entity that detects collisions with a `HitboxComponent` and forwards the impact to its assigned `HealthComponent`.
*   [ProjectileLauncher](components/projectile_launcher/projectile_launcher.gd): Specialized component for ranged enemies. Calculates interpolated parabolic trajectories through a shot context object (`TrajectoryContext`) and tweens to launch projectiles modularly without interfering with the enemy body's base physics.

### 2. Communication via Signals (Upward) and Methods (Downward)
To keep loose coupling, communication follows a strict rule:
*   **Direct calls downward (Methods):** The root node invokes methods on its child components when it needs to alter their internal state (e.g. heal, manually apply damage, enable/disable hitboxes).
*   **Signals upward (Reactive Programming):** Components never modify their parents directly. When a relevant event occurs (e.g. `died`), the component emits a signal. The main entity or UI systems connect to these signals to react visually and logically.

### 3. Localized Service Locator Pattern (Static Variables)
To avoid linear scene-tree lookups that hurt performance (like `get_tree().get_nodes_in_group()`), a **Service Locator** pattern was implemented through static class variables (`static var`):
*   `Player.active_player`: Registers its runtime reference. Lets enemies and the UI access the player instantly, strongly typed and with autocompletion from any script.
*   `MainMenu.active_menu`: Makes it easy to invoke the game menu on Game Over events globally and efficiently.

### 4. Modular AI and State Machines
Entity behavior is delegated to specialized systems that separate decision-making from physical execution:
*   **Player (Finite State Machine):** Controlled by a hierarchical state machine ([LimboHSM](player/player.gd)) structured into independent states:
    *   [IdleState](player/states/idle_state.gd) / [WalkState](player/states/walk_state.gd)
    *   [AttackState](player/states/attack_state.gd) (and its combo substates `Attack1State` and `Attack2State`)
    *   [ParryState](player/states/parry_state.gd): Fully blocks damage for a small fraction of a second through a configurable active window. Uses a `ParryCooldownTimer` on the player to prevent ability spam.
    *   [HurtState](player/states/hurt_state.gd) / [DeadState](player/states/dead_state.gd)
*   **Enemies (LimboAI - Behavior Trees):** Enemies use highly modular behavior trees ([basic_enemy.tres](enemies/ai/trees/basic_enemy.tres) and [range_enemy.tres](enemies/ai/trees/range_enemy.tres)). Specific actions (chase, patrol, keep range, flee) are encapsulated in independent task scripts inside `ai/tasks/`, making it easy to add new enemies without rewriting the core code.

---

## Detailed Enemy Behavior (Behavior Trees)

### 1. Melee Enemy (Basic Enemy)

The tree defined in [basic_enemy.tres](enemies/ai/trees/basic_enemy.tres) processes logic through a Selector made up of three flows prioritized left to right:

*   **Reactive Pursuit (Detect and combat):** The tree uses a Parallel composite node that simultaneously processes the [InRange(0, 300)](enemies/ai/tasks/in_range.gd) condition and the movement sequence toward the target ([Pursue player](enemies/ai/tasks/pursue.gd)). This lets the agent constantly check the real-time distance while moving; if the player moves far enough away to break the 300-unit range, the branch fails instantly, letting the player escape.
*   **Melee Combat (Melee attack):** If the player is within physical range, the tree stops movement, runs [FaceTarget](enemies/ai/tasks/face_target.gd) to orient the sprite, applies a 0.1s tactical delay, modularly invokes the [attack()](enemies/enemy.gd#L53) method on the root node, and applies a 0.6s recovery cooldown.
*   **Passive Patrol (Patrol):** If there's no active player detection, the agent plays its movement animation, picks a random position within a range of 100.0 to 300.0 units ([SelectRandomNearbyPos](enemies/ai/tasks/select_random_nearby_pos.gd)), and moves toward it via the [Arrive](enemies/ai/tasks/arrive_pos.gd) task.

### 2. Range Enemy

The tree defined in [range_enemy.tres](enemies/ai/trees/range_enemy.tres) manages the archer's combat distances through a physical-zone selector:

*   **Emergency Evasion (Check if player gets too close):** If the player breaks the safety distance by entering a critical 0-200 unit range, the condition triggers and the enemy starts a flee sequence. It uses the [SelectFleePosFrom](enemies/ai/tasks/select_flee_position_from_target.gd) task to compute a vector opposite the player and immediately moves via [Arrive](enemies/ai/tasks/arrive_pos.gd).
*   **Ranged Attack (Detect and combat):** If the player is in the optimal firing zone ([InRange(201, 500)](enemies/ai/tasks/in_range.gd)), the enemy plants itself, orients its sprite with [FaceTarget](enemies/ai/tasks/face_target.gd), fires modularly by invoking [attack()](enemies/enemy.gd#L53) through the [ProjectileLauncher](components/projectile_launcher/projectile_launcher.gd) component, and processes a strict 1.5s reload time.
*   **Passive Patrol (Patrol):** Just like the basic enemy, if the player is outside its influence radius, the agent patrols nearby random zones to keep the scene dynamic.

---

## File Organization: Feature-Based Structure

The project's file system implements a **Feature/Domain-Based Structure**, aligned with Godot's native Self-Contained Scenes philosophy.

```
prueba-tecnica/
├── addons/                  # Third-party plugins (LimboAI, Shaker)
├── components/              # Composition components (Health, Hitbox, Hurtbox, ProjectileLauncher)
├── core/                    # Global systems and Autoloads (GameManager, TimeManager)
├── enemies/                 # Enemy scenes, scripts, and AI logic
│   ├── ai/                  # Behavior Trees and reusable Tasks (BT Tasks)
│   ├── basic_enemy/         # Melee Enemy
│   └── range_enemy/         # Range Enemy
├── player/                  # Player scenes, sprites, and FSM states
│   └── states/              # Individual HSM state implementations
├── scenery/                 # Level resources, tilemaps, and decoration
├── shared/                  # Generic shaders and shared audio resources
└── ui/                      # HUD and user interfaces (menus, loading screens, etc.)
```

### Localization Principle
Each entity folder (like `player/` or `enemies/range_enemy/`) contains all the resources the micro-module needs to work: scripts (`.gd`), scenes (`.tscn`), textures, and animations. To remove an enemy, it's enough to delete its directory without breaking external references or leaving orphaned files.

---

## Feedback and Juice (Game Feel)

Several impact and feedback mechanics were added to make the game much more interactive and satisfying:

1.  **Hit Stop (Time Freeze):** Implemented in the global autoload [TimeManager](core/autoloads/TimeManager.gd). Momentarily stops or slows down the game's time scale (`Engine.time_scale`) on critical hits and deaths to give weight to impacts.
2.  **Hit Flash Shader:** When taking damage, character sprites run a color flash effect (white/red) driven dynamically through the [flash.gdshader](shared/shaders/flash.gdshader) shader and a `Tween` node.
3.  **Camera Shake:** Integrated via `ShakerComponent2D` on the player's camera, triggered when the player takes damage to accentuate the physical impact.
4.  **Particle System:** Spark and flash particles on a **successful Parry**.
5.  **Full Sound Design:**
    *   Looping background music.
    *   Differentiated footstep SFX, player melee attacks, ranged enemy arrow shots, and impacts.
    *   *Audio Credits:* Sounds sourced from the **Free Fantasy SFX Pack by TomMusic**.

---

## Best Practices Applied

*   **Mandatory Strong Typing:** All GDScript code is strongly typed (`var x : Type`, `func foo() -> void`).
*   **Official Style Guide:** Strict compliance with Godot's official conventions (`snake_case` for variables/functions, `PascalCase` for class names, `SCREAMING_SNAKE_CASE` constants, and past-tense signals).
*   **No Magic Numbers:** Arbitrary numeric values were extracted into self-descriptive class-level constants.
*   **Clean Project:** Loads and runs free of errors and warnings in the Godot editor.
