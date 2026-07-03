# Tiny Swords — Demo Técnica Top-Down 2D

Proyecto desarrollado en **Godot 4.6.2** utilizando **GDScript** con tipado fuerte. Esta demo técnica implementa un sistema modular de combate y movimiento Top-Down 2D, con inteligencia artificial avanzada mediante Árboles de Comportamiento (Behavior Trees) y una Máquina de Estados Finitos (FSM) jerárquica para el personaje principal.

---

## Instrucciones para Abrir y Probar el Proyecto

### Requisitos y Versiones
*   **Engine:** Godot Engine **4.6.2**.
*   **Addons Requeridos:**
    *   **LimboAI** (v1.8.0): Motor de inteligencia artificial para Árboles de Comportamiento y FSM.
    *   **Shaker** (v1.0.7): Sistema de sacudida de cámara/pantalla para retroalimentación de impactos.
*   **Assets Originales:** Tiny Swords (Pixel Frog).

### Pasos para Ejecutar
1.  Descarga o clona este repositorio.
2.  Importa el proyecto en Godot Engine.
3.  Asegúrate de que los addons **LimboAI** y **Shaker** están activados en `Proyecto -> Configuración del Proyecto -> Plugins`.
4.  Abre y ejecuta la escena principal: [demo_sector.tscn](scenery/sectors/demo_sector.tscn) (ubicada en `res://scenery/sectors/demo_sector.tscn`).

### Controles
*   **Movimiento:** `W`, `A`, `S`, `D` (Movimiento Top-Down en 8 direcciones).
*   **Ataque:** `J` (Ejecuta un combo de ataques cuerpo a cuerpo).
*   **Parry (Bloqueo Perfecto):** `K` (Bloquea daño por completo durante una pequeña ventana de tiempo).
*   **Menú de Pausa:** `Esc` (Abre/cierra el menú de pausa. *Nota:* El menú no detiene el juego).


---

## Arquitectura del Proyecto: Composición sobre Herencia

### 1. Desacoplamiento Estricto de Componentes
Los nodos dentro de la carpeta `components/` están diseñados de forma ciega y autónoma:
*   [HealthComponent](components/health/health_component.gd): Gestiona exclusivamente los puntos de vida, muta variables y emite señales de estado (`damage_taken`, `died`, `max_health_changed`). No asume el tipo de su nodo padre.
*   [HitboxComponent](components/hitbox/hitbox_component.gd): Área de daño física (`Area2D`) que inflige puntos de daño a las áreas que la toquen y que posean un `HurtboxComponent`.
*   [HurtboxComponent](components/hurtbox/hurtbox_component.gd): Área receptora de daño física (`Area2D`) o entidad que detecta colisiones con `HitboxComponent` y traslada el impacto a su `HealthComponent` asignado.
*   [ProjectileLauncher](components/projectile_launcher/projectile_launcher.gd): Componente especializado para enemigos a distancia. Calcula trayectorias parabólicas interpoladas mediante un objeto de contexto de disparo (`TrajectoryContext`) y tweens para lanzar proyectiles de forma modular sin interferir con la física básica del cuerpo del enemigo.

### 2. Comunicación mediante Señales (Hacia Arriba) y Métodos (Hacia Abajo)
Para mantener un acoplamiento débil (*loose coupling*), el flujo de comunicación sigue una regla estricta:
*   **Llamadas directas hacia abajo (Métodos):** El nodo raíz invoca métodos en sus componentes hijos cuando requiere alterar su estado interno (ej: curar, aplicar daño manualmente, activar o desactivar hitboxes).
*   **Señales hacia arriba (Programación Reactiva):** Los componentes nunca modifican directamente a sus padres. Cuando ocurre un evento relevante (por ejemplo, `died`), el componente emite una señal. La entidad principal o los sistemas de interfaz de usuario se conectan a estas señales para reaccionar visual y lógicamente.

### 3. Patrón Service Locator Localizado (Variables Estáticas)
Para erradicar búsquedas lineales en el árbol de escenas que comprometan el rendimiento (como `get_tree().get_nodes_in_group()`), se implementó un patrón de **Localizador de Servicios** a través de variables de clase estáticas (`static var`):
*   `Player.active_player`: Registra su referencia en tiempo de ejecución. Permite a los enemigos y la interfaz acceder al jugador de manera instantánea, fuertemente tipada y con autocompletado desde cualquier script.
*   `MainMenu.active_menu`: Facilita la invocación del menú del juego ante eventos de Game Over de forma global y eficiente.

