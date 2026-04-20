[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/HLeZUs-R)
# Space Shooter - Flame Tutorial

## 4b1. GameWidget y Game Loop

### GameWidget

El **GameWidget** se encuentra en la **línea 11** del archivo `lib/main.dart`:

```dart
void main() {
  runApp(GameWidget(game: SpaceShooterGame()));
}
```

`GameWidget` es el widget de Flutter que actúa como puente entre Flutter y Flame. Se encarga de:
- Integrar el juego Flame dentro del árbol de widgets de Flutter.
- Renderizar el canvas del juego.
- Redirigir los eventos de input (taps, drags, teclado) al juego.
- Gestionar el ciclo de vida (pause/resume) del juego.

Recibe como parámetro una instancia de `SpaceShooterGame`, que es la clase principal del juego.

### Game Loop

El **Game Loop no está definido explícitamente** en el código. Flame lo gestiona internamente a través de la clase `FlameGame` (de la cual `SpaceShooterGame` hereda en la **línea 14**):

```dart
class SpaceShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection {
```

`FlameGame` extiende `Game`, que implementa el game loop automáticamente. Este loop interno ejecuta en cada frame:

1. **`update(double dt)`** → Actualiza la lógica de todos los componentes (movimiento, colisiones, spawns). El parámetro `dt` es el delta time entre frames. En este proyecto se usa en:
   - `Bullet.update(dt)` (línea 139): mueve las balas hacia arriba (`position.y += dt * -500`).
   - `Enemy.update(dt)` (línea 174): mueve los enemigos hacia abajo (`position.y += dt * 250`).

2. **`render(Canvas canvas)`** → Dibuja todos los componentes en pantalla (parallax, player, balas, enemigos, explosiones).

El game loop se inicia automáticamente cuando `GameWidget` se monta en el árbol de widgets de Flutter. No es necesario crearlo ni configurarlo manualmente.

---

## 4b2. Render y Update del GameWidget

El `GameWidget` delega las funciones de **render** y **update** al objeto `FlameGame` que recibe como parámetro. En cada frame del game loop, Flame ejecuta automáticamente estos dos métodos sobre todos los componentes del árbol.

### Update

El método **`update(double dt)`** se encarga de actualizar la **lógica del juego** en cada frame. El parámetro `dt` (delta time) indica los segundos transcurridos desde el último frame, lo que permite que el movimiento sea independiente de la velocidad de refresco.

En este proyecto, `update` se sobrescribe explícitamente en dos componentes:

**Bullet** (línea 139 de `lib/main.dart`):
```dart
@override
void update(double dt) {
  super.update(dt);
  position.y += dt * -500;  // Mueve la bala hacia arriba a 500 px/s
  if (position.y < -height) {
    removeFromParent();      // Elimina la bala si sale de la pantalla
  }
}
```

**Enemy** (línea 174 de `lib/main.dart`):
```dart
@override
void update(double dt) {
  super.update(dt);
  position.y += dt * 250;   // Mueve el enemigo hacia abajo a 250 px/s
  if (position.y > game.size.y) {
    removeFromParent();      // Elimina el enemigo si sale de la pantalla
  }
}
```

Además, Flame ejecuta internamente `update` en otros componentes sin necesidad de sobrescribirlo:
- **`SpawnComponent`**: controla el temporizador que genera enemigos cada 1 segundo y balas cada 0.2 segundos.
- **`ParallaxComponent`**: actualiza la posición de las capas de estrellas para crear el efecto de desplazamiento.
- **`SpriteAnimationComponent`**: avanza los frames de las animaciones (player, bullet, enemy, explosion).
- **`HasCollisionDetection`** (mixin del game): comprueba las colisiones entre hitboxes en cada frame.

### Render

El método **`render(Canvas canvas)`** se encarga de **dibujar** todos los componentes visibles en pantalla. En este proyecto **no se sobrescribe en ningún componente**, porque `SpriteAnimationComponent` ya implementa el renderizado automáticamente.

En cada frame, Flame recorre el árbol de componentes y renderiza en este orden (de atrás hacia adelante):

