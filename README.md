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