### 4. Inteligencia Artificial Modular y Máquinas de Estados
El comportamiento de las entidades se delega a sistemas especializados que separan la toma de decisiones de la ejecución física:
*   **Jugador (Finite State Machine):** Controlado por una máquina de estados jerárquica ([LimboHSM](player/player.gd)) estructurada en estados independientes:
    *   [IdleState](player/states/idle_state.gd) / [WalkState](player/states/walk_state.gd)
    *   [AttackState](player/states/attack_state.gd) (y sus subestados combo `Attack1State` y `Attack2State`)
    *   [ParryState](player/states/parry_state.gd): Bloquea el daño por completo durante una pequeña fracción de segundo mediante una ventana activa configurable. Utiliza un `ParryCooldownTimer` en el jugador para evitar abusos de la mecánica.
    *   [HurtState](player/states/hurt_state.gd) / [DeadState](player/states/dead_state.gd)
*   **Enemigos (LimboAI - Behavior Trees):** Los enemigos utilizan árboles de comportamiento altamente modulares ([basic_enemy.tres](enemies/ai/trees/basic_enemy.tres) y [range_enemy.tres](enemies/ai/trees/range_enemy.tres)). Las acciones específicas (perseguir, patrullar, mantener rango, huir) se encapsulan en scripts de tareas independientes en la carpeta `ai/tasks/`, facilitando la expansión del juego con nuevos enemigos sin reescribir el núcleo del código.

---

## Comportamiento Detallado de los Enemigos (Behavior Trees)

### 1. Enemigo Cuerpo a Cuerpo (Basic Enemy)

El árbol estructurado en [basic_enemy.tres](enemies/ai/trees/basic_enemy.tres) procesa la lógica mediante un Selector compuesto por tres flujos priorizados de izquierda a derecha:

*   **Persecución Reactiva (Detect and combat):** El árbol utiliza un nodo compuesto Parallel que procesa de manera simultánea la condición [InRange(0, 300)](enemies/ai/tasks/in_range.gd) y la secuencia de movimiento hacia el objetivo ([Pursue player](enemies/ai/tasks/pursue.gd)). Esto permite que el agente compruebe constantemente la distancia en tiempo real mientras se desplaza; de esta forma, si el jugador se aleja lo suficiente y rompe el rango de 300 unidades, la rama falla instantáneamente permitiendo que el jugador escape.
*   **Combate Cuerpo a Cuerpo (Melee attack):** Si el jugador está dentro del rango físico, el árbol detiene el movimiento, ejecuta [FaceTarget](enemies/ai/tasks/face_target.gd) para orientar el sprite, aplica un retraso táctico de 0.1s, invoca de manera modular el método [attack()](enemies/enemy.gd#L53) en el nodo raíz y aplica un cooldown de recuperación de 0.6s.
*   **Patrulla Pasiva (Patrol):** Si no hay detección activa del jugador, el agente reproduce su animación de movimiento, selecciona una posición aleatoria en un rango de 100.0 a 300.0 unidades ([SelectRandomNearbyPos](enemies/ai/tasks/select_random_nearby_pos.gd)) y se desplaza hacia ella mediante la tarea [Arrive](enemies/ai/tasks/arrive_pos.gd).

### 2. Enemigo a Distancia (Range Enemy)

El árbol estructurado en [range_enemy.tres](enemies/ai/trees/range_enemy.tres) gestiona las distancias de combate del arquero mediante un selector de zonas físicas:

*   **Evasión de Emergencia (Check if player gets too close):** Si el jugador rompe la distancia de seguridad entrando en un rango crítico de 0 a 200 unidades, la condición se cumple y el enemigo activa una secuencia de huida. Utiliza la tarea [SelectFleePosFrom](enemies/ai/tasks/select_flee_position_from_target.gd) para calcular un vector opuesto al jugador y se desplaza inmediatamente mediante [Arrive](enemies/ai/tasks/arrive_pos.gd).
*   **Ataque de Rango (Detect and combat):** Si el jugador se encuentra en la zona óptima de disparo ([InRange(201, 500)](enemies/ai/tasks/in_range.gd)), el enemigo se planta en el sitio, orienta su sprite con [FaceTarget](enemies/ai/tasks/face_target.gd), genera el disparo modular invocando [attack()](enemies/enemy.gd#L53) a través del componente [ProjectileLauncher](components/projectile_launcher/projectile_launcher.gd) y procesa un tiempo de recarga estricto de 1.5s.
*   **Patrulla Pasiva (Patrol):** Al igual que el enemigo básico, si el jugador está fuera del mapa de influencia, el agente patrulla zonas aleatorias cercanas para mantener el escenario dinámico.

---

## Organización de Archivos: Estructura por Funcionalidad

El sistema de archivos del proyecto implementa una **Estructura Orientada a Funcionalidades o Dominios** (*Feature-Based Structure*), alineada con la filosofía de Escenas Autocontenidas nativa de Godot.

```
prueba-tecnica/
├── addons/                  # Plugins de terceros (LimboAI, Shaker)
├── components/              # Componentes de composición (Health, Hitbox, Hurtbox, ProjectileLauncher)
├── core/                    # Sistemas y Autoloads globales (GameManager, TimeManager)
├── enemies/                 # Escenas, scripts y lógica de IA de los enemigos
│   ├── ai/                  # Behavior Trees y Tareas reutilizables (BT Tasks)
│   ├── basic_enemy/         # Enemigo cuerpo a cuerpo (Melee Enemy)
│   └── range_enemy/         # Enemigo que ataca a distancia (Range Enemy)
├── player/                  # Escenas, sprites y estados de la FSM del Player
│   └── states/              # Implementaciones individuales de los estados de la HSM
├── scenery/                 # Recursos de nivel, mapas de tilemaps y decoración
├── shared/                  # Shaders genéricos y recursos de audio compartidos
└── ui/                      # HUD e interfaces de usuario (Menús, pantallas de carga, etc.)
```

### Principio de Localización
Cada carpeta de entidad (como `player/` o `enemies/range_enemy/`) contiene todos los recursos necesarios para que el micromódulo funcione: scripts (`.gd`), escenas (`.tscn`), texturas y animaciones. Si se necesita remover un enemigo, basta con eliminar su directorio sin romper referencias externas ni dejar archivos huérfanos.

---

## Retroalimentación y Juice (Sensación de Juego)

Se añadieron diversas mecánicas de impacto y retroalimentación para hacer el juego mucho más interactivo y satisfactorio:

1.  **Hit Stop (Detención del Tiempo):** Implementado en el autoload global [TimeManager](core/autoloads/TimeManager.gd). Detiene o ralentiza momentáneamente la escala de tiempo del juego (`Engine.time_scale`) en los impactos críticos y muertes para dar peso a los golpes.
2.  **Hit Flash Shader:** Al recibir daño, los sprites de los personajes ejecutan un efecto de destello de color (blanco/rojo) controlado dinámicamente mediante el sombreador [flash.gdshader](shared/shaders/flash.gdshader) y un nodo `Tween`.
3.  **Camera Shake (Sacudida de Pantalla):** Integrado mediante `ShakerComponent2D` en la cámara del jugador, activándose cuando el jugador recibe daño para acentuar el impacto físico.
4.  **Sistema de Partículas:** Emisión de chispas y partículas de destello al realizar un **Parry exitoso**.
5.  **Sonorización Completa:**
    *   Música de fondo en bucle.
    *   Efectos de sonido (SFX) para pasos (*Footsteps*) diferenciados, ataques físicos del jugador, lanzamiento de flechas de los enemigos de rango e impactos.
    *   *Créditos de Audio:* Sonidos extraídos de **Free Fantasy SFX Pack by TomMusic**.

---

## Buenas Prácticas Aplicadas

*   **Tipado Fuerte Obligatorio:** Todo el código GDScript está fuertemente tipado (`var x : Type`, `func foo() -> void`).
*   **Guía de Estilo Oficial:** Cumplimiento estricto con las convenciones oficiales de Godot (nomenclatura `snake_case` para variables/funciones, `PascalCase` para nombres de clase, constantes en `SCREAMING_SNAKE_CASE` y señales en pasado).
*   **Ausencia de Magic Numbers:** Los valores numéricos arbitrarios fueron extraídos en constantes autodescriptivas a nivel de clase.
*   **Proyecto Limpio:** Libre de errores y advertencias al cargarse y ejecutarse en el editor de Godot.