1. **`ParallaxComponent`** → Dibuja las 3 capas de estrellas (`stars_0.png`, `stars_1.png`, `stars_2.png`) como fondo.
2. **`Player`** → Dibuja la animación de la nave del jugador (4 frames de `player.png`, 32×48px cada uno).
3. **`Bullet`** (múltiples) → Dibuja la animación de cada bala activa (4 frames de `bullet.png`, 8×16px).
4. **`Enemy`** (múltiples) → Dibuja la animación de cada enemigo activo (4 frames de `enemy.png`, 16×16px).
5. **`Explosion`** (temporales) → Dibuja la animación de explosión (6 frames de `explosion.png`, 32×32px) y se auto-elimina al terminar (`removeOnFinish: true`).

El `GameWidget` toma el resultado de `render` y lo pinta en su `Canvas` de Flutter, integrándolo visualmente en la app.

### Resumen del ciclo por frame

| Fase | Qué hace | Ejemplo en el código |
|------|----------|---------------------|
| **Update** | Actualiza posiciones, timers, colisiones y lógica | `Bullet`: sube 500px/s · `Enemy`: baja 250px/s · `SpawnComponent`: genera enemigos/balas |
| **Render** | Dibuja sprites y animaciones en pantalla | Parallax → Player → Bullets → Enemies → Explosions |

---

## 4b3. Components: Visibility, Position, Size, Scale, Anchor

Tots els components del joc (`Player`, `Bullet`, `Enemy`, `Explosion`) hereten de `SpriteAnimationComponent`, que a la vegada hereta de `PositionComponent`. Aquesta classe base proporciona les propietats següents:

### Position

La **posició** (`position`) és un `Vector2(x, y)` que indica on es troba el component dins del món del joc.

**On s'utilitza al codi:**

| Component | Línia | Ús |
|-----------|-------|-----|
| **Player** | 88 | `position = game.size / 2;` → El col·loca al centre de la pantalla en carregar. |
| **Player** | 106 | `position.add(delta);` → Mou el jugador segons el gest d'arrossegar. |
| **Bullet** | 119 | `super.position` → Rep la posició inicial com a paràmetre del constructor (posició del jugador - meitat d'alçada). |
| **Bullet** | 143 | `position.y += dt * -500;` → Mou la bala cap amunt a 500 px/s. |
| **Enemy** | 157 | `super.position` → Rep la posició inicial del `SpawnComponent` (zona superior de la pantalla). |
| **Enemy** | 178 | `position.y += dt * 250;` → Mou l'enemic cap avall a 250 px/s. |
| **Explosion** | 196 | `super.position` → Rep la posició de l'enemic destruït. |

### Size

La **mida** (`size`) és un `Vector2(amplada, alçada)` que defineix les dimensions visuals del component en píxels lògics.

**On s'utilitza al codi:**

| Component | Línia | Valor | Descripció |
|-----------|-------|-------|------------|
| **Player** | 69 | `Vector2(100, 150)` | Nau de 100×150 px |
| **Bullet** | 120 | `Vector2(25, 50)` | Bala de 25×50 px |
| **Enemy** | 159 | `Vector2.all(50)` | Enemic quadrat de 50×50 px |
| **Explosion** | 198 | `Vector2.all(150)` | Explosió de 150×150 px |

Cal notar que el `size` és independent del `textureSize` de l'animació. Per exemple, el `Player` té textures de 32×48 px però es renderitza a 100×150 px (Flame l'escala automàticament).

### Scale

La propietat **`scale`** (`Vector2`) permet escalar un component multiplicativament. Un `scale` de `Vector2(2, 2)` faria el component el doble de gran visualment.

**En aquest projecte, `scale` no s'utilitza explícitament.** Tots els components usen el valor per defecte `Vector2(1, 1)` (escala 1:1). L'ajust de mida visual es fa directament amb `size`, que ja redimensiona la textura original al renderitzar.

### Anchor

> **Nota:** "cnativr" de l'enunciat s'interpreta com **anchor** (possiblement un error tipogràfic).

