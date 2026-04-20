import 'package:flame/collisions.dart'; // Importa funciones de detección de colisiones del motor Flame
import 'package:flame/components.dart'; // Importa componentes base para crear objetos del juego
import 'package:flame/events.dart'; // Importa eventos como toques y gestos del usuario
import 'package:flame/experimental.dart'; // Importa características experimentales de Flame
import 'package:flame/game.dart'; // Importa la clase principal del juego (FlameGame)
import 'package:flame/input.dart'; // Importa funciones para detectar entrada del usuario
import 'package:flame/parallax.dart'; // Importa componente de efecto parallax (fondos en movimiento)
import 'package:flutter/material.dart'; // Importa componentes básicos de Flutter (UI)

void main() { // Punto de entrada principal del programa
  runApp(GameWidget(game: SpaceShooterGame())); // Inicia la app con el widget del juego
}

class SpaceShooterGame extends FlameGame // Clase principal que hereda de FlameGame
    with PanDetector, HasCollisionDetection { // Detecta gestos de arrastre y colisiones
  late Player player; // Declara una variable que guardará al jugador

  @override
  Future<void> onLoad() async { // Método que se ejecuta cuando carga todo el juego
    final parallax = await loadParallaxComponent( // Carga el fondo con efecto parallax (capas que se mueven a diferentes velocidades)
      [ // Lista de imágenes que forman el fondo
        ParallaxImageData('stars_0.png'), // Primera capa de estrellas (la más lejana)
        ParallaxImageData('stars_1.png'), // Segunda capa de estrellas (distancia media)
        ParallaxImageData('stars_2.png'), // Tercera capa de estrellas (la más cercana)
      ],
      baseVelocity: Vector2(0, -5), // Velocidad base: se mueve hacia arriba
      repeat: ImageRepeat.repeat, // Repite las imágenes para que el fondo sea infinito
      velocityMultiplierDelta: Vector2(0, 5), // Cada capa se mueve 5 píxeles más rápido que la anterior
    );
    add(parallax); // Añade el fondo al juego

    player = Player(); // Crea una nueva instancia del jugador
    add(player); // Añade el jugador al juego para que aparezca y se actualice

    add( // Añade un componente generador de enemigos
      SpawnComponent( // Crea enemigos automáticamente
        factory: (index) { // Esta función es la "fábrica" que crea cada enemigo
          return Enemy(); // Crea y retorna un nuevo enemigo
        },
        period: 1, // Genera un enemigo cada 1 segundo
        area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize), // Área donde aparecen los enemigos (arriba de la pantalla)
      ),
    );
  }

  @override
  void onPanUpdate(DragUpdateInfo info) { // Se ejecuta cada vez que el jugador mueve el dedo en la pantalla
    player.move(info.delta.global); // Mueve el jugador según cuánto se movió el dedo
  }

  @override
  void onPanStart(DragStartInfo info) { // Se ejecuta cuando empieza a tocar la pantalla (presiona)
    player.startShooting(); // Inicia los disparos del jugador
  }

  @override
  void onPanEnd(DragEndInfo info) { // Se ejecuta cuando deja de tocar la pantalla (suelta)
    player.stopShooting(); // Para los disparos del jugador
  }
}

class Player extends SpriteAnimationComponent // Clase del jugador que puede mostrar animaciones
    with HasGameReference<SpaceShooterGame> { // Permite acceder a referencias del juego
  Player() // Constructor del jugador
    : super(
        size: Vector2(100, 150), // Tamaño: 100 de ancho, 150 de alto
        anchor: Anchor.center, // El punto central del sprite está en el centro
      );

  late final SpawnComponent _bulletSpawner; // Generador de balas que se inicializa después

  @override
  Future<void> onLoad() async { // Se ejecuta cuando carga el jugador en el juego
    await super.onLoad(); // Llama al método onLoad de la clase padre

    animation = await game.loadSpriteAnimation( // Carga la animación del jugador
      'player.png', // Archivo de imagen que contiene todos los frames de la animación
      SpriteAnimationData.sequenced( // Configura cómo se anima la imagen
        amount: 4, // La animación tiene 4 frames (4 imágenes diferentes)
        stepTime: 0.2, // Cada frame dura 0.2 segundos (5 frames por segundo)
        textureSize: Vector2(32, 48), // Tamaño de cada frame en píxeles (32x48)
      ),
    );

    position = game.size / 2; // Coloca el jugador en el centro de la pantalla

    _bulletSpawner = SpawnComponent( // Crea el generador de balas
      period: 0.2, // Genera una bala cada 0.2 segundos (5 balas por segundo)
      selfPositioning: true, // Las balas posicionan a sí mismas (no usan la posición del spawner)
      factory: (index) { // Función que crea cada bala
        return Bullet( // Crea una nueva bala
          position: // Posición donde aparece la bala
              position + // Posición actual del jugador más...
              Vector2( // Un desplazamiento de:
                0, // 0 píxeles a la derecha
                -height / 2, // La mitad de la altura del jugador hacia arriba
              ),
        );
      },
      autoStart: false, // No comienza a generar balas automáticamente (espera a que se llame startShooting)
    );

    game.add(_bulletSpawner); // Añade el generador de balas al juego
  }

  void move(Vector2 delta) { // Método para mover el jugador
    position.add(delta); // Suma el movimiento a la posición actual
  }

  void startShooting() { // Método para comenzar a disparar
    _bulletSpawner.timer.start(); // Inicia el temporizador del generador de balas
  }

  void stopShooting() { // Método para dejar de disparar
    _bulletSpawner.timer.stop(); // Detiene el temporizador del generador de balas
  }
}