L'**`anchor`** defineix el **punt de referència** del component. Indica quin punt del sprite correspon a la seva `position`. Per defecte és `Anchor.topLeft`, però en aquest projecte **tots els components usen `Anchor.center`**:

| Component | Línia | Valor |
|-----------|-------|-------|
| **Player** | 70 | `anchor: Anchor.center` |
| **Bullet** | 121 | `anchor: Anchor.center` |
| **Enemy** | 160 | `anchor: Anchor.center` |
| **Explosion** | 199 | `anchor: Anchor.center` |

Això significa que quan es defineix `position`, el **centre** del sprite es col·loca en aquell punt (no la cantonada superior esquerra). És especialment important per a:
- **Rotacions**: el component rota sobre el seu centre.
- **Colisions**: les hitboxes es calculen respecte al centre.
- **Explosions**: apareixen exactament on era l'enemic (`position` de l'enemic = centre de l'explosió).

### Visibility

La propietat **`isVisible`** (booleana) controla si un component es renderitza o no. Quan és `false`, el mètode `render` no es crida, però `update` continua executant-se (la lògica segueix activa).

**En aquest projecte, `isVisible` no s'utilitza explícitament.** Tots els components són visibles per defecte (`isVisible = true`). Per "amagar" elements, el codi utilitza una altra estratègia: **`removeFromParent()`**, que elimina completament el component del joc (tant render com update). Exemples:
- `Bullet`: s'elimina quan surt de pantalla (línia 145).
- `Enemy`: s'elimina quan surt de pantalla (línia 180) o quan rep una bala (línia 189).
- `Explosion`: s'elimina automàticament en acabar l'animació (`removeOnFinish: true`, línia 199).

### Resum visual

| Propietat | Usada explícitament? | Valor per defecte | On es veu al codi |
|-----------|---------------------|-------------------|-------------------|
| **position** | ✅ Sí | `Vector2(0, 0)` | Moviment de Player, Bullet, Enemy; posició inicial d'Explosion |
| **size** | ✅ Sí | `Vector2(0, 0)` | Constructor de cada component (Player 100×150, Bullet 25×50, etc.) |
| **scale** | ❌ No | `Vector2(1, 1)` | Escala 1:1 per defecte; la mida visual es controla amb `size` |
| **anchor** | ✅ Sí | `Anchor.topLeft` | `Anchor.center` en tots els components |
| **visibility** | ❌ No | `true` | Sempre visibles; s'usa `removeFromParent()` en lloc d'amagar |

---

## 4b4. SpriteComponent, Animation i AnimationGroup

### SpriteComponent

`SpriteComponent` és una classe de Flame que mostra una **imatge estàtica** (un sol frame) en pantalla. Hereta de `PositionComponent` i afegeix la capacitat de renderitzar un `Sprite`.

**En aquest projecte, `SpriteComponent` no s'utilitza directament.** Tots els components visuals utilitzen la seva variant animada: `SpriteAnimationComponent`. Això és perquè tots els elements del joc (nau, bales, enemics, explosions) tenen animacions amb múltiples frames en comptes d'imatges estàtiques.

La jerarquia de classes és:
```
Component → PositionComponent → SpriteComponent    (imatge estàtica)
                               → SpriteAnimationComponent (imatge animada) ← USAT
```

### Animation (SpriteAnimationComponent)

`SpriteAnimationComponent` és la classe que s'utilitza en **tots els components visuals** del joc. Hereta de `PositionComponent` i mostra una **seqüència de frames** (sprite sheet) que es reprodueix automàticament.

**On s'aplica al codi:**

#### Player (línia 62)
```dart
class Player extends SpriteAnimationComponent
```
Animació carregada a la línia 76:
```dart
animation = await game.loadSpriteAnimation(
  'player.png',
  SpriteAnimationData.sequenced(
    amount: 4,        // 4 frames d'animació
    stepTime: 0.2,    // canvia de frame cada 0.2s
    textureSize: Vector2(32, 48),  // cada frame és 32×48 px
  ),
);
```
→ La nau del jugador té una animació cíclica de 4 frames (propulsors encesos).

#### Bullet (línia 119)
```dart
class Bullet extends SpriteAnimationComponent
```
Animació carregada a la línia 132:
```dart
animation = await game.loadSpriteAnimation(
  'bullet.png',
  SpriteAnimationData.sequenced(
    amount: 4,        // 4 frames d'animació
    stepTime: 0.2,    // canvia de frame cada 0.2s
    textureSize: Vector2(8, 16),   // cada frame és 8×16 px
  ),
);
```
→ Les bales tenen una animació cíclica de 4 frames (efecte de brillantor/pulsació).

#### Enemy (línia 160)
```dart
class Enemy extends SpriteAnimationComponent
```
Animació carregada a la línia 175:
```dart
animation = await game.loadSpriteAnimation(
  'enemy.png',
  SpriteAnimationData.sequenced(
    amount: 4,        // 4 frames d'animació
    stepTime: 0.2,    // canvia de frame cada 0.2s
    textureSize: Vector2.all(16),  // cada frame és 16×16 px
  ),
);
```
→ Els enemics tenen una animació cíclica de 4 frames.

#### Explosion (línia 213)
```dart
class Explosion extends SpriteAnimationComponent
```
Animació carregada a la línia 227:
```dart
animation = await game.loadSpriteAnimation(
  'explosion.png',
  SpriteAnimationData.sequenced(
    amount: 6,        // 6 frames d'animació
    stepTime: 0.1,    // canvia de frame cada 0.1s (més ràpid)
    textureSize: Vector2.all(32),  // cada frame és 32×32 px
    loop: false,      // NO es repeteix (es reprodueix un sol cop)
  ),
);
```
→ L'explosió té 6 frames que es reprodueixen un sol cop (`loop: false`) i el component s'elimina automàticament en acabar (`removeOnFinish: true`).

### AnimationGroup (SpriteAnimationGroupComponent)

`SpriteAnimationGroupComponent` permet definir **múltiples animacions** associades a **estats** (per exemple: `idle`, `running`, `jumping`) i canviar entre elles dinàmicament amb `current = MyState.running`.

**En aquest projecte, `AnimationGroup` no s'utilitza.** Cada component té una sola animació, per tant, n'hi ha prou amb `SpriteAnimationComponent`. Es podria fer servir, per exemple, si el jugador tingués animacions diferents per moure's a l'esquerra, a la dreta, o estar quiet:

```dart
// Exemple hipotètic (NO present al codi):
enum PlayerState { idle, movingLeft, movingRight }

class Player extends SpriteAnimationGroupComponent<PlayerState> {
  @override
  Future<void> onLoad() async {
    animations = {
      PlayerState.idle: idleAnimation,
      PlayerState.movingLeft: leftAnimation,
      PlayerState.movingRight: rightAnimation,
    };
    current = PlayerState.idle;
  }
}
```

### Resum

| Concepte | Classe Flame | Usat al projecte? | On |
|----------|-------------|-------------------|-----|
| **SpriteComponent** | `SpriteComponent` | ❌ No | No s'usa; tots els elements són animats |
| **Animation** | `SpriteAnimationComponent` | ✅ Sí | Player (4 frames), Bullet (4 frames), Enemy (4 frames), Explosion (6 frames) |
| **AnimationGroup** | `SpriteAnimationGroupComponent` | ❌ No | No s'usa; cada component té una sola animació, no cal gestionar estats |

---

## 4b5. Generació d'elements (Spawning)

Sí, el joc utilitza **generació automàtica d'elements** en dos llocs, ambdós mitjançant la classe `SpawnComponent` de Flame. Aquesta classe funciona com una "fàbrica" amb un temporitzador que crea instàncies de components de forma periòdica.

### 1. Generació d'enemics (línia 37 de `lib/main.dart`)

Dins de `SpaceShooterGame.onLoad()`:

```dart
add(
  SpawnComponent(
    factory: (index) {
      return Enemy();
    },
    period: 1,
    area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
  ),
);
```