class Bullet extends SpriteAnimationComponent // Clase de las balas que pueden tener animación
    with HasGameReference<SpaceShooterGame> { // Permite acceder a referencias del juego
  Bullet({ // Constructor de la bala
    super.position, // Recibe la posición inicial como parámetro
  }) : super(
         size: Vector2(25, 50), // Tamaño: 25 de ancho, 50 de alto
         anchor: Anchor.center, // El punto central del sprite está en el centro
       );

  @override
  Future<void> onLoad() async { // Se ejecuta cuando carga la bala en el juego
    await super.onLoad(); // Llama al método onLoad de la clase padre

    animation = await game.loadSpriteAnimation( // Carga la animación de la bala
      'bullet.png', // Archivo de imagen que contiene los frames de la animación
      SpriteAnimationData.sequenced( // Configura cómo se anima la imagen
        amount: 4, // La animación tiene 4 frames
        stepTime: 0.2, // Cada frame dura 0.2 segundos
        textureSize: Vector2(8, 16), // Tamaño de cada frame (8x16 píxeles)
      ),
    );

    add( // Añade una forma de colisión a la bala
      RectangleHitbox( // Crea una caja rectangular para detectar colisiones
        collisionType: CollisionType.passive, // La bala es "pasiva" (no impulsa otros objetos, solo detecta)
      ),
    );
  }

  @override
  void update(double dt) { // Se ejecuta cada frame para actualizar la bala (dt = tiempo desde el último frame)
    super.update(dt); // Llama al update de la clase padre

    position.y += dt * -500; // Mueve la bala hacia arriba (-500 píxeles por segundo)

    if (position.y < -height) { // Si la bala salió por la parte superior de la pantalla
      removeFromParent(); // Elimina la bala del juego
    }
  }
}

class Enemy extends SpriteAnimationComponent // Clase de los enemigos que pueden tener animación
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks { // Permite acceder al juego y detectar colisiones
  Enemy({ // Constructor del enemigo
    super.position, // Recibe la posición inicial como parámetro
  }) : super(
         size: Vector2.all(enemySize), // Tamaño: enemySize por enemySize (cuadrado)
         anchor: Anchor.center, // El punto central del sprite está en el centro
       );

  static const enemySize = 50.0; // Constante: tamaño del enemigo (50x50 píxeles)

  @override
  Future<void> onLoad() async { // Se ejecuta cuando carga el enemigo en el juego
    await super.onLoad(); // Llama al método onLoad de la clase padre

    animation = await game.loadSpriteAnimation( // Carga la animación del enemigo
      'enemy.png', // Archivo de imagen que contiene los frames de la animación
      SpriteAnimationData.sequenced( // Configura cómo se anima la imagen
        amount: 4, // La animación tiene 4 frames
        stepTime: 0.2, // Cada frame dura 0.2 segundos
        textureSize: Vector2.all(16), // Tamaño de cada frame (16x16 píxeles)
      ),
    );

    add(RectangleHitbox()); // Añade una caja rectangular para detectar colisiones
  }

  @override
  void update(double dt) { // Se ejecuta cada frame para actualizar el enemigo
    super.update(dt); // Llama al update de la clase padre

    position.y += dt * 250; // Mueve el enemigo hacia abajo (250 píxeles por segundo)

    if (position.y > game.size.y) { // Si el enemigo salió por la parte inferior de la pantalla
      removeFromParent(); // Elimina el enemigo del juego
    }
  }

  @override
  void onCollisionStart( // Se ejecuta cuando empieza una colisión con otro objeto
    Set<Vector2> intersectionPoints, // Puntos donde chocan los dos objetos
    PositionComponent other, // El otro objeto con el que choca
  ) {
    super.onCollisionStart(intersectionPoints, other); // Llama al método de la clase padre

    if (other is Bullet) { // Si el objeto que choca es una bala
      removeFromParent(); // Elimina el enemigo del juego
      other.removeFromParent(); // Elimina la bala del juego
      game.add(Explosion(position: position)); // Crea una explosión en la posición del enemigo
    }
  }
}
// La clase Enemy detecta colisiones con balas. Cuando un enemigo colisiona con una bala, ambos se eliminan del juego y se crea una explosión en la posición del enemigo. Esto se logra mediante el método onCollisionStart, que verifica si el otro objeto es una instancia de Bullet y luego realiza las acciones correspondientes.
class Explosion extends SpriteAnimationComponent // Clase de las explosiones que tienen animación
    with HasGameReference<SpaceShooterGame> { // Permite acceder a referencias del juego
  Explosion({ // Constructor de la explosión
    super.position, // Recibe la posición inicial como parámetro
  }) : super(
         size: Vector2.all(150), // Tamaño: 150x150 píxeles
         anchor: Anchor.center, // El punto central del sprite está en el centro
         removeOnFinish: true, // Se elimina automáticamente cuando termina la animación
       );
// La propiedad removeOnFinish hace que el componente se elimine del juego automáticamente cuando la animación termine, lo que es ideal para efectos como explosiones que solo deben mostrarse una vez.
  @override
  Future<void> onLoad() async { // Se ejecuta cuando carga la explosión en el juego
    await super.onLoad(); // Llama al método onLoad de la clase padre

    animation = await game.loadSpriteAnimation( // Carga la animación de la explosión
      'explosion.png', // Archivo de imagen que contiene los frames de la animación
      SpriteAnimationData.sequenced( // Configura cómo se anima la imagen
        amount: 6, // La animación tiene 6 frames
        stepTime: 0.1, // Cada frame dura 0.1 segundos
        textureSize: Vector2.all(32), // Tamaño de cada frame (32x32 píxeles)
        loop: false, // La animación no se repite (se ejecuta solo una vez)
      ),
    );
  }
} 