| Paràmetre | Valor | Descripció |
|-----------|-------|------------|
| `factory` | `(index) => Enemy()` | Funció que crea un nou enemic cada vegada |
| `period` | `1` | Genera un enemic **cada 1 segon** |
| `area` | `Rectangle.fromLTWH(0, 0, size.x, -enemySize)` | Zona de spawn: tota l'amplada de la pantalla, just **per sobre** del límit superior (y negatiu) |

L'enemic apareix en una posició X aleatòria dins de l'àrea definida i cau cap avall a 250 px/s gràcies al seu `update()`.

### 2. Generació de bales (línia 90 de `lib/main.dart`)

Dins de `Player.onLoad()`:

```dart
_bulletSpawner = SpawnComponent(
  period: 0.2,
  selfPositioning: true,
  factory: (index) {
    return Bullet(
      position: position + Vector2(0, -height / 2),
    );
  },
  autoStart: false,
);
game.add(_bulletSpawner);
```

| Paràmetre | Valor | Descripció |
|-----------|-------|------------|
| `factory` | `(index) => Bullet(position: ...)` | Crea una bala a la posició actual del jugador (part superior de la nau) |
| `period` | `0.2` | Genera una bala **cada 0.2 segons** (5 bales per segon) |
| `selfPositioning` | `true` | La bala es posiciona ella mateixa (no utilitza l'àrea del spawner) |
| `autoStart` | `false` | **No comença automàticament**; s'activa manualment amb `startShooting()` i es para amb `stopShooting()` |

El control d'inici/parada es fa amb:
- `player.startShooting()` → `_bulletSpawner.timer.start()` (quan l'usuari toca la pantalla, `onPanStart`)
- `player.stopShooting()` → `_bulletSpawner.timer.stop()` (quan l'usuari deixa de tocar, `onPanEnd`)

### 3. Generació d'explosions (línia 191 de `lib/main.dart`)

A diferència dels dos anteriors, les explosions **no usen `SpawnComponent`** sinó que es creen manualment dins del callback de col·lisió de l'enemic:

```dart
void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
  super.onCollisionStart(intersectionPoints, other);
  if (other is Bullet) {
    removeFromParent();
    other.removeFromParent();
    game.add(Explosion(position: position));  // ← generació manual
  }
}
```

Es crea una `Explosion` a la posició exacta de l'enemic destruït. No és periòdica, sinó **per event** (cada cop que una bala impacta un enemic).

### Resum de generació d'elements

| Element | Mètode | Freqüència | Activació |
|---------|--------|-----------|-----------|
| **Enemy** | `SpawnComponent` | Cada 1 segon | Automàtica (al carregar el joc) |
| **Bullet** | `SpawnComponent` | Cada 0.2 segons | Manual (tocar pantalla = disparar) |
| **Explosion** | `game.add()` manual | Per event (col·lisió bala-enemic) | Automàtica (al detectar col·lisió) |

---

## 4b6. Shape, Circle i Arithmetic

### Shape (Formes geomètriques - Hitboxes)

El joc fa servir **formes geomètriques** com a àrees de col·lisió (hitboxes). Flame ofereix diversos tipus: `RectangleHitbox`, `CircleHitbox` i `PolygonHitbox`. En aquest projecte s'utilitza exclusivament **`RectangleHitbox`** (forma rectangular).

**On s'aplica al codi:**

#### Bullet - Hitbox passiva (línia 142 de `lib/main.dart`)
```dart
add(
  RectangleHitbox(
    collisionType: CollisionType.passive,
  ),
);
```
- Crea un rectangle de col·lisió que cobreix tota la mida de la bala (25×50 px).
- `CollisionType.passive`: la bala **no inicia** deteccions de col·lisió, però **pot ser detectada** per altres objectes actius. Això optimitza el rendiment (les bales no es comproven entre elles).

#### Enemy - Hitbox activa (línia 184 de `lib/main.dart`)
```dart
add(RectangleHitbox());
```
- Crea un rectangle de col·lisió que cobreix tota la mida de l'enemic (50×50 px).
- `CollisionType.active` (per defecte): l'enemic **busca activament** col·lisions amb altres hitboxes. Quan detecta una bala (passiva), executa `onCollisionStart`.

#### Rectangle com a àrea de spawn (línia 41 de `lib/main.dart`)
```dart
area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
```
- No és una hitbox, sinó una **forma geomètrica** (`Rectangle`) que defineix l'àrea on apareixen els enemics.
- Cobreix tota l'amplada de la pantalla (`size.x`) i una franja per sobre del límit superior (y negatiu).

#### Sistema de col·lisions

El sistema es configura amb el mixin `HasCollisionDetection` (línia 15):
```dart
class SpaceShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection {
```
I el callback `CollisionCallbacks` a `Enemy` (línia 161):
```dart
class Enemy extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {
```
Que permet reaccionar a les col·lisions amb `onCollisionStart` (línia 199).

### Circle

**`Circle` / `CircleHitbox` no s'utilitza en aquest projecte.** Totes les hitboxes són rectangulars (`RectangleHitbox`). Es podria fer servir, per exemple, per donar a les explosions una àrea de dany circular:

```dart
// Exemple hipotètic (NO present al codi):
add(CircleHitbox(radius: 75));  // Hitbox circular de radi 75 px
```

### Arithmetic (Operacions aritmètiques amb vectors)

El joc fa un ús extensiu d'**operacions aritmètiques amb `Vector2`** per calcular posicions, velocitats i desplaçaments. `Vector2` suporta suma, resta, multiplicació, divisió i operacions component a component.

**On s'aplica al codi:**

| Línia | Codi | Operació | Descripció |
|-------|------|----------|------------|
| 85 | `position = game.size / 2` | **Divisió** | Divideix el vector mida de pantalla entre 2 per obtenir el centre |
| 92-96 | `position + Vector2(0, -height / 2)` | **Suma de vectors** + **Divisió** | Calcula la posició de spawn de la bala (jugador + desplaçament cap amunt) |
| 107 | `position.add(delta)` | **Suma** (in-place) | Suma el vector de moviment del dit a la posició del jugador |
| 152 | `position.y += dt * -500` | **Multiplicació** escalar | Calcula el desplaçament de la bala: `dt` × velocitat (-500 px/s) |
| 191 | `position.y += dt * 250` | **Multiplicació** escalar | Calcula el desplaçament de l'enemic: `dt` × velocitat (250 px/s) |
| 26 | `baseVelocity: Vector2(0, -5)` | **Vector de velocitat** | Defineix la velocitat base del parallax |
| 28 | `velocityMultiplierDelta: Vector2(0, 5)` | **Vector multiplicador** | Cada capa es mou 5 px/s més ràpid que l'anterior |

#### Patró comú: moviment basat en dt

La fórmula `position += dt * velocitat` és l'operació aritmètica fonamental del joc. Garanteix que el moviment sigui **independent del framerate**:
- A 60 FPS: `dt ≈ 0.0167s` → bala es mou `0.0167 × 500 = 8.33 px` per frame
- A 30 FPS: `dt ≈ 0.0333s` → bala es mou `0.0333 × 500 = 16.67 px` per frame
- En ambdós casos: **500 px/s** de velocitat real

### Resum

| Concepte | Usat al projecte? | On |
|----------|-------------------|-----|
| **Shape (Rectangle)** | ✅ Sí | `RectangleHitbox` a Bullet (passiva) i Enemy (activa); `Rectangle` com àrea de spawn |
| **Circle** | ❌ No | No s'usa cap forma circular; totes les hitboxes són rectangulars |
| **Arithmetic** | ✅ Sí | Operacions amb `Vector2`: divisió (centrar player), suma (posició bala), multiplicació amb `dt` (moviment de bales i enemics) |

---

## 4b7. Comanda per desplegar a GitHub

Per desplegar (pujar) el projecte a GitHub des de la línia de comandes:

### 1. Afegir tots els canvis al staging
```bash
git add -A
```

### 2. Crear un commit
```bash
git commit -m "Missatge descriptiu del canvi"
```

### 3. Pujar al repositori remot (GitHub)
```bash
git push origin main
```

### Comanda completa en una línia
```bash
git add -A && git commit -m "Missatge del commit" && git push origin main
```

### Notes
- `origin` és l'alias del repositori remot a GitHub (en aquest projecte: `https://github.com/Bemen3M07/a7-489-ra4-ra5-videojocs-aluxni.git`).
- `main` és la branca principal. Si treballes en una altra branca, substitueix `main` pel nom de la branca.
- Si és el primer push d'una branca nova, cal usar: `git push -u origin nom-branca`.
- Per verificar el remote configurat: `git remote -v`.

---

## 4b8. loadingBuilder, backgroundBuilder i overlayBuilderMap

Aquests tres paràmetres són propietats opcionals del **`GameWidget`** que permeten integrar widgets de Flutter amb el joc Flame. **Originalment no s'utilitzaven** al codi; s'han afegit a `lib/main.dart` (línia 11) per demostrar-ne l'ús.

### loadingBuilder

Mostra un **widget de Flutter mentre el joc està carregant** (és a dir, mentre s'executa `onLoad()`). Un cop el joc ha acabat de carregar animacions, parallax, etc., aquest widget desapareix automàticament.

```dart
loadingBuilder: (context) => const Center(
  child: CircularProgressIndicator(),
),
```

- Mostra un indicador de càrrega circular centrat a la pantalla.
- És útil perquè `onLoad()` del joc és asíncron: carrega 7 imatges (player, bullet, enemy, explosion, 3× stars), cosa que pot trigar uns instants.
- Sense `loadingBuilder`, la pantalla queda negra fins que acaba la càrrega.

### backgroundBuilder

Dibuixa un **widget de Flutter darrere del joc** (per sota del canvas de Flame). Es renderitza cada frame.

```dart
backgroundBuilder: (context) => Container(
  color: Colors.black,
),
```

- Pinta un fons negre sòlid darrere del canvas del joc.
- Evita que es vegi el color per defecte de Flutter (blanc/gris) si el canvas de Flame no cobreix tota la pantalla o durant les transicions.
- Es podria utilitzar per posar un gradient, una imatge decorativa, o qualsevol widget de Flutter com a fons.

### overlayBuilderMap

Defineix un **mapa d'overlays** (capes d'interfície d'usuari Flutter) que es poden mostrar o amagar dinàmicament durant el joc. Cada overlay té un nom (clau `String`) i un builder que retorna un widget.

```dart
overlayBuilderMap: {
  'PauseMenu': (BuildContext context, SpaceShooterGame game) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.black54,
        child: const Text(
          'PAUSA',
          style: TextStyle(fontSize: 40, color: Colors.white),
        ),
      ),
    );
  },
},
```

- Defineix un overlay anomenat `'PauseMenu'` que mostra el text "PAUSA" centrat amb fons semitransparent.
- Els overlays es controlen des del codi del joc amb:
  - `game.overlays.add('PauseMenu')` → Mostra l'overlay.
  - `game.overlays.remove('PauseMenu')` → Amaga l'overlay.
- Es rendereritzen **per sobre** del canvas del joc (són widgets Flutter normals).
- Casos d'ús típics: menú de pausa, pantalla de Game Over, marcador de puntuació, botons de UI.

### Jerarquia de capes

Les tres propietats defineixen capes que es dibuixen en aquest ordre (de baix a dalt):

```
┌─────────────────────────────┐
│  overlayBuilderMap (UI)     │  ← Capa 3: Overlays Flutter (PauseMenu, etc.)
├─────────────────────────────┤
│  GameWidget / FlameGame     │  ← Capa 2: Canvas del joc (parallax, player, enemies...)
├─────────────────────────────┤
│  backgroundBuilder          │  ← Capa 1: Fons Flutter (color negre)
├─────────────────────────────┤
│  loadingBuilder             │  ← Temporal: Només visible durant onLoad()
└─────────────────────────────┘
```

### Resum

| Propietat | Funció | Usat al projecte? | Línia |
|-----------|--------|-------------------|-------|
| **loadingBuilder** | Widget mostrat mentre carrega el joc | ✅ Sí (afegit) | 13-15 |
| **backgroundBuilder** | Widget dibuixat darrere del canvas del joc | ✅ Sí (afegit) | 17-19 |
| **overlayBuilderMap** | Mapa d'overlays Flutter mostrables/ocultables | ✅ Sí (afegit) | 21-32 |

Aquest document s'ha fet amb l'ajuda de Copilot

## 1) Prerequisits

- Flutter SDK instal·lat i disponible al PATH
- Comprova la instal·lació de Flutter:

```bash
flutter doctor
```

## 2) Comença des d’un estat net del repositori

Si vols descartar els canvis locals i tornar a l’últim estat confirmat al repositori:

```bash
git reset --hard
git clean -fd
```

## 3) Genera només l’estructura de plataforma Web + Android

Des de l’arrel del projecte:

```bash
flutter create --platforms=web,android .
```

Què fa aquesta comanda:

- Regenera els fitxers d’esquelet de Flutter que faltin
- Crea/actualitza les carpetes de plataforma `web/` i `android/`
- Manté el codi Dart existent de l’app sempre que sigui possible

Opcions disponibles per `--platforms`:

- `android`
- `ios`
- `web`
- `windows`
- `macos`
- `linux`

Exemple amb totes les plataformes:

```bash
flutter create --platforms=android,ios,web,windows,macos,linux .
```

Pots combinar només les que necessitis, separades per comes.

## 4) Comandes de compilació

Compila només l’app web:

```bash
flutter build web
```

Compila l’APK d’Android:

```bash
flutter build apk
```

Android App Bundle opcional (Play Store):

```bash
flutter build appbundle
```

## 5) Comandes d’execució (segons dispositiu)

Fes `flutter run -d <dispositiu>` per executar l’aplicació en un dispositiu concret.

Opcionalment, pots afegir `&` al final de la comanda per executar-la en segon pla.

- `-d` és el mateix que `--device-id`.
- `&` executa la comanda en segon pla (el `run` bloqueja la terminal si no l’afegeixes).
- Serveix per indicar a Flutter en quin dispositiu/target vols executar l’app.
- Exemples: `chrome`, `android`, `ios`, `windows`, `macos`, `linux` (segons les plataformes que tinguis disponibles al teu entorn).

### Chrome

Executa al navegador Chrome:

```bash
flutter run -d chrome
```

L’opció `chrome` es pot executar directament per desenvolupament i proves.
Si vols desplegar la versió web en un servidor, has de generar el build amb `flutter build web` i publicar el contingut de `build/web`.

### Android

Arrenca un emulador Android per línia de comandes (CLI):

```bash
flutter emulators # Per veure tots els emuladors disponibles
flutter emulators --launch <emulator_id>
flutter devices # Per veure tots els dispositius iniciats
flutter run -d <device_id>
```

Exemple:

```bash
flutter emulators --launch Pixel_6_API_34
flutter run -d emulator-5554
```

## 6) Comportament esperat de Git

- Hauries de veure fitxers de codi/configuració dins de `web/` i `android/` versionats a Git.
- No hauries de pujar sortides de compilació generades dins de `build/`.
- No hauries de pujar fitxers locals d’IDE (`.idea/`, `.vscode/`, `*.iml`).

Si cal, mantén aquestes regles a `.gitignore`:

```gitignore
build/
.idea/
.vscode/
*.iml
```

Nota:

- No ignoris tota la carpeta `web/` si web és una plataforma suportada.
- No ignoris tota la carpeta `android/` si Android és una plataforma suportada.

## 7) Checklist ràpid de verificació

Després de regenerar, comprova:

```bash
flutter analyze
flutter test
flutter build web
flutter build apk
```

Si totes les comandes passen, el teu flux de plantilla neta és correcte.